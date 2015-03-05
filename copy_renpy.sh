#!/bin/bash

set -ex

renpy=/home/tom/ab/renpy
prototype=$(dirname $(readlink -f $0))/prototype

pushd $renpy
$renpy/run.sh "$1" quit
popd

rm -Rf $prototype/base || true
mkdir $prototype/base

cp -a --no-preserve=ownership "$1"/game $prototype/base
cp -a --no-preserve=ownership $renpy/renpy $prototype/base
cp -a --no-preserve=ownership $renpy/renpy.py $prototype/base/main.py
