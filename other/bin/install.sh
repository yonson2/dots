#!/bin/bash

dots="https://gitlab.com/GaugeK/dots.git"

pacman -Syyu --noconfirm --needed dialog archlinux-keyring

getuserandpass() {
	# Prompts user for new username an password.
	# Checks if username is valid and confirms passwd.
	export name=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	namere="^[a-z_][a-z0-9_-]*$"
	while ! [[ "${name}" =~ ${namere} ]]; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	while ! [[ ${pass1} == ${pass2} ]]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
}

adduserandpass() {
	# Adds user `$name` with password $pass1.
	dialog --infobox "Adding user \"$name\"..." 4 50
	useradd -m -g wheel -s /bin/bash "$name" &>/dev/null ||
	usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
	echo "$name:$pass1" | chpasswd
	unset pass1 pass2
}

putgitrepo() {
	# Downlods a gitrepo $1 and places the files in $2 only overwriting conflicts
	dir=$(mktemp -d)
	chown -R "$name":wheel "$dir"
	sudo -u "$name" git clone --depth 1 "$1" "$dir"/gitrepo &>/dev/null &&
	sudo -u "$name" mkdir -p "$2" &&
	sudo -u "$name" cp -rT "$dir"/gitrepo "$2"
}

###
### THE ACTUAL SCRIPT ###
###
### This is how everything happens in an intuitive format and order.
###

# Get and verify username and password.
getuserandpass

### The rest of the script requires no user input.

adduserandpass

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
echo -e "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

pacman --noconfirm --needed -S base-devel &>/dev/null



echo "Installing yay, an AUR helper"

[[ -f /usr/bin/yay ]] || (
cd /tmp
rm -rf /tmp/"yay"*
curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"yay".tar.gz &&
sudo -u "$name" tar -xvf "yay".tar.gz &>/dev/null &&
cd "yay" &&
 makepkg --noconfirm -si &>/dev/null
cd /tmp)


echo "Making sure the root user has sudoers permissions"

if ! grep "root ALL=(ALL) ALL" "/etc/sudoers" &>/dev/null; then
	echo "root ALL=(ALL) ALL" >> /etc/sudoers
fi

echo "Installing programs"
pacman -S --noconfirm --needed \
	git bspwm sxhkd xclip util-linux \
	transmission-cli \
	noto-fonts noto-fonts-cjk \
	xorg-server xorg-xdpyinfo xorg-xwininfo \
	xorg-xinit xorg-xkill xorg-xset \
	xorg-xprop xorg-xrandr xorg-xgamma \
	curl wget papirus-icon-theme \
	dosfstools exfat-utils \
	feh ffmpeg firefox-developer-edition \
	rofi zsh ntfs-3g \
	pulseaudio pulseaudio-alsa \
	scrot maim unrar unzip \
	wget xdotool xssstate youtube-dl \
	vlc mpv gimp inkscape \
	xf86-input-synaptics dunst \
	python xautolock playerctl \
	rsync acpi imagemagick neovim \
	zsh-completions compton mpd ncmpcpp \
	gcolor3 gnome-system-monitor \
	xsettingsd lxappearance ttf-fira-mono


for i in i3lock-color-git qview pulseaudio-ctl light-git lemonbar-xft-git transmission-remote-cli-git mpdris2; do
	sudo -u $name yay -S --noconfirm --needed $i
done

echo -e "installing dotfiles"

# Install the dotfiles in the user's home directory
mkdir -p "/home/$name/opt/"
putgitrepo "$dots" "/home/$name/opt/dots"

sudo -u $name bash "/home/$name/opt/dots/deploy"


# Get rid of the beep!
rmmod pcspkr
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

# This line, overwriting the `newperms` command above will allow the user to run
# serveral important commands, `shutdown`, `reboot`, updating, etc. without a password.
echo -e "%wheel ALL=(ALL) ALL\\n%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/packer -Syu,/usr/bin/packer -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/yay,/usr/bin/pacman -Syyuw --noconfirm, /usr/bin/kbdrate" >> /etc/sudoers


echo "Installing some fonts"

mkdir -p /usr/share/fonts/TTF
mkdir -p /usr/share/fonts/OTF

echo " - Iosevka"
curl -Ls https://github.com/be5invis/Iosevka/releases/download/v2.0.1/02-iosevka-term-2.0.1.zip -o /tmp/iosevka.zip
unzip -o /tmp/iosevka.zip -d /usr/share/fonts/TTF/ &>/dev/null

echo " - Roboto"
curl -Ls https://fonts.google.com/download?family=Roboto -o /tmp/Roboto.zip
unzip -o /tmp/Roboto.zip -d /usr/share/fonts/TTF/ &>/dev/null

echo " - Roboto Condensed"
curl -Ls https://fonts.google.com/download?family=Roboto%20Condensed -o /tmp/Roboto-Condensed.zip
unzip -o /tmp/Roboto-Condensed.zip -d /usr/share/fonts/TTF/ &>/dev/null

echo " - Regular nerd font"
curl -Ls https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Regular.zip -o /tmp/Regular.zip
unzip -o /tmp/Regular.zip -d /usr/share/fonts/TTF/ &>/dev/null


fc-cache -f



echo "Disabling mouse acceleration"
# Disable mouse acceleration
if [ ! -f /etc/X11/xorg.conf.d/50-mouse-acceleration.conf ]; then
echo 'Section "InputClass"
    Identifier "My Mouse"
    MatchIsPointer "yes"
    Option "AccelerationProfile" "-1"
    Option "AccelerationScheme" "none"
    Option "AccelSpeed" "-0.75"
EndSection' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf
fi

# Touchpad stuff
echo "Making some minor touchpad modifications"
if [ ! -f /etc/X11/xorg.conf.d/70-synaptics.conf ]; then
echo 'Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
        Option "PalmDetect" "1"
        Option "PalmMinWidth" "8"
        Option "PalmMinZ" "100"
        Option "TapButton1" "1"
        Option "TapButton2" "3"
        Option "TapButton3" "2"
        Option "VertEdgeScroll" "on"
        Option "VertTwoFingerScroll" "on"
        Option "HorizEdgeScroll" "on"
        Option "HorizTwoFingerScroll" "on"
        Option "CircularScrolling" "on"
        Option "CircScrollTrigger" "2"
        Option "EmulateTwoFingerMinZ" "40"
        Option "EmulateTwoFingerMinW" "8"
        Option "CoastingSpeed" "0"
        Option "FingerLow" "30"
        Option "FingerHigh" "50"
        Option "MaxTapTime" "125"
EndSection
' >> /etc/X11/xorg.conf.d/70-synaptics.conf
fi

# Make sudo as normal user request the root user's password instead of that user's
#if [[ -z $(grep "Defaults rootpw" "/etc/sudoers") ]]; then
#	sed -i '/## Defaults specification/a Defaults rootpw' /etc/sudoers
#fi

echo "Enabling verbose package lists in pacman"
# One line per pkg pacman
sed -i "s/^#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf

echo "Enabling pacman loading bar in pacman"
# Pacman-like loading bar in pacman
if [[ -z $(grep ILoveCandy "/etc/pacman.conf") ]]; then
	sed -i '/# Misc options/a ILoveCandy' /etc/pacman.conf
fi

echo "Making pacman/yay colourful"
# Make pacman and yay colorful because why not.
sed -i "s/^#Color/Color/g" /etc/pacman.conf

# Make wifi faster on my card
#if [ -n /etc/modprobe.d/iwlwifi.conf ]; then
#	sh -c 'echo "options iwlwifi bt_coex_active=0 swcrypto=1 11n_disable=8" > /etc/modprobe.d/iwlwifi.conf'
#fi

echo "Shortening systemd timeout"
# Shorter timeout for systemd init
sed -i "s/^#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=15s/g" /etc/systemd/system.conf
sed -i "s/^#DefaultTimeoutstopSec=90s/DefaultTimeoutstopSec=10s/g" /etc/systemd/system.conf
systemctl daemon-reload

# Show details about boot while booting up
sed -i "s/quiet//" /etc/default/grub

echo "Enabling hibernation in grub/mkinitcpio"
# Enable hibernation (Probably won't work lmao)
if [[ -n $(grep swap /etc/fstab) ]]; then
	uswap="$(grep swap /etc/fstab | awk '{print $1}')"
fi

if [[ -n $(grep swap /etc/fstab) ]] && [[ -z $(grep "resume" "/etc/default/grub") ]]; then 
	sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/ $//" /etc/default/grub 
	sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/\"$//" /etc/default/grub 
	sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/$/ resume=${uswap} \"/" /etc/default/grub 

	grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
fi

if [[ -n $(grep swap /etc/fstab) ]] && [[ -z $(grep "resume" "/etc/mkinitcpio.conf") ]]; then 
	sed -i '/HOOKS=/s/\<filesystems\>/resume &/' /etc/mkinitcpio.conf
	mkinitcpio -p linux &>/dev/null
fi


# Enable Multilib repo if not already enabled
if [[ -n $(grep "\#\[multilib\]" /etc/pacman.conf) ]]; then
	echo "Enabling multilib repo"

	multiline="$(grep -n "\[multilib\]" /etc/pacman.conf |  tr -dc '0-9')"

	multiline2="$(( ${multiline} + 1 ))"

	sed -i "${multiline}s/\#\[multilib\]/\[multilib\]/" ~/pacman.conf

	sed -i "${multiline2}s/\#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/" ~/pacman.conf

fi

# Install the nvidia drivers
if [[ -n $(lspci | grep -i NVIDIA) ]]; then
	echo "Installing nvidia drivers"
	pacman -S --noconfirm nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
fi


echo "Downloading syntax highlighting plugin for zsh"
# Syntax highlighting in zsh 
git clone https://github.com/zdharma/fast-syntax-highlighting /usr/share/zsh/plugins/fast-syntax-highlighting

# Change default shell to zsh
chsh -s /bin/zsh $name

mkdir -p /home/$name/opt/git

echo "Installing st"
git clone https://github.com/gaugek/st.git /home/$name/opt/git/st &&
cd /home/$name/opt/git/st &&
make clean install &>/dev/null

echo "Installing stmessage to live-reload st"
git clone https://github.com/PaxPlay/thememenu /home/$name/opt/git/thememenu
cd /home/$name/opt/git/thememenu
make; cp stmessage /usr/local/bin/

echo "Installing tabbed"
git clone https://gitlab.com/gaugek/tabbed.git /home/$name/opt/git/tabbed &&
cd /home/$name/opt/git//tabbed &&
make clean install &>/dev/null

echo "Installing dmenu"
git clone https://gitlab.com/gaugek/dmenu.git /home/$name/opt/git/dmenu &&
cd /home/$name/opt/git/dmenu &&
make clean install &>/dev/null

echo "Installing wmutils"
git clone https://github.com/wmutils/core /home/$name/opt/git/wmutils;
	cd /home/$name/opt/git/wmutils; make clean install &>/dev/null

echo "Adding mpris support to mpv"
mkdir -p /etc/mpv/scripts
cd /tmp
git clone https://github.com/hoyon/mpv-mpris
cd /tmp/mpv-mpris
make &>/dev/null
cp mpris.so /etc/mpv/scripts/

echo "Adding scripts to send a notification when a usb is removed/inserted"
mkdir -p /usr/local/bin /usr/local/sounds;
curl -L https://github.com/GaugeK/dots/raw/master/other/bin/usb-remove -o /usr/local/bin/usb-remove;
curl -L https://github.com/GaugeK/dots/raw/master/other/bin/usb-insert -o /usr/local/bin/usb-insert;
curl -L https://github.com/GaugeK/dots/raw/master/other/bin/usb.rules -o /etc/udev/rules.d/usb.rules;
curl -L https://github.com/GaugeK/dots/raw/master/other/bin/usb-insert.wav -o /usr/local/sounds/usb-insert.wav;
curl -L https://github.com/GaugeK/dots/raw/master/other/bin/usb-remove.wav -o /usr/local/sounds/usb-remove.wav;

udevadm control --reload-rules;



echo "Installing vim-plug for neovim"
curl -fLo /home/$name/usr/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


echo "Changing a few things in journald to possibly speed up boot time"
sed -i \
	-e 's/^#Storage=.*/Storage=auto/' \
	-e 's/^#SystemMaxFiles=.*/SystemMaxFiles=5/' \
	-e 's/^#SystemMaxFileSize=.*/SystemMaxFileSize=1G/' \
	/etc/systemd/journald.conf



echo 'ZDOTDIR=$HOME/.config/zsh
[[ $UID = 0 ]] && source $HOME/etc/zsh/.zprofile' > /etc/zsh/zshenv
sed -i 's/load-module module-esound-protocol-unix/#load-module module-esound-protocol-unix/g' /etc/pulse/default.pa

echo "Telling linux to use no more than 10M ram for caching writes"
echo 10000000 > /proc/sys/vm/dirty_bytes

if ! grep XDG_CONFIG_HOME /etc/environment &>/dev/null; then
	echo '
XDG_CONFIG_HOME="$HOME/etc"
XDG_CACHE_HOME="$HOME/usr/cache"
XDG_DATA_HOME="$HOME/usr"' >> /etc/environment
fi

echo 'ZDOTDIR="$HOME/etc/zsh"' >> /etc/environment





echo 'finished'
