
if [ $2 ] 
then 
buildSeattle=0
buildOrlando=0
else
buildSeattle=1
buildOrlando=1
fi

if  [ $2 == "orlando" ]
then buildOrlando=1
fi

if  [ $2 == "seattle" ]
then buildSeattle=1
fi

if [ $3 == "noclean" ]
then 
cleanArmv7=""
cleanSim=""
else
cleanArmv7="make clean BUILD_TARGET=iOS_armv7 BUILD_TYPE="$1 
cleanSim="make clean BUILD_TARGET=iOS_i386 BUILD_TYPE="$1
fi

if [ $3 == "updatefile" ]
then
cleanArmv7=""
cleanSim=""
allArmv7=""
allSim=""
else
allArmv7="make BUILD_TARGET=iOS_armv7 BUILD_TYPE="$1
allSim="make BUILD_TARGET=iOS_i386 BUILD_TYPE="$1
fi

rootFolder=${PWD##*/}

if [ $buildSeattle == 1 ]
then
echo "build seattle"
cd ../seattle/build/iOS
$cleanArmv7
$cleanSim
$allArmv7
$allSim

cd ../../../$rootFolder

#cp -f ../seattle/bin/$1/iOS_i386/libseattle.a TouchPalDialer/Classes/Engine/bin/libseattle_sim.a
cp -vf ../seattle/bin/$1/iOS_armv7/libseattle.a Shared/Shared/Seattle/lib/libseattle_armv7.a
cp -vf -R ../seattle/src/export/*.h Shared/Shared/Seattle/inc/
cp -vf -R ../seattle/src/interface/*.h Shared/Shared/Seattle/inc/
fi

if [ $buildOrlando == 1 ]
then
echo "build orlando"
cd ../orlando/lib/pcre/build/iOS
$cleanArmv7
$cleanSim
$allArmv7
$allSim

cd ../../../../build/iOS
$cleanArmv7
$cleanSim
$allArmv7
$allSim

cd ../../../$rootFolder

#cp -f ../orlando/bin/$1/iOS_i386/liborlando.a TouchPalDialer/Classes/Engine/bin/liborlando_sim.a
cp -f  ../orlando/bin/$1/iOS_armv7/liborlando.a TouchPalDialer/Classes/Engine/bin/liborlando_armv7.a
cp -f -R ../orlando/src/export/*.h TouchPalDialer/Classes/Engine/Loacl/
fi
