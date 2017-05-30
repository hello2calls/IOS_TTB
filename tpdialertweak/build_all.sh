#!/bin/bash
debpath=deb_for_channels

rm *.deb
rm -r -f $debpath

mkdir deb_for_channels

./build_for_channel.sh 10010
./build_for_channel.sh 10011
./build_for_channel.sh 10012
./build_for_channel.sh 10013
./build_for_channel.sh 10014
./build_for_channel.sh 10015
