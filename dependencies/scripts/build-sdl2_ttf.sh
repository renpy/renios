#!/bin/bash

. $(dirname $0)/utils.sh

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

# Link SDL2 as SDL, so we can find it.
rm $TMPROOT/SDL
try ln -s $TMPROOT/SDL2-$SDL_VERSION $TMPROOT/SDL

echo 'Building SDL2_ttf'

pushd $TMPROOT/SDL2_ttf-$SDL2_TTF_VERSION/Xcode-iOS
try xcodebuild -project SDL_ttf.xcodeproj -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH clean
try xcodebuild -project SDL_ttf.xcodeproj -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH 
popd

echo "Moving SDL_ttf products into place"
try cp Xcode-iOS/build/$RENIOSBUILDCONFIGURATION-$SDKBASENAME/libSDL2_ttf.a $BUILDROOT/lib
try cp -a SDL_ttf.h $BUILDROOT/include

popd
