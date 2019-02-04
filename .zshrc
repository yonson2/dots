#     ~/.zshrc     #

# Syntax Hightlighting in shell
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# Colourful sudo prompt
export SUDO_PROMPT="$(tput setaf 4)[sudo]$(tput setaf 3) password for %p:$(tput setaf 7) "
export ZSH="/usr/share/oh-my-zsh"    # oh-my-zsh location
source $ZSH/oh-my-zsh.sh             # start oh-my-zsh
autoload -U promptinit; promptinit   # Start shell theme daemon
prompt pure                          # Shell theme
source ~/.zprofile                   # Execute commands from ~/.zprofile when zsh is opened
source ~/.aliases                    # Aliases
shortcuts                            # Generate directory / file shortcuts
source ~/.sc.sh                      # Add directory / file shortcuts to shell
stty -ixon                           # Disable Ctrl-S && Ctrl-Q
