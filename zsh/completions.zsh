# dream-terminal — zsh completions for custom functions

# Path-taking legacy helpers
_sp_complete() { _files -W "$HOME/signpost"; }
_m4_complete() { _files -W "$HOME/macfor"; }
_fc_complete() { _files -W "$HOME/fcamara"; }
compdef _sp_complete sp
compdef _m4_complete m4
compdef _fc_complete fc

# bn completion — list brain markdown notes minus .md extension
_bn_complete() {
  local -a notes
  notes=(${(f)"$(fd -e md . "$HOME/cabral-dev/brain" 2>/dev/null | sed "s|$HOME/cabral-dev/brain/||" | sed 's|\.md$||')"})
  _describe 'brain notes' notes
}
compdef _bn_complete bn

# aip completion — list brain/prompts entries minus .md
_aip_complete() {
  local -a prompts
  prompts=(${(f)"$(fd -e md . "$HOME/cabral-dev/brain/prompts" 2>/dev/null | xargs -n1 basename | sed 's|\.md$||')"})
  _describe 'prompts' prompts
}
compdef _aip_complete aip
