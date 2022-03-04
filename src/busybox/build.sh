#!/usr/bin/env bash

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="1.35.0"

# Gentoo is fucked so this *could(?)* be different on other hosts
MGCC="musl-gcc"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting busybox source..."
    wget https://busybox.net/downloads/busybox-${ver}.tar.bz2
    tar -xf busybox-${ver}.tar.bz2 -C ${src}/
}

build () {
    cp bb-config ${src}/busybox-${ver}/.config
    cd ${src}
    inf "Ensuring kernel headers..."
    if [ -d kernel-headers ]; then
        pushd kernel-headers && git pull && popd
    else
        git clone https://github.com/sabotage-linux/kernel-headers
    fi
    cd busybox-${ver}
    mkdir -p ${out}/overlay/usr/{sbin,bin}
    mkdir -p ${out}/overlay/{bin,sbin}
    inf "Building..."
    make CC=${MGCC} && cp .config ${dir}/bb-config

    inf "Installing"
    cp busybox ${out}/overlay/usr/bin/busybox
    pushd ${out}/overlay
    for util in $(./usr/bin/busybox --list-full); do
        ln -s /usr/bin/busybox $util
        echo "linked busybox to $util"

        # debug
        #echo "$util" >> ${dir}/things_linked.txt

    done
    popd
    cd ${dir}
    cp -r ${out}/overlay fuck-tar
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf busybox-*.tar.bz2 > /dev/null 2>&1
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