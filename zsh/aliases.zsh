# dream-terminal — aliases
# Sourced from ~/.zshrc. Do NOT put secrets here.

# Claude Code CLI
alias cc='claude'
alias cs='claude-sandbox'

# Brain / Obsidian — list commands
alias bnl='ls "$HOME/cabral-dev/brain/learnings/"'
alias bns='ls "$HOME/cabral-dev/brain/solutions/"'
alias bnd='ls "$HOME/cabral-dev/brain/decisions/"'
alias bnp='ls "$HOME/cabral-dev/brain/prompts/"'
alias bnmoc='ls "$HOME/cabral-dev/brain/maps/"'
alias brain='cursor "$HOME/cabral-dev/brain"'

# Modern CLI replacements
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first'
alias la='eza -la --icons --git --group-directories-first'
alias tree='eza --tree --icons --level=3'
alias catp='bat'
alias lg='lazygit'
