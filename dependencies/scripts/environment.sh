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
export FREETYPE_VERSION=2.4.12
export FRIBIDI_VERSION=0.19.2


export SDL_VERSION=2.0.4
export SDL_URL_PREFIX=https://www.libsdl.org/tmp/release/

export SDL2_GFX_VERSION=1.0.1
export SDL2_TTF_VERSION=2.0.12
export SDL2_IMAGE_VERSION=2.0.1
export LIBPNG_VERSION=1.6.18
export LIBJPEG_TURBO_VERSION=1.4.1
export FFI_VERSION=3.2.1
export FFMPEG_VERSION=3.0

