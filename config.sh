#!/bin/bash

# Empty newline at the bottom of PROG is needed
# Set PROG path without quotes
PROG=prog

# Installer visuals
LOGO="-->"
SPACING=""
COLOR='\033[0;36m'

# Installation medium
DISK="/dev/sdX"

LUKS_PASSWORD="Test"

WIFI_SETUP=0

# Mirrors
COUNTRYCODE="DE"

KEYMAP="de"

# Timezone
REGION="Europe"
CITY="Berlin"

LOCALE="en_US.UTF-8 UTF-8"

# Root and user password
PASSWORD="Test"

# Username
USERNAME="jeinzi"

AURHELPER="yay"

DISPLAY_MANAGER="sddm"

# Home directory repository
CONFIG_FILES="https://github.com/Jeinzi/arch-configuration"
INSTALLATION="/home/$USERNAME/.bin/install.sh"

# Services
declare -a SERVICES=("$DISPLAY_MANAGER" "NetworkManager" "autofs" "org.cups.cupsd.path")