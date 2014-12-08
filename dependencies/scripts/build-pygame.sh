#!/bin/bash

. $(dirname $0)/utils.sh

export PYGAME_SDL2_ROOT="${PYGAME_SDL2_ROOT:-/Users/tom/ab/pygame_sdl2}"

if [ ! -d "$PYGAME_SDL2_ROOT" ]; then
    echo "Please set PYGAME_SDL2_ROOT to point to pygame_sdl2."
    exit 1
fi

try pushd $PYGAME_SDL2_ROOT

# Set environment variables for Python module cross-compile
OLD_CC="$CC"
OLD_CFLAGS="$CFLAGS"
OLD_LDSHARED="$LDSHARED"
export CC="$ARM_CC"
export CFLAGS="$ARM_CFLAGS"
export CFLAGS="$CFLAGS -I$BUILDROOT/include -I$BUILDROOT/include/SDL2"
export LDSHARED="$RENIOSDEPROOT/scripts/liblink"

HOSTPYTHON="$RENIOSDEPROOT/tmp/Python-$PYTHON_VERSION/hostpython"

echo 'Configuring pygame_sdl2 source'
export PYGAME_SDL2_IOS=1
# try $HOSTPYTHON config.py 2>&1 >/dev/null

export PYGAME_SDL2_EXCLUDE="pygame_sdl2.mixer pygame_sdl2.mixer_music"
export PYGAME_SDL2_INSTALL_HEADERS=1

echo 'Building pygame_sdl2'
try $HOSTPYTHON -OO setup.py \
    build_ext -g -b build/lib.$PYARCH -t build/tmp.$PYARCH \
    install -O2 --root $DESTROOT
    
echo $DESTROOT


echo "Linking and deduplicating pygame_sdl2 libraries"
rm -rf $BUILDROOT/lib/libpygame.a
ls build/lib.$PYARCH
try $RENIOSDEPROOT/scripts/biglink $BUILDROOT/lib/libpygame.a build/lib.$PYARCH/pygame_sdl2
# bd=$TMPROOT/pygame-${PYGAME_VERSION}release/build/lib.macosx-*/pygame
# try $RENIOSDEPROOT/scripts/biglink $BUILDROOT/lib/libpygame.a $bd

deduplicate $BUILDROOT/lib/libpygame.a

rm -Rf "$BUILDROOT/python/lib/python2.7/site-packages/pygame_sdl2" 
rm -Rf "$BUILDROOT/include/pygame_sdl2"
cp -R "$DESTROOT/usr/local/lib/python2.7/site-packages/pygame_sdl2" "$BUILDROOT/python/lib/python2.7/site-packages"
cp -R "$DESTROOT/usr/local/include/python2.7/pygame_sdl2" "$BUILDROOT/include"
ls "$BUILDROOT/python/lib/python2.7/site-packages/pygame_sdl2" 

export CC="$OLD_CC"
export CFLAGS="$OLD_CFLAGS"
export LDSHARED="$OLD_LDSHARED"

popd # pygame

