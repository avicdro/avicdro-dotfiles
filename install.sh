#!/usr/bin/env bash
# install.sh — prepara Zsh + Oh My Zsh + Powerlevel10k, crea estructura de código,
#               configura identidades Git condicionadas por carpeta e instala
#               herramientas CLI modernas ("Modern Unix").
# ------------------------------------------------------------------------------
set -euo pipefail

# ── Colores para output ──────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}▶ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $*${NC}"; }
fail()  { echo -e "${RED}✖ $*${NC}"; }

# ── Helper: instalar herramienta con Cargo ────────────────────────────────────
cargo_install() {
  local bin="$1"; shift   # nombre del binario a verificar
  local crates=("$@")     # uno o más crates a instalar
  if command -v "$bin" &>/dev/null; then
    info "$bin ya está instalado — omitiendo."
  else
    info "Instalando ${crates[*]} con Cargo..."
    if cargo install "${crates[@]}"; then
      info "$bin instalado correctamente."
    else
      fail "No se pudo instalar $bin. Continuando..."
    fi
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# 0) Variables
# ══════════════════════════════════════════════════════════════════════════════
PKGS=(git curl wget zsh stow build-essential unzip ripgrep btop tldr jq duf)
OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM="${OMZ_DIR}/custom"
P10K_THEME_DIR="${OMZ_CUSTOM}/themes/powerlevel10k"
JBM_VERSION="3.3.0"
JBM_URL_BASE="https://github.com/ryanoasis/nerd-fonts/releases/download/v${JBM_VERSION}"
LOCAL_BIN="$HOME/.local/bin"

# Detectar arquitectura del sistema
case "$(uname -m)" in
  x86_64)  ARCH="x86_64" ; ARCH_ALT="amd64" ;;
  aarch64) ARCH="aarch64"; ARCH_ALT="arm64" ;;
  *)       fail "Arquitectura $(uname -m) no soportada."; exit 1 ;;
esac

mkdir -p "$LOCAL_BIN"

# ══════════════════════════════════════════════════════════════════════════════
# 1) Instalar paquetes básicos (apt)
# ══════════════════════════════════════════════════════════════════════════════
info "Instalando paquetes básicos: ${PKGS[*]}"
sudo apt update
sudo apt install -y "${PKGS[@]}"

# ── fastfetch (apt si disponible, si no .deb de GitHub) ───────────────────────
if ! command -v fastfetch &>/dev/null; then
  if apt-cache show fastfetch &>/dev/null 2>&1; then
    info "Instalando fastfetch desde apt..."
    sudo apt install -y fastfetch
  else
    info "fastfetch no disponible en apt — descargando .deb de GitHub..."
    FF_VERSION=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" \
      | jq -r '.tag_name')
    if [[ -n "$FF_VERSION" && "$FF_VERSION" != "null" ]]; then
      FF_DEB="fastfetch-linux-${ARCH_ALT}.deb"
      FF_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/${FF_VERSION}/${FF_DEB}"
      TMP_DEB=$(mktemp)
      if curl -Lo "$TMP_DEB" "$FF_URL"; then
        sudo dpkg -i "$TMP_DEB"
        sudo apt install -f -y   # resolver dependencias si faltan
        info "fastfetch ${FF_VERSION} instalado."
      else
        fail "Error descargando fastfetch .deb. Continuando..."
      fi
      rm -f "$TMP_DEB"
    else
      fail "No se pudo obtener la versión de fastfetch. Continuando..."
    fi
  fi
else
  info "fastfetch ya instalado — omitiendo."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 2) Instalar Oh My Zsh
# ══════════════════════════════════════════════════════════════════════════════
if [[ ! -d "$OMZ_DIR" ]]; then
  info "Instalando Oh‑My‑Zsh..."
  export RUNZSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 3) Clonar Powerlevel10k y plugins
# ══════════════════════════════════════════════════════════════════════════════
info "Asegurando tema Powerlevel10k y plugins..."
mkdir -p "${OMZ_CUSTOM}/themes" "${OMZ_CUSTOM}/plugins"

# Tema Powerlevel10k
if [[ ! -d "$P10K_THEME_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
fi

# Plugin: zsh‑autosuggestions
if [[ ! -d "${OMZ_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "${OMZ_CUSTOM}/plugins/zsh-autosuggestions"
fi

# Plugin: zsh‑syntax‑highlighting
if [[ ! -d "${OMZ_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${OMZ_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 4) Crear estructura de código
# ══════════════════════════════════════════════════════════════════════════════
info "Creando carpetas de desarrollo en ~/code/{personal,trabajo}..."
mkdir -p "$HOME/code/personal" "$HOME/code/trabajo"

# ══════════════════════════════════════════════════════════════════════════════
# 5) Perfiles Git condicionales
# ══════════════════════════════════════════════════════════════════════════════

# 5‑a) Perfil personal (interactivo)
if [[ -f "$HOME/.gitconfig-personal" ]]; then
  info "Perfil personal ya existe en ~/.gitconfig-personal"
  echo "    Si necesitas modificar algún dato, edita directamente ese archivo."
else
  echo ""
  info "Configurando perfil personal de Git..."
  read -rp "    Nombre de usuario (ej: tuUsuario): " PERSONAL_NAME
  read -rp "    Email personal   (ej: tu@email.com): " PERSONAL_EMAIL
  if [[ -n "$PERSONAL_NAME" && -n "$PERSONAL_EMAIL" ]]; then
    cat > "$HOME/.gitconfig-personal" <<EOF
[user]
    name  = ${PERSONAL_NAME}
    email = ${PERSONAL_EMAIL}
EOF
    info "Perfil personal creado en ~/.gitconfig-personal"
  else
    warn "Nombre o email vacío. Se omite la creación del perfil personal."
  fi
fi

# 5‑b) Perfil de trabajo (interactivo)
if [[ -f "$HOME/.gitconfig-trabajo" ]]; then
  info "Perfil de trabajo ya existe en ~/.gitconfig-trabajo"
  echo "    Si necesitas modificar algún dato, edita directamente ese archivo."
else
  echo ""
  read -rp "¿Tienes un perfil de empresa/trabajo? [s/N]: " TIENE_TRABAJO
  if [[ "$TIENE_TRABAJO" =~ ^[sS]$ ]]; then
    read -rp "    Nombre (ej: nombre.apellido): " TRABAJO_NAME
    read -rp "    Email  (ej: nombre@empresa.com): " TRABAJO_EMAIL
    if [[ -n "$TRABAJO_NAME" && -n "$TRABAJO_EMAIL" ]]; then
      cat > "$HOME/.gitconfig-trabajo" <<EOF
[user]
    name  = ${TRABAJO_NAME}
    email = ${TRABAJO_EMAIL}
EOF
      info "Perfil de trabajo creado en ~/.gitconfig-trabajo"
    else
      warn "Nombre o email vacío. Se omite la creación del perfil de trabajo."
    fi
  else
    info "Sin perfil de trabajo — omitiendo."
  fi
fi

# 5‑c) Incluir perfiles según la ruta del repo (idempotente)
git config --global includeIf.gitdir:"$HOME/code/personal/".path "$HOME/.gitconfig-personal"
if [[ -f "$HOME/.gitconfig-trabajo" ]]; then
  git config --global includeIf.gitdir:"$HOME/code/trabajo/".path "$HOME/.gitconfig-trabajo"
fi
# Editor: usa VS Code si está disponible, si no, usa el editor del sistema
if command -v code &>/dev/null; then
  git config --global core.editor "code --wait"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 6) Enlazar dotfiles con GNU Stow
# ══════════════════════════════════════════════════════════════════════════════
info "Enlazando dotfiles con GNU Stow..."
cd "$(dirname "$0")"
stow -R zsh
cd - >/dev/null

# ══════════════════════════════════════════════════════════════════════════════
# 7) Descargar e instalar JetBrains Mono Nerd Font
# ══════════════════════════════════════════════════════════════════════════════
SYSTEM_FONT_DIR="$HOME/.local/share/fonts"
if ls "$SYSTEM_FONT_DIR"/JetBrainsMono*.ttf &>/dev/null 2>&1; then
  info "JetBrains Mono Nerd Font ya instalada — omitiendo."
else
  info "Descargando e instalando JetBrains Mono Nerd Font v${JBM_VERSION}…"
  mkdir -p "$SYSTEM_FONT_DIR"
  TMP_ZIP=$(mktemp)
  if curl -Lo "$TMP_ZIP" "${JBM_URL_BASE}/JetBrainsMono.zip"; then
    unzip -qo "$TMP_ZIP" -d "$SYSTEM_FONT_DIR" '*.ttf' -x '*Windows*' 2>/dev/null || true
    rm -f "$TMP_ZIP"
    # Refrescar caché de fuentes
    if command -v fc-cache &>/dev/null; then
      fc-cache -f "$SYSTEM_FONT_DIR"
    fi
    info "JetBrains Mono NF instalada en $SYSTEM_FONT_DIR."
  else
    fail "Error descargando JetBrains Mono NF. Continuando..."
    rm -f "$TMP_ZIP"
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# 8) Hacer Zsh tu shell por defecto
# ══════════════════════════════════════════════════════════════════════════════
info "Estableciendo Zsh como shell predeterminado..."
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 9) Instalar Rust / Cargo (requerido para herramientas modernas)
# ══════════════════════════════════════════════════════════════════════════════
if ! command -v cargo &>/dev/null; then
  info "Instalando Rust y Cargo (desatendido)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
  info "Rust $(rustc --version) instalado."
else
  info "Cargo ya disponible — omitiendo instalación de Rust."
  # Asegurar que el env está cargado para este script
  # shellcheck disable=SC1091
  [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
fi

# ══════════════════════════════════════════════════════════════════════════════
# 10) Instalar Node.js con fnm (Fast Node Manager)
# ══════════════════════════════════════════════════════════════════════════════
if ! command -v fnm &>/dev/null; then
  info "Instalando fnm (Fast Node Manager)..."
  if curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell; then
    # Cargar fnm en esta sesión para poder instalar Node
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"
    info "fnm instalado. Instalando Node.js LTS..."
    fnm install --lts
    fnm default lts-latest
    info "Node.js $(node --version) instalado con fnm."
  else
    fail "Error instalando fnm. Continuando..."
  fi
else
  info "fnm ya instalado — omitiendo."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 11) Instalar Python con uv (Astral)
# ══════════════════════════════════════════════════════════════════════════════
if ! command -v uv &>/dev/null; then
  info "Instalando uv (gestor de Python por Astral)..."
  if curl -LsSf https://astral.sh/uv/install.sh | sh; then
    # shellcheck disable=SC1091
    [[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
    info "uv $(uv --version) instalado."
  else
    fail "Error instalando uv. Continuando..."
  fi
else
  info "uv ya instalado — omitiendo."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 12) Herramientas modernas vía Cargo
# ══════════════════════════════════════════════════════════════════════════════
info "── Herramientas CLI modernas (Cargo) ──"

cargo_install eza   eza
cargo_install bat   bat
cargo_install fd    fd-find
cargo_install xh    xh
cargo_install dust  du-dust

# ══════════════════════════════════════════════════════════════════════════════
# 13) Herramientas modernas vía scripts / binarios
# ══════════════════════════════════════════════════════════════════════════════
info "── Herramientas CLI modernas (scripts/binarios) ──"

# ── zoxide ────────────────────────────────────────────────────────────────────
if ! command -v zoxide &>/dev/null; then
  info "Instalando zoxide..."
  if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
    info "zoxide instalado."
  else
    fail "Error instalando zoxide. Continuando..."
  fi
else
  info "zoxide ya instalado — omitiendo."
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
if ! command -v fzf &>/dev/null; then
  info "Instalando fzf (git clone + install)..."
  if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  if "$HOME/.fzf/install" --all --no-bash --no-fish; then
    info "fzf instalado."
  else
    fail "Error instalando fzf. Continuando..."
  fi
else
  info "fzf ya instalado — omitiendo."
fi

# ── atuin ─────────────────────────────────────────────────────────────────────
if ! command -v atuin &>/dev/null; then
  info "Instalando atuin..."
  if curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh; then
    info "atuin instalado."
  else
    fail "Error instalando atuin. Continuando..."
  fi
else
  info "atuin ya instalado — omitiendo."
fi

# ── lazygit ───────────────────────────────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
  info "Instalando lazygit (último release de GitHub)..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | jq -r '.tag_name' | sed 's/^v//')

  if [[ -n "$LAZYGIT_VERSION" && "$LAZYGIT_VERSION" != "null" ]]; then
    LAZYGIT_ARCHIVE="lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
    LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/${LAZYGIT_ARCHIVE}"
    TMP_DIR=$(mktemp -d)
    if curl -Lo "${TMP_DIR}/${LAZYGIT_ARCHIVE}" "$LAZYGIT_URL" && \
       tar xzf "${TMP_DIR}/${LAZYGIT_ARCHIVE}" -C "$TMP_DIR" lazygit; then
      install "${TMP_DIR}/lazygit" "$LOCAL_BIN/lazygit"
      info "lazygit v${LAZYGIT_VERSION} instalado en $LOCAL_BIN."
    else
      fail "Error descargando/extrayendo lazygit. Continuando..."
    fi
    rm -rf "$TMP_DIR"
  else
    fail "No se pudo obtener la versión de lazygit. Continuando..."
  fi
else
  info "lazygit ya instalado — omitiendo."
fi

# ── yazi (prebuilt binary desde GitHub) ───────────────────────────────────────
if ! command -v yazi &>/dev/null; then
  info "Instalando yazi (último release de GitHub)..."
  YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" \
    | jq -r '.tag_name' | sed 's/^v//')

  if [[ -n "$YAZI_VERSION" && "$YAZI_VERSION" != "null" ]]; then
    YAZI_ARCHIVE="yazi-${ARCH}-unknown-linux-gnu.zip"
    YAZI_URL="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/${YAZI_ARCHIVE}"
    TMP_DIR=$(mktemp -d)
    if curl -Lo "${TMP_DIR}/${YAZI_ARCHIVE}" "$YAZI_URL" && \
       unzip -qo "${TMP_DIR}/${YAZI_ARCHIVE}" -d "$TMP_DIR"; then
      install "${TMP_DIR}/yazi-${ARCH}-unknown-linux-gnu/yazi" "$LOCAL_BIN/yazi"
      install "${TMP_DIR}/yazi-${ARCH}-unknown-linux-gnu/ya" "$LOCAL_BIN/ya"
      info "yazi v${YAZI_VERSION} instalado en $LOCAL_BIN."
    else
      fail "Error descargando/extrayendo yazi. Continuando..."
    fi
    rm -rf "$TMP_DIR"
  else
    fail "No se pudo obtener la versión de yazi. Continuando..."
  fi
else
  info "yazi ya instalado — omitiendo."
fi

# ── opencode (AI coding assistant) ─────────────────────────────────────────
if ! command -v opencode &>/dev/null; then
  if command -v npm &>/dev/null; then
    info "Instalando OpenCode (AI coding assistant)..."
    if npm install -g opencode-ai; then
      info "OpenCode $(opencode --version 2>&1 | head -1) instalado."
    else
      fail "Error instalando OpenCode. Continuando..."
    fi
  else
    warn "npm no disponible — no se puede instalar OpenCode. Instala Node.js primero."
  fi
else
  info "OpenCode ya instalado — omitiendo."
fi

# ══════════════════════════════════════════════════════════════════════════════
# 15) Mensaje final
# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}Todo listo. Cierra y vuelve a abrir la terminal.${NC}"
echo "   Después ejecuta:  p10k configure"
echo ""
if [[ -f "$HOME/.gitconfig-personal" ]]; then
  echo -e "${GREEN}Perfil PERSONAL:${NC}"
  grep -A2 '\[user\]' "$HOME/.gitconfig-personal" | sed 's/^/    /'
  echo "    Para modificarlo: edita ~/.gitconfig-personal"
  echo ""
fi
if [[ -f "$HOME/.gitconfig-trabajo" ]]; then
  echo -e "${YELLOW}Perfil de TRABAJO:${NC}"
  grep -A2 '\[user\]' "$HOME/.gitconfig-trabajo" | sed 's/^/    /'
  echo "    Para modificarlo: edita ~/.gitconfig-trabajo"
  echo ""
fi
echo -e "${GREEN}Verificando herramientas instaladas:${NC}"
for cmd in eza bat fd xh dust rg fzf zoxide atuin lazygit yazi fastfetch duf btop tldr jq rustc fnm node uv opencode; do
  printf "    %-12s" "$cmd"
  if command -v "$cmd" &>/dev/null; then
    echo -e "${GREEN}✅${NC} $($cmd --version 2>&1 | head -1)"
  else
    echo -e "${RED}❌ no encontrado${NC}"
  fi
done
echo ""
echo "    Revisa tu .zshrc para ver los aliases y configuraciones."

# ── Aviso específico para WSL ─────────────────────────────────────────────────
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  echo ""
  echo -e "${YELLOW}⚠  Estás en WSL ($WSL_DISTRO_NAME).${NC}"
  echo "   Las fuentes se instalaron dentro de Linux, pero tu emulador de"
  echo "   terminal (Windows Terminal, etc.) usa las fuentes de Windows."
  echo ""
  echo "   Para que los iconos se vean correctamente:"
  echo "   1. Descarga JetBrains Mono Nerd Font:"
  echo "      https://github.com/ryanoasis/nerd-fonts/releases/latest"
  echo "      (archivo: JetBrainsMono.zip)"
  echo "   2. Descomprime e instala los .ttf en Windows (doble clic → Instalar)"
  echo "   3. En tu terminal → Settings → Profile → Font face →"
  echo "      selecciona \"JetBrainsMono Nerd Font\""
fi
