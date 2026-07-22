# lsd
alias ls='lsd'
alias ll='ls -la'

# Zoxide
eval "$(zoxide init zsh)"

# Starship
eval "$(starship init zsh)"

# Mise
eval "$(/opt/homebrew/bin/mise activate zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
