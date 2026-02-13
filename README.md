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

> **fnm** soporta `.node-version` y `.nvmrc` automáticamente gracias al flag `--use-on-cd` configurado en `.zshrc`.

## Aliases configurados

```bash
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

> **Fastfetch** se ejecuta automáticamente al abrir la primera terminal de la sesión (usa un lock file en `/tmp` que se resetea al reiniciar WSL).

## Verificar instalación

Ejecuta este one-liner para comprobar que todas las herramientas están disponibles:

```bash
for cmd in git zsh stow eza bat fd xh dust rg fzf zoxide atuin lazygit yazi fastfetch duf btop tldr jq rustc fnm node uv python3; do
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
├── install.sh          # Script de instalación principal
├── README.md
└── zsh/
    └── .zshrc          # Configuración de Zsh (enlazado con Stow a ~/.zshrc)
```

## Git — Perfiles condicionales

El script configura automáticamente **dos identidades Git** según la ruta del repositorio:

| Ruta | Identidad |
|------|-----------|
| `~/code/personal/` | Se solicita durante la instalación (nombre y email) |
| `~/code/trabajo/` | Se solicita durante la instalación (nombre y email de empresa) |

Si ya existe `~/.gitconfig-trabajo`, el script lo detecta y no vuelve a preguntar. Para modificarlo, edita ese archivo directamente.

## Re-ejecutar

El script verifica cada herramienta con `command -v` antes de instalar. Si algo ya existe, lo omite. Es seguro ejecutar múltiples veces:

```bash
bash ~/dotfiles/install.sh
```

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
