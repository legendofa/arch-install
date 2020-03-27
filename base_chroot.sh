#!/bin/bash

# Stop script on exit 1
set -e
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh
source $DIR/funcs.sh

# Set mirrors
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
_ sed -i -e 's/MODULES=()/MODULES=(ext4)/g' /etc/mkinitcpio.conf
_ sed -i -e 's/HOOKS=(/HOOKS=(systemd keyboard sd-vconsole sd-encrypt /g' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Bootloader
package_install grub
package_install efibootmgr
_ rm -f /etc/fstab
_ grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
lines /etc/default/grub "GRUB_TIMEOUT=.5"
lines /etc/default/grub "GRUB_CMDLINE_LINUX=\"cryptdevice=${DISK}2:luks:allow-discards\""
_ grub-mkconfig -o /boot/grub/grub.cfg

# Enable swap in swapfile
package_install systemd-swap
_ sed "s/swapfc_enabled=0/swapfc_enabled=1/g" /etc/systemd/swap.conf
_ systemctl enable systemd-swap

# Create user
if [ ! $(id -u "$USERNAME") ]; then
	_ useradd -m $USERNAME -g wheel
fi
_ chpasswd <<< "${USERNAME}:$PASSWORD"

# Allow user to run sudo without password
new_permissions "%wheel ALL=(ALL) NOPASSWD: ALL"

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
_ sudo -u $USERNAME bash $INSTALLATION
system_update

# Enable services
_ systemctl daemon-reload
for i in "${SERVICES[@]}"
do
   _ systemctl enable $i
done

# Set X11 keymap
_ lines /home/$USERNAME/.xinitrc "setxkbmap -layout $KEYMAP"

# Changing sudoers file
new_permissions "%wheel ALL=(ALL) ALL #ARCH
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/packer -Syu,/usr/bin/packer -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/yay,/usr/bin/pacman -Syyuw --noconfirm"
