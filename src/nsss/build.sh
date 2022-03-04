#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."

ver="0.2.0.1"

ska_ver="2.11.1.0"

MGCC="musl-gcc"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

build () {
    inf "Getting source..."
    wget http://skarnet.org/software/nsss/nsss-${ver}.tar.gz
    tar -xvf nsss-${ver}.tar.gz -C ${src}/

    cd ${src}/nsss-${ver}
    wget http://skarnet.org/software/skalibs/skalibs-${ska_ver}.tar.gz
    tar -xvf skalibs-${ska_ver}.tar.gz

    mkdir SKA
    cd SKA && PDIR=$(pwd) && cd ../
    
    cd skalibs-${ska_ver}
    CC="${MGCC}" ./configure --prefix=${PDIR}
    make -j$(nproc)
    make install

    cd ../

    mkdir -p ${out}/overlay/usr
    CC="${MGCC}" ./configure --prefix=${out}/overlay/usr --with-include=${PDIR}/include --with-sysdeps=${PDIR}/lib/skalibs/sysdeps
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
    build
    clean
    permissions
    exit 0
}

main