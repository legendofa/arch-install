#!/bin/bash

# Stop script on exit 1
set -e
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh
source $DIR/funcs.sh

# Environment checks
check_root
check_archlinux

# Basic connection, time and keyboard setup
if [ $WIFI_SETUP -eq 1 ]; then
	wifi-menu
fi
check_connection
_ loadkeys $KEYMAP
_ timedatectl set-ntp true

# Make partitions, format disks and mount
partition $DISK

# Set mirrors
mirror_setup

# Install Arch
if [ ! -e /etc/arch-release ]; then
	_ pacstrap /mnt base base-devel linux linux-firmware sudo nano
fi

# Configure the system
_ rm -f /mnt/etc/fstab
_ genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and preparation
_ mkdir -p /mnt/scripts
_ cp -r $DIR/* /mnt/scripts
_ arch-chroot /mnt /bin/bash -c "bash /scripts/base_chroot.sh"
