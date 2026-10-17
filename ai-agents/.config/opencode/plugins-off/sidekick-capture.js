// sidekick-capture — plugin de opencode para sidekick (fase 2, RF-6).
// Caché rodante de archivos del proyecto + boundary de prompts → JSONL
// por proyecto en ~/.local/share/sidekick/<sha1(cwd)>.jsonl
// Ver design.md §4.1 y research.md §3.1 (T-20).

import { appendFileSync, existsSync, mkdirSync, readFileSync, readdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { homedir } from "node:os";
import { dirname, isAbsolute, join, relative, resolve } from "node:path";

const MAX_FILE_BYTES = 8 * 1024 * 1024; // skip > 8 MiB
const BIN_SNIFF = 8 * 1024; // NUL en los primeros 8 KiB → binario
const MAX_SESSION_BYTES = 64 * 1024 * 1024; // skip total > 64 MiB por sesión
const WATCHER_DEBOUNCE_MS = 300;
const AUTO_OPEN_REDEBOUNCE_MS = 15_000; // una invocación por prompt y no más

// RF-19 de la misma config de sidekick (herdr/plugins/config/sidekick).
function autoOpenFlag() {
  try {
    const xdg = process.env.XDG_CONFIG_HOME || join(homedir(), ".config");
    const text = readFileSync(
      join(xdg, "herdr", "plugins", "config", "sidekick", "config.toml"),
      "utf8",
    );
    return /auto_open\s*=\s*true/.test(text);
  } catch {
    return false; // sin config: nunca auto-open
  }
}

import { spawn } from "node:child_process";

function triggerAutoOpen() {
  try {
    // el launcher de sidekick reutiliza/crea el pane y lo pone en review
    spawn("herdr", ["plugin", "action", "invoke", "sidekick.changes"], {
      detached: true,
      stdio: "ignore",
    }).unref();
  } catch {
    // nunca romper opencode por sidekick
  }
}

function dataDir() {
  return process.env.XDG_DATA_HOME || join(homedir(), ".local", "share");
}

function isBinary(buf) {
  const n = Math.min(buf.length, BIN_SNIFF);
  for (let i = 0; i < n; i++) {
    if (buf[i] === 0) return true;
  }
  return false;
}

// null = no legible (borrado); undefined = skip (binario/grande/error).
function readContent(abs) {
  try {
    const buf = readFileSync(abs);
    if (buf.length > MAX_FILE_BYTES) return undefined; // skip por tamaño
    if (isBinary(buf)) return undefined;
    return buf.toString("utf8");
  } catch (e) {
    if (e?.code === "ENOENT") return null; // borrado
    return undefined; // otro error: skip
  }
}

const SKIP_DIRS = new Set([
  ".git", "node_modules", "target", "dist", "build", ".next",
  "__pycache__", ".venv", "venv", ".cache", ".sidekick",
]);

// Escaneo base del proyecto: da `before` real a los archivos que el agente
// edite aunque sidekick-capture no los haya visto nunca (T-27).
function scanProject(dir, cache) {
  let total = 0;
  let stack = [dir];
  while (stack.length && total < MAX_SESSION_BYTES) {
    const cur = stack.pop();
    let entries;
    try {
      entries = readdirSync(cur, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const e of entries) {
      const abs = join(cur, e.name);
      if (e.isDirectory()) {
        if (!SKIP_DIRS.has(e.name)) stack.push(abs);
        continue;
      }
      if (!e.isFile() || total > MAX_SESSION_BYTES) continue;
      const c = readContent(abs);
      if (c === null || c === undefined) continue; // binario/grande/borrado
      total += c.length;
      cache.set(abs, c);
    }
  }
}

export const SidekickCapturePlugin = async (ctx) => {
  const dir = ctx?.directory ? resolve(ctx.directory) : null;
  if (!dir) return {};

  const hash = createHash("sha1").update(dir).digest("hex");
  const storeDir = join(dataDir(), "sidekick");
  const storePath = join(storeDir, `${hash}.jsonl`);
  let headerWritten = false;
  let sessionBytes = 0;

  // caché rodante: ruta absoluta → contenido (string)
  const cache = new Map();
  scanProject(dir, cache); // baseline: archivos preexistentes
  const pendingWatcher = new Map();
  let currentSessionID;
  let lastAutoOpen = 0;

  function record(obj) {
    try {
      if (!headerWritten && !existsSync(storePath)) {
        mkdirSync(storeDir, { recursive: true });
        appendFileSync(
          storePath,
          JSON.stringify({ kind: "project", dir, hash, ts: Date.now() }) + "\n",
        );
      }
      headerWritten = true;
      if (obj.kind === "edit" && obj.bytes) {
        sessionBytes += obj.bytes;
        if (sessionBytes > MAX_SESSION_BYTES) return; // cap de sesión
      }
      appendFileSync(storePath, JSON.stringify(obj) + "\n");
    } catch {
      // nunca romper opencode por sidekick
    }
  }

  function rel(abs) {
    const r = relative(dir, abs);
    return r && !r.startsWith("..") && !isAbsolute(r) ? r : abs;
  }

  function trackSession(sessionID) {
    if (typeof sessionID === "string" && sessionID) currentSessionID = sessionID;
  }

  function refreshCache(abs) {
    const c = readContent(abs);
    if (c === undefined) return; // ilegible: dejar el caché como esté
    if (c === null) cache.delete(abs);
    else cache.set(abs, c);
  }

  return {
    // boundary de prompt del usuario (RF-6); resetea el cap por sesión
    "chat.message": async (input) => {
      trackSession(input?.sessionID);
      sessionBytes = 0;
      record({
        kind: "prompt",
        sessionID: input?.sessionID,
        dir,
        ts: Date.now(),
      });
      // baseline por prompt: el `before` refleja el estado ANTES del prompt
      scanProject(dir, cache);
    },

    event: async ({ event }) => {
      const type = event?.type;
      const properties = event?.properties ?? {};
      trackSession(properties.sessionID);

      // cambio externo (o eco del agente): refresco diferido del caché.
      // Si llega file.edited antes del debounce, gana el edit y cancela esto.
      if (type === "file.watcher.updated") {
        const abs = properties.file && isAbsolute(properties.file)
          ? resolve(properties.file)
          : properties.file
            ? resolve(dir, properties.file)
            : null;
        if (!abs || !abs.startsWith(dir)) return;
        const prev = pendingWatcher.get(abs);
        if (prev) clearTimeout(prev);
        pendingWatcher.set(
          abs,
          setTimeout(() => {
            pendingWatcher.delete(abs);
            refreshCache(abs);
          }, WATCHER_DEBOUNCE_MS),
        );
        return;
      }

      // edición del agente (RF-6): before = caché, after = disco
      if (type === "file.edited") {
        const abs = properties.file && isAbsolute(properties.file)
          ? resolve(properties.file)
          : properties.file
            ? resolve(dir, properties.file)
            : null;
        if (!abs || !abs.startsWith(dir)) return;
        const pending = pendingWatcher.get(abs);
        if (pending) {
          clearTimeout(pending);
          pendingWatcher.delete(abs);
        }
        const before = cache.has(abs) ? cache.get(abs) : null;
        const after = readContent(abs);
        if (after === undefined) return; // binario/grande: skip silencioso
        record({
          kind: "edit",
          sessionID: currentSessionID ?? properties.sessionID,
          file: rel(abs),
          before: cache.has(abs) ? before : null, // nunca observado → alta
          after,
          ts: Date.now(),
          bytes: (after?.length ?? 0) + (before?.length ?? 0),
        });
        if (after === null) cache.delete(abs);
        else cache.set(abs, after);
        // RF-19: primer edit del prompt → abrir el review
        if (Date.now() - lastAutoOpen > AUTO_OPEN_REDEBOUNCE_MS && autoOpenFlag()) {
          lastAutoOpen = Date.now();
          triggerAutoOpen();
        }
        return;
      }
    },
  };
};
