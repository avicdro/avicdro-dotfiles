# ── Herramientas CLI modernas ─────────────────────────────────────────────────

# Editor por defecto — VSCode con fallback a Neovim
# ~/bin va primero en PATH (ver línea abajo), así que `nvim` resuelve al nuevo.
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# PATH — herramientas locales, Cargo, fnm y Atuin
# ~/bin va PRIMERO para que ~/bin/nvim (0.12.1) tenga prioridad sobre /usr/bin/nvim (0.9.5)
export PATH="$HOME/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.atuin/bin:$PATH"

# ── fnm (Fast Node Manager — use-on-cd para .node-version/.nvmrc) ───────────
if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# ── Zoxide (smart cd) ─────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# ── Atuin (shell history sync) ────────────────────────────────────────────────
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh)"
fi

# ── fzf (fuzzy finder) ────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Paleta Gruvbox Dark para fzf
export FZF_DEFAULT_OPTS='
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#83a598
  --color=fg:#ebdbb2,header:#83a598,info:#fabd2f,pointer:#fb4934
  --color=marker:#fe8019,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598
  --color=selected-bg:#3c3836
'

# Usar fd como backend (respeta .gitignore)
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Previsualización con bat en Ctrl+T
if command -v bat &>/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi

# ── uv (Python — autocompletado) ───────────────────────────────────────────────
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
fi

# ── Atuin env (fallback) ──────────────────────────────────────────────────────
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"

# ── OpenCode Ollama Cloud (Fast + Pro) ───────────────────────────────────────
if command -v opencode &>/dev/null; then
  # Modelos de Ollama Cloud
  export OPENCODE_FAST_MODEL="ollama-cloud/deepseek-v4-flash"
  export OPENCODE_PRO_MODEL="ollama-cloud/deepseek-v4-pro"

  # Pregunta rápida: respuesta concisa y directa (modelo fast)
  function ask() {
    opencode run --model "$OPENCODE_FAST_MODEL" \
      "Responde de forma concisa, directa y útil. Sin introducciones ni despedidas innecesarias. Si es código, usa bloques markdown con la sintaxis correcta. Pregunta: $*"
  }

  # Genera SOLO el comando shell, listo para copiar y pegar (modelo fast)
  function cmd() {
    opencode run --model "$OPENCODE_FAST_MODEL" \
      "Eres un generador de comandos de shell. Responde EXCLUSIVAMENTE con el comando exacto, sin formato markdown, sin backticks, sin comillas, sin explicaciones, sin texto adicional. El comando debe ser ejecutable directamente en una terminal POSIX (bash/zsh). Tarea: $*"
  }

  # Explicación detallada con ejemplos y contexto (modelo pro)
  function explain() {
    opencode run --model "$OPENCODE_PRO_MODEL" \
      "Explica el siguiente tema de forma clara, completa y bien estructurada. Incluye ejemplos prácticos cuando sea relevante. Asume que el usuario tiene conocimientos técnicos intermedios. Usa markdown para mejorar la legibilidad (encabezados, listas, bloques de código). Tema: $*"
  }

  alias '??'="cmd"
fi
