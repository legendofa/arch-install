#!/bin/bash

# Feedback functions
color_string(){
	NO_COLOR="\033[0m"
	echo -en "${COLOR}$1${NO_COLOR}"
}
print_color(){
	echo -n $LOGO $1 " "; color_string $2; echo " " $3
}
print_block(){
	echo $SPACING
	echo $LOGO $1
	echo $SPACING
}
print_block_color(){
	echo $SPACING
	print_color $1 $2 $3
	echo $SPACING
}
_(){
	echo -en "\n${COLOR}$@\e[0;0m\n\n" 1>&2
	"$@"
}

# Basic gpt partition table for swapfile usage
partition(){
	_ parted --script $1 mklabel gpt
	_ parted --script $1 mkpart primary ext4 1MiB 260MiB
	_ parted --script $1 mkpart primary ext4 260MiB 100%
	_ mkfs.ext4 "${1}2"
	_ mount "${1}2" /mnt
	_ mkfs.fat -F32 "${1}1"
	_ mkdir /mnt/efi
	_ mount "${1}1" /mnt/efi
}

# Write functions
lines(){
	local target=$1
	echo -en "\n${COLOR}configuring $target\e[0;0m\n\n" 1>&2
	for x in $(seq 2 ${#}); do
		echo "${!x}" >> $target
	done
}
new_permissions(){
	_ sed -i "/#ARCH/d" /etc/sudoers
	_ echo "$* #ARCH" >> /etc/sudoers
}

# Installation functions
system_update(){
	_ pacman -Syu
}
mirror_setup(){
	system_update
	package_install reflector
	_ reflector --country $COUNTRYCODE --fastest 10 --protocol http --sort rate --save /etc/pacman.d/mirrorlist
}
package_install(){
	_ pacman -S $1 --noconfirm
}
manual_install(){
	_ [ -f "/usr/bin/$1" ] || (
	_ cd /tmp || exit
	_ rm -rf /tmp/"$1"*
	_ curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz
	_ sudo -u $2 tar -xvf "$1".tar.gz
	_ cd "$1"
	_ sudo -u $2 makepkg --noconfirm -si
	_ cd /tmp || return)
}
aur_package_install(){
	_ sudo -u $1 $2 -S --noconfirm $3
}

# Misc
systembeep_off(){
	_ rmmod pcspkr
	_ echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
}

# Hardware and software check
check_root(){
	if [[ "$(id -u)" != "0" ]]; then
		print_block "ERROR! You must execute the script as the root user."
		exit 1
	fi
}
check_archlinux(){
	if [[ ! -e /etc/arch-release ]]; then
		print_block "ERROR! You must execute the script on Arch Linux."
		exit 1
	fi
}
check_connection(){
	wget -q --spider 1.1.1.1
	if [ $? -eq 0 ]; then
		print_block "Internet connection established."
	else
		print_block "No internet, please connect."
		exit 1
	fi
}