#KDE as Desktop Session for openbox, for Qt themes
#if [[ $DESKTOP_SESSION="openbox" ]]; then
#export DESKTOP_SESSION="kde"
#export XDG_CURRENT_DESKTOP="KDE" 
#export KDE_SESSION_VERSION="5"
#fi

export QT_QPA_PLATFORMTHEME="qt5ct"

#Faster keyboard repeat rate
xset r rate 200 60 

#GTK Global menu
if [ -n "$GTK_MODULES" ]; then
    GTK_MODULES="${GTK_MODULES}:appmenu-gtk-module"
else
    GTK_MODULES="appmenu-gtk-module"
fi

if [ -z "$UBUNTU_MENUPROXY" ]; then
    UBUNTU_MENUPROXY=1
fi

export GTK_MODULES
export UBUNTU_MENUPROXY

#Default user
export DEFAULT_USER="gauge"

export PATH="$PATH:$(du "$HOME/bin/" | cut -f2 | tr '\n' ':'):$HOME/.local/bin"
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER="firefox"
export FILE="dolphin"

# less/man colors
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m' # reset underline
#if [ "$TTY" = "/dev/tty1" ]; then
#	pgrep -x openbox || exec startx
#fi
