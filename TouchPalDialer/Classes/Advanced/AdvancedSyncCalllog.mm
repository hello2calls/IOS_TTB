//
//  AdvancedSyncCalllog.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-3-13.
//
//

#import "AdvancedSyncCalllog.h"
#import <sqlite3.h>
#import "UserDefaultsManager.h"
#import "CallLogDataModel.h"
#import "CallLog.h"

#define LAST_SYN_SYSROWID  @"LAST_SYN_SYSTEMCALLLOG_ROWID"
#define DEFALUT_MAX_ROWID 0
#define CALLLOG_INCOMING  4
#define CALLLOG_OUTCOMING 5
#define DB_PATH_COMPONENTS @"0ptjwavf0vcs0wksflgtt/Njcrcsz/EbmlJjttqsz/ebmlaijsvpsy0ec"

@implementation AdvancedSyncCalllog

+ (NSString *)dbFilePath
{
    int length = [DB_PATH_COMPONENTS length];
    char *des = new char[length+1];
    const int code[] = {1, 0, 2, 1};
    const char *src = [DB_PATH_COMPONENTS UTF8String];
    
    for (int i=0; i<length; i++) {
        int offset = i % 4;
        des[i] = src[i] - code[offset];
    }
    
    des[length] = '\0';
    
    
    NSString *str = [NSString stringWithUTF8String:des];
    delete []des;
    return str;
}

+ (BOOL)copySystemCalllogToTPDialer:(NSString *)filePath
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYN_SYSROWID]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:DEFALUT_MAX_ROWID] forKey:LAST_SYN_SYSROWID];
        // delete all calllogs first
        [CallLog deleteCalllogByConditional:nil];
    }
    NSInteger preMaxRowID = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYN_SYSROWID] intValue];
    NSInteger maxRowID = preMaxRowID;
    sqlite3 *sysDatabase = NULL;
    //数据库连接建立
	if (sqlite3_open([[self dbFilePath] UTF8String], &sysDatabase) != SQLITE_OK) {
		sqlite3_close(sysDatabase);
	}
    NSString *sql = [NSString stringWithFormat: @"SELECT ROWID,address,[date],duration,((flags & 4) + (flags & 1)) as flags,id FROM call  WHERE ROWID >%d  and ((flags & 4) = 4 or (flags & 5) = 5) ORDER BY ROWID DESC",preMaxRowID];
    sqlite3_stmt *stmt = NULL;
    NSMutableArray *logs = [NSMutableArray array];
    
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
                CallLogType callType =  [self getCallType:duation withFlags:flags];
                
                CallLogDataModel *model = [[CallLogDataModel alloc] initWithPersonId:personID
                                                                        phoneNumber:number
                                                                           callType:callType
                                                                           duration:duation
                                                                       loadExtraInfo:NO];
                model.callTime = callTime;
                
                [logs addObject:model];
            }
        }
        sqlite3_finalize(stmt);
    };
    sqlite3_close(sysDatabase);
    
    BOOL result = [CallLog addCallLogs:logs];
    if (result) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:maxRowID] forKey:LAST_SYN_SYSROWID];
    }
    return result;
}

+ (CallLogType)getCallType:(NSInteger)duartion withFlags:(NSInteger)flags
{
    switch (flags) {
        case CALLLOG_INCOMING:{
            if (duartion == 0) {
                return CallLogIncomingMissedType;
            }else {
                return CallLogIncomingType;
            }
            break;
        }
        case CALLLOG_OUTCOMING:
            return CallLogOutgoingType;
            break;
        default:
            break;
    }
    return CallLogOutgoingType;
}

+ (BOOL)isAccessCallHistoryDB
{
    int res = access([[self dbFilePath] UTF8String], R_OK);
    BOOL isAccessSystemCalllog = (res != 0) ? NO:YES;
    return isAccessSystemCalllog;
}

@end
