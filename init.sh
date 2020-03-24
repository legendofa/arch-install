#!/bin/bash

# Initialize the installation
lsblk
pacman -Sy
pacman -S git --noconfirm && cd arch-install && git pull
# git clone http://192.168.178.67:8080/Julian/arch-install
ls -la