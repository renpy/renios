#!/bin/bash

. $(dirname $0)/utils.sh

set -x

if [ ! -f $CACHEROOT/zlib-$ZLIB_VERSION.tar.gz ]; then
  echo 'Downloading zlib source'
  try curl -L http://zlib.net/zlib-$ZLIB_VERSION.tar.gz > $CACHEROOT/zlib-$ZLIB_VERSION.tar.gz
fi

try rm -rf $TMPROOT/zlib-$ZLIB_VERSION
echo 'Extracting zlib source'
try tar xvzf $CACHEROOT/zlib-$ZLIB_VERSION.tar.gz -C $TMPROOT # 2>&1 >/dev/null

pushd $TMPROOT/zlib-$ZLIB_VERSION

echo 'Configuring zlib'
CC="$ARM_CC" AR="$ARM_AR" LDFLAGS="$ARM_LDFLAGS" CFLAGS="$ARM_CFLAGS" \
    try ./configure --prefix=$DESTROOT --static 
     # 2>&1 >/dev/null
try make clean 2>&1 >/dev/null

echo 'Building zlib'
try make 2>&1 >/dev/null
try make install 2>&1 >/dev/null

popd

echo 'Moving zlib build products into place'
try cp $DESTROOT/lib/libz.a $BUILDROOT/lib
try cp -a $DESTROOT/include/* $BUILDROOT/include

