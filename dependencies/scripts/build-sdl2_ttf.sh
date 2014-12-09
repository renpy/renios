#!/bin/bash

. $(dirname $0)/utils.sh

set -x

if [ ! -f $CACHEROOT/SDL2_ttf-$SDL2_TTF_VERSION.tar.gz ]; then
    echo 'Downloading SDL2_ttf source'
    curl -L https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$SDL2_TTF_VERSION.tar.gz > $CACHEROOT/SDL2_ttf-$SDL2_TTF_VERSION.tar.gz
fi

# Clean any previous extractions,
rm -rf $TMPROOT/SDL2_ttf-$SDL2_TTF_VERSION
# then extract SDL2_ttf source to cache directory
echo 'Extracting SDL2_ttf source'
try tar xzf $CACHEROOT/SDL2_ttf-$SDL2_TTF_VERSION.tar.gz -C $TMPROOT # 2>&1 >/dev/null
try pushd $TMPROOT/SDL2_ttf-$SDL2_TTF_VERSION


for i in SDL_ttf.c; do
    try $ARM_REAL_CC $ARM_CFLAGS -I$BUILDROOT/include/SDL2 -I$BUILDROOT/include/freetype -c $i
done

rm $BUILDROOT/lib/libSDL2_ttf.a
try $ARM_AR rcs $BUILDROOT/lib/libSDL2_ttf.a *.o
try cp -a SDL_*.h $BUILDROOT/include/SDL2

try popd
