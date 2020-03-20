#!/bin/bash

# Initialize the installation
lsblk
mkdir /usb
mount /dev/sda1 /usb
pacman -Sy
pacman -S git --noconfirm
git clone http://192.168.178.67:8080/Julian/arch-install /usb
git clone http://192.168.178.67:8080/Julian/Julian /usb
git pull http://192.168.178.67:8080/Julian/arch-install /usb
git pull http://192.168.178.67:8080/Julian/Julian /usb
pacman -Rns git --noconfirm
cd /usb
ls -la