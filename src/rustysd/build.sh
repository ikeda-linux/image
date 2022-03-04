#!/usr/bin/env bash

set -e

src="$(pwd)/src"
out="$(pwd)/out"
dir="$(pwd)/."
ver="n/a"

inf () {
    echo "==> \033[1;32m$1\033[0m"
}

build () {
    # I would love to not clone out of tree, but for some reason that's the only way it works
    
    if [[ ! -d ~/rustysd ]]; then
        git clone git@git.tar.black:ikeda/rustysd.git ~/rustysd
    else
        pushd ~/rustysd && git pull && popd
    fi

    pushd ~/rustysd

    cargo build --target=x86_64-unknown-linux-musl --release
    
    popd

    mkdir -p ${out}/overlay/bin
    cp ~/rustysd/target/x86_64-unknown-linux-musl/release/rustysd ${out}/overlay/bin/.
    cp ~/rustysd/target/x86_64-unknown-linux-musl/release/rsdctl ${out}/overlay/bin/.
}

clean () {
    inf "Getting rid of build artifacts..."
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