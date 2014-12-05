#!/bin/bash

. $(dirname $0)/utils.sh


# Download Python if necessary
if [ ! -f $CACHEROOT/SDL2_gfx-$SDL2_GFX_VERSION.tar.gz ]; then
    echo 'Downloading SDL2_gfx source'
    curl -L http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$SDL2_GFX_VERSION.tar.gz > $CACHEROOT/SDL2_gfx-$SDL2_GFX_VERSION.tar.gz
fi

# Clean any previous extractions,
rm -rf $TMPROOT/SDL2_gfx-$SDL2_GFX_VERSION
# then extract SDL2_gfx source to cache directory
echo 'Extracting SDL2_gfx source'
try tar xzf $CACHEROOT/SDL2_gfx-$SDL2_GFX_VERSION.tar.gz -C $TMPROOT # 2>&1 >/dev/null
try pushd $TMPROOT/SDL2_gfx-$SDL2_GFX_VERSION

echo 'Building SDL2_gfx'

for i in *.c; do
    try $ARM_REAL_CC $ARM_CFLAGS -I$BUILDROOT/include/SDL2 -c $i
done

try $ARM_AR rcs $BUILDROOT/lib/libSDL2_gfx.a *.o
try cp -a SDL2_*.h $BUILDROOT/include/SDL2

try popd
