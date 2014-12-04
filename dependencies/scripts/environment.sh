#!/bin/bash

# From https://github.com/kivy/kivy-ios

# Set up build locations
export RENIOSDEPROOT="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"
export TMPROOT="$RENIOSDEPROOT/tmp"
export CACHEROOT="$RENIOSDEPROOT/cache"

# Set up path to include our gas-preprocessor.pl
export PATH="$RENIOSDEPROOT/scripts:/usr/local/bin:$PATH"

# create build directories if not found
try mkdir -p $CACHEROOT
try mkdir -p $TMPROOT

# Versions

export PYTHON_VERSION=2.7.3
# export RENPY_VERSION=6.14.1
# export PYGAME_VERSION=1.9.1
export FREETYPE_VERSION=2.3.12
export FRIBIDI_VERSION=0.19.2
export SDL_VERSION=2.0.3
export SDL2_TTF_REVISION=15fdede47c58
export SDL2_IMAGE_VERSION=2.0.0
export LIBPNG_VERSION=1.6.15
export LIBJPEG_TURBO_VERSION=1.3.1
# export LIBAV_VERSION=0.7.6
