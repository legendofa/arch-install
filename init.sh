#!/bin/bash

# Initialize the installation
lsblk
pacman -Sy
pacman -S git --noconfirm
git clone http://192.168.178.67:8080/Julian/arch-install
git clone http://192.168.178.67:8080/Julian/Julian
pacman -Rns git --noconfirm
ls -la