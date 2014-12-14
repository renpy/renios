#!/bin/bash

set -xe

build () {
     ./scripts/build.sh $1 
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
build pygame
build renpy
build final

popd
