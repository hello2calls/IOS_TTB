#!/bin/sh

#
# Upload ipa file to fir.im
#
# Syntax: upload_fir.sh {my-application.ipa}
#
# fir.im/account  jinghua.wen@cootek.cn
# fir.im/password  CooTek1234
# enterprise type for all ios device

IPA=$1

if [ -z "$IPA" ]
then
	echo "Syntax: upload_fir.sh {my-application.ipa}"
	exit 1
fi

Bundle_Id=com.cootek.ContactsEnterprise

if [ $2 ] && [ $3 ]
then
    Id=$2
    API_TOKEN=$3
else
    Id="577b474af2fc42364200001e"
    API_TOKEN="c32999ea778924c21d46d9317a729095"
fi

echo "getting token"

INFO=`curl -d "type=ios&api_token=${API_TOKEN}&bundle_id=${Bundle_Id}" "http://api.fir.im/apps/${Id}/releases" 2>/dev/null`
echo ${INFO}
echo '上面是info哈哈哈哈哈哈'
KEY=$(echo ${INFO} | grep "binary.*$" -o | grep "key.*$" -o | awk -F '"' '{print $3;}')
TOKEN=$(echo ${INFO} | grep "binary.*$" -o | grep "token.*$" -o | awk -F '"' '{print $3;}')
UP_URL=$(echo ${INFO} | grep "binary.*$" -o | grep "upload_url.*$" -o | awk -F '"' '{print $3;}')
#echo key ${KEY}
#echo token ${TOKEN}



echo "uploading"
APP_INFO=`curl -# -F file=@${IPA} -F "key=${KEY}" -F "token=${TOKEN}" -F "x:changelog="121.52.235.231:30013"" ${UP_URL}`

echo '==================================='

if [ $? != 0 ]
then
	echo "upload error"
	exit 1
fi

echo ${APP_INFO}
#echo ${APPOID}

curl -X PUT -d changelog="121.52.235.231:30013" http://api.fir.im/apps/${Id}?api_token=${API_TOKEN}
