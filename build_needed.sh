#!/usr/bin/env bash

for pkg in $(ls src | grep -v linux); do
	sudo sgma build $pkg
done

if [[ "$1" == "" ]]; then
	printf "Enter 'vm' or 'vanilla': "
	read ktype
else
	ktype="$1"
fi

sudo sgma build linux-${ktype}
