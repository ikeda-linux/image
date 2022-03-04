#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="git"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Setting up execs"
    mkdir -p ${out}/overlay/usr/bin

    # nofetch
    wget https://git.tar.black/notools/nofetch/-/raw/master/nofetch
    chmod +x nofetch
    mv nofetch ${out}/overlay/usr/bin

    #notop
    wget https://git.tar.black/notools/notop/-/raw/master/notop
    chmod +x notop
    mv notop ${out}/overlay/usr/bin
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf ${src}/* ${src}/.* > /dev/null 2>&1
}

permissions () {
    inf "Setting correct permissions..."
    chown -R root:root ${out}/
    chmod -R 777 ${out}/
    chmod +x ${out}/overlay/usr/bin/*
}

main () {
    get
    clean
    permissions
    exit 0
}

main