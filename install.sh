#!/usr/bin/env bash
# install.sh — dream-terminal installer (idempotent, reversible)
set -euo pipefail

REPO="$HOME/cabral-dev/dream-terminal"
BACKUP_ROOT="$HOME"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="${BACKUP_ROOT}/.dream-terminal-backup-${TIMESTAMP}"
DRY_RUN="${1:-}"

log()  { printf '\033[0;36m[dream]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[warn]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[0;31m[err]\033[0m  %s\n' "$*" >&2; }

ensure_backup_dir() {
  [[ "$DRY_RUN" == "--dry-run" ]] && return 0
  mkdir -p "$BACKUP"
}

symlink_with_backup() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "✓ $dst already linked"
    return 0
  fi
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would link $dst → $src"
    return 0
  fi
  if [[ -e "$dst" ]]; then
    mkdir -p "$(dirname "$BACKUP/$dst")"
    cp -a "$dst" "$BACKUP/$dst"
  fi
  rm -rf "$dst"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  log "→ $dst → $src"
}

merge_json_fragment() {
  local target="$1" fragment="$2"
  command -v jq >/dev/null 2>&1 || { err "jq required"; return 1; }
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would merge $fragment into $target"
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  [[ -f "$target" ]] || echo '{}' > "$target"
  mkdir -p "$(dirname "$BACKUP/$target")"
  cp -a "$target" "$BACKUP/$target"
  jq -s '.[0] * .[1]' "$target" "$fragment" > "$target.tmp"
  mv "$target.tmp" "$target"
  log "merged $(basename "$fragment") into $target"
}

ensure_zshrc_block() {
  local rc="$HOME/.zshrc"
  local marker_start="# >>> dream-terminal >>>"
  [[ -f "$rc" ]] || { warn "~/.zshrc missing — skipping block insert"; return; }
  if grep -q "$marker_start" "$rc"; then
    log "✓ .zshrc block present"
    return
  fi
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would append dream-terminal block to ~/.zshrc"
    return
  fi
  mkdir -p "$BACKUP"
  cp -a "$rc" "$BACKUP/.zshrc"
  cat >> "$rc" <<'EOF'

# >>> dream-terminal >>>
source "$HOME/cabral-dev/dream-terminal/zsh/aliases.zsh"
source "$HOME/cabral-dev/dream-terminal/zsh/functions.zsh"
source "$HOME/cabral-dev/dream-terminal/zsh/completions.zsh"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
# <<< dream-terminal <<<
EOF
  log "appended dream-terminal block to ~/.zshrc"
}

remove_zinit_block() {
  local rc="$HOME/.zshrc"
  [[ -f "$rc" ]] || return 0
  grep -q "### Added by Zinit" "$rc" || { log "✓ no zinit block"; return; }
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would remove zinit block from ~/.zshrc"
    return
  fi
  cp -a "$rc" "$BACKUP/.zshrc.pre-zinit-removal"
  sed -i '' '/### Added by Zinit.s installer/,/### End of Zinit.s installer chunk/d' "$rc"
  log "removed zinit block from ~/.zshrc"
}

remove_spaceship_theme() {
  local rc="$HOME/.zshrc"
  [[ -f "$rc" ]] || return 0
  grep -q 'ZSH_THEME="spaceship"' "$rc" || { log "✓ no spaceship theme"; return; }
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would comment out ZSH_THEME=spaceship"
    return
  fi
  cp -a "$rc" "$BACKUP/.zshrc.pre-theme-removal"
  sed -i '' 's/^ZSH_THEME="spaceship"/# ZSH_THEME="spaceship"  # superseded by starship/' "$rc"
  sed -i '' '/^SPACESHIP_/s/^/# /' "$rc"
  log "commented out spaceship config; starship takes over"
}

install_omz_custom_plugin() {
  local name="$1" repo="$2"
  local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"
  if [[ -d "$dest" ]]; then
    log "✓ omz plugin $name present"
    return
  fi
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would clone $repo → $dest"
    return
  fi
  git clone --depth 1 "$repo" "$dest"
  log "cloned $name"
}

# Ghostty cask does not symlink its CLI; do it ourselves (idempotent).
# `ghostty` CLI inside the .app is needed by `ghostty +show-config` in verify steps.
link_ghostty_cli() {
  local bin_dir
  if   [[ -d /opt/homebrew/bin ]]; then bin_dir=/opt/homebrew/bin
  elif [[ -d /usr/local/bin     ]]; then bin_dir=/usr/local/bin
  else warn "no brew bin dir found — skipping ghostty CLI link"; return; fi
  local target="$bin_dir/ghostty"
  local src="/Applications/Ghostty.app/Contents/MacOS/ghostty"
  if [[ ! -x "$src" ]]; then
    warn "Ghostty.app not installed — skipping ghostty CLI link"
    return
  fi
  if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
    log "✓ ghostty CLI link present"
    return
  fi
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would link $target → $src"
    return
  fi
  ln -sfn "$src" "$target"
  log "→ $target → $src"
}

main() {
  log "dream-terminal install starting (backup: $BACKUP)"
  ensure_backup_dir
  # Phase actions — filled in subsequent tasks
  log "done."
}

main "$@"
