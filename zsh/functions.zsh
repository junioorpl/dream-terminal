# dream-terminal — functions
# Sourced from ~/.zshrc. Requires: fd, fzf, bat, jq.

# Obsidian launcher — mirrors `cursor <path>` pattern
obsidian() {
  local target="${1:-$HOME/cabral-dev/brain}"
  if [[ ! -e "$target" ]]; then
    target=$(fd -e md . "$HOME/cabral-dev/brain" | fzf --query="$1" -1 -0)
  fi
  [[ -n "$target" ]] && open -a "Obsidian" "$target"
}

# Open a specific brain note in Obsidian via URI scheme (vault: brain)
bn() {
  local pick
  pick=$(fd -e md . "$HOME/cabral-dev/brain" \
    | fzf --query="$1" --preview='bat --color=always {}' --preview-window=right:60%)
  [[ -z "$pick" ]] && return
  local rel="${pick#$HOME/cabral-dev/brain/}"
  rel="${rel%.md}"
  open "obsidian://open?vault=brain&file=$(printf '%s' "$rel" | jq -sRr @uri)"
}

# AI prompt launcher — fuzzy pick + copy to clipboard
aip() {
  local pick
  pick=$(fd -e md . "$HOME/cabral-dev/brain/prompts" \
    | fzf --query="$1" --preview='bat --color=always {}')
  [[ -z "$pick" ]] && return
  pbcopy < "$pick" && echo "✓ copied: $(basename "$pick" .md)"
}

# Preserved legacy helpers — same behavior as pre-migration .zshrc
sp()      { cursor "$HOME/signpost/$1"; }
m4()      { cursor "$HOME/macfor/$1"; }
fc()      { cursor "$HOME/fcamara/$1"; }
creatr()  { cursor "$HOME/study/clip-creatr-next"; }
pull()    { git stash && git pull && git stash apply; }
commit()  { git commit -m "$1"; }
merge-master()  { git stash && git checkout master  && git pull && git checkout "$1" && git merge master; }
merge-main()    { git stash && git checkout main    && git pull && git checkout "$1" && git merge main; }
merge-develop() { git stash && git checkout develop && git pull && git checkout "$1" && git merge develop; }
