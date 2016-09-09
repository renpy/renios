#!/bin/bash

. $(dirname $0)/utils.sh

if [ ! -f $CACHEROOT/SDL2_image-$SDL2_IMAGE_VERSION.tar.gz ]; then
    echo 'Downloading SDL2_image source'
    curl -L https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$SDL2_IMAGE_VERSION.tar.gz > $CACHEROOT/SDL2_image-$SDL2_IMAGE_VERSION.tar.gz
fi

# Clean any previous extractions,
rm -rf $TMPROOT/SDL2_image-$SDL2_IMAGE_VERSION
# then extract SDL2_image source to cache directory
echo 'Extracting SDL2_image source'
try tar xzf $CACHEROOT/SDL2_image-$SDL2_IMAGE_VERSION.tar.gz -C $TMPROOT # 2>&1 >/dev/null
try pushd $TMPROOT/SDL2_image-$SDL2_IMAGE_VERSION

# Link SDL2 as SDL, so we can find it.
rm $TMPROOT/SDL
try ln -s $TMPROOT/SDL2-$SDL_VERSION $TMPROOT/SDL

echo 'Building SDL2_image'

set -ex

# Disable the internal PNG-saving function, as it can't compile on iOS.
sed -i.bak "s/define SAVE_PNG/undef SAVE_PNG/" IMG_png.c

LOCAL_CFLAGS="-DSDL_IMAGE_USE_COMMON_BACKEND -DLOAD_BMP -DLOAD_GIF -DLOAD_LBM -DLOAD_PCX -DLOAD_PNM -DLOAD_TGA -DLOAD_XCF -DLOAD_XPM -DLOAD_XV -DLOAD_PNG -DLOAD_WEBP -DLOAD_JPG"
BUILD_CFLAGS="-I$BUILDROOT/include -I$BUILDROOT/include/SDL2 "
SOURCE="IMG.c IMG_gif.c   IMG_lbm.c   IMG_png.c   IMG_tga.c   IMG_webp.c  IMG_xpm.c   IMG_xxx.c IMG_bmp.c   IMG_jpg.c   IMG_pcx.c   IMG_pnm.c   IMG_tif.c   IMG_xcf.c   IMG_xv.c"
OBJS="IMG.o IMG_gif.o   IMG_lbm.o   IMG_png.o   IMG_tga.o   IMG_webp.o  IMG_xpm.o   IMG_xxx.o IMG_bmp.o   IMG_jpg.o   IMG_pcx.o   IMG_pnm.o   IMG_tif.o   IMG_xcf.o   IMG_xv.o"

$ARM_CC $ARM_CFLAGS $BUILD_CFLAGS $LOCAL_CFLAGS -c $SOURCE
$ARM_AR rcs libSDL_image.a $OBJS

ls -l $OBJS

# echo "Moving SDL_image products into place"
cp -a libSDL_image.a "$BUILDROOT/lib/libSDL_image.a"
cp -a SDL_image.h $BUILDROOT/include

popd


# pushd $TMPROOT/SDL2_image-$SDL2_IMAGE_VERSION/Xcode-iOS
# try xcodebuild -project SDL_image.xcodeproj -target libSDL_image -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH clean
# try xcodebuild -project SDL_image.xcodeproj -target libSDL_image -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH
# popd
#

# echo "Moving SDL_image products into place"
# try cp Xcode-iOS/build/$RENIOSBUILDCONFIGURATION-$SDKBASENAME/libSDL2_image.a $BUILDROOT/lib/libSDL2_image.a
# try cp -a SDL_image.h $BUILDROOT/include


