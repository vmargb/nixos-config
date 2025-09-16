# Fish shell config
set -gx EDITOR nvim
set -gx VISUAL nvim

# Add ~/.local/bin to PATH
fish_add_path ~/.local/bin

# Aliases
alias ls="eza --icons"
alias cat="bat"
alias grep="rg"
alias f="fzf"

# Use zoxide for smarter cd
zoxide init fish | source

# Starship prompt
starship init fish | source
