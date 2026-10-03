# ── Aliases personales ────────────────────────────────────────────────────────
# Estos aliases complementan los que ya provee el plugin git de Oh My Zsh.
# Para ver los de OMZ: alias | grep git  (o consultar ~/.oh-my-zsh/plugins/git/git.plugin.zsh)

# ── Neovim — forzar versión 0.12+ de ~/bin ────────────────────────────────────
# El PATH ya pone ~/bin primero, pero este alias es seguridad adicional.
alias nvim='$HOME/bin/nvim'

# ── Git (extras que OMZ no incluye) ───────────────────────────────────────────
alias gst-short='git status --short --branch'
alias glg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gundo='git reset --soft HEAD~1'
alias gamend='git commit --amend --no-edit'
alias gbranches='git branch -a --sort=-committerdate'
alias gstash-all='git stash push --include-untracked'

# ── Editores con Git ─────────────────────────────────────────────────────────
alias gtcode='env GIT_EDITOR="code --wait" git commit'
alias gtantig='env GIT_EDITOR="antigravity --wait" git commit'

# ── eza (ls moderno) ──────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --git --group-directories-first'
  alias tree='eza --tree --icons --git --group-directories-first'
fi

# ── bat (cat moderno) ─────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

# ── rsync seguro (copia con progreso) ─────────────────────────────────────────
alias cpg="rsync -ah --progress"

# ── herdr ──────────────────────────────────────────────────────────────────────
alias h='herdr'

# ── opencode (modo yolo) ──────────────────────────────────────────────────────
alias op='opencode --yolo'
