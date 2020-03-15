#!/bin/bash

source config.sh
source funcs.sh

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
_ cp -r . /mnt/scripts
_ arch-chroot /mnt /bin/bash -c "cd /scripts && bash base_chroot.sh"
