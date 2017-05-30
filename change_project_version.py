#!/usr/bin/env python
#! -*- encoding: utf-8 -*-
#

import os.path
import logging
import re
import glob
import time
import fileinput
import argparse

import plistlib
from plistlib import PlistFormat


'''
constants
'''
KEY_VERSION = [
    'CFBundleVersion',
    'CFBundleShortVersionString',
]

PROJECT_NAME = 'TouchPalDialer'

EXTENTIONS = [
    PROJECT_NAME,
    'TodayWidget', 
    'CallDirectoryExtension',
    'IntermediaryCallExtension',
    'FraudCallExtension',
    'PromoteCallExtension',
    'YellowPageCallExtension',
]

FILE_TOUCHPAL_VERSION = 'TouchPalDialer/Classes/Utility/TouchPalVersionInfo.h'

MACRO_DEFINE = '#define'

'''
settings
'''
TARGET_VERSION = 5559

'''
'''
def change_pb_version(version=None, file_names=None):
    logging.debug(file_names)
    # if file_names is None:
    #     file_names = EXTENTIONS
    # if len(file_names) == 0:
    #     raise Exception('illegal file name')
    if version is None:
        version = TARGET_VERSION
    if len(str(version)) != 4:
        raise Exception('illegal version %s' % (version))

    for extension in EXTENTIONS:
        if extension == PROJECT_NAME:
            dir_path = PROJECT_NAME
        else:
            dir_path = '%s/%s' % (PROJECT_NAME, extension)

        for plfile in get_plist(dir_path):
            set_version(plfile, version)

def get_plist(dir_path):
    pattern = '%s/*[iI]nfo.plist' % (dir_path)
    return glob.glob(pattern)

def set_version(info_file, version):
    logging.debug('info_file = %s, version = %d', info_file, version)
    with open(info_file, 'rb+') as fb:
        info = plistlib.load(fb, fmt=PlistFormat.FMT_XML)

        ver_str = str(version)
        short_ver_str = ver_str[:3]
        ver_str = '.'.join(ver_str)
        short_ver_str = '.'.join(short_ver_str)

        logging.debug('version: %s', ver_str)
        logging.debug('short version: %s', short_ver_str)

        info['CFBundleVersion'] = ver_str
        info['CFBundleShortVersionString'] = short_ver_str
        # save_plist(fb, proj_info)
        # cursor to the file head, 
        # or the whole file will be replaced 
        # which is not desirable in `git diff `
        fb.seek(0)
        plistlib.dump(info, fb, fmt=PlistFormat.FMT_XML)
        logging.debug('End write version, %s', info_file)

def platform_str(raw):
    if raw == True:
        return 'YES'
    elif raw == False:
        return 'NO'
    else:
        return '@"%s"' % (str(raw))

def change_debug_settings(settings=None):
    CONFIGURABLE_SETTTINGS = {
        'VERSION_DATE': time.strftime('%Y/%m/%d'),
        'CURRENT_TOUCHPAL_VERSION': TARGET_VERSION,
        'USE_DEBUG_SERVER': False,
    }
    if settings is None:
        settings = CONFIGURABLE_SETTTINGS
    set_macro_define(settings)

def set_macro_define(configurations, file=FILE_TOUCHPAL_VERSION):
    with open(file, 'r') as fr:
        lines = fr.readlines()
        
    with open(file, 'w') as fb:
        for line in lines:
            if MACRO_DEFINE in line:
                components = line.split(maxsplit=2)
                if len(components) == 3 and components[0] == MACRO_DEFINE:
                    for define_pattern, value in configurations.items():
                        if components[1] == define_pattern:
                            if components[-1].endswith('\n'):
                                components[-1] = components[-1][:-1]
                            components[-1] = platform_str(value)
                            logging.debug(components)
                            line = ('\t'.join(components) + '\n')  
            fb.write(line)
    pass

def parse_args():
    parser = argparse.ArgumentParser(description='change deploy versions of extensions in all info.plist files')
    parser.add_argument('-v', '--version', dest='version', type=int, required=True, help='target version(int)', )
    return parser.parse_args()
    pass

def main():
    global TARGET_VERSION
    logging.basicConfig(level=logging.DEBUG, 
        format='[%(levelname).1s %(process)d %(asctime)s (%(filename)s:%(lineno)d) %(funcName)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S')
    args = parse_args()
    TARGET_VERSION = args.version

    logging.debug('args = %s', str(args))
    logging.debug('main, TARGET_VERSION = %d', TARGET_VERSION)

    change_pb_version()
    change_debug_settings()
    pass

if __name__ == '__main__':
    main()
