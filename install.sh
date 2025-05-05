#!/usr/bin/env bash
# install.sh — prepara Zsh + Oh My Zsh + Powerlevel10k, crea estructura de código
#               y configura identidades Git condicionadas por carpeta
# ------------------------------------------------------------------------------
set -euo pipefail

# 0) Variables -----------------------------------------------------------------
PKGS=(git curl wget zsh stow)
OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM="${OMZ_DIR}/custom"                # Ruta oficial para plugins/temas
P10K_THEME_DIR="${OMZ_CUSTOM}/themes/powerlevel10k"
FONT_DIR="$HOME/p10k-fonts"
MESLO_URL_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"

# 1) Instalar paquetes básicos -------------------------------------------------
echo "▶ Instalando paquetes básicos: ${PKGS[*]}"
sudo apt update
sudo apt install -y "${PKGS[@]}"

# 2) Instalar Oh My Zsh --------------------------------------------------------
if [[ ! -d "$OMZ_DIR" ]]; then
  echo "▶ Instalando Oh‑My‑Zsh..."
  export RUNZSH=no   # evita que cambie de shell a mitad del script
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3) Clonar Powerlevel10k y plugins -------------------------------------------
echo "▶ Asegurando tema Powerlevel10k y plugins..."
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

# 4) Crear estructura de código ----------------------------------------------
echo "▶ Creando carpetas de desarrollo en ~/code/{personal,trabajo}..."
mkdir -p "$HOME/code/personal" "$HOME/code/trabajo"

# 5) Perfiles Git condicionales ----------------------------------------------
# 5‑a) Generar archivos de identidad si no existen
if [[ ! -f "$HOME/.gitconfig-personal" ]]; then
  cat > "$HOME/.gitconfig-personal" <<'EOF'
[user]
    name  = avicdro
    email = avicdro@gmail.com
EOF
fi

if [[ ! -f "$HOME/.gitconfig-trabajo" ]]; then
  cat > "$HOME/.gitconfig-trabajo" <<'EOF'
[user]
    name  = valvarez
    email = valvarez@ext.laliga.com
EOF
fi

# 5‑b) Incluir perfiles según la ruta del repo
# (comandos son idempotentes; se pueden re‑ejecutar sin duplicar)

git config --global includeIf.gitdir:"$HOME/code/personal/".path "$HOME/.gitconfig-personal"
git config --global includeIf.gitdir:"$HOME/code/trabajo/".path  "$HOME/.gitconfig-trabajo"

git config --global core.editor "code --wait"

# 6) Enlazar dotfiles con GNU Stow -------------------------------------------
echo "▶ Enlazando dotfiles con GNU Stow..."
cd "$(dirname "$0")"   # raíz del repo
stow -R zsh              # sólo el paquete zsh/
cd - >/dev/null

# 7) Descargar Meslo LGS NF ---------------------------------------------------
echo "▶ Descargando la fuente Meslo LGS NF en $FONT_DIR (sin instalar)…"
mkdir -p "$FONT_DIR"
for style in "Regular" "Bold" "Italic" "Bold%20Italic"; do
  file="MesloLGS NF ${style}.ttf"
  [[ -f "$FONT_DIR/$file" ]] && continue
  wget -qO "$FONT_DIR/$file" "$MESLO_URL_BASE/${file// /%20}"
fi
echo "  – Archivos guardados. Instálalos a tu gusto después."

: <<'EOF'
# Instalación opcional de las fuentes dentro de WSL/Ubuntu:
mkdir -p ~/.local/share/fonts
cp ~/p10k-fonts/*.ttf ~/.local/share/fonts/
fc-cache -fv ~/.local/share/fonts
EOF
# ---------------------------------------------------------------------------

# 8) Hacer Zsh tu shell por defecto ------------------------------------------
echo "▶ Estableciendo Zsh como shell predeterminado..."
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

# 9) Mensaje final ------------------------------------------------------------
echo -e "\n✅ Todo listo. Cierra y vuelve a abrir la terminal."
echo "   Después ejecuta:  p10k configure"
echo -e "\n🔔  Perfil de TRABAJO configurado con:\n    name  = valvarez\n    email = valvarez@ext.laliga.com"
echo "   Si cambias de empresa modifícalo editando ~/.gitconfig-trabajo y vuelve a ejecutar este script."
