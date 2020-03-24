#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh
source $DIR/funcs.sh

# Environment checks
check_root
check_archlinux

# Basic connection, time and keyboard setup
check_connection
_ loadkeys $KEYMAP
_ timedatectl set-ntp true

# Make partitions, format disks and mount
partition $DISK

# Set mirrors
mirror_setup

# Install Arch
_ pacstrap /mnt base base-devel linux linux-firmware sudo

# Configure the system
_ genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and preparation
_ mkdir /mnt/scripts
_ cp -r $DIR/* /mnt/scripts
_ arch-chroot /mnt /bin/bash -c "bash /scripts/base_chroot.sh"
