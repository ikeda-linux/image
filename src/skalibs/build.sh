#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="2.11.1.0"

MGCC="musl-gcc"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    wget http://skarnet.org/software/skalibs/skalibs-${ver}.tar.gz
    tar -xvf skalibs-${ver}.tar.gz -C ${src}/
}

build () {
    cd ${src}/skalibs-${ver}
    mkdir -p ${out}/overlay/usr
    inf "Building..."
    CC="${MGCC}" ./configure --prefix=${out}/overlay/usr
    make -j$(nproc)
    make install
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf *.tar.gz > /dev/null 2>&1
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