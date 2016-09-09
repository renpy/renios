. $(dirname $0)/utils.sh

if [ ! -f $CACHEROOT/libwebp-$LIBWEBP_VERSION.tar.gz ]; then
  echo "Downloading libwebp source"
  try curl -L https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$LIBWEBP_VERSION.tar.gz > $CACHEROOT/libwebp-$LIBWEBP_VERSION.tar.gz
fi

try rm -rf $TMPROOT/libwebp-$LIBWEBP_VERSION
try tar xf $CACHEROOT/libwebp-$LIBWEBP_VERSION.tar.gz
try mv libwebp-$LIBWEBP_VERSION $TMPROOT

set -ex

pushd $TMPROOT/libwebp-$LIBWEBP_VERSION

./configure --prefix=$DESTROOT \
    --host="$ARM_HOST" \
    --enable-static \
    --disable-shared \
    CC="$ARM_REAL_CC" AR="$ARM_AR" \
    CFLAGS="$ARM_CFLAGS" \
    LDFLAGS="$ARM_LDFLAGS" \
    CCASFLAGS="$ARM_CFLAGS" \
    CPPFLAGS="$ARM_CFLAGS"

make V=1
make install

cp -a "$DESTROOT/include/webp" "$BUILDROOT/include"
cp -a "$DESTROOT/lib/libwebp.a" "$BUILDROOT/lib"

popd
