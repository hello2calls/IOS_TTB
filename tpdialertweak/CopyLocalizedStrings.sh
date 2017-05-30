rm -rf layout
mkdir -p layout/DEBIAN
cp -f ./control layout/DEBIAN/control


mkdir -p layout/System/Library/CoreServices/SpringBoard.app/English.lproj
mkdir -p layout/System/Library/CoreServices/SpringBoard.app/en_GB.lproj
#mkdir -p layout/System/Library/CoreServices/SpringBoard.app/zh-Hans.lproj
mkdir -p layout/System/Library/CoreServices/SpringBoard.app/zh_CN.lproj
#mkdir -p layout/System/Library/CoreServices/SpringBoard.app/zh-Hant.lproj
mkdir -p layout/System/Library/CoreServices/SpringBoard.app/zh_TW.lproj

cp -f ../TPDialerAdvanced/TPDialerAdvanced/en.lproj/TPDialerAdvanced.strings layout/System/Library/CoreServices/SpringBoard.app/English.lproj/TPDialerAdvanced.strings
cp -f ../TPDialerAdvanced/TPDialerAdvanced/en.lproj/TPDialerAdvanced.strings layout/System/Library/CoreServices/SpringBoard.app/en_GB.lproj/TPDialerAdvanced.strings

#cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hans.lproj/TPDialerAdvanced.strings  layout/System/Library/CoreServices/SpringBoard.app/zh-Hans.lproj/TPDialerAdvanced.strings
cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hans.lproj/TPDialerAdvanced.strings  layout/System/Library/CoreServices/SpringBoard.app/zh_CN.lproj/TPDialerAdvanced.strings

#cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hant.lproj/TPDialerAdvanced.strings  layout/System/Library/CoreServices/SpringBoard.app/zh-Hant.lproj/TPDialerAdvanced.strings
cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hant.lproj/TPDialerAdvanced.strings  layout/System/Library/CoreServices/SpringBoard.app/zh_TW.lproj/TPDialerAdvanced.strings


mkdir -p layout/Applications/MobilePhone.app/English.lproj
mkdir -p layout/Applications/MobilePhone.app/en_GB.lproj
#mkdir -p layout/Applications/MobilePhone.app/zh-Hans.lproj
mkdir -p layout/Applications/MobilePhone.app/zh_CN.lproj
#mkdir -p layout/Applications/MobilePhone.app/zh-Hant.lproj
mkdir -p layout/Applications/MobilePhone.app/zh_TW.lproj

cp -f ../TPDialerAdvanced/TPDialerAdvanced/en.lproj/TPDialerAdvanced.strings layout/Applications/MobilePhone.app/English.lproj/TPDialerAdvanced.strings
cp -f ../TPDialerAdvanced/TPDialerAdvanced/en.lproj/TPDialerAdvanced.strings layout/Applications/MobilePhone.app/en_GB.lproj/TPDialerAdvanced.strings

#cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hans.lproj/TPDialerAdvanced.strings  layout/Applications/MobilePhone.app/zh-Hans.lproj/TPDialerAdvanced.strings
cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hans.lproj/TPDialerAdvanced.strings  layout/Applications/MobilePhone.app/zh_CN.lproj/TPDialerAdvanced.strings

#cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hant.lproj/TPDialerAdvanced.strings  layout/Applications/MobilePhone.app/zh-Hant.lproj/TPDialerAdvanced.strings
cp -f ../TPDialerAdvanced/TPDialerAdvanced/zh-Hant.lproj/TPDialerAdvanced.strings  layout/Applications/MobilePhone.app/zh_TW.lproj/TPDialerAdvanced.strings
