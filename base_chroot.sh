#!/bin/bash

# Stop script on exit 1
set -e
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh
source $DIR/funcs.sh

# Set mirrors
system_update
mirror_setup

# Time zone
_ ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
_ hwclock --systohc

# Localisation
lines /etc/locale.gen "$LOCALE"
lines /etc/locale.conf "LANG=${LOCALE/ */}"
_ locale-gen

# Network
package_install dhcpcd
_ dhcpcd

# Root password
_ chpasswd <<< "root:$PASSWORD"

# Configure mkinitcpio
_ sed -i "s/MODULES=()/MODULES=(ext4)/g" /etc/mkinitcpio.conf
_ sed -i "s/HOOKS=(base.*fsck)/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)/g" /etc/mkinitcpio.conf
_ mkinitcpio -p linux

# Bootloader
package_install grub
package_install efibootmgr
_ grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
lines /etc/default/grub "GRUB_TIMEOUT=.5"
lines /etc/default/grub "GRUB_CMDLINE_LINUX=\"cryptdevice=${DISK}2:luks_root\""
_ grub-mkconfig -o /boot/grub/grub.cfg

# Enable swap in swapfile
package_install systemd-swap
_ sed -i "s/swapfc_enabled=0/swapfc_enabled=1/g" /etc/systemd/swap.conf
_ systemctl enable systemd-swap

# Create user
if [ ! $(id -u "$USERNAME") ]; then
	_ useradd -m $USERNAME -g wheel
fi
_ chpasswd <<< "${USERNAME}:$PASSWORD"

# Allow user to run sudo without password
lines /etc/sudoers "%wheel ALL=(ALL) NOPASSWD: ALL"

# Setup yay
package_install wget
package_install curl
package_install git
package_install go-pie
manual_install $AURHELPER $USERNAME 
$AURHELPER -Syu

# Disable system beep
systembeep_off

# Install display manager
aur_package_install $USERNAME $AURHELPER $DISPLAY_MANAGER

# Install programs
_ bash $DIR/install.sh

# Install user configurations
_ rm -rf /temp
_ mkdir /temp
_ git clone $CONFIG_FILES /temp
_ chown -R $USERNAME /temp
_ chgrp -R wheel /temp
_ shopt -s dotglob nullglob
_ sudo -u $USERNAME cp -rf /temp/* /home/$USERNAME
_ shopt -u dotglob nullglob
_ rm -r /temp
_ chmod 755 /home/$USERNAME
_ sudo -u $USERNAME bash $INSTALLATION
system_update

# Enable services
_ systemctl daemon-reload
for i in "${SERVICES[@]}"
do
   _ systemctl enable $i
done

# Set X11 and console keymap
_ localectl set-keymap $KEYMAP

# Change sudoers permissions
_ sed -i "s/%wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: \/usr\/bin\/pacman -Syu, \/usr\/bin\/pacman -Syu --noconfirm/g" /etc/sudoers
lines /etc/sudoers "%wheel ALL=(ALL) ALL"