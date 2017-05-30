//
//  TPDialerAdvanced.h
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LAST_SYN_SYSROWID  @"LAST_SYN_SYSTEMCALLLOG_ROWID"
#define DEFALUT_MAX_ROWID 0
#define SYS_CALLDB_FILE_PATH @"/private/var/wireless/Library/CallHistory/call_history.db"

@interface TPDialerAdvanced : NSObject

// Calllog hook
+(BOOL)isAccessCallHistoryDB;
+(BOOL)copySystemCalllogToTPDialer:(NSString *)filePath;
//@privte
+(NSInteger)getCallType:(NSInteger)duartion withFlags:(NSInteger)flags;
//+(void)addRegisterCallObserver;
//void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

// phone location hook

+(BOOL) checkVersion:(NSInteger)requiredMininumVersion;

+(void) setCurrentCall:(id) call;

// hook MobilePhone and call this function to update UI. The phone number can be extracted by currentCall which is set just before this function been called.
+(void) updateLCDView:(id) view withText:(NSString*) text label:(NSString*) label;

// in iOS 5.0 and above, hook springboard and call this function to update UI. 
+(void) updateFullView:(id) view withText:(NSString*) text label:(NSString*) label number:(NSString*)number;

// in iOS 4, hook springboard and call this function to update UI. Unfortunately we cannot get the raw phone number if the number is in contacts list. 
+(void) updateOldFullView:(id) view withText:(NSString*) text label:(NSString*) label breakPoint:(unsigned int)breakPoint;

+(id) querySetting:(NSString*) key;

+(void) attachCrashHandler;

@end
