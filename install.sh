#!/usr/bin/env bash
# install.sh — dream-terminal installer (idempotent, reversible)
set -euo pipefail

REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
  # Cursor/VSCode settings + keybindings are JSONC (// comments, /* */ blocks,
  # trailing commas). Strip with a string-aware state machine — regex gets fooled
  # by strings containing `//` like file:/// URLs. Comments are lost on merge;
  # backup above preserves the pre-merge file with comments intact.
  python3 - "$target" "$fragment" <<'PY' > "$target.tmp"
import json, re, sys
target, fragment = sys.argv[1], sys.argv[2]
with open(target, 'r', encoding='utf-8') as f: txt = f.read()

def strip_jsonc(s):
    out, i, n = [], 0, len(s)
    in_string = False
    escape = False
    while i < n:
        c = s[i]
        if in_string:
            out.append(c)
            if escape: escape = False
            elif c == '\\': escape = True
            elif c == '"': in_string = False
            i += 1
            continue
        if c == '"':
            in_string = True; out.append(c); i += 1; continue
        if c == '/' and i + 1 < n:
            nxt = s[i+1]
            if nxt == '/':
                j = s.find('\n', i)
                i = j if j != -1 else n
                continue
            if nxt == '*':
                j = s.find('*/', i+2)
                i = (j + 2) if j != -1 else n
                continue
        out.append(c); i += 1
    return ''.join(out)

cleaned = strip_jsonc(txt)
cleaned = re.sub(r',(\s*[}\]])', r'\1', cleaned)
base = json.loads(cleaned) if cleaned.strip() else ({} if fragment.endswith('settings.json.fragment') else [])
with open(fragment, 'r', encoding='utf-8') as f: frag = json.load(f)
if isinstance(base, list) and isinstance(frag, list):
    merged = base + frag
elif isinstance(base, dict) and isinstance(frag, dict):
    merged = {**base, **frag}
else:
    raise SystemExit(f"type mismatch: base={type(base).__name__} frag={type(frag).__name__}")
json.dump(merged, sys.stdout, indent=2)
PY
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
  cat >> "$rc" <<EOF

# >>> dream-terminal >>>
export DREAM_TERMINAL_REPO="$REPO"
# Optional: override where the brain vault lives (default: \$HOME/cabral-dev/brain)
# export BRAIN_DIR="\$HOME/path/to/your/obsidian-vault"
source "\$DREAM_TERMINAL_REPO/zsh/aliases.zsh"
source "\$DREAM_TERMINAL_REPO/zsh/functions.zsh"
source "\$DREAM_TERMINAL_REPO/zsh/completions.zsh"
eval "\$(starship init zsh)"
eval "\$(zoxide init zsh)"
eval "\$(atuin init zsh)"
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
  # Detect either the theme line OR leftover SPACESHIP_* identifiers
  if ! grep -qE '^(ZSH_THEME="spaceship"|SPACESHIP_)' "$rc"; then
    log "✓ no spaceship config"
    return
  fi
  if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "would delete spaceship config block(s)"
    return
  fi
  cp -a "$rc" "$BACKUP/.zshrc.pre-theme-removal"
  # Delete full spaceship stanza: theme line, multi-line PROMPT_ORDER array, and any SPACESHIP_* scalars
  sed -i '' '/^ZSH_THEME="spaceship"/d' "$rc"
  sed -i '' '/^SPACESHIP_[A-Z_]*=(/,/^)/d' "$rc"
  sed -i '' '/^SPACESHIP_/d' "$rc"
  log "removed spaceship config; starship takes over"
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

# Merge Cursor/VSCode theme + keybinds into a target IDE's user config.
# $1 = label (display), $2 = app-support dir name, $3 = CLI command
align_ide() {
  local label="$1" app_dir="$2" cli="$3"
  local base="$HOME/Library/Application Support/$app_dir/User"
  if [[ ! -d "$HOME/Library/Application Support/$app_dir" ]]; then
    warn "$label user dir not found — skipping"
    return
  fi
  if command -v "$cli" >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == "--dry-run" ]]; then
      log "would install $label extension enkia.tokyo-night"
    else
      "$cli" --install-extension enkia.tokyo-night >/dev/null 2>&1 \
        && log "✓ $label extension enkia.tokyo-night" \
        || warn "failed to install enkia.tokyo-night in $label (non-fatal)"
    fi
  else
    warn "$cli CLI missing — skipping Tokyo Night extension install for $label"
  fi
  merge_json_fragment "$base/settings.json"    "$REPO/cursor/settings.json.fragment"
  merge_json_fragment "$base/keybindings.json" "$REPO/cursor/keybindings.json.fragment"
}

main() {
  log "dream-terminal install starting (backup: $BACKUP)"
  ensure_backup_dir

  # Phase 3a — Ghostty (config + CLI symlink)
  link_ghostty_cli
  symlink_with_backup "$REPO/ghostty/config"          "$HOME/.config/ghostty/config"
  # Phase 3b — Starship
  symlink_with_backup "$REPO/starship/starship.toml"  "$HOME/.config/starship.toml"
  # Phase 3c — Hyper (config only; plugin removal below)
  symlink_with_backup "$REPO/hyper/.hyper.js"         "$HOME/.hyper.js"

  # Phase 3c follow-up — remove dead plugin
  local hdrac="$HOME/.hyper_plugins/node_modules/hyper-dracula"
  if [[ -d "$hdrac" ]]; then
    if [[ "$DRY_RUN" == "--dry-run" ]]; then
      log "would remove stale $hdrac"
    else
      mkdir -p "$BACKUP/.hyper_plugins/node_modules"
      cp -a "$hdrac" "$BACKUP/.hyper_plugins/node_modules/hyper-dracula"
      rm -rf "$hdrac"
      log "removed stale hyper-dracula plugin"
    fi
  else
    log "✓ hyper-dracula already absent"
  fi

  # Phase 4 — Shell fragments + .zshrc mutation
  install_omz_custom_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions.git
  install_omz_custom_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
  install_omz_custom_plugin zsh-completions         https://github.com/zsh-users/zsh-completions.git
  remove_zinit_block
  remove_spaceship_theme
  ensure_zshrc_block

  # Phase 5 — Cursor + VSCode merge (same fragments; VSCode is the parent schema)
  align_ide "Cursor" "Cursor" "cursor"
  align_ide "VSCode" "Code"   "code"

  log "done. backup: $BACKUP"
  log "next: quit and relaunch Ghostty / Hyper / Cursor / VSCode to pick up changes."
}

main "$@"
