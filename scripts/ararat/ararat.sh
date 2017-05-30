#!/bin/bash
#
# Author: Siyi Xie (siyi.xie@cootek.cn)
# Created On: 2016-09-07
#
# util for testing the ararat, pulling down the message from servers
#

usage() {
    cat <<__EOF
arara.sh [-p] <auth_token>

Description
    testing the noah notification center. The debug server will be test by default;
    specify the -p option to test the production server. The auth_token is acceptable
    from production server even in testing debug server.

OPTIONS
    -p
        test the production server.
    -h
        show help info.
__EOF
}


PRODUCTION_ARARAT_SERVER="http://ararat.cootekservice.com:80"
DEBUG_ARARAT_SERVER="http://ararat-test.cootekservice.com:80"

server_url=${DEBUG_ARARAT_SERVER}


while getopts "hp" OPTION; do
    case $OPTION in
        h )
            usage
            exit 0
            ;;
        p )
            server_url=${PRODUCTION_ARARAT_SERVER}
            ;;
        \? )
            echo "Error: invalid option -${OPTION}" >&2
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

auth_token="$1"
if [[ -z "${auth_token}" ]]; then
    echo 'Error: no token'
    usage
    exit
fi


now_timestamp=$(date +%s%3N)

curl -v \
    --cookie "auth_token=${auth_token}" \
    --header "Content-Type: application/json; charset=utf-8" \
    --user-agent "TouchPalDialer/5.5.1.0 iPhone; iOS9.3.5; Scale/2.00" \
    --data-binary '{"locale":"zh-cn","data_name":"Presentation","conf_version":1,"sdkversion":"1000","lasttime":-1}' \
    --insecure \
    --http1.1 \
    --request POST \
    --url "${server_url}/notification_center/${auth_token}/${now_timestamp}/"  | python -m json.tool





