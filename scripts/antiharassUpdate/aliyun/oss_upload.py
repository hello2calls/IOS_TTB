#!/usr/bin/env python
#coding=utf8
import time
import logging
from oss_api import *

HOST="oss.aliyuncs.com"
content_type = "JPEG"

def oss_upload(filename, bucket, obj, access_id, access_key):
    oss = OssAPI(HOST, access_id, access_key)
    headers = {}
    res = oss.put_object_from_file(bucket, obj + filename, filename, content_type, headers)
    if (res.status / 100) == 2:
        #print "put_object_from_file OK"
        return True
    else:
        logging.info('picture upload error!')
        return False
        #print "put_object_from_file ERROR"

if __name__ == "__main__":
    pass
