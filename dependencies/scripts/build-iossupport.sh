#!/bin/bash

. $(dirname $0)/utils.sh


try pushd "$RENIOSDEPROOT/iossupport"

HOSTPYTHON="$RENIOSDEPROOT/tmp/Python-$PYTHON_VERSION/hostpython"

try $HOSTPYTHON -O setup.py install -O2 --root $DESTROOT

try cp "$DESTROOT/usr/local/lib/python2.7/site-packages/iossupport.pyo" "$BUILDROOT/python/lib/python2.7/site-packages"

echo BUILDROOT "$BUILDROOT/python/lib/python2.7/site-packages"

try popd
