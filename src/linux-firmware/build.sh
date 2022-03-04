#!/usr/bin/env bash

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="20211027"

srcurl="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-${ver}.tar.gz"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    wget ${srcurl} -O firmware.tgz
    tar -xvf firmware.tgz -C ${src}/
}

build () {
    cd ${src}/linux-firmware*
    mkdir -p ${out}/overlay/
    inf "Building..."
    make DESTDIR=${out}/overlay/ install
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf firmware.tgz > /dev/null 2>&1
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