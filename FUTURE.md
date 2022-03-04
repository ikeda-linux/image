# Musl-cross-make (?)
```sh
ensure_musl() {
    printsection "Checking MUSL source"

    if [ ! -d musl-cross-make ]; then
        git clone https://github.com/richfelker/musl-cross-make
    else
        pushd musl-cross-make && git pull && popd
    fi
}

musl() {
    printsection "Making MUSL"
    ensure_musl

    FP="$PWD/musl-out"
    cp musl.config.mak musl-cross-make/config.mak
    sed -i "s|SOMEPATHHERE|$FP|g" musl-cross-make/config.mak

    if [ ! -d musl-out ]; then
        mkdir musl-out
        pushd musl-cross-make
        make -j${cores}
        make install
        popd
    else
        echo "Not rebuilding MUSL stuff"
    fi

}
```