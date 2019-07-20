#           ---
#     GaugeK's zshrc
#  gitlab.com/GaugeK/dots
#           ---
bindkey '^E' end-of-line              # [Ctrl-E] - Jump to the end of the line
bindkey '^[[P' delete-char            # [Delete] - Delete character under cursor
bindkey '^[[4~' end-of-line           # [End] - Go to end of line
bindkey '^[[3~' delete-char           # [Delete] - Delete character under cursor
bindkey '^A' beginning-of-line        # [Ctrl-A] - Jump to the start of the line
bindkey '^[[1;5C' forward-word        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word       # [Ctrl-LeftArrow] - move backward one word
bindkey '^[[H' beginning-of-line      # [Home] - Go to beginning of line
bindkey '^?' backward-delete-char     # [Backspace] - Delete backward
bindkey '^[[5~' up-line-or-history    # [PageUp] - Up a line of history
bindkey '^[[6~' down-line-or-history  # [PageDown] - Down a line of history
bindkey '^[[Z' reverse-menu-complete  # [Shift-Tab] - move through the completion menu backwards
bindkey '^r' history-incremental-search-backward  # [Ctrl-r] - Search backward incrementally for a string.

#     ---
#   History
#     ---
HISTSIZE=999999
SAVEHIST=999999
HISTFILE="$HOME/.config/zsh_history"
setopt hist_verify             # Show command with history expansion to user before running it
setopt share_history           # Share command history data
setopt extended_history        # Record timestamp of command in HISTFILE
setopt hist_ignore_dups        # Ignore duplicated commands history list
setopt inc_append_history      # Add commands to HISTFILE in order of execution
setopt hist_expire_dups_first  # Delete duplicates first when HISTFILE size exceeds HISTSIZE

# Arrow keys search history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

#        ---
#   Autocompletion
#        ---
setopt auto_menu         # Show completion menu on successive tab press
setopt always_to_end     # Move cursor to end of word if completed in-word
setopt complete_in_word
ZSH_CACHE_DIR=$HOME/.cache/zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR
autoload -U compinit && compinit -u -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

#       ---
#   Shell Theme
#       ---
setopt prompt_subst
color="4"
[[ $color = 1 ]] && false="3" || false="1"
PROMPT=$'%(?.%{\e[3${color}m%}.%{\e[3${false}m%})%(!.#.>)%{\e[0m%} '
export SUDO_PROMPT=$'\e[34m[sudo]\e[95m password for %p:\e[0m '   # Colourful sudo prompt

#        ---
#   Miscellaneous
#        ---
set -k                     # Allow comments in shell
setopt auto_cd             # cd by just typing the directory name
unsetopt flowcontrol       # Disable Ctrl-S + Ctrl-Q
unsetopt menu_complete     # Do not autoselect the first completion entry
source ~/.config/aliases   # Aliases

# vim: ft=sh
