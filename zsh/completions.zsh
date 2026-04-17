# dream-terminal — zsh completions for custom functions
: "${BRAIN_DIR:=$HOME/cabral-dev/brain}"

# bn completion — list brain markdown notes minus .md extension
_bn_complete() {
  [[ -d "$BRAIN_DIR" ]] || return 0
  local -a notes
  notes=(${(f)"$(fd -e md . "$BRAIN_DIR" 2>/dev/null | sed "s|$BRAIN_DIR/||" | sed 's|\.md$||')"})
  _describe 'brain notes' notes
}
compdef _bn_complete bn

# aip completion — list $BRAIN_DIR/prompts entries minus .md
_aip_complete() {
  [[ -d "$BRAIN_DIR/prompts" ]] || return 0
  local -a prompts
  prompts=(${(f)"$(fd -e md . "$BRAIN_DIR/prompts" 2>/dev/null | xargs -n1 basename | sed 's|\.md$||')"})
  _describe 'prompts' prompts
}
compdef _aip_complete aip
