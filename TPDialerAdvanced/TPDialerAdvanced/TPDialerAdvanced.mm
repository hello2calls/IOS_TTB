//
//  TPDialerAdvanced.m
//  TPDialerAdvanced
//
//  Created by Xu Elfe on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>
#import "TPDialerAdvanced.h"
#import "LCDUpdator.h"
#import "Util.h"
#import "AdvancedSettingKeys.h"
#import "TPUncaughtExceptionHandler.h"
#import "AdvancedSettingUtility.h"

#define CALLLOG_INCOMING 4
#define CALLLOG_OUTGOING 5
#define CALLLOG_7_INCOMING 0
#define CALLLOG_7_OUTGOING 9

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

//extern "C" CFNotificationCenterRef CTTelephonyCenterGetDefault(void); // 获得 TelephonyCenter (电话消息中心) 的引用
//extern "C" void CTTelephonyCenterAddObserver(CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior);
//extern "C" void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center, const void *observer, CFStringRef name, const void *object);
//extern "C" NSString *CTCallCopyAddress(void *, CTCall *call); //获得来电号码
//extern "C" void CTCallDisconnect(CTCall *call); // 挂断电话
//extern "C" void CTCallAnswer(CTCall *call); // 接电话
//extern "C" void CTCallAddressBlocked(CTCall *call);
//extern "C" int CTCallGetStatus(CTCall *call); // 获得电话状态　拨出电话时为３，有呼入电话时为４，挂断电话时为５
//extern "C" int CTCallGetGetRowIDOfLastInsert(void); // 获得最近一条电话记录在电话记录数据库中的位置

@implementation TPDialerAdvanced

NSString* settingPath = @"/Library/MobileSubstrate/DynamicLibraries/TouchPalContactsSetting.plist";

#pragma mark calllog
+(BOOL)copySystemCalllogToTPDialer:(NSString *)filePath{
    cootek_log_function;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYN_SYSROWID]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:DEFALUT_MAX_ROWID] forKey:LAST_SYN_SYSROWID];
    }
    NSInteger preMaxRowID = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYN_SYSROWID] intValue];
    NSInteger maxRowID = preMaxRowID;
    sqlite3 *sysDatabase = NULL;
    //数据库连接建立
	if (sqlite3_open([SYS_CALLDB_FILE_PATH UTF8String], &sysDatabase) != SQLITE_OK) {
		sqlite3_close(sysDatabase);
	}
    NSString *sql;
    if (IS_IOS7) {
        sql = [NSString stringWithFormat: @"SELECT ROWID,address,[date],duration,flags,id FROM call  WHERE ROWID >%d  and (flags = 0 or flags = 9) ORDER BY ROWID DESC",preMaxRowID];
    } else {
        sql = [NSString stringWithFormat: @"SELECT ROWID,address,[date],duration,((flags & 4) + (flags & 1)) as flags,id FROM call  WHERE ROWID >%d  and ((flags & 4) = 4 or (flags & 5) = 5) ORDER BY ROWID DESC",preMaxRowID];
    }
    sqlite3_stmt *stmt = NULL;
    NSString *insertSql = @"";
    NSString *deltetSql = @"";
    if (DEFALUT_MAX_ROWID == preMaxRowID) {
        deltetSql = @"delete from calllog;";
    }
    if(sqlite3_prepare_v2(sysDatabase,[sql UTF8String], -1, &stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            if (maxRowID == preMaxRowID) {
                //MAX
                maxRowID = sqlite3_column_int(stmt, DEFALUT_MAX_ROWID);
            }
            NSString  *number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) 
                                                   encoding:NSUTF8StringEncoding];
            NSRange range = [number rangeOfString:@"@"];
            if (range.length == 0)
            {
                NSInteger callTime = sqlite3_column_int(stmt, 2);
                NSInteger duation = sqlite3_column_int(stmt, 3);
                NSInteger flags = sqlite3_column_int(stmt, 4);
                NSInteger personID=sqlite3_column_int(stmt, 5);
                //callType 
                NSInteger callType =  [TPDialerAdvanced getCallType:duation withFlags:flags];
                NSString *oneSql = [NSString stringWithFormat:@"INSERT INTO calllog(personID,phoneNumber,callTime,callType,duration) VALUES(%d,'%@',%d,%d,%d);\n",personID,number,callTime,callType,duation];
                insertSql = [insertSql stringByAppendingString:oneSql];
            }
        }
        sqlite3_finalize(stmt);
    };
    sqlite3_close(sysDatabase);
    
    if (preMaxRowID == DEFALUT_MAX_ROWID) {
        insertSql = [NSString stringWithFormat:@"%@%@",deltetSql,insertSql];
    }
    BOOL result = NO;
    if ([insertSql length] >0) {
        sysDatabase = NULL;
        //数据库连接建立
        if (sqlite3_open([filePath UTF8String], &sysDatabase) != SQLITE_OK) {
            sqlite3_close(sysDatabase);
        }
        char *errorMsg = NULL;
        int execResult = sqlite3_exec(sysDatabase, [insertSql UTF8String], NULL,NULL, &errorMsg); 
        if (execResult == SQLITE_OK) {
            result =YES;
        }
        sqlite3_free(errorMsg);
        sqlite3_close(sysDatabase);
    }
    if (result) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:maxRowID] forKey:LAST_SYN_SYSROWID];
    }
    return result;
}
+(NSInteger)getCallType:(NSInteger)duartion withFlags:(NSInteger)flags{
    switch (flags) {
        case CALLLOG_INCOMING:
        case CALLLOG_7_INCOMING:{
            if (duartion == 0) {
                return 2;//missed
            }else {
                return 0;//outcoming
            }
            break;
        }
        case CALLLOG_OUTGOING:
        case CALLLOG_7_OUTGOING:
            return 1;//incoming
            break;   
        default:
            break;
    }
    return 0;//outcoming
}
+(BOOL)isAccessCallHistoryDB{
    int res = access("/private/var/wireless/Library/CallHistory/call_history.db", R_OK);
    BOOL isAccessSystemCalllog = (res != 0) ? NO:YES;
    return isAccessSystemCalllog;
}

#pragma mark hook api
//+(void)addRegisterCallObserver{
//    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, &callBack, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
//}
//void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
//    if ([(NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"]) {
//        CTCall *call = (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];
//        NSString *caller = CTCallCopyAddress(NULL, call); // caller 便是来电号码
//        NSLog(@"xx=%@",caller);
//    }
//}

static NSString* currentNumber;

+(BOOL) checkVersion:(NSInteger)requiredMininumVersion {
    NSString* version = [TPDialerAdvanced querySetting:ADVANCED_SETTING_LATEST_TWEAK_VERSION];
    if(version == nil) {
        return NO;
    }
    NSLog(@"%@", version);
    return ([version integerValue] >= requiredMininumVersion);
}

+(void) setCurrentCall:(id) call {
    cootek_log_function;
    @synchronized(self) {
        if(call != nil) {
            
            if(currentNumber != nil) {
                [currentNumber release];
                currentNumber = nil;
            }
        
            if([call respondsToSelector:@selector(number)]) {
                currentNumber = (NSString*)[[call number] retain];
                cootek_log(@"set current call with number:%@", currentNumber);
            }
        }
    }
}

+(void) updateLCDView:(id) view withText:(NSString*) text label:(NSString*) label {
    cootek_log_function;
     @synchronized(self) {
        LCDUpdator* lcdUpdator = [[[LCDUpdator alloc] init] autorelease];
        lcdUpdator.hookee = view;
        lcdUpdator.updatorType = UTMobilePhone;
        lcdUpdator.text = text;
        lcdUpdator.label = label;
         
        // The MobilePhone will first create an PhoneCall instance, then call this function.
        // TODO: validate the multiple phone call at same time scenario 
        lcdUpdator.number = currentNumber; 
         
        [lcdUpdator update];
    }
}

+(void) updateFullView:(id) view withText:(NSString*) text label:(NSString*) label number:(NSString*)number {
    cootek_log_function;
    @synchronized(self) {
        LCDUpdator* lcdUpdator = [[[LCDUpdator alloc] init] autorelease];
        lcdUpdator.hookee = view;
        lcdUpdator.updatorType = UTFull;
        lcdUpdator.text = text;
        lcdUpdator.label = label;
        lcdUpdator.number = number;
        [lcdUpdator update];
    }
}

+(void) updateOldFullView:(id) view withText:(NSString*) text label:(NSString*) label breakPoint:(unsigned int)breakPoint{
    cootek_log_function;
    @synchronized(self) {
        LCDUpdator* lcdUpdator = [[[LCDUpdator alloc] init] autorelease];
        lcdUpdator.hookee = view;
        lcdUpdator.updatorType = UTOldFull;
        lcdUpdator.text = text;
        lcdUpdator.label = label;
        lcdUpdator.breakPoint = breakPoint;
        [lcdUpdator update];
    }
}

#pragma mark settings

+(id) querySetting:(NSString*) key {
    return [AdvancedSettingUtility querySetting:key];
}

+(void) attachCrashHandler {
    [TPUncaughtExceptionHandler attachHandler];
}


@end
