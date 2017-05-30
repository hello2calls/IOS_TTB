#!/usr/bin/env python
#coding: utf-8

"UpdateData.py -- update yellowpage and callerid"

import sys
import json
import os
import zipfile
import shutil

#add more orlando versions in the future if need to support more orlando versions
#add more app versions for each orlando version with the corresponding mapping
#e.g. if since 4520, we want to use incompatiable orlando version v2, we should use
#       formatVersions={'orlandoV1':[4500,4510],
#               'orlandoV2':[4520,4530,4540,4550]}
latestOrlando = 'orlandoV1'
formatVersions = {'orlandoV1':[4500,4510,4520,4530]}
#specify the target out put root
targetRoot='../server_files/iphone/default/yellowpage'


def printHelp():
    print 'UpdateData.py [-td] [-te] [-a][-ao]'
    print '-td: use test data'
    print '-te: use test environment' 
    print '-a:  also update national data files in app'
    print '-ao: only update national data files in app'


def prepareFolderForCleanWrite(folderPath):
    if os.path.exists(folderPath):
        shutil.rmtree(folderPath)

    os.mkdir(folderPath)
    return

#utility function. remove the existing file, get the directory ready, for creating new file 
def prepareFilePathForCleanWrite(filePath):
    if os.path.exists(filePath):
        os.remove(filePath)
        return
    
    dirName=os.path.dirname(filePath)
    if not os.path.exists(dirName):
        os.makedirs(dirName)
    

def CreateZipFile(cityPath, targetAppVersion, zipPath, update):
    print 'create zip file  %s for %s' % (zipPath, cityPath)
    
    prepareFilePathForCleanWrite(zipPath)
        
    zipHelp=zipfile.ZipFile(zipPath,'w',compression=zipfile.ZIP_DEFLATED)
    list=os.listdir(cityPath)
    hasUpdate=False
    for name in list:
        filePath=os.path.join(cityPath,name)
        if name.endswith('_data.img'):
            if not update: 
                zipHelp.write(filePath, 'data.img', zipfile.ZIP_DEFLATED)
        elif name.endswith('_index.img'):
            if not update:
                zipHelp.write(filePath, 'index.img', zipfile.ZIP_DEFLATED)
        elif name.endswith('_number.img'):
            if not update:
                zipHelp.write(filePath, 'number.img', zipfile.ZIP_DEFLATED)
        elif name.endswith('_table.img'):
            if not update:
                zipHelp.write(filePath, 'table.img', zipfile.ZIP_DEFLATED)
        elif name.endswith('LogoTable.img'):
            zipHelp.write(filePath, 'logo.img', zipfile.ZIP_DEFLATED)
        elif name.endswith('_deltadata.img'):
            zipHelp.write(filePath, 'dataUpdate.img', zipfile.ZIP_DEFLATED)
            hasUpdate=True
        elif name.endswith('_deltaindex.img'):
            zipHelp.write(filePath, 'indexUpdate.img', zipfile.ZIP_DEFLATED)
            hasUpdate=True
        elif name.endswith('_deltatable.img'):
            zipHelp.write(filePath, 'tableUpdate.img', zipfile.ZIP_DEFLATED)
            hasUpdate=True
        elif name.endswith('_deltanumber.img'):
            zipHelp.write(filePath, 'numberUpdate.img', zipfile.ZIP_DEFLATED)
            hasUpdate=True
        elif name.endswith('.png'):
            imgpath='image/%s' % name
            zipHelp.write(filePath, imgpath, zipfile.ZIP_DEFLATED)
            
    zipHelp.close()
    
    if update and (not hasUpdate):
        os.remove(zipPath)
        return 0
    
    #output the file size in KB, with two digits after .
    stinfo=os.stat(zipPath)
    tmpSize=stinfo.st_size/1024
    if tmpSize == 0:
        tmpSize = 1
    return tmpSize
    
    

def processCity(cityInfo, cityPath, targetAppVersion):
    global useTestEnv
    
    baseDataVersion=cityInfo['base_version']
    updateDataVersion=cityInfo['update_version']
    cityName=cityInfo['city_name']
    cityId=cityInfo['city_id']
    if cityId == 'national':
        cityId = 'nation'
    
    print 'process city %s with folder %s' % (cityName, cityPath)
    
    if useTestEnv:
        #downloadPath='http://dialer.corp.cootek.com/iphone/default/yellowpage/v%d/default/' % targetAppVersion
        downloadPath='http://58.32.229.109/iphone/default/yellowpage/v%d/default/' % targetAppVersion
    else:
        downloadPath='http://dialer.cootekservice.com/iphone/default/yellowpage/v%d/default/' % targetAppVersion
    
    info={}
        
    mainFileName='ios_%d_%s%d.zip' % (targetAppVersion,cityId,updateDataVersion)
    zipPath='%s/v%d/default/%s' % (targetRoot,targetAppVersion,mainFileName)
    mainSize=CreateZipFile(cityPath, targetAppVersion, zipPath, False)
    updateFileName='ios_%d_%s%d_update.zip' % (targetAppVersion,cityId,updateDataVersion)
    zipPath='%s/v%d/default/%s' % (targetRoot,targetAppVersion,updateFileName)
    updateSize=CreateZipFile(cityPath, targetAppVersion, zipPath, True)
    
    info['city_id']=cityId
    info['city_name']=cityName
    info['main_version']='%d' % baseDataVersion
    info['main_url']=downloadPath+mainFileName
    info['main_size']=mainSize
    if updateSize > 0:
        info['update_version']='%d' % updateDataVersion
        info['update_url']=downloadPath+updateFileName
        info['update_size']=updateSize
    else:
        info['update_version']='%d' % baseDataVersion
        info['update_url']=''
        info['update_size']=0
    
    return info
    

def updateData(sourceFolder, targetAppVersions):
    global updateApp
    global allCities
    targetAppVersion=targetAppVersions[0]
    print 'Update %s for %d' % (sourceFolder,targetAppVersion)
    
    #json contents array
    contents=[]
    
    for item in allCities:
        cityId=item['city_id']
        cityPath='%s/%s' % (sourceFolder, cityId)
        if not os.path.exists(cityPath):
            print 'warning: %s not exists' % cityPath 
            continue
        result=processCity(item, cityPath, targetAppVersion)
        contents.append(result)
    
    #write to package list file
    contentsStr=json.dumps(contents)
    
    for ver in targetAppVersions:
        contentsFilePath='%s/v%d/default/packagelist' % (targetRoot,ver)
        print 'write to %s with %s' % (contentsFilePath, contentsStr)
        prepareFilePathForCleanWrite(contentsFilePath)
        contentsFile=open(contentsFilePath,'a')
        print >> contentsFile, contentsStr
        contentsFile.close()
    
    return

def updateAppFiles():
    updateAppFilesForFolder('TouchPalDialer/yellowpagedata/')
    updateAppFilesForFolder('CallerInfoShow/CallerInfoShow/ResourceFiles/yellowpagedata/')
    return
  
def updateAppFilesForFolder(rootPath):
    
    global sourcePath
    sourceFolder=sourcePath+latestOrlando+'/national'
    list=os.listdir(sourceFolder)
    for name in list:
        filePath=os.path.join(sourceFolder,name)
        if name.endswith('_data.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'data.img'))
        elif name.endswith('_index.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'index.img'))
        elif name.endswith('_number.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'number.img'))
        elif name.endswith('_table.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'table.img'))
        elif name.endswith('LogoTable.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'logo.img'))
        elif name.endswith('_deltadata.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'ataUpdate.img'))
        elif name.endswith('_deltaindex.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'indexUpdate.img'))
        elif name.endswith('_deltatable.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'tableUpdate.img'))
        elif name.endswith('_deltanumber.img'):
            os.system('cp %s %s%s' % (filePath, rootPath, 'numberUpdate.img'))
        elif name.endswith('.png'):
            imgpath='%simage/%s' % (rootPath, name)
            os.system('cp %s %s' % (filePath, imgpath))
    
    return


def processArgs():
    global useTestData
    global useTestEnv
    global updateApp
    global updateAppOnly
    global sourcePath
    i = 1
    count = len(sys.argv)
    useTestData=False
    useTestEnv=False
    updateApp=False
    updateAppOnly=False
    
    while i < count:
        opt=sys.argv[i]
        i=i+1
        if opt== '-td':
            useTestData=True
        elif opt=='-te':
            useTestEnv=True
        elif opt=='-a':
            updateApp=True
        elif opt=='-ao':
            updateApp=True
            updateAppOnly=True
        else:
            print 'input is wrong'
            printHelp()
            sys.exit()
    
    if useTestData:
        sourcePath='../orlando/test_data/'
    else:
        sourcePath='../orlando/public_data/'
        
def run():  
    global sourcePath
    global updateApp
    global updateAppOnly
    processArgs()
    global allCities
    
    if not updateAppOnly:
        for key in formatVersions.iterkeys():
            sourceFolder=sourcePath+key
            versionFile=open(sourceFolder+'/version.txt')
            allCities=json.load(versionFile)
            versionFile.close()
            updateData(sourceFolder, formatVersions[key])
    
    #update the image file for build-in national data
    if updateApp:
       updateAppFiles()
       
    #to support old version app, need to copy package list file to old location
    os.system('cp ../server_files/iphone/default/yellowpage/v4500/default/packagelist ../server_files/package/yellowpage/packagelist/cootek.contactplus.ios.public/4500') 
run()

    