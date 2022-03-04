#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="6.2"

MGCC="musl-gcc"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    wget https://invisible-mirror.net/archives/ncurses/ncurses-${ver}.tar.gz
    tar -xvf ncurses-${ver}.tar.gz -C ${src}/
}

build () {
    cd ${src}/ncurses-${ver}
    mkdir -p ${out}/overlay/usr/{lib,share}
    inf "Building..."
    ./configure --prefix=${out}/overlay/usr --with-shared --without-debug
    make
    make install
    inf "Snatching termcap info from host"
    cp -rv /usr/lib/terminfo ${out}/overlay/usr/lib/.
    cp -rv /usr/share/terminfo ${out}/overlay/usr/share/.
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf ncurses-*.tar.xz > /dev/null 2>&1
    rm -rf ${src}/* ${src}/.* > /dev/null 2>&1
}

permissions () {
    inf "Setting correct permissions..."
    chown -R root:root ${out}/
    chmod -R 777 ${out}/
}

main () {
    get
    build
    clean
    permissions
    exit 0
}

main