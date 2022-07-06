#!/usr/bin/env bash

if [[ "$1" == "" ]]; then
	printf "Enter 'vm' or 'vanilla': "
	read ktype
else
	ktype="$1"
fi

for pkg in $(ls src | grep -v linux); do
	sudo sgma build $pkg
done

sudo sgma build linux-${ktype}
sudo sgma build linux-firmware
