# Zsh config
export EDITOR="nvim"
export VISUAL="nvim"

# Aliases
alias ls="eza --icons"
alias cat="bat"
alias grep="rg"
alias f="fzf"

# Enable zoxide
eval "$(zoxide init zsh)"

# Enable Starship prompt
eval "$(starship init zsh)"

