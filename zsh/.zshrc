# ═══════════════════════════════════════════════════════════════════════════════
#  ~/.zshrc — Orquestador principal
#  Gestionado con GNU Stow (paquete zsh). No editar fuera del repo ~/dotfiles.
#
#  Estructura modular:
#    ~/.zsh/aliases.zsh    → Aliases (git extras, eza, bat, rsync, editores)
#    ~/.zsh/functions.zsh  → Funciones (antig WSL, yazi wrapper)
#    ~/.zsh/tools.zsh      → Herramientas CLI (fnm, zoxide, fzf, atuin, uv, opencode)
#
#  Para personalizar el prompt: p10k configure
#  Para ver aliases activos:    alias | grep <patron>
#  Para ver los de OMZ git:     alias | grep '^g'
# ═══════════════════════════════════════════════════════════════════════════════

# ── Fastfetch (solo la primera terminal de la sesión) ─────────────────────────
# Usa un lock file por sesión en /run/user/<uid>/ (se limpia al reiniciar).
LOCK_FILE="/run/user/$(id -u)/fastfetch_session_lock"
if command -v fastfetch &>/dev/null && [ ! -f "$LOCK_FILE" ]; then
    fastfetch
    touch "$LOCK_FILE"
fi

# ── Powerlevel10k instant prompt ──────────────────────────────────────────────
# Debe estar cerca del inicio del archivo. Cualquier código que requiera input
# del usuario (contraseñas, confirmaciones [y/n]) debe ir ANTES de este bloque.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── fpath sanitization ────────────────────────────────────────────────────────
# Excluir completions rotas (symlinks apuntando a destinos inexistentes).
# Docker Desktop WSL deja un symlink roto cuando no está montado.
if [[ -L /usr/share/zsh/vendor-completions/_docker && ! -e /usr/share/zsh/vendor-completions/_docker ]]; then
  fpath=(${fpath:#/usr/share/zsh/vendor-completions})
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
# Plugins estándar en $ZSH/plugins/, custom en $ZSH/custom/plugins/.
# El plugin "git" provee ~150 aliases (ga, gc, gp, gst, gl, etc.).
# Agregar plugins con cuidado — muchos plugins ralentizan el arranque.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ── Powerlevel10k ─────────────────────────────────────────────────────────────
# Para reconfigurar: p10k configure  |  Para editar manualmente: ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ── Módulos propios (~/.zsh/) ─────────────────────────────────────────────────
# Carga automáticamente todos los .zsh del directorio ~/.zsh/ (symlink de Stow).
# El glob (N) evita error si el directorio está vacío.
# Orden de carga: alfabético (aliases → functions → tools).
for module in "$HOME/.zsh/"*.zsh(N); do
  source "$module"
done
export PATH="$HOME/.config/symfony-cli/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Obsidian via Wayland nativo (fix offset fullscreen en WSLg, 2026-08-31)
alias obsidian="/usr/bin/obsidian --ozone-platform=wayland"

# Added by stepwise installer
export PATH="$HOME/.stepwise/bin:$PATH"
export CODA_SINGLE_AGENT_MAX_ITERATIONS=200
