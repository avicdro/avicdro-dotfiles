# Dotfiles

Configuración personal para **Ubuntu / Debian**. Gestión con [GNU Stow](https://www.gnu.org/software/stow/) para mantener todo versionado y enlazado de forma limpia. Compatible con instalaciones nativas, VMs y WSL2.

## Instalación rápida

```bash
git clone https://github.com/avicdro/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
bash install.sh
```

El script es **idempotente** — puedes re-ejecutarlo sin romper nada.

## ¿Qué instala?

### Paquetes base (apt)

| Paquete | Descripción |
|---------|-------------|
| `git` | Control de versiones |
| `curl` / `wget` | Descargas HTTP |
| `zsh` | Shell moderno |
| `stow` | Gestor de symlinks para dotfiles |
| `build-essential` | Compilador C/C++ y herramientas de build |
| `unzip` | Descompresor ZIP |
| `jq` | Procesador JSON en línea de comandos |

### Shell y prompt

| Herramienta | Descripción |
|-------------|-------------|
| [Oh My Zsh](https://ohmyz.sh/) | Framework de configuración para Zsh |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Tema rápido y personalizable para Zsh |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Sugerencias basadas en historial |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Resaltado de sintaxis en la línea de comandos |
| [JetBrains Mono NF](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono) | Fuente Nerd Font con amplio soporte de iconos |

### Herramientas CLI modernas

| Herramienta | Lenguaje | Peso aprox. | Propósito | Repo |
|-------------|----------|-------------|-----------|------|
| [eza](https://github.com/eza-community/eza) | Rust | ~3 MB | Listado moderno archivos | [eza-community/eza](https://github.com/eza-community/eza) |
| [bat](https://github.com/sharkdp/bat) | Rust | ~6 MB | Visor sintaxis highlighting | [sharkdp/bat](https://github.com/sharkdp/bat) |
| [fd](https://github.com/sharkdp/fd) | Rust | ~4 MB | Búsqueda rápida archivos | [sharkdp/fd](https://github.com/sharkdp/fd) |
| [xh](https://github.com/ducaale/xh) | Rust | ~7 MB | Cliente HTTP moderno | [ducaale/xh](https://github.com/ducaale/xh) |
| [dust](https://github.com/bootandy/dust) | Rust | ~3 MB | Analizador uso disco | [bootandy/dust](https://github.com/bootandy/dust) |
| [delta](https://github.com/dandavison/delta) | Rust | ~7 MB | Pager visual para diffs Git | [dandavison/delta](https://github.com/dandavison/delta) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Rust | ~5 MB | Búsqueda recursiva código | [BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep) |
| [fzf](https://github.com/junegunn/fzf) | Go | ~3 MB | Fuzzy finder universal | [junegunn/fzf](https://github.com/junegunn/fzf) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Rust | ~1 MB | Navegación inteligente directorios | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) |
| [atuin](https://github.com/atuinsh/atuin) | Rust | ~20 MB | Historial shell avanzado | [atuinsh/atuin](https://github.com/atuinsh/atuin) |
| [lazygit](https://github.com/jesseduffield/lazygit) | Go | ~15 MB | Interfaz TUI Git | [jesseduffield/lazygit](https://github.com/jesseduffield/lazygit) |
| [yazi](https://github.com/sxyazi/yazi) | Rust | ~8 MB | File manager terminal | [sxyazi/yazi](https://github.com/sxyazi/yazi) |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | C | ~1 MB | Info sistema terminal | [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| [duf](https://github.com/muesli/duf) | Go | ~3 MB | Uso disco legible | [muesli/duf](https://github.com/muesli/duf) |
| [btop](https://github.com/aristocratos/btop) | C++ | ~2 MB | Monitor recursos sistema | [aristocratos/btop](https://github.com/aristocratos/btop) |
| [tldr](https://github.com/tldr-pages/tldr) | — | ~1 MB | Páginas ayuda simplificadas | [tldr-pages/tldr](https://github.com/tldr-pages/tldr) |
| [jq](https://github.com/jqlang/jq) | C | ~1 MB | Procesador JSON CLI | [jqlang/jq](https://github.com/jqlang/jq) |

### Gestores de runtime

| Herramienta | Propósito | Instalación | Repo |
|-------------|----------|-------------|------|
| [rustup](https://rustup.rs/) | Toolchain de Rust/Cargo | Script oficial | [rust-lang/rustup](https://github.com/rust-lang/rustup) |
| [fnm](https://github.com/Schniz/fnm) | Node.js version manager (reemplaza nvm) | Script oficial + LTS auto | [Schniz/fnm](https://github.com/Schniz/fnm) |
| [uv](https://docs.astral.sh/uv/) | Gestor de Python ultra-rápido (por Astral) | Script oficial | [astral-sh/uv](https://github.com/astral-sh/uv) |
| [opencode](https://opencode.ai/) | Agente de codificación IA en terminal | npm global | [anomalyco/opencode](https://github.com/anomalyco/opencode) |

> **fnm** soporta `.node-version` y `.nvmrc` automáticamente gracias al flag `--use-on-cd` configurado en `.zshrc`.

## Aliases configurados

Los aliases se definen en módulos dentro de `zsh/.zsh/` y complementan los que provee el plugin `git` de Oh My Zsh.

```bash
# Git (extras sobre OMZ)
gst-short → git status --short --branch
glg       → git log --graph --pretty (visual)
gundo     → git reset --soft HEAD~1
gamend    → git commit --amend --no-edit
gbranches → git branch -a --sort=-committerdate
gstash-all→ git stash push --include-untracked
gtcode    → commit con VS Code como editor
gtantig   → commit con Antigravity como editor

# eza (ls moderno)
ls      → eza --icons --group-directories-first
ll      → eza -la --icons --git --group-directories-first
tree    → eza --tree --icons --git --group-directories-first

# bat (cat moderno)
cat     → bat --paging=never

# rsync seguro
cpg     → rsync -ah --progress

# zoxide (cd inteligente)
cd      → z  (alias, aprende de tu uso)

# yazi (file manager)
y       → wrapper que cambia al directorio al salir
```

### Delta

**Delta** se usa **exclusivamente en lazygit** (no como pager global de Git). Esto mantiene la salida nativa de `git diff/log/show` en terminal, lo que es mejor para scripts y agentes IA que no manejan bien la salida ANSI de delta. Se configura en `lazygit/.config/lazygit/config.yml`.

## OpenCode — Asistente de Terminal Lite ⚡

Integración con [OpenCode](https://opencode.ai/) usando el modelo **GPT-5 Nano** (gratuito y ultra-rápido) para consultas de terminal sin salir de Zsh.

| Atajo | Qué hace | Ejemplo |
|-------|----------|---------|
| `?? <duda>` | Devuelve solo el comando limpio | `?? listar archivos pdf` |
| `explain <comando>` | Explicación breve + código | `explain tar -xzvf` |

> El bloque solo se carga si `opencode` está instalado. Modelo configurable vía `$OPENCODE_FAST_MODEL`.

> **Fastfetch** se ejecuta automáticamente al abrir la primera terminal de la sesión (usa un lock file en `/run/user/<uid>/fastfetch_session_lock`, que se recrea al iniciar una nueva sesión).

Su configuración queda versionada en `fastfetch/.config/fastfetch/config.jsonc` y se enlaza a `~/.config/fastfetch/config.jsonc` mediante GNU Stow durante la instalación.

También se versionan en paquetes separados de Stow las configuraciones base de `git`, `lazygit`, `yazi`, `atuin`, `btop`, `bat` y `~/.local/bin`.

## Verificar instalación

Ejecuta este one-liner para comprobar que todas las herramientas están disponibles:

```bash
for cmd in git zsh stow eza bat fd xh dust delta rg fzf zoxide atuin lazygit yazi fastfetch duf btop tldr jq rustc fnm node uv python3 opencode; do
  printf "%-12s" "$cmd"; command -v $cmd &>/dev/null && echo "✅ ($($cmd --version 2>&1 | head -1))" || echo "❌ no encontrado"
done
```

## Configuración de FZF

- **Backend**: usa `fd` en lugar de `find` (respeta `.gitignore`)
- **Ctrl+T**: previsualización con `bat` (sintaxis highlighting)
- **Alt+C**: navegación de directorios con `fd`

## Estructura del repositorio

```
dotfiles/
├── .stow-global-ignore   # Patrones que Stow ignora globalmente
├── install.sh             # Script de instalación principal
├── README.md
├── scripts/
│   └── audit-dotfiles.sh  # Auditoría de salud de los dotfiles
├── atuin/
│   └── .config/atuin/config.toml
├── bat/
│   └── .config/bat/config
├── bin/
│   └── .local/bin/.keep
├── btop/
│   └── .config/btop/btop.conf
├── fastfetch/
│   └── .config/fastfetch/config.jsonc
├── git/
│   ├── .gitattributes_global
│   ├── .gitconfig
│   └── .gitignore_global
├── lazygit/
│   └── .config/lazygit/config.yml   # Delta + tema Atom dark
├── yazi/
│   └── .config/yazi/yazi.toml
└── zsh/
    ├── .p10k.zsh
    ├── .zshrc              # Orquestador (carga módulos)
    └── .zsh/
        ├── aliases.zsh     # Aliases (git extras, eza, bat, etc.)
        ├── functions.zsh   # Funciones (antig, yazi wrapper)
        └── tools.zsh       # Herramientas CLI (fnm, zoxide, fzf, atuin, uv, opencode)
```

## Git — Perfiles condicionales

La configuración global de Git ahora se versiona en `git/.gitconfig` y mantiene **dos identidades Git** separadas según ruta:

| Ruta | Identidad |
|------|-----------|
| `~/code/personal/` | Se solicita durante la instalación (nombre y email) |
| `~/code/trabajo/` | Se solicita durante la instalación (nombre y email de empresa) |

Si ya existe `~/.gitconfig-trabajo`, el script lo detecta y no vuelve a preguntar. Para modificarlo, edita ese archivo directamente.

Antes de enlazar con Stow, `install.sh` hace backup automático de archivos locales existentes en `~/.dotfiles-backups/` con sufijo `.pre-stow.bak.<timestamp>`.

## Re-ejecutar

El script verifica cada herramienta con `command -v` antes de instalar. Si algo ya existe, lo omite. Es seguro ejecutar múltiples veces:

```bash
bash ~/dotfiles/install.sh
```

## Auditoria rapida

Para revisar sintaxis, simulacion de Stow, symlinks esperados y estado git:

```bash
bash ~/dotfiles/scripts/audit-dotfiles.sh
```

Para ver salida detallada de la simulacion de Stow:

```bash
bash ~/dotfiles/scripts/audit-dotfiles.sh --verbose
```

El script devuelve:

- `0` si todo lo critico pasa
- `1` si detecta fallos (por ejemplo symlink roto o conflicto de Stow)

Los warnings no rompen la ejecucion, pero se reportan en el resumen.

## Requisitos previos

- Ubuntu 22.04+ / Debian 12+ (nativo, VM o WSL2)
- Acceso a `sudo`
- Conexión a internet

## Nota para usuarios de WSL

En WSL, el emulador de terminal (Windows Terminal, etc.) usa las fuentes de **Windows**, no las de Linux. Aunque el script instala JetBrains Mono NF dentro de Ubuntu, necesitas instalarla también en Windows para que los iconos se muestren correctamente:

1. Descarga [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest) (archivo `JetBrainsMono.zip`)
2. Descomprime e instala los `.ttf` en Windows (doble clic → **Instalar**)
3. En tu terminal → **Settings** → **Profile** → **Font face** → selecciona `JetBrainsMono Nerd Font`

> El script detecta automáticamente si estás en WSL y te muestra este aviso al finalizar.

## Licencia

Uso personal. Siéntete libre de adaptar lo que necesites.
