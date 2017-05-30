#!/bin/bash

rm *.deb

ccpath="./channelcode.h"

rm $ccpath

echo -n \#define CHANNEL_CODE \(@\"$1\"\)  >> $ccpath

./CopyHeader.sh

make clean

make

make package

for files in *.deb
do
	mv "$files" "${files}_$1.deb"
done

mkdir deb_for_channels

mv *.deb  deb_for_channels
