#!/bin/sh

./ios.sh -s -x \
  --target=16.0 \
  --disable-armv7 \
  --disable-armv7s \
  --disable-arm64-mac-catalyst \
  --disable-arm64e \
  --disable-i386 \
  --disable-x86-64 \
  --disable-x86-64-mac-catalyst \
  --enable-opus \
  --enable-ios-audiotoolbox \
  --enable-ios-videotoolbox \
  --enable-ios-avfoundation \
  --enable-ios-zlib \
  --enable-ios-bzip2 \
  --enable-ios-libiconv \
  --no-bitcode
