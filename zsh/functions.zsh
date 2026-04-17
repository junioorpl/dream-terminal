# dream-terminal — functions
# Sourced from ~/.zshrc. Requires: fd, fzf, bat, jq.
# BRAIN_DIR defaults to $HOME/cabral-dev/brain; override in your shell env.
: "${BRAIN_DIR:=$HOME/cabral-dev/brain}"

# Obsidian launcher — opens a path (or fuzzy-picks a note) in the Obsidian app.
obsidian() {
  local target="${1:-$BRAIN_DIR}"
  if [[ ! -e "$target" ]]; then
    [[ -d "$BRAIN_DIR" ]] || { echo "BRAIN_DIR not found: $BRAIN_DIR"; return 1; }
    target=$(fd -e md . "$BRAIN_DIR" | fzf --query="$1" -1 -0)
  fi
  [[ -n "$target" ]] && open -a "Obsidian" "$target"
}

# Open a specific brain note in Obsidian via URI scheme. Vault name is
# derived from the BRAIN_DIR basename — Obsidian must have that vault registered.
bn() {
  [[ -d "$BRAIN_DIR" ]] || { echo "BRAIN_DIR not found: $BRAIN_DIR"; return 1; }
  local pick
  pick=$(fd -e md . "$BRAIN_DIR" \
    | fzf --query="$1" --preview='bat --color=always {}' --preview-window=right:60%)
  [[ -z "$pick" ]] && return
  local rel="${pick#$BRAIN_DIR/}"
  rel="${rel%.md}"
  local vault
  vault="$(basename "$BRAIN_DIR")"
  open "obsidian://open?vault=${vault}&file=$(printf '%s' "$rel" | jq -sRr @uri)"
}

# AI prompt launcher — fuzzy pick from $BRAIN_DIR/prompts + copy to clipboard.
aip() {
  [[ -d "$BRAIN_DIR/prompts" ]] || { echo "BRAIN_DIR/prompts not found: $BRAIN_DIR/prompts"; return 1; }
  local pick
  pick=$(fd -e md . "$BRAIN_DIR/prompts" \
    | fzf --query="$1" --preview='bat --color=always {}')
  [[ -z "$pick" ]] && return
  pbcopy < "$pick" && echo "✓ copied: $(basename "$pick" .md)"
}
