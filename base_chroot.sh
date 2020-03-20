#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh
source $DIR/funcs.sh

# Set mirrors
mirror_setup

# Time zone
_ ln -sf /usr/share/zoneinfo/$REGION/$CITY /etc/localtime
_ hwclock --systohc

# Localisation
lines /etc/locale.gen $LOCALE
lines /etc/locale.conf "LANG=${LOCALE/ */}"
_ locale-gen

# Network
package_install dhcpcd
_ dhcpcd

# Root password
_ chpasswd <<< "root:$PASSWORD"

# Bootloader
package_install grub
package_install efibootmgr
_ grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
lines /etc/default/grub "GRUB_TIMEOUT=.5"
_ grub-mkconfig -o /boot/grub/grub.cfg

# Enable swap in swapfile
package_install systemd-swap
_ sed "s/swapfc_enabled=0/swapfc_enabled=1/g" /etc/systemd/swap.conf
_ systemctl enable systemd-swap

# Create user
_ useradd -m $USERNAME -g wheel
_ chpasswd <<< "${USERNAME}:$PASSWORD"

# Allow user to run sudo without password
new_permissions "%wheel ALL=(ALL) NOPASSWD: ALL"

# Setup yay
package_install wget
package_install curl
package_install git
package_install go
manual_install $AURHELPER $USERNAME 
$AURHELPER -Syu

# Disable system beep
systembeep_off

# Install display manager
aur_package_install $USERNAME $AURHELPER $DISPLAY_MANAGER
systemctl enable "${DISPLAY_MANAGER}.service"

# Install user configurations
_ mkdir /post
_ mount /dev/sda1 /post
_ rm -r /temp
_ git clone $CONFIG_FILES /temp
_ sudo -u $USERNAME cp -r /temp/* /home/$USERNAME
_ sudo -u $USERNAME $(bash $INSTALLATION)
system_update

# Install programs
_ bash install.sh

# Enable services
_ systemctl daemon-reload
for i in "${SERVICES[@]}"
do
   _ systemctl enable $i
done

# Set X11 keymap
_ sudo -u $USERNAME localectl --no-convert set-x11-keymap $KEYMAP

# Changing sudoers file
new_permissions "%wheel ALL=(ALL) ALL #ARCH
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/packer -Syu,/usr/bin/packer -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/yay,/usr/bin/pacman -Syyuw --noconfirm"