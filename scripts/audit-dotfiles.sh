#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES=(zsh fastfetch git lazygit yazi atuin btop bat bin)
VERBOSE=0

EXPECTED_LINKS=(
  "$HOME/.gitconfig|$DOTFILES_DIR/git/.gitconfig"
  "$HOME/.gitignore_global|$DOTFILES_DIR/git/.gitignore_global"
  "$HOME/.gitattributes_global|$DOTFILES_DIR/git/.gitattributes_global"
  "$HOME/.zsh|$DOTFILES_DIR/zsh/.zsh"
  "$HOME/.config/fastfetch/config.jsonc|$DOTFILES_DIR/fastfetch/.config/fastfetch/config.jsonc"
  "$HOME/.config/lazygit/config.yml|$DOTFILES_DIR/lazygit/.config/lazygit/config.yml"
  "$HOME/.config/atuin/config.toml|$DOTFILES_DIR/atuin/.config/atuin/config.toml"
  "$HOME/.config/btop/btop.conf|$DOTFILES_DIR/btop/.config/btop/btop.conf"
  "$HOME/.config/yazi|$DOTFILES_DIR/yazi/.config/yazi"
  "$HOME/.config/bat|$DOTFILES_DIR/bat/.config/bat"
)

warn_count=0
fail_count=0

while (($# > 0)); do
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      ;;
    -h|--help)
      echo "Uso: $(basename "$0") [--verbose]"
      echo "  --verbose, -v   Muestra salida completa de la simulacion de Stow"
      exit 0
      ;;
    *)
      echo "Argumento no reconocido: $1"
      echo "Usa --help para ver opciones disponibles."
      exit 2
      ;;
  esac
  shift
done

section() {
  printf "\n== %s ==\n" "$1"
}

pass() {
  printf "[OK]   %s\n" "$1"
}

warn() {
  warn_count=$((warn_count + 1))
  printf "[WARN] %s\n" "$1"
}

fail() {
  fail_count=$((fail_count + 1))
  printf "[FAIL] %s\n" "$1"
}

require_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "Comando disponible: $cmd"
  else
    fail "Comando faltante: $cmd"
  fi
}

section "Prerequisitos"
require_cmd stow
require_cmd readlink
require_cmd git

section "Sintaxis shell"
if bash -n "$DOTFILES_DIR/install.sh"; then
  pass "install.sh sin errores de sintaxis"
else
  fail "install.sh con errores de sintaxis"
fi

if zsh -n "$DOTFILES_DIR/zsh/.zshrc"; then
  pass "zsh/.zshrc sin errores de sintaxis"
else
  fail "zsh/.zshrc con errores de sintaxis"
fi

for mod in "$DOTFILES_DIR/zsh/.zsh/"*.zsh; do
  mod_name="$(basename "$mod")"
  if zsh -n "$mod"; then
    pass "zsh/.zsh/$mod_name sin errores de sintaxis"
  else
    fail "zsh/.zsh/$mod_name con errores de sintaxis"
  fi
done

section "Simulacion de Stow"
TMP_OUT="$(mktemp)"
(
  cd "$DOTFILES_DIR"
  stow -n -R "${PACKAGES[@]}"
) >"$TMP_OUT" 2>&1 || true

if (( VERBOSE == 1 )); then
  printf '%s\n' "-- Salida completa de stow -n -R --"
  cat "$TMP_OUT"
fi

if grep -qiE "conflicts|existing target is neither" "$TMP_OUT"; then
  fail "Stow detecto conflictos en simulacion"
else
  pass "Sin conflictos de stow en simulacion"
fi

if grep -q "BUG in find_stowed_path" "$TMP_OUT"; then
  warn "Stow reporto BUG in find_stowed_path (suele pasar por symlinks fuera de HOME Linux en WSL)"
fi

if grep -qi "WARNING" "$TMP_OUT"; then
  warn "Stow emitio warnings; revisa el detalle"
fi

section "Enlaces esperados"
for entry in "${EXPECTED_LINKS[@]}"; do
  IFS='|' read -r path expected <<< "$entry"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    fail "No existe: $path"
    continue
  fi

  if [[ ! -L "$path" ]]; then
    fail "No es symlink: $path"
    continue
  fi

  resolved="$(readlink -f "$path")"
  if [[ "$resolved" == "$expected" ]]; then
    pass "$path -> $resolved"
  else
    fail "$path apunta a $resolved (esperado: $expected)"
  fi
done

section "Estado del repositorio"
status_lines="$(cd "$DOTFILES_DIR" && git status --short | wc -l | tr -d ' ')"
if [[ "$status_lines" == "0" ]]; then
  pass "Working tree limpio"
else
  warn "Working tree con cambios ($status_lines lineas en git status --short)"
fi

section "Resumen"
printf "Warnings: %d\n" "$warn_count"
printf "Fails:    %d\n" "$fail_count"

rm -f "$TMP_OUT"

if (( fail_count > 0 )); then
  exit 1
fi

exit 0
