
#!/usr/bin/env python
#coding: utf-8
import os.path
print("start changeIcon");
filepath = './TouchPalDialer/TouchPalDialer/Images.xcassets/AppIcon.appiconset/Contents.json';
if not os.path.exists(filepath):
	print("not exit");
	exit(-1);
fp = open(filepath,'r+')  
lines = open(filepath).readlines()
for s in lines:
	fp.write(s.replace('icon@2x.png','iconEnterprise@2x.png'))   
fp.close() 


print("start changeGroupBondleID");
filepath = './TouchPalDialer/TouchPalDialer.entitlements';
if not os.path.exists(filepath):
	print("not exit");
	exit(-1);
fp = open(filepath,'r+')  
lines = open(filepath).readlines()
for s in lines:
	fp.write(s.replace('<string>group.com.cootek.Contacts</string>','<string>group.com.cootek.ContactsEnterprise</string>'))   
fp.close() 
print("start changeTodayGroupBondleID");
filepath = './TouchPalDialer/TodayWidget/TodayWidget.entitlements';
if not os.path.exists(filepath):
	print("not exit");
	exit(-1);
fp = open(filepath,'r+')  
lines = open(filepath).readlines()
for s in lines:
	fp.write(s.replace('<string>group.com.cootek.Contacts</string>','<string>group.com.cootek.ContactsEnterprise</string>'))   
fp.close() 


print("start changeBondleIDAndrunOnlyForDeploymentPostprocessing");
filepath = './TouchPalDialer/TouchPalDialer.xcodeproj/project.pbxproj';
if not os.path.exists(filepath):
	print("not exit");
	exit(-1);
fp = open(filepath,'r+')  
lines = open(filepath).readlines()
for s in lines:
	fp.write(s.replace('PRODUCT_BUNDLE_IDENTIFIER = com.cootek.Contacts.widget;','PRODUCT_BUNDLE_IDENTIFIER = com.cootek.ContactsEnterprise.mywidget;').replace('PRODUCT_BUNDLE_IDENTIFIER = com.cootek.Contacts;','PRODUCT_BUNDLE_IDENTIFIER = com.cootek.ContactsEnterprise;').replace('AFC0439A1B1574B100CFE7D0 /* TodayWidget.appex in Embed App Extensions */,',''))
fp.close()