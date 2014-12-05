#!/bin/bash

. $(dirname $0)/utils.sh

# Download Python if necessary
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

pushd $TMPROOT/SDL2_image-$SDL2_IMAGE_VERSION/Xcode-iOS
try xcodebuild -project SDL_image.xcodeproj -target libSDL_image -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH clean
try xcodebuild -project SDL_image.xcodeproj -target libSDL_image -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH 
popd

echo "Moving SDL_image products into place"
try cp Xcode-iOS/build/$RENIOSBUILDCONFIGURATION-$SDKBASENAME/libSDL2_image.a $BUILDROOT/lib/libSDL2_image.a
try cp -a SDL_image.h $BUILDROOT/include


# Patch
# echo 'Patching SDL_image source'
# try patch -p1 < $RENIOSDEPROOT/patches/SDL_image/SDL_image-$SDL2_IMAGE_REVISION-ios.patch

# set -x
# try ./configure --prefix=$DESTROOT \
#   --with-freetype-prefix=$DESTROOT \
#   --host="$ARM_HOST" \
#   --enable-static=yes \
#   --enable-shared=no \
#   --without-x \
#   --disable-sdltest \
#   OBJC="$ARM_CC" \
#   CC="$ARM_CC" AR="$ARM_AR" \
#   LDFLAGS="$ARM_LDFLAGS" CFLAGS="$ARM_CFLAGS" \
#   SDL_CONFIG="$BUILDROOT/bin/sdl-config"

# try make clean
# try make libSDL2_image.la

