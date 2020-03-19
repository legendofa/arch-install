#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh
source $DIR/funcs.sh

check_connection

if [ ! -f "./$PROG" ]; then
	echo $LOGO "Please specify the path of the list of programms to install."
	exit 1
fi

while read p; do
	SEARCH_RESULT="$(${AURHELPER} -Ss $p)"
	if [ -n "$SEARCH_RESULT" ]; then
		$AURHELPER -Qi $p > /dev/null
		if [ $? -eq 1 ]; then
			aur_package_install $USERNAME $AURHELPER $p
			if [ $? -eq 1 ]; then
				print_block_color "Installation of" $p "failed, please install manually."
				lines ./install.log "Installation of" $p "failed, please install manually."
			else
				print_block_color "Installation of" $p "complete."
			fi
		else
			print_color "Pkg:" $p "is already installed."
		fi
	else
		print_color "Pkg:" $p "is not in the repo."
	fi
done <$PROG
