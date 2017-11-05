#!/bin/bash

. $(dirname $0)/utils.sh

OPENSSL_VERSION=1.0.2m

set -x

if [ ! -f $CACHEROOT/openssl-$OPENSSL_VERSION.tar.gz ]; then
  echo 'Downloading openssl sources'
  try curl -L https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz > $CACHEROOT/openssl-$OPENSSL_VERSION.tar.gz
fi

if [ ! -d $TMPROOT/openssl-$OPENSSL_VERSION ]; then
    try rm -rf $TMPROOT/openssl-$OPENSSL_VERSION
    try tar xzf $CACHEROOT/openssl-$OPENSSL_VERSION.tar.gz
    mv openssl-$OPENSSL_VERSION $TMPROOT

    pushd $TMPROOT/openssl-$OPENSSL_VERSION
    try patch -p0 < $RENIOSDEPROOT/patches/openssl.diff
    popd
fi

export PATH="$(dirname $0):$PATH"

echo "Configuring openssl"

pushd $TMPROOT/openssl-$OPENSSL_VERSION

export CC="opensslcc.sh $ARM_CC $ARM_CFLAGS" AR="$ARM_AR" LD="opensslcc.sh $ARM_LD $ARM_LDFLAGS"

try ./Configure --prefix=$BUILDROOT -fPIC no-asm no-shared iphoneos-cross

rm -Rf "$BUILDROOT/ssl"

echo "Building openssl"
try make clean
try make
try make install

popd
