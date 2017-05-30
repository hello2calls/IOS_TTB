#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import time
import datetime
import string
import commands
import zipfile
import shutil


appTargetName = 'TouchPalDialer' # executable file name
appContainerDir = appTargetName + '.app' #
src_root_path = os.environ.get('SRCROOT') #commands.getoutput('${SRCROOT}')
if src_root_path is None:
  print("[Error]: environ['SRCROOT'] is None")
  exit(1)

buildTimePath = src_root_path + '/Classes/TPBuild/TPBuildTime.h'
fileCount = 100

checkOldFileDir = os.path.expanduser('~/Desktop/Build/')


def moveTouchPalDialer(buildDir):
    tmpAppPath = os.path.join(appContainerDir, appTargetName)
    absAppPath = os.path.join(buildDir, tmpAppPath)
    buildAppPath = os.path.join(buildDir, appTargetName)

    print(' buildDir   = %s\n absAppPath = %s\n buildPath  = %s' % (buildDir, absAppPath, buildAppPath))
    # rename and delete original folders
    shutil.copy(absAppPath, buildAppPath)

    absAppContainer = os.path.join(buildDir, appContainerDir)
    shutil.rmtree(os.path.join(absAppContainer, os.pardir), ignore_errors=True)


def copyFiles(sourceDir,  targetDir):
    for file in os.listdir(sourceDir):
        sourceFile = os.path.join(sourceDir,  file)
        targetFile = os.path.join(targetDir,  file)
        if os.path.isfile(sourceFile):
            if not os.path.exists(targetDir):
                os.makedirs(targetDir)
            if not os.path.exists(targetFile) or(os.path.exists(targetFile) and (os.path.getsize(targetFile) != os.path.getsize(sourceFile))):
                    open(targetFile, "wb").write(open(sourceFile, "rb").read())
        if os.path.isdir(sourceFile):
            copyFiles(sourceFile, targetFile)


def removeFiles(filesDirOrFile):
  if os.path.exists(filesDirOrFile):
    if os.path.isfile(filesDirOrFile):
       os.remove(filesDirOrFile)
    else :
      for file in os.listdir(filesDirOrFile):
        delfile = os.path.join(filesDirOrFile,  file)
        if os.path.isfile(delfile):
          os.remove(delfile)
        if os.path.isdir(delfile):
          removeFiles(delfile)
          os.rmdir(delfile)


def getBuildTime():
    f = open(buildTimePath)             # 返回一个文件对象
    lines = f.readlines()             # 调用文件的 readline()方法
    f.close()
    timeString = ""
    for line in lines:
        texts = line.split()
        if(len(texts)>=3   and (texts[1] == 'TP_DEBUG_BUILD_TIME')):
             timeString = texts[-1]
             break
    timeFloat = string.atof(timeString)
    x = time.localtime(timeFloat)
    realTime = time.strftime('%Y-%m-%d %H:%M:%S',x)
    return realTime


def compare(x, y):
    stat_x = os.stat(checkOldFileDir + "/" + x)
    stat_y = os.stat(checkOldFileDir + "/" + y)
    if stat_x.st_ctime < stat_y.st_ctime:
       return -1
    elif stat_x.st_ctime > stat_y.st_ctime:
       return 1
    else:
       return 0


def checkOldFile():
    checkCountList = []
    iterms = os.listdir(checkOldFileDir)
    iterms.sort(compare)
    if(len(iterms)>=fileCount):
       checkCountList.extend(iterms[:(len(iterms)-fileCount)])
    for oldFile in checkCountList:
       oldFilePath = checkOldFileDir + oldFile
       if (os.path.exists(oldFilePath)):
          removeFiles(oldFilePath)


def zip_dir(dirname,zipfilename):
    filelist = []
    if os.path.isfile(dirname):
       filelist.append(dirname)
    else :
       for root, dirs, files in os.walk(dirname):
          for name in files:
             filelist.append(os.path.join(root, name))

    zf = zipfile.ZipFile(zipfilename, "w", zipfile.zlib.DEFLATED)
    for tar in filelist:
       arcname = tar[len(dirname):]
    #print arcname
       zf.write(tar,arcname)
    zf.close()


def zipFileAndDelete(filepath):
    zip_dir(filepath,filepath+'.zip')
    removeFiles(filepath)
    os.rmdir(filepath)
    checkOldFile()


def main():
    os.system('defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE')

    dest_build_dir = os.path.join(os.path.expanduser('~/Desktop/Build'), getBuildTime())
    if not os.path.isdir(dest_build_dir):
        try:
          os.makedirs(dest_build_dir)
        except Exception, e:
          print(e)
          exit(1)

    # do NOT put the slash in the beginning!!!! Error
    configuration = os.environ.get('CONFIGURATION', 'Debug')
    config_dir =  ('build/%s-iphoneos' % (configuration))
    src_build_dir = os.path.join(src_root_path, config_dir)

    print(' src_build_dir= %s\n dest_build_dir= %s\n src_root_path= %s' % (src_build_dir, dest_build_dir, src_root_path))
    if os.path.exists(src_build_dir):
        copyFiles(src_build_dir, dest_build_dir)
        moveTouchPalDialer(dest_build_dir)
        zipFileAndDelete(dest_build_dir)
    else:
        print('[Error]: %s does not exist' % (src_build_dir))


if __name__ == '__main__':
    main()
