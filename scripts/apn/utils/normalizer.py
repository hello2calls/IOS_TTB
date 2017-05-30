#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Author: Siyi Xie (siyi.xie@cootek.cn)
# Created On: 2016-09-08
#
# strip whitespace from the input the json string
#

import json
import os
import logging

CURRENT_DIR = os.path.dirname(__file__)

NORMALIZED_PUSH_INFO_FILE = 'normalized_push_info.txt'
PUSH_INFO_FILE = 'push_info.txt'


def load_push_message(push_info_file=None):
    if push_info_file is None:
        push_script_dir = os.path.join(CURRENT_DIR, os.pardir)
        push_info_file = os.path.join(push_script_dir, PUSH_INFO_FILE)

    message = None
    with open(push_info_file, 'r') as f:
        try:
            message = json.load(f)
        except Exception as e:
            logging.error('Error, load json file, %s' % str(e))
    return message


def main():
    message = load_push_message()
    if message is not None:
        with open(os.path.join(CURRENT_DIR, NORMALIZED_PUSH_INFO_FILE), 'w+') as nf:
            try:
                json.dump(push, nf)
            except Exception as e:
                print('Error: can not load json file `push_info.txt`')


if __name__ == '__main__':
    main()


