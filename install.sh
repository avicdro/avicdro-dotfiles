#!/usr/bin/env bash
# install.sh — prepara Zsh + Oh My Zsh + Powerlevel10k y enlaza dotfiles con GNU Stow
# ------------------------------------------------------------------------------
set -euo pipefail

# 0) Variables ---------------------------------------------------------------
PKGS=(git curl wget zsh stow)
OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM="${OMZ_DIR}/custom"                # ruta ofi 
FONT_DIR="$HOME/p10k-fonts"
MESLO_URL_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"

# 1) Instalar paquetes básicos ----------------------------------------------
echo "▶ Instalando paquetes básicos: ${PKGS[*]}"
sudo apt update
sudo apt install -y "${PKGS[@]}"

# 2) Instalar Oh My Zsh ------------------------------------------------------
if [[ ! -d "$OMZ_DIR" ]]; then
  echo "▶ Instalando Oh-My-Zsh..."
  export RUNZSH=no                   # evita salto de shell a mitad del script
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3) Clonar Powerlevel10k y plugins -----------------------------------------
echo "▶ Asegurando tema Powerlevel10k y plugins..."
mkdir -p "${OMZ_CUSTOM}/themes" "${OMZ_CUSTOM}/plugins"

# Tema Powerlevel10k
if [[ ! -d "{$OMZ_CUSTOM}/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "{$OMZ_CUSTOM}/themes/powerlevel10k" 2>/dev/null || true
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

# 4) Enlazar dotfiles con GNU Stow ------------------------------------------
echo "▶ Enlazando dotfiles con GNU Stow..."
cd "$(dirname "$0")"          # raíz del repo
stow -R zsh                   # sólo el paquete zsh/
cd - >/dev/null

# 5) Descargar Meslo LGS NF -----------------------------------------------
echo "▶ Descargando la fuente Meslo LGS NF en $FONT_DIR (sin instalar)…"
mkdir -p "$FONT_DIR"
for style in "Regular" "Bold" "Italic" "Bold%20Italic"; do
  file="MesloLGS NF ${style}.ttf"
  [[ -f "$FONT_DIR/$file" ]] && continue
  wget -qO "$FONT_DIR/$file" "$MESLO_URL_BASE/${file// /%20}"
done
echo "  – Archivos guardados. Instálalos a tu gusto después."

: <<'EOF'
# Instalación opcional de las fuentes dentro de WSL/Ubuntu:
mkdir -p ~/.local/share/fonts
cp ~/p10k-fonts/*.ttf ~/.local/share/fonts/
fc-cache -fv ~/.local/share/fonts
EOF
# --------------------------------------------------------------------------

# 6) Hacer Zsh tu shell por defecto ----------------------------------------
echo "▶ Estableciendo Zsh como shell predeterminado..."
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

echo -e "\n✅ Todo listo. Cierra y vuelve a abrir la terminal."
echo "   Después ejecuta:  p10k configure"
