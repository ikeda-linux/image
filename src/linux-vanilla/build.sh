#!/usr/bin/env bash

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="5.16.12"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

get () {
    inf "Getting source..."
    wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${ver}.tar.xz
    tar -xvf linux-${ver}.tar.xz -C ${src}/
    wget https://raw.githubusercontent.com/archlinux/svntogit-packages/eb49d8a9288e277c6e6fbfae5557ccba618b8f06/linux/trunk/config
    cp config ${src}/linux-${ver}/.config
}

build () {
    cd ${src}/linux-${ver}
    mkdir -p ${out}/overlay/boot
    mkdir -p ${out}/overlay/usr/
    inf "Building..."
    make olddefconfig
    make -j$(nproc)
    inf "Copying kernel binary..."
    cp ${src}/linux-${ver}/arch/x86_64/boot/bzImage ${out}/overlay/boot 
    inf "Installing modules..."
    make INSTALL_MOD_PATH="${out}/overlay/usr" INSTALL_MOD_STRIP=1 modules_install
    cd ${dir}
}

clean () {
    inf "Getting rid of build artifacts..."
    rm -rf config > /dev/null 2>&1
    rm -rf linux-*.tar.xz > /dev/null 2>&1
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