#! -*- coding=utf-8 -*-
#

import os,sys
import shutil
import zipfile
import const
from aliyun.oss_api import *

import commands
from optparse import OptionParser

ZIP_FILE_PREFIX = 'ios_tag'

'''
    :update: 2016-11-29 
            add OptParse for command line; 
            remove access id and key from `const.py`
'''

def execute():
    parse_options()
    version = judgeFile()
    if (version == None or len(version)!=8):
        print '[Error] wrong zip file name: no ios_tag_xxx.zip file'
        return
    else:
        print 'version: %s'%version
    unzip_dir(version)
    zip_dir(version)
    uploadAliyun()

def parse_options():
    global cmd_options
    global cmd_args

    parser = OptionParser()
    parser.add_option("-k", "--access-key", dest="access_key", 
                    help="access key for aliyun")
    parser.add_option("-i", "--access-id", dest="access_id",
                      help="access id for aliyun")
    (cmd_options, cmd_args) = parser.parse_args()
    if cmd_options.access_key is None \
        or cmd_options.access_id is None:
        print(commands.getoutput('python antiharassUpload.py -h'))
        raise Exception("[Error] you must specify the aliyun access key and id")
    pass

def judgeFile():
    nowDirName = os.getcwd()
    for root, dirlist, files in os.walk(nowDirName):
        for filename in files:
            if filename.startswith(ZIP_FILE_PREFIX) and filename.endswith('zip'):
                print "findfile : %s" % filename
                version = os.path.splitext(filename)[0][8:]
                return version
    return

def unzip_dir(version):
    zipFileName = os.path.abspath('ios_tag_%s.zip' % version)
    zipDirName = os.path.abspath('ios_tag')
    print "%s\n%s" % (zipFileName,zipDirName)

    if not os.path.exists(zipFileName):
        print "[Error] no such file: %s" % zipFileName
        return

    if os.path.exists(zipDirName):
        print "[Warning] remove exist zipDirName:%s" % zipDirName
        shutil.rmtree(zipDirName)
    os.mkdir(zipDirName)

    srcZip = zipfile.ZipFile(zipFileName,"r")
    for eachfile in srcZip.namelist():
        print "[Verbose] unzip file : %s" % eachfile
        eachfilename = os.path.normpath(os.path.join(zipDirName, "antiharass_ios_%s"%eachfile))
        eachdirname = os.path.dirname(eachfilename)
        if not os.path.exists(eachdirname):
            os.makedirs(eachdirname)
        fd=open(eachfilename, "wb")
        fd.write(srcZip.read(eachfile))
        fd.close()
    srcZip.close()

def zip_dir(version):
    zipDirName = os.path.abspath('ios_tag')
    for root, dirlist, files in os.walk(zipDirName):
        for filename in files:
            print filename
            prefix = os.path.splitext(filename)[0]
            destfile = "%s.zip" % prefix
            zipDir = "%s/%s" % (root,destfile)
            zipFile = "%s/%s" % (root,filename)
            os.system('zip -j %s %s' % (zipDir,zipFile))
            os.remove(zipFile)

    versionFileDir = '%s/antiharass_version' % zipDirName
    fd=open(versionFileDir, "wb")
    fd.write(version)
    fd.close()

def uploadAliyun():
    global oss

    access_host = get_confidential('host')
    access_id = get_confidential('id')
    access_key = get_confidential('key')

    print('[Info] host: %s\n id: %s\n key: %s\n' % (access_host, access_id, access_key))

    oss = OssAPI(access_host, access_id, access_key)

    zipDirName = os.path.abspath('ios_tag')

    for root, dirlist, files in os.walk(zipDirName):
        for filename in files:
            try:
                local = "%s/%s" % (root,filename)
                remote = "%s/%s" % (const.cloud_path,filename)
                oss.multi_upload_file(const.bucket, remote, local)
            except Exception as error:
                print(error)

def get_confidential(item_name):
    global cmd_options
    full_name = 'access_' + item_name
    if hasattr(cmd_options, full_name):
        value = getattr(cmd_options, full_name)
        print('[Info] cmd_options, %s => %s' % (full_name, value))

    elif hasattr(const, full_name):
        value = getattr(const, full_name)
        print('[Info] const, %s => %s' % (full_name, value))

    if value is not None:
        return value
    else:
        raise Exception('[Error] no value for key %s' % full_name)

if __name__ == '__main__':
    try:
        execute()
    except Exception as error:
        print(error)
