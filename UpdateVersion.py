#!/usr/bin/env python
#coding: utf-8

"UpdateVersion.py -- update version info file"


import json
import os

#update these values
#notes for 4510: 4520 is a hotfix for 4510, and we don't want to notify 4510 users (only from 91) to upgrade. So the allVersions list does not have item for 4510.
# for next version, we need to add 4510 and 4520 into the list.
allVersions=[1000,4000,4001,4020,4100,4110,4120,4200,4300,4310,4500]
version=4520
url='http://itunes.apple.com/us/app/chu-bao-zhi-neng-bo-hao/id503130474?ls=1&mt=8'
description_en_us='TouchPal has new version about v4.5.2.\nNew features:\n1. CallerTell add 20 cities offline city packages\n2. Support vibrate on connect\n3. Customize dialer page item actions\n4. Beautify detail information page and improve user experience'
description_zh_cn='触宝拨号有新版本了！\nv4.5.2版本：\n1.  号码慧眼新增20个城市公共号码包\n2.  支持接通震动功能\n3.  拨号器页面列表条目支持左右滑动快捷拨号、发短信\n4.  美化详细信息页面，酷炫的通话记录页面切换体验'
description_zh_tw='觸寶撥號有新版本了！\nv4.5.2版本：\n1.  號碼慧眼新增;0個城市公共號碼包\n2.  支持接通震動功能\n3.  撥號器頁面列表條目支持左右滑動快捷撥號、發短信\n4.  美化詳細信息頁面，酷炫的通話記錄頁面切換體驗'

dict={}
dict['version']=version
dict['url']=url
dict['description_en_us']=description_en_us
dict['description_zh_cn']=description_zh_cn
dict['description_zh_tw']=description_zh_tw

tmpName='tmpVersion'
if os.path.exists(tmpName):
    os.remove(tmpName)
    
tmpFile=open(tmpName,'a')
content=json.dumps(dict)
print >> tmpFile, content
tmpFile.close()

for v in allVersions:
    fileName='../server_files/version/cootek.contactplus.ios.public/%d.ver' % v
    if os.path.exists(fileName):
        os.remove(fileName)
    os.system('cp %s %s' % (tmpName, fileName))

os.remove(tmpName)    	
