TPBUILD_DIR=${SRCROOT}/Classes/TPBuild
if [ ! -d ${TPBUILD_DIR} ]; then
mkdir ${TPBUILD_DIR}
fi
TARGET_FILE="TPBuildTime.h"
TARGET_PATH="${TPBUILD_DIR}/${TARGET_FILE}"

# empty the target header file
echo -n "" > ${TARGET_PATH}

# write the timestamp into the target header file
BUILD_TIMESTAMP=`date +%s`
DEFINE_TIMESTAMP="#define TP_DEBUG_BUILD_TIME ${BUILD_TIMESTAMP}"

# current git branch name
CURRENT_BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
DEFINE_CURRENT_BRANCH="#define TP_DEBUG_CURRENT_BRANCH (@\"${CURRENT_BRANCH_NAME}\")"
# current git commit
CURRENT_COMMIT=`git rev-parse --short HEAD`
DEFINE_CURRENT_COMMIT="#define TP_DEBUG_CURRENT_COMMIT (@\"${CURRENT_COMMIT}\")"

# write into the TPBuildTime.h
# only the last line should be append a new line character
echo ${DEFINE_TIMESTAMP} >> ${TARGET_PATH}
echo ${DEFINE_CURRENT_BRANCH} >> ${TARGET_PATH}
echo ${DEFINE_CURRENT_COMMIT} >> ${TARGET_PATH}