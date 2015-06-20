#!/bin/bash

. $(dirname $0)/utils.sh

# Download Python if necessary
if [ ! -f $CACHEROOT/SDL2-$SDL_VERSION.tar.gz ]; then
    echo 'Downloading SDL2 source'
    curl -L $SDL_URL_PREFIX/SDL2-$SDL_VERSION.tar.gz > $CACHEROOT/SDL2-$SDL_VERSION.tar.gz
fi

rm -rf $TMPROOT/SDL2-$SDL_VERSION
echo 'Extracting SDL2 source'
try tar xzf $CACHEROOT/SDL2-$SDL_VERSION.tar.gz -C $TMPROOT # 2>&1 >/dev/null

try pushd $TMPROOT/SDL2-$SDL_VERSION

# try patch -p1 < $RENIOSDEPROOT/patches/sdl/sdl-premain.diff

echo 'Building SDL'

pushd $TMPROOT/SDL2-$SDL_VERSION/Xcode-iOS/SDL
try xcodebuild -project SDL.xcodeproj -target libSDL -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH clean
try xcodebuild -project SDL.xcodeproj -target libSDL -configuration $RENIOSBUILDCONFIGURATION -sdk $SDKBASENAME$SDKVER -arch $RENIOSARCH
popd

popd

# Yes, copy it over to a different name.
try cp $TMPROOT/SDL2-$SDL_VERSION/Xcode-iOS/SDL/build/$RENIOSBUILDCONFIGURATION-$SDKBASENAME/libSDL2.a $BUILDROOT/lib/libSDL2.a
try rm -rdf $BUILDROOT/include/SDL2
try cp -a $TMPROOT/SDL2-$SDL_VERSION/include $BUILDROOT/include/SDL2

#try mkdir -p $BUILDROOT/bin
#try sed s:BUILDROOT:$BUILDROOT: <$RENIOSDEPROOT/src/sdl/sdl-config >$BUILDROOT/bin/sdl2-config
#try chmod a+x $BUILDROOT/bin/sdl2-config
#
#mkdir -p $BUILDROOT/pkgconfig
#cat>$BUILDROOT/pkgconfig/sdl2.pc<<EOF
# sdl pkg-config source file
#
#prefix=$BUILDROOT
#exec_prefix=\${prefix}
#libdir=\${exec_prefix}/lib
#includedir=\${prefix}/include
#
#Name: sdl2
#Description: Simple DirectMedia Layer is a cross-platform multimedia library designed to provide low level access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D video framebuffer.
#Version: 2.0.0
#Requires:
#Conflicts:
#Libs: -L\${libdir}  -lSDLmain -lSDL2   -Wl,-framework,Cocoa
#Libs.private: \${libdir}/libSDL.a  -Wl,-framework,OpenGL  -Wl,-framework,Cocoa -Wl,-framework,ApplicationServices -Wl,-framework,Carbon -Wl,-framework,AudioToolbox -Wl,-framework,AudioUnit -Wl,-framework,IOKit
#Cflags: -I\${includedir}/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE
#EOF
