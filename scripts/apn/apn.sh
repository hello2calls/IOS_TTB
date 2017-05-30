#!/bin/bash
#
# Author: Siyi Xie (siyi.xie@cootek.cn)
# Created On: 2016-09-08
#
# util for testing the Apple Push Notification in development
# or production mode.
#

#
# Reference
# http://qiita.com/toshinoriwatanabe/items/7b5b78ac9c27eb2f59d9

# key point:
# convert the certificate in p12 format into PEM format
# openssl pkcs12 -in apn-privatekey.p12 -out apn-privatekey.pem -nodes -clcerts

#curl -v \
#-d '{"aps":{"alert":"Hello","badge":"1"}}' \
#-H "apns-priority: 10" \
#-H "apns-expiration: 0" \
#-H "apns-topic: com.cootek.Contacts" \
#--http2 \
#--cert apn-privatekey.pem \
#https://api.development.push.apple.com/3/device/b618233f17cdb1289a2feee596530d79a9c08d59b4f68cb54fa7c6ff04a9a8dc
#
############

APN_PRODUCTION_SERVER='https://api.push.apple.com'
APN_DEV_SERVER='https://api.development.push.apple.com'


APN_PRODUCTION_PEM='apn-key-production.pem'
APN_DEV_PEM='apn-key-dev.pem'


KEY_DIR='keys'
BUNDLE_ID='com.cootek.Contacts'

TOKEN_FILE='tokens.txt'
RAW_PUSH_INFO_FILE='push_info.txt'

NORMALIZED_PUSH_INFO_FILE='utils/normalized_push_info.txt'
PY_NORMALIZER='utils/normalizer.py'

# important
# set the path for curl supporting HTTP/2
curl_path=/usr/local/Cellar/curl/7.50.0/bin/curl



usage() {
    cat <<__EOF

Summary
    an util for testing the Apple Pushing Notification service 
    in development or production mode. Attention: the curl command
    shoud support HTTP/2 protocol.

Usage
    apn.sh [-hdp] [tokens...]

Options
    -h
        show help info
    -d
        run a dry push, i.e. showing the config and input tokens
        but do NOT push to the Apple servers.
    -p
        push to the production APN server.

__EOF
}


check_http2() {
    if [[ $(curl --version | grep http2) ]]; then
        curl_path=$(type -p curl)
        return 0
    fi

    if [[ ! -f "${curl_path}" ]]; then
        echo 'Error: curl do NOT support HTTP2. Try to update to  curl with HTTP/2 feature by HomeBrew'
        echo 'Then set the `curl_path` variable in this script'
        exit 2
    fi
}


push_noti() {
    local token="$1"
    local server
    local key_path

    if [[ "${push_mode}" == 'PRODUCTION' ]]; then
        server=${APN_PRODUCTION_SERVER}
        key_path=${APN_PRODUCTION_PEM}
    else
        server=${APN_DEV_SERVER}
        key_path=${APN_DEV_PEM}
    fi
    ${curl_path} -v \
        -d @${NORMALIZED_PUSH_INFO_FILE} \
        -H "apns-priority: 10" \
        -H "apns-expiration: 0" \
        -H "apns-topic: ${BUNDLE_ID}" \
        --http2 \
        --cert "${KEY_DIR}/${key_path}" \
        --url "${server}/3/device/${token}"
}


push_mode='DEVELOPMENT'

while getopts ':hdp' opt; do
    case ${opt} in
        h )
            usage
            exit 0
            ;;

        d )
            push_mode='DRY'
            ;;
        p )
            push_mode='PRODUCTION'
            ;;
        * )
            echo 'bad options'
            usage
            exit 1
            ;;
    esac
done

shift "$((OPTIND - 1))"
manual_tokens="$@"

check_http2

echo "<<<<<< push_mode: ${push_mode}"

if [[ ! ${manual_tokens} ]]; then
    python ${PY_NORMALIZER}
    tokens=$(cat ${TOKEN_FILE} | grep -v '#')
    echo '<<<<<< read in tokens and config from files'
else
    tokens=${manual_tokens}
    echo '<<<<<< read in tokens from command line'
fi

echo ''

cat ${NORMALIZED_PUSH_INFO_FILE}
printf "\n\n"

for device_token in ${tokens}; do
    printf "device_token: ${device_token}\n"
    if [[ "${push_mode}" == 'PRODUCTION'
        || "${push_mode}" == 'DEVELOPMENT' ]]; then
        push_noti "${device_token}"
    fi
    printf "\n\n"
done
