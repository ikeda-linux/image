#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

build () {
    mkdir -p ${out}/overlay
    mkdir -p ${out}/overlay/usr/{sbin,bin} ${out}/overlay/bin ${out}/overlay/sbin ${out}/overlay/boot
    mkdir -p ${out}/overlay/{dev,etc,home,lib,mnt,opt,proc,srv,sys,run}
    mkdir -p ${out}/overlay/var/{lib,lock,log,run,spool,cache}
    install -d -m 0750 ${out}/overlay/root
    install -d -m 1777 ${out}/overlay/tmp
    mkdir -p ${out}/overlay/usr/{include,lib,share,src,local}

    # :yea:
    cp -rv ${dir}/configs/* ${out}/overlay/.

    # this is weird but *shrug* it was in the old build script
    chmod -R -x ${out}/overlay/etc/*
    chmod +x ${out}/overlay/etc/startup
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf ${src}/* ${src}/.* > /dev/null 2>&1
}

main () {
    build
    clean
    exit 0
}

main