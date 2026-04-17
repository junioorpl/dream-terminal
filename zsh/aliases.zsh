# dream-terminal — aliases
# Sourced from ~/.zshrc. Do NOT put secrets here.
# BRAIN_DIR defaults to $HOME/cabral-dev/brain; override in your shell env.
: "${BRAIN_DIR:=$HOME/cabral-dev/brain}"

# Claude Code CLI
alias cc='claude'
alias cs='claude-sandbox'

# Brain / Obsidian — list commands (no-op if BRAIN_DIR missing)
alias bnl='ls "$BRAIN_DIR/learnings/"'
alias bns='ls "$BRAIN_DIR/solutions/"'
alias bnd='ls "$BRAIN_DIR/decisions/"'
alias bnp='ls "$BRAIN_DIR/prompts/"'
alias bnmoc='ls "$BRAIN_DIR/maps/"'
alias brain='cursor "$BRAIN_DIR"'

# Modern CLI replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first'
alias la='eza -la --icons --git --group-directories-first'
alias tree='eza --tree --icons --level=3'
alias catp='bat'
alias lg='lazygit'
