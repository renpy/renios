#!/bin/bash

. $(dirname $0)/utils.sh

if [ ! -f $CACHEROOT/libpng-$LIBPNG_VERSION.tar.gz ]; then
  echo 'Downloading libpng source'
  echo http://downloads.sourceforge.net/project/libpng/libpng16/$LIBPNG_VERSION/libpng-$LIBPNG_VERSION.tar.gz

  try curl -L http://downloads.sourceforge.net/project/libpng/libpng16/$LIBPNG_VERSION/libpng-$LIBPNG_VERSION.tar.gz > $CACHEROOT/libpng-$LIBPNG_VERSION.tar.gz
fi

try rm -rf $TMPROOT/libpng-$LIBPNG_VERSION
echo 'Extracting libpng source'
try tar xzf $CACHEROOT/libpng-$LIBPNG_VERSION.tar.gz 2>&1 >/dev/null
try mv libpng-$LIBPNG_VERSION $TMPROOT

pushd $TMPROOT/libpng-$LIBPNG_VERSION

echo 'Building libpng'
try cp scripts/pnglibconf.h.prebuilt pnglibconf.h

SOURCE='png.c pngerror.c pngget.c pngmem.c pngpread.c pngread.c pngrio.c pngrtran.c pngrutil.c pngset.c pngtrans.c pngwio.c pngwrite.c pngwtran.c pngwutil.c'
OBJS='png.o pngerror.o pngget.o pngmem.o pngpread.o pngread.o pngrio.o pngrtran.o pngrutil.o pngset.o pngtrans.o pngwio.o pngwrite.o pngwtran.o pngwutil.o'

try $ARM_CC $ARM_CFLAGS -DPNG_ARM_NEON_OPT=0 -c $SOURCE
try $ARM_AR rcs libpng.a $OBJS

echo 'Moving libpng build products into place'
try cp -a libpng.a $BUILDROOT/lib/
try cp png.h pngconf.h pnglibconf.h $BUILDROOT/include

popd
