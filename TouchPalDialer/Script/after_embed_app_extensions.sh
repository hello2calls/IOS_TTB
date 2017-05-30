#!/bin/sh
#
# Author: Siyi Xie
# Email: siyi.xie@cootek.cn
# Created on: 2016-08-18
# Copyright:
#
# Zip the dSYM directories and the TouchPalDialer
# executable for crash symbolication
#

########################
#### this variables are exported by the xcodebuild
########################
# ${EXECUTABLE_NAME} TouchPalDialer
# ${EXECUTABLE_PATH} TouchPalDialer.app/TouchPalDialer
# ${CONFIGURATION_BUILD_DIR} /Users/siyi/gitWorkspace/yosemite/TouchPalDialer/build/Debug-iphoneos
# FULL_PRODUCT_NAME=TouchPalDialer.app

########################
# the variable FULL_WIDGET_NAME is defined similar to FULL_PRODUCT_NAME
########################
# FULL_WIDGET_NAME=TodayWidget.appex/
#
########################

ZIP_CONTAINER=~/Desktop/Build
if [[ ! -d "${ZIP_CONTAINER}" ]]; then
    mkdir "${ZIP_CONTAINER}"
fi

CURRENT_BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
CURRENT_COMMIT=`git rev-parse --short HEAD`
CURRENT_TIME="$(date +%Y-%m-%d_%H-%M-%S)"

### settings
ENABLE_DEBUG=YES

ENABLE_ZIP=YES
MAX_ARCHIVE_COUNT=40

### variables
SUFFIX_APP='app'
SUFFIX_DSYM='dSYM'
FULL_WIDGET_NAME=TodayWidget.appex


########################
#
# write log to the log file. Can be disabled by setting the ENABLE_DEBUG=NO
#
########################
log() {
    local log_path=~/Desktop/Build/build.log
    echo "$1" >> "${log_path}"
}

########################
#
# zip the executable file and .dSYM directories
#
########################
zip_file_name() {
    echo "${CURRENT_TIME}_${CURRENT_BRANCH_NAME}_${CURRENT_COMMIT}"
}

########################
#
# check the total size of  the zip files and try to delete the old ones
# to make sure the zip files does not occupy too much disk space
#
########################
check_max_and_delete() {
    local current_count=$(ls ${ZIP_CONTAINER} | grep '*.zip' | wc -l)
    if [[ ${current_count} -gt ${MAX_ARCHIVE_COUNT} ]]; then
        local delete_count=$(( current_count - MAX_ARCHIVE_COUNT ))
        for zip_file in $(ls -ltr ${ZIP_CONTAINER}/*.zip); do
            [[ ${delete_count} -gt 0 ]] \
            && [[ -f ${zip_file} ]] \
            && rm -f "${zip_file}" \
            && $((delete_count--)) \
            && log "$(date +%Y-%m-%d_%H-%M-%S) deleted ${zip_file}"
        done
    fi
}


# logic starts here
check_max_and_delete

### try to zip
PRODUCT_DSYM_DIR="${FULL_PRODUCT_NAME}.${SUFFIX_DSYM}"
PRODUCT_EXECUTABLE_PATH="${EXECUTABLE_PATH}"
WIDGET_DSYM_DIR="${FULL_WIDGET_NAME}.${SUFFIX_DSYM}"

ZIP_FILE=$(zip_file_name)
ZIP_FILE_PATH="${ZIP_CONTAINER}/${ZIP_FILE}"

ZIP_STATUS='zip DISABLED'

if [[ ${ENABLE_ZIP} == 'YES' ]]; then
    cd ${CONFIGURATION_BUILD_DIR}
    zip -q -r "${ZIP_FILE_PATH}" "${PRODUCT_EXECUTABLE_PATH}" "${PRODUCT_DSYM_DIR}" "${WIDGET_DSYM_DIR}"

    if [[ $? ]]; then
        ZIP_STATUS="zip OK"
    else
        ZIP_STATUS="zip FAILED"
    fi
fi

if [[ "${ENABLE_DEBUG}" == 'YES' ]]; then
    log ""
    log "${CURRENT_TIME} ${CURRENT_BRANCH_NAME} ${CURRENT_COMMIT}"
    log "zip status: ${ZIP_STATUS}"
    log "ZIP_FILE_PATH: ${ZIP_FILE_PATH}"
    log "PRODUCT_DSYM_DIR: ${CONFIGURATION_BUILD_DIR}/${PRODUCT_DSYM_DIR}"
    log "PRODUCT_EXECUTABLE_PATH: ${CONFIGURATION_BUILD_DIR}/${PRODUCT_EXECUTABLE_PATH}"
    log "WIDGET_DSYM_DIR: ${CONFIGURATION_BUILD_DIR}/${WIDGET_DSYM_DIR}"
fi




