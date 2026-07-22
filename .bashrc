# lsd
alias ls='lsd'
alias ll='lsd -la'

# Zoxide
eval "$(zoxide init bash)"

# Starship
eval "$(starship init bash)"

# Mise
eval "$(mise activate bash)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
