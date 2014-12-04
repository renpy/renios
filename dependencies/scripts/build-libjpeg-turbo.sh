#!/bin/bash

. $(dirname $0)/utils.sh

export PATH="$PATH:`pwd`"

if [ ! -f $CACHEROOT/libjpeg-turbo-$LIBJPEG_TURBO_VERSION.tar.gz ]; then
  echo 'Downloading libjpeg-turbo source'
  try curl -L http://downloads.sourceforge.net/project/libjpeg-turbo/$LIBJPEG_TURBO_VERSION/libjpeg-turbo-$LIBJPEG_TURBO_VERSION.tar.gz > $CACHEROOT/libjpeg-turbo-$LIBJPEG_TURBO_VERSION.tar.gz
fi

try rm -rf $TMPROOT/libjpeg-turbo-$LIBJPEG_TURBO_VERSION
echo 'Extracting libjpeg-turbo source'
try tar xjf $CACHEROOT/libjpeg-turbo-$LIBJPEG_TURBO_VERSION.tar.gz 2>&1 >/dev/null
try mv libjpeg-turbo-$LIBJPEG_TURBO_VERSION $TMPROOT

pushd $TMPROOT/libjpeg-turbo-$LIBJPEG_TURBO_VERSION

echo 'Configuring libjpeg-turbo'
try autoreconf -fiv 2>&1 >/dev/null

# Under Xcode 5, this compile fails if -O is set to anything other than 0.

# The simd assembly hasn't been ported to arm64. We live without it and hope
# the CPU is fast.
if [ "$RENIOSARCH" = "arm64" ] ; then

	try ./configure --prefix=$DESTROOT \
	  --with-jpeg8 \
	  --host="$ARM_HOST" \
	  --enable-static \
	  --disable-shared \
	  --without-simd \
	  CC="$ARM_REAL_CC" AR="$ARM_AR" \
	  CFLAGS="$ARM_CFLAGS" \
	  LDFLAGS="$ARM_LDFLAGS" \
	  CCASFLAGS="$ARM_CFLAGS" \
	  CPPFLAGS="$ARM_CFLAGS"
else

    try ./configure --prefix=$DESTROOT \
      --with-jpeg8 \
      --host="$ARM_HOST" \
      --enable-static \
      --disable-shared \
      CC="$ARM_REAL_CC" AR="$ARM_AR" \
      LDFLAGS="-no-integrated-as $ARM_LDFLAGS" \
      CFLAGS="-no-integrated-as $ARM_CFLAGS -O0" \
      CCASFLAGS="-no-integrated-as $ARM_CFLAGS" \
      CPPFLAGS="$ARM_CFLAGS"

            #        CFLAGS="-no-integrated-as $ARM_CFLAGS -O0" \

fi
    

try make clean 2>&1 >/dev/null
echo 'Building libjpeg-turbo'
try make 2>&1 >/dev/null
try make install 2>&1 >/dev/null

popd

echo 'Moving libjpeg-turbo build products into place'
try cp $DESTROOT/lib/libjpeg.a $BUILDROOT/lib

try cp $DESTROOT/include/jpeglib.h $BUILDROOT/include
try cp $DESTROOT/include/jconfig.h $BUILDROOT/include
try cp $DESTROOT/include/jerror.h $BUILDROOT/include
try cp $DESTROOT/include/jmorecfg.h $BUILDROOT/include
try cp $DESTROOT/include/jerror.h $BUILDROOT/include
