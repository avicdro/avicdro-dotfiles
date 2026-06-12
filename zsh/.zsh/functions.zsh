# ── Funciones de shell ────────────────────────────────────────────────────────

# ── Antigravity (Windsurf/VSCode fork) — wrapper WSL ─────────────────────────
antig() {
    if [ -n "$WSL_DISTRO_NAME" ]; then
        antigravity --remote "wsl+${WSL_DISTRO_NAME}" $(pwd)
    else
        antigravity "$@"
    fi
}

# ── Yazi (file manager — wrapper para cambiar de directorio al salir) ─────────
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
