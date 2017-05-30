#!/bin/sh

rm TouchPalDialerEnterprise.ipa

cd ./TouchPalDialer

export CONFIGURATION_BUILD_DIR='./build/DailyBuild-iphoneos'

xcodebuild -project "TouchPalDialer.xcodeproj"  -target "TouchPalDialer"  -configuration "DailyBuild" CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_DIR} clean

if [ $1 ]
then
echo "has parameter"
xcodebuild -project "TouchPalDialer.xcodeproj" -sdk iphoneos  -scheme "TouchPalDialer" -configuration "DailyBuild" CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_DIR} GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS '"$(printf '%q ' "$1")"
else
xcodebuild -project "TouchPalDialer.xcodeproj" -sdk iphoneos  -scheme "TouchPalDialer" -configuration "DailyBuild" CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_DIR}
fi


xcrun -sdk iphoneos PackageApplication -v "${CONFIGURATION_BUILD_DIR}/TouchPalDialer.app" -o "$(printf '%q' "$(pwd)")/../TouchPalDialerEnterprise.ipa" --embed "./Profile/DisContactsEnterprise.mobileprovision" CODE_SIGN_IDENTITY "iPhone Distribution: Shanghai HanXiang (CooTek) Information Technology Co., Ltd."
