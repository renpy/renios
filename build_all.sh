#!/bin/bash

set -e

builds="${1:-debug release}"
platforms="${2:-x86_64 armv7 arm64 i386}"

echo $builds
echo $platforms

build () {
     ./scripts/build.sh $1 "$builds" "$platforms"
}

build_once() {
    if [ ! -e ./build/built.$1 ] ; then
        build $1
        touch ./build/built.$1
    fi
}


root=$(dirname $0)
pushd $root/dependencies

build_once libffi
build_once python
build_once sdl
build_once libpng
build_once libjpeg-turbo
build_once fribidi
build_once freetype
build_once sdl2_ttf
build_once sdl2_image
build_once sdl2_gfx
build_once pyobjus
build_once ffmpeg
build iossupport
build pygame
build renpy
build final

popd
