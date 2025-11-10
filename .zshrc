# Aliases
alias ls='lsd'
alias ll='ls -la'
alias cd='z'

# Required by Zoxide
eval "$(zoxide init zsh)"

# Java_HOME Java Version
#export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
#export JAVA_HOME=$(/usr/libexec/java_home -v 11)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
#export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# m2 local
export M2_LOCAL=~/.m2/repository

# GNU-sed
GSED=$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
export PATH=$GSED:$PATH
