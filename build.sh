#!/bin/sh
set -e

./ios.sh -s \
  --target=16.0 \
  --disable-armv7 \
  --disable-armv7s \
  --disable-arm64-mac-catalyst \
  --disable-arm64e \
  --disable-i386 \
  --disable-x86-64 \
  --disable-x86-64-mac-catalyst \
  --enable-opus \
  --enable-libvpx \
  --enable-ios-audiotoolbox \
  --enable-ios-videotoolbox \
  --enable-ios-avfoundation \
  --enable-ios-zlib \
  --enable-ios-bzip2 \
  --enable-ios-libiconv \
  --no-bitcode

FRAMEWORK_NAMES=(ffmpegkit libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale)
VISIONOS_SIM_PLATFORM=xrossim
VISIONOS_PLATFORM=xros
VISIONOS_MINOS=1.0
VISIONOS_SDK=1.0

IOS_SIM_PLATFORM=iossim
IOS_SIM_MINOS=16.0
IOS_SIM_SDK=16.0

IOS_PATH=prebuilt/bundle-apple-framework-ios
IOS_SIM_PATH=prebuilt/bundle-apple-framework-iphonesimulator
VISIONOS_PATH=prebuilt/bundle-apple-framework-visionos
VISIONOSSIM_PATH=prebuilt/bundle-apple-framework-visionsimulator

rm -rf ${VISIONOS_PATH} ${VISIONOSSIM_PATH} ${IOS_SIM_PATH}
cp -r ${IOS_PATH} ${VISIONOS_PATH}
cp -r ${IOS_PATH} ${VISIONOSSIM_PATH}
cp -r ${IOS_PATH} ${IOS_SIM_PATH}

for FRAMEWORK in "${FRAMEWORK_NAMES[@]}"; do
  echo Processing $FRAMEWORK.framework
  rm ${VISIONOS_PATH}/${FRAMEWORK}.framework/${FRAMEWORK}
  vtool \
    -set-build-version ${VISIONOS_PLATFORM} ${VISIONOS_MINOS} ${VISIONOS_SDK} \
    -replace \
    -output ${VISIONOS_PATH}/${FRAMEWORK}.framework/${FRAMEWORK} \
    ${IOS_PATH}/${FRAMEWORK}.framework/${FRAMEWORK}
  vtool \
    -set-build-version ${VISIONOS_SIM_PLATFORM} ${VISIONOS_MINOS} ${VISIONOS_SDK} \
    -replace \
    -output ${VISIONOSSIM_PATH}/${FRAMEWORK}.framework/${FRAMEWORK} \
    ${IOS_PATH}/${FRAMEWORK}.framework/${FRAMEWORK}
  vtool \
    -set-build-version ${IOS_SIM_PLATFORM} ${IOS_SIM_MINOS} ${IOS_SIM_SDK} \
    -replace \
    -output ${IOS_SIM_PATH}/${FRAMEWORK}.framework/${FRAMEWORK} \
    ${IOS_PATH}/${FRAMEWORK}.framework/${FRAMEWORK}
done

rm -rf prebuilt/patched-xcframeworks
mkdir -p prebuilt/patched-xcframeworks

LIST=()
for FRAMEWORK in "${FRAMEWORK_NAMES[@]}"; do
  xcodebuild -create-xcframework \
    -framework ${IOS_PATH}/${FRAMEWORK}.framework \
    -framework ${IOS_SIM_PATH}/${FRAMEWORK}.framework \
    -framework ${VISIONOS_PATH}/${FRAMEWORK}.framework \
    -framework ${VISIONOSSIM_PATH}/${FRAMEWORK}.framework \
    -output prebuilt/patched-xcframeworks/${FRAMEWORK}.xcframework
  pushd prebuilt/patched-xcframeworks > /dev/null
    rm -rf ${FRAMEWORK}.xcframework.zip
    zip -q -r ${FRAMEWORK}.xcframework.zip ${FRAMEWORK}.xcframework
    HASH=$(sha256sum ${FRAMEWORK}.xcframework.zip | awk '{print $1}')
    LIST+=("\"${FRAMEWORK}\": \"${HASH}\",")
  popd > /dev/null
done

echo "["
for ITEM in "${LIST[@]}"; do
  echo "  ${ITEM}"
done
echo "]"
