# lsd
alias ls='lsd'
alias ll='ls -la'

# Zoxide
alias cd='z'
eval "$(zoxide init zsh)"

# m2 local
export M2_LOCAL=~/.m2/repository

# GNU-sed
GSED=$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
export PATH=$GSED:$PATH

# Starship
eval "$(starship init zsh)"

# Mise
eval "$(/opt/homebrew/bin/mise activate zsh)"
