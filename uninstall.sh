#!/usr/bin/env bash
# uninstall.sh — restores files from the most recent dream-terminal backup
set -euo pipefail

REPO="$HOME/cabral-dev/dream-terminal"
BACKUP_ROOT="$HOME"

log()  { printf '\033[0;36m[dream]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[warn]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[0;31m[err]\033[0m  %s\n' "$*" >&2; }

latest="$(ls -dt "${BACKUP_ROOT}"/.dream-terminal-backup-* 2>/dev/null | head -1 || true)"
if [[ -z "$latest" ]]; then
  err "no backup directories found under ${BACKUP_ROOT}"
  exit 1
fi
log "restoring from $latest"

# Remove symlinks that point into the repo
find "$HOME" -maxdepth 4 -type l 2>/dev/null | while read -r link; do
  target="$(readlink "$link" 2>/dev/null || true)"
  case "$target" in
    "$REPO"/*) rm -f "$link"; log "unlinked $link" ;;
  esac
done

# Restore backed-up originals
(cd "$latest" && find . -type f -print0) | while IFS= read -r -d '' rel; do
  src="${latest}/${rel#./}"
  dst="${HOME}/${rel#./}"
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  log "restored $dst"
done

log "uninstall done — backup preserved at $latest"
