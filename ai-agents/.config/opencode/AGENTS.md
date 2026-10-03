# Herramientas de este sistema (WSL2 + zsh, Ubuntu)

Conocimiento de entorno, no mandatos: usa tu criterio según la tarea. Si una
herramienta de esta lista te ahorra tiempo o tokens, úsala; si no aplica, no.

## Preferibles a las nativas (más rápidas y/o salida más útil)

- `rg` — en vez de `grep`: mucho más rápido, respeta `.gitignore`. Ej: `rg -t ts "parse_user" src/`
- `fd` — en vez de `find`: sintaxis simple, respeta `.gitignore`. Ej: `fd -e sql migrations`
- `jq` — consulta JSON directamente en vez de leer el archivo completo. Ej: `jq -r '.version' package.json`
- `xh` — peticiones HTTP con salida limpia y parseable. Ej: `xh GET api.github.com/zen`
- `duf` / `dust` — uso de disco más compacto y legible que `df` / `du`
- `gh` — issues/PRs/releases/workflows cuando la tarea toque GitHub. Ya autenticado.
- `tldr` — uso y flags de un comando de forma concisa, en vez de `man` completo

## Solo para el humano — NO las uses

Generan colores ANSI, iconos o interfaces interactivas: te añaden ruido,
consumen tokens de más y pueden confundirte. Para eso ya tienes tus tools
nativas `Read`/`Grep`/`Glob`.

`eza`, `bat`, `delta`, `lumen`, `lazygit`, `yazi`, `fzf`, `zoxide`, `atuin`,
`btop`, `broot`, `hunk`, `tmux`

## No instaladas en esta máquina — no las sugieras ni las invoques

`yq`, `just`, `hyperfine`, `procs`, `sd`, `watchexec`, `sd`, `tree`
(instrucción esencial), cualquier wrapper de la familia "axi"/TOON
(`gh-axi`, `tok`, `omni`, etc.)

## Nota de mantenimiento

Este archivo es mantenido a mano por el humano (repo `~/dotfiles`, paquete
stow `ai-agents`). Si detectas que una herramienta de la lista ya no existe,
avísalo; no edites este archivo sin pedirlo.
