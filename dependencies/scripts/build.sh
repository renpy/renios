#!/bin/bash

. $(dirname $0)/utils.sh

set -e

RENIOSCOMPONENT=$1

if [ "X$RENIOSCOMPONENT" == "X" ]; then
  echo $(basename $0) "<component>"
  exit 1
fi

. $(dirname $0)/environment.sh

builds="${2:-debug release}"
platforms="${3:-x86_64 armv7 arm64}"

for build in $builds; do
  for platform in $platforms; do
    if [ $platform = "x86_64" ]; then
      simulator=simulator-
    else
      simulator=
    fi

    echo "$build build for $platform..."

		. $(dirname $0)/environment-$simulator$platform.sh
		. $(dirname $0)/environment-$build.sh
		$(dirname $0)/build-$RENIOSCOMPONENT.sh

  done
done

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

  ./scripts/lipo_and_strip.py $RENIOSDEPROOT

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


  try find "$PROTOTYPE/prebuilt/release/python/lib" -name \*.py -delete
  try find "$PROTOTYPE/prebuilt/release/python/lib" -name \*.pyc -delete
  try find "$PROTOTYPE/prebuilt/release/python/lib" -name install-sh -delete

fi

echo "REN'IOS BUILD COMPLETE"
