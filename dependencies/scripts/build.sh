#!/bin/bash

. $(dirname $0)/utils.sh

RENIOSCOMPONENT=$1

if [ "X$RENIOSCOMPONENT" == "X" ]; then
  echo $(basename $0) "<component>"
  exit 1
fi

. $(dirname $0)/environment.sh

echo "STARTING REN'IOS BUILD"

# BUILD FOR SIMULATOR, i386

#echo "BUILDING FOR SIMULATOR i386 (DEBUG)"
#
#. $(dirname $0)/environment-simulator-i386.sh
#. $(dirname $0)/environment-debug.sh
#try $(dirname $0)/build-$RENIOSCOMPONENT.sh
#
#echo "BUILDING FOR SIMULATOR i386 (RELEASE)"
#
#. $(dirname $0)/environment-simulator-i386.sh
#. $(dirname $0)/environment-release.sh
#try $(dirname $0)/build-$RENIOSCOMPONENT.sh

# BUILD FOR SIMULATOR, x86_64

echo "BUILDING FOR SIMULATOR x86_64 (DEBUG)"

. $(dirname $0)/environment-simulator-x86_64.sh
. $(dirname $0)/environment-debug.sh
try $(dirname $0)/build-$RENIOSCOMPONENT.sh

echo "BUILDING FOR SIMULATOR x86_64 (RELEASE)"

. $(dirname $0)/environment-simulator-x86_64.sh
. $(dirname $0)/environment-release.sh
try $(dirname $0)/build-$RENIOSCOMPONENT.sh

# BUILD FOR DEVICE, ARMV7

echo "BUILDING FOR ARMV7 (DEBUG)"

. $(dirname $0)/environment-armv7.sh
. $(dirname $0)/environment-debug.sh
try $(dirname $0)/build-$RENIOSCOMPONENT.sh

echo "BUILDING FOR ARMV7 (RELEASE)"

. $(dirname $0)/environment-armv7.sh
. $(dirname $0)/environment-release.sh
try $(dirname $0)/build-$RENIOSCOMPONENT.sh

# BUILD FOR DEVICE, ARMV7S

#echo "BUILDING FOR ARMV7S (DEBUG)"
#
#. $(dirname $0)/environment-armv7s.sh
#. $(dirname $0)/environment-debug.sh
#try $(dirname $0)/build-$RENIOSCOMPONENT.sh
#
#echo "BUILDING FOR ARMV7S (RELEASE)"
#
#. $(dirname $0)/environment-armv7s.sh
#. $(dirname $0)/environment-release.sh
#try $(dirname $0)/build-$RENIOSCOMPONENT.sh

# BUILD FOR DEVICE, ARM64

echo "BUILDING FOR ARM64 (DEBUG)"

. $(dirname $0)/environment-arm64.sh
. $(dirname $0)/environment-debug.sh
try $(dirname $0)/build-$RENIOSCOMPONENT.sh

echo "BUILDING FOR ARM64 (RELEASE)"

. $(dirname $0)/environment-arm64.sh
. $(dirname $0)/environment-release.sh
try $(dirname $0)/build-$RENIOSCOMPONENT.sh


run_lipo () {

    try lipo -create -output $RENIOSDEPROOT/build/debug/lib/$1 \
        -arch x86_64 $RENIOSDEPROOT/build/iphonesimulator-x86_64/debug/lib/$1 \
        -arch armv7 $RENIOSDEPROOT/build/iphoneos-armv7/debug/lib/$1 \
        -arch arm64 $RENIOSDEPROOT/build/iphoneos-arm64/debug/lib/$1
                        
        # -arch armv7s $RENIOSDEPROOT/build/iphoneos-armv7s/debug/lib/$1
        #-arch i386 $RENIOSDEPROOT/build/iphonesimulator-i386/debug/lib/$1 \

    try lipo -create -output $RENIOSDEPROOT/build/release/lib/$1 \
        -arch x86_64 $RENIOSDEPROOT/build/iphonesimulator-x86_64/release/lib/$1 \
        -arch armv7 $RENIOSDEPROOT/build/iphoneos-armv7/release/lib/$1 \
        -arch arm64 $RENIOSDEPROOT/build/iphoneos-arm64/release/lib/$1
}

if [ "$RENIOSCOMPONENT" == "all" -o "$RENIOSCOMPONENT" == "final" ]; then

  echo "PRODUCING FAT BINARIES"

  # PRODUCE FAT BINARIES

  try mkdir -p $RENIOSDEPROOT/build/debug/lib

  # Copy most (non-binary) files from one of the builds, doesn't matter which.
  try cp -a $RENIOSDEPROOT/build/iphoneos-armv7/debug/include $RENIOSDEPROOT/build/debug/
  try cp -a $RENIOSDEPROOT/build/iphoneos-armv7/debug/python $RENIOSDEPROOT/build/debug/
  # try cp -a $RENIOSDEPROOT/build/iphoneos-armv7s/debug/renpy $RENIOSDEPROOT/build/debug/

  try mkdir -p $RENIOSDEPROOT/build/release/lib

  # Copy most (non-binary) files from one of the builds, doesn't matter which.
  try cp -a $RENIOSDEPROOT/build/iphoneos-armv7/release/include $RENIOSDEPROOT/build/release/
  try cp -a $RENIOSDEPROOT/build/iphoneos-armv7/release/python $RENIOSDEPROOT/build/release/
  # try cp -a $RENIOSDEPROOT/build/iphoneos-armv7/release/renpy $RENIOSDEPROOT/build/release/
    
  for i in $RENIOSDEPROOT/build/iphoneos-armv7/release/lib/lib*.a; do
        run_lipo $(basename $i) 
  done

  try pushd $RENIOSDEPROOT/build/debug/lib
  # Strip debugging symbols to avoid "Unable to open object file" errors
  # TODO: So what is the point of having a separate debug build anymore?
  try xcrun strip -Sxr *.a
  try popd

  # Strip debugging symbols to avoid "Unable to open object file" errors
  try pushd $RENIOSDEPROOT/build/release/lib
  try xcrun strip -Sxr *.a
  try popd
  
  PROTOTYPE=$RENIOSDEPROOT/../prototype
  
  rm -Rf "$PROTOTYPE/prebuilt"
  try mkdir -p "$PROTOTYPE/prebuilt/release/python/include/python2.7"
  try cp "$RENIOSDEPROOT/build/release/python/include/python2.7/pyconfig.h" "$PROTOTYPE/prebuilt/release/python/include/python2.7"
  try cp -a "$RENIOSDEPROOT/build/release/python/lib" "$PROTOTYPE/prebuilt/release/python"
  try cp -a "$RENIOSDEPROOT/build/release/lib" "$PROTOTYPE/prebuilt/release/lib"
  try cp -a "$RENIOSDEPROOT/build/release/include" "$PROTOTYPE/prebuilt/release/include"
  try cp -a "$RENIOSDEPROOT/build/release/python/include/python2.7" "$PROTOTYPE/prebuilt/release/include"
    
  try mkdir -p "$PROTOTYPE/prebuilt/debug"
  try cp -a "$RENIOSDEPROOT/build/debug/lib" "$PROTOTYPE/prebuilt/debug/lib"


fi

echo "REN'IOS BUILD COMPLETE"
