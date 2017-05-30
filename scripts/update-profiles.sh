#!/bin/bash
#
# Perform updating or deleting the profiles


#######################################
# Usage of this script

#######################################
usage() {
    cat <<__EOF

NAME
    update-profiles -- update the profiles by the project settings

SYNOPSIS
    update-profiles [-hudl]

DESCRIPTION
    operate the mobileprofile files in our project and the user\`s
    libray at \`~/Library/MobileDevice/Provisoning\ Profiles folder\`
    Attention: make sure that to execute this script in \`script\` directory of your project root.

        -l
            list the profiles with uuid and names
        -u
            update the project profiles to user's library path
        -d
            delete all the profiles in the user's libray
        -h
            show help info

EXAMPLES
    update-profiles -l
        list all the profiles
    update-profiles -u
        add the profiles in this project into the user's library
    update-profiles -du
        delete all profiles in the user's library and add the profiles in this project
    update-profiles
        defaultly it is to update the profiles, same as \`update-profiles -u \`
__EOF
}

echo_header() {
    echo '************************'
    echo "==== $1"
    if [[ $# == 2 ]]; then
        echo "==== $2"
    fi
    echo '************************'
}

echo_ok() {
    echo "[OK] $1"
    echo ""
}


#######################################
# Remove all profiles from user's library

#######################################
delete_lib_profiles() {
    echo_header "Delete profiles in the user's library ${MAC_PROFILE_DIR}"
    for pfile in $(ls "${MAC_PROFILE_DIR}"); do
        rm -f "${MAC_PROFILE_DIR}/${pfile}"
        if [ $? ]; then
            echo "  [deleted] ${pfile}"
        fi
    done
    echo_ok "removed user's library profiles"
}


#######################################
# Update all project profiles to user's library

#######################################
update_from_project_profiles() {
    local cp_action='Added'
    echo_header "Update profiles to the user's library" \
        "${MAC_PROFILE_DIR} <-- ${PROJ_PROFILE_DIR}"

    for file in ${PROJ_PROFILE_DIR}/*.*provision*; do
        uuid=$(grep UUID -A1 -a "$file" | grep -io "[-A-Z0-9]\{36\}")
        extension="${file##*.}"
        target_file_name="${uuid}.${extension}"

        origin_file_name=$(basename ${file})
        # TODO: permit overwrite?
        cp -n "$file" "${MAC_PROFILE_DIR}/${target_file_name}"
        echo "  [${cp_action}] ${target_file_name} <-- ${origin_file_name}"
    done
    echo_ok "updated profiles to the user's library"
    echo_header 'Rebuild the project (quit, restart Xcode and rebuild if necessary)'
}


#######################################
# List all profiles of this project

#######################################
list_project_profiles() {
    echo_header "List project profiles in ${PROJ_PROFILE_DIR}"

    for file in ${PROJ_PROFILE_DIR}/*.*provision*; do
        uuid=`grep UUID -A1 -a "$file" | grep -io "[-A-Z0-9]\{36\}"`
        extension="${file##*.}"
        target_file_name="${uuid}.${extension}"
        if [ $? ]; then
            origin_file_name=$(basename ${file})
            echo "  ${target_file_name} <-- ${origin_file_name}"
        fi
    done
    echo_ok "Listed project profiles"
}

#######################################
# Check the execution path of this script

#######################################
check_exec_path() {
    echo_header 'Check execution path'
    current_dir_path=$(pwd)
    current_dir=$(basename ${current_dir_path})
    if [[ ! $current_dir == 'scripts' ]]; then
        echo '[error]  You are required to run this script in the directory of `scripts`'
        exit
    fi
    echo_ok "execution path ready"
}



# Ref
# http://stackoverflow.com/questions/10398456/can-an-xcode-mobileprovision-file-be-installed-from-the-command-line

MAC_PROFILE_DIR=~/Library/MobileDevice/"Provisioning Profiles"
PROJ_PROFILE_DIR=../TouchPalDialer/Profile


if [[ $# -eq 0 ]]; then
    update_from_project_profiles
    exit
elif [[ $# -gt 1 ]] && [[ ! $1 == '-h' ]]; then
    check_exec_path
fi

while getopts "hlud" OPTION; do
    case $OPTION in
        h )
            usage
            ;;
        l )
            list_project_profiles
            ;;
        u )
            update_from_project_profiles
            ;;
        d )
            delete_lib_profiles
            ;;
        \? )
            list_project_profiles
            ;;
    esac
done


