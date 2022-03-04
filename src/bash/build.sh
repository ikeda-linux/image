#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="5.1.8"

MGCC="musl-gcc"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    wget https://ftp.gnu.org/gnu/bash/bash-${ver}.tar.gz
    tar -xvf bash-${ver}.tar.gz -C ${src}/
}

build () {
    cd ${src}/bash-${ver}
    mkdir -p ${out}/overlay
    inf "Building..."
    CC="${MGCC} -static" ./configure --without-bash-malloc --prefix="${out}/overlay/" && make && make install 
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf bash-*.tar.xz > /dev/null 2>&1
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