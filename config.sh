#!/bin/bash

# Empty newline at the bottom of PROG is needed
# Set PROG path without quotes
PROG=prog

# Installer visuals
LOGO="-->"
SPACING="~~~"
COLOR='\033[0;36m'

# Installation medium
DISK="/dev/vda"

# Mirrors
COUNTRYCODE="DE"

KEYMAP="de"

# Timezone
REGION="Europe"
CITY="Berlin"

LOCALE="en_EN.UTF-8 UTF-8"

# Root and user password
PASSWORD="Test"

# Username
USERNAME="julian"

AURHELPER="yay"

DISPLAY_MANAGER="sddm"

# Home directory repository
CONFIG_FILES="/post/julian"
INSTALLATION="/home/julian/bin/setup.sh"

# Services
declare -a SERVICES=("NetworkManager")