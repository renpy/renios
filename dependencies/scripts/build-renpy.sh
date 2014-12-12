#!/bin/bash

. $(dirname $0)/utils.sh

export RENPY_ROOT="${RENPY_ROOT:-/Users/tom/ab/renpy}"

if [ ! -d "$RENPY_ROOT" ]; then
    echo "Please set RENPY_ROOT to point to renpy."
    exit 1
fi

try pushd $RENPY_ROOT/module

# Set environment variables for Python module cross-compile
OLD_CC="$CC"
OLD_CFLAGS="$CFLAGS"
OLD_LDSHARED="$LDSHARED"
export CC="ccache $ARM_CC"
export CFLAGS="$ARM_CFLAGS"
export CFLAGS="$CFLAGS -I$BUILDROOT/include -I$BUILDROOT/include/SDL2 -I$BUILDROOT/include/freetype"
export LDSHARED="$RENIOSDEPROOT/scripts/liblink"

HOSTPYTHON="$RENIOSDEPROOT/tmp/Python-$PYTHON_VERSION/hostpython"

echo 'Configuring renpy source'
export RENPY_IOS=1
export RENPY_CYTHON=cython


echo 'Building renpy'
rm -Rf build/lib.$PYARCH
rm -Rf build/tmp.$PYARCH


try $HOSTPYTHON -O setup.py \
    build_ext -g -b build/lib.$PYARCH -t build/tmp.$PYARCH \
    install -O2 --root $DESTROOT

try pushd build/lib.$PYARCH

for i in $(find . -name \*.so); do
  try mkdir -p "$DESTROOT/usr/local/lib/python2.7/site-packages/$(dirname $i)"
  try cp $i "$DESTROOT/usr/local/lib/python2.7/site-packages/$i"
done

try popd

echo "Linking and deduplicating renpy libraries"

rm -rf $BUILDROOT/lib/librenpy.a
try $RENIOSDEPROOT/scripts/biglink $BUILDROOT/lib/librenpy.a $(find build/lib.$PYARCH -type d)
try deduplicate $BUILDROOT/lib/librenpy.a

rm -Rf "$BUILDROOT/python/lib/python2.7/site-packages/renpy" 
cp -R "$DESTROOT/usr/local/lib/python2.7/site-packages/renpy" "$BUILDROOT/python/lib/python2.7/site-packages"
cp -R "$DESTROOT/usr/local/lib/python2.7/site-packages/_renpy.so" "$BUILDROOT/python/lib/python2.7/site-packages"

export CC="$OLD_CC"
export CFLAGS="$OLD_CFLAGS"
export LDSHARED="$OLD_LDSHARED"

popd

