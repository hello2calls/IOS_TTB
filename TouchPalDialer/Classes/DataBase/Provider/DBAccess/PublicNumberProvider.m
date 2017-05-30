//
//  PublicNumberProvider.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import "PublicNumberProvider.h"
#import "DataBaseModel.h"
#import "PublicNumberModel.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"
#import "PublicNumberMessage.h"
#import "TouchPalVersionInfo.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "PushConstant.h"

@implementation PublicNumberProvider

+ (NSString *)safeStringFromCString:(const unsigned char *)cString {
    
    if (cString == NULL) {
        return @"";
    } else {
        return [NSString stringWithUTF8String:(char *)cString];
    }
}


+ (BOOL)addPublicNumberInfos:(NSArray *)infos {
    if (infos.count <= 0) {
        return YES;
    }
    __block BOOL success = YES;
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        for (PublicNumberModel *model in infos) {
            NSString* send_id = safe(model.sendId);
            NSString *insertModel = [NSString stringWithFormat:@"insert into public_number_info (user_phone, send_id, name, data, menus, error_url, icon_link, logo_link, company_name, desc, available, new_msg_count, url, new_msg_time) values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', %d, %d, '%@', %d)", safe([self userPhone]), send_id, safe(model.name), safe(model.data), safe(model.menus), safe(model.errorUrl), safe(model.iconLink), safe(model.logoLink), safe(model.compName), safe(model.desc), model.available, 0, safe(model.url), 0];
            char *erroMsg = NULL;
            int result = sqlite3_exec(db, [insertModel UTF8String], NULL, NULL, &erroMsg);
            if (result == SQLITE_OK) {
                cootek_log(@"update public_number_info success");
            } else {
                cootek_log(@"update public_number_info ERROR!!! %d", result);
                success = NO;
            }
            sqlite3_free(erroMsg);
            //icons table
            NSString *insert = [NSString stringWithFormat:@"insert into public_number_icons (link) values ('%@'); insert into public_number_icons (link) values ('%@')", safe(model.iconLink), safe(model.logoLink)];
            [self execute:insert withSuccessBlock:nil andFailBlock:nil];
            
            //update available
            if (!success) {
                NSInteger available = 0;
                NSString *select = [NSString stringWithFormat:@"select available from public_number_info where user_phone='%@' and send_id='%@'",safe([self userPhone]),send_id];
                sqlite3_stmt *stmt;
                NSUInteger resultSelect = sqlite3_prepare_v2(db, [select UTF8String], -1, &stmt, NULL);
                if (resultSelect == SQLITE_OK) {
                    available = sqlite3_column_int(stmt, 0);
                    cootek_log(@"public_number_info available is %d",available);
                }
                sqlite3_finalize(stmt);
                
                if (model.url && model.url.length > 0) {
                    NSString *update = [NSString stringWithFormat:@"update public_number_info set available = %d, name = '%@', data = '%@', menus = '%@', error_url= '%@',icon_link = '%@', logo_link = '%@', company_name = '%@', desc = '%@', url = '%@' where send_id = '%@' and new_msg_time < %d ", available?:model.available, safe(model.name), safe(model.data), safe(model.menus), safe(model.errorUrl), safe(model.iconLink), safe(model.logoLink), safe(model.compName), safe(model.description), safe(model.url), send_id, model.newMsgTime];
                    [self execute:update withSuccessBlock:nil andFailBlock:nil];
                } else {
                    NSString *update = [NSString stringWithFormat:@"update public_number_info set available = %d, name = '%@', data = '%@', menus = '%@', error_url= '%@',icon_link = '%@', logo_link = '%@', company_name = '%@', desc = '%@', url = '%@' where send_id = '%@'", available?:model.available, safe(model.name), safe(model.data), safe(model.menus), safe(model.errorUrl), safe(model.iconLink), safe(model.logoLink), safe(model.compName), safe(model.description), safe(model.url), send_id];
                    [self execute:update withSuccessBlock:nil andFailBlock:nil];
                }

            }

        }
    }];
    return success;
}

NSString * safe(NSString *text) {
    if (text == nil) {
        return @"";
    }
    return text;
}

+ (BOOL)getPublicNumberInfos:(NSMutableArray *)infos {
    NSString *userPhone = [self userPhone];
    __block BOOL success = YES;
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        NSString *select = [NSString stringWithFormat:@"select a.user_phone, a.send_id, a.name, data, menus, error_url, icon_link, logo_link, company_name, a.desc, available, new_msg_time, new_msg_count, new_msg_desc, b.path, c.path, if_noah, a.url from public_number_info a inner join public_number_icons b on b.link = a.icon_link inner join public_number_icons c on c.link = a.logo_link inner join public_number_message d on d.user_phone= a.user_phone and d.status = 1 and a.send_id = d.send_id where a.user_phone= '%@' and a.available = 1 group by a.user_phone,a.send_id order by new_msg_time DESC",userPhone];
        sqlite3_stmt *stmt;
        NSUInteger result = sqlite3_prepare_v2(db, [select UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                PublicNumberModel *model = [[PublicNumberModel alloc] init];
                model.userPhone = [self safeStringFromCString:sqlite3_column_text(stmt, 0)];
                model.sendId = [self safeStringFromCString:sqlite3_column_text(stmt, 1)];
                model.name = [self safeStringFromCString:sqlite3_column_text(stmt, 2)];
                model.data = [self safeStringFromCString:sqlite3_column_text(stmt, 3)];
                model.menus = [self safeStringFromCString:sqlite3_column_text(stmt, 4)];
                model.errorUrl = [self safeStringFromCString:sqlite3_column_text(stmt, 5)];
                model.iconLink = [self safeStringFromCString:sqlite3_column_text(stmt, 6)];
                model.logoLink = [self safeStringFromCString:sqlite3_column_text(stmt, 7)];
                model.compName = [self safeStringFromCString:sqlite3_column_text(stmt, 8)];
                model.desc = [self safeStringFromCString:sqlite3_column_text(stmt, 9)];
                model.available = sqlite3_column_int(stmt, 10);
                model.newMsgTime = sqlite3_column_int64(stmt, 11);
                model.newMsgCount = sqlite3_column_int(stmt, 12);
                model.msgContent = [self safeStringFromCString:sqlite3_column_text(stmt, 13)];
                model.iconPath = [self safeStringFromCString:sqlite3_column_text(stmt, 14)];
                model.logoPath = [self safeStringFromCString:sqlite3_column_text(stmt, 15)];
                model.ifNoah = sqlite3_column_int(stmt, 16);
                model.url = [self safeStringFromCString:sqlite3_column_text(stmt, 17)];
                [infos addObject:model];
            }
        } else {
            success = NO;
        }
        sqlite3_finalize(stmt);
        
    }];
    return success;
}

+ (BOOL)updateLogo:(NSString *)path withServiceId:(NSString *)serviceId {
    NSString *userPhone = [self userPhone];
    __block BOOL success = YES;
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        NSString *update = [NSString stringWithFormat:@"update public_number_info set logo_path = '%@' where user_phone = '%@' and send_id= '%@'", path, userPhone, serviceId];
        sqlite3_stmt *stmt;
        NSUInteger result = sqlite3_prepare_v2(db, [update UTF8String], -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            success = NO;
            cootek_log(@"update public number logo info fail :%d", result);
        }
        sqlite3_finalize(stmt);
    }];
    return success;
}

+ (BOOL)updateIcon:(NSString *)path withServiceId:(NSString *)serviceId {
    NSString *userPhone = [self userPhone];
    __block BOOL success = YES;
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        NSString *update = [NSString stringWithFormat:@"update public_number_info set icon_path = '%@' where user_phone = '%@' and send_id= '%@'", path, userPhone, serviceId];
        sqlite3_stmt *stmt;
        NSUInteger result = sqlite3_prepare_v2(db, [update UTF8String], -1, &stmt, NULL);
        if (result != SQLITE_OK) {
            success = NO;
            cootek_log(@"update public number icon info fail :%d", result);
        }
        sqlite3_finalize(stmt);
    }];
    return success;
}

+ (NSString *)userPhone {
    NSString *userPhone = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    if (userPhone.length == 0) {
        userPhone = [SeattleFeatureExecutor getToken];
    }
    return userPhone;

}

+ (BOOL)clearNewCountForServiceId:(NSString *)serviceId {
    NSString *sql = [NSString stringWithFormat:@"update public_number_info set new_msg_count = 0 where send_id = '%@' and user_phone= '%@'", serviceId, [self userPhone]];
    __block BOOL success = YES;
    [self execute:sql withSuccessBlock:nil andFailBlock:^{
        success = NO;
    }];
    return success;
}

+ (BOOL)addPublicNumberMsgs:(NSArray *)msgs withTheBeforeMsgId:(PublicNumberMessage *)theBeforeMsg andIfNoah:(BOOL)ifNoah{
    BOOL success = YES;
    NSMutableDictionary *serviceMsgs = [NSMutableDictionary dictionary];
    for(PublicNumberMessage *msg in msgs) {
        NSMutableArray *array = [serviceMsgs objectForKey:msg.sendId];
        if (!array) {
            array = [NSMutableArray arrayWithCapacity:4];
        }
        [array addObject:msg];
        [serviceMsgs setObject:array forKey:msg.sendId];
    }
    for (NSString *serviceId in [serviceMsgs allKeys]) {
        [self addPublicNumberMsgs:[serviceMsgs objectForKey:serviceId] withServiceId:serviceId andMsgsAreBeforeTheMsg:theBeforeMsg andIfNoah:ifNoah];
    }
    return success;
}

/**
 *if the theBeforeMsg is nil, ensure the msgs is the newest msgs from server or may cause problem
 
 *****important: msgs include theBeforMsg
 **/

+ (BOOL)addPublicNumberMsgs:(NSArray *)msgs withServiceId:(NSString *)serviceId andMsgsAreBeforeTheMsg:(PublicNumberMessage *)theBeforeMsg andIfNoah:(BOOL)ifNoah{
    if (msgs.count == 0) {
        return YES;
    }
    __block NSString *msgId = nil;
    NSString *userPhone = [self userPhone];
    NSString *select = [NSString stringWithFormat:@"select message_id, create_time from public_number_message where user_phone='%@' and send_id = '%@' order by create_time DESC limit 1", userPhone, serviceId];
    if (theBeforeMsg) {
        msgId = theBeforeMsg.msgId;
        select = [NSString stringWithFormat:@"select message_id, create_time from public_number_message where user_phone='%@' and send_id = '%@' and create_time < %ld order by create_time DESC limit 1", userPhone, serviceId, [theBeforeMsg.createTime integerValue]];
    }
    __block NSInteger createTime = [theBeforeMsg.createTime integerValue];
    [self select:select withSuccessBlock:^(sqlite3_stmt *stmt) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            msgId = [self safeStringFromCString:sqlite3_column_text(stmt, 0)];
            createTime = sqlite3_column_int64(stmt, 1);
        }
    } andFailBlock:nil];
    NSArray *sortedMsgs = [msgs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PublicNumberMessage *msg1 = obj1;
        PublicNumberMessage *msg2 = obj2;
        if ([msg1.createTime integerValue] > [msg2.createTime integerValue]) {
            return NSOrderedDescending;
        } else {
            if([msg1.createTime integerValue] == [msg2.createTime integerValue]){
                if ([msg1.msgId compare:msg2.msgId]) {
                    return NSOrderedDescending;
                }
            }
            return NSOrderedAscending;
        }
    }];
    PublicNumberMessage *theNewestmsg = [sortedMsgs objectAtIndex:sortedMsgs.count - 1];
    __block int newCount = 0;
//    if (theBeforeMsg == nil && msgId && theNewestmsg.createTime.intValue <= createTime) {
//        newCount = -1;
//    }
    __block BOOL success = YES;
    __block NSString *prevMsgId = nil;

    if (msgId) {
        __block BOOL isFirst = YES;
        [sortedMsgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PublicNumberMessage *msg = obj;
            if (prevMsgId || isFirst) {
                success = [self insertOneMessage:msg andPreviousMsg:prevMsgId andIfNoah:ifNoah];
                if (success) {
                    if ([msg hasStatKey]) {
                        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_STAT_KEY_MSG_RECEIVED kvs:Pair(@"stat_key", msg.statKey), Pair(@"service_id", msg.sendId), nil];
                    }
                    prevMsgId = msg.msgId;
                    newCount++;
                } else{
                    prevMsgId = msg.msgId;
                }
                isFirst = NO;
            }
            if (prevMsgId == nil && [msg.msgId isEqual: msgId]) {
                prevMsgId = msgId;
            }
        }];
    }
    if (prevMsgId == nil && success) {
        [sortedMsgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PublicNumberMessage *msg = obj;
            success = [self insertOneMessage:msg andPreviousMsg:prevMsgId andIfNoah:ifNoah];
            if (success) {
                if ([msg hasStatKey]) {
                    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_STAT_KEY_MSG_RECEIVED kvs:Pair(@"stat_key", msg.statKey), Pair(@"service_id", msg.sendId), nil];
                }
                prevMsgId = msg.msgId;
                newCount ++;
            } else {
                *stop = YES;
            }
        }];
    }
//    //update the before message
//    if (newCount > 0 && theBeforeMsg) {
//        [self updateTheBeforeMsg:theBeforeMsg.msgId withPrevMsg:theNewestmsg.msgId];
//    }
    //update public number info
    if (theBeforeMsg == nil) {
        [self updatePublicInfoWithSendId:serviceId newCount:newCount content:theNewestmsg.desc andCreateTime:[theNewestmsg.createTime integerValue]];
    }
    return success;
}

+ (BOOL)updateTheBeforeMsg:(NSString *)msgId withPrevMsg:(NSString *)prevMsgId{
    NSString *sql = [NSString stringWithFormat:@"update public_number_message set pre_msg='%@' where message_id = '%@'", prevMsgId, msgId];
    __block BOOL success = YES;
    [self execute:sql withSuccessBlock:nil andFailBlock:^{
        success = NO;
    }];
    return success;
}

+ (BOOL)updatePublicInfoWithSendId:(NSString *)sendId newCount:(int)newCount content:(NSString *)newContent andCreateTime:(NSInteger)createTime {    
    @synchronized(self)
    {
        NSString *key = [NSString stringWithFormat:@"%@-%@",sendId,[self userPhone]];
        NSInteger lastUpdateTime =[UserDefaultsManager intValueForKey:key];
        if (lastUpdateTime <= createTime && newCount > 0) {
            NSString *sql = [NSString stringWithFormat:@"update public_number_info set new_msg_count = new_msg_count + %d, new_msg_desc = '%@', new_msg_time = %ld where send_id = '%@' and user_phone = '%@'", newCount, newContent, createTime, sendId, [self userPhone]];
            __block BOOL success = YES;
            [self execute:sql withSuccessBlock:nil andFailBlock:^{
                success = NO;
            }];
            if (success) {
                [UserDefaultsManager setIntValue:createTime forKey:key];
            }
            return success;
        }
        return YES;
    }
}

+ (BOOL)forceUpdatePublicInfoWithSendId:(NSString *)sendId content:(NSString *)newContent andCreateTime:(NSInteger)createTime {
    
    NSString *key = [NSString stringWithFormat:@"%@-%@",sendId,[self userPhone]];
    NSString *sql = [NSString stringWithFormat:@"update public_number_info set new_msg_desc = '%@', new_msg_time = %ld where send_id = '%@' and user_phone = '%@'", newContent, createTime, sendId, [self userPhone]];
        __block BOOL success = YES;
        [self execute:sql withSuccessBlock:nil andFailBlock:^{
            success = NO;
        }];
        if (success) {
            [UserDefaultsManager setIntValue:createTime forKey:key];
        }
        return success;
}

+ (BOOL)updatePublicInfoDescriptionWithSendId:(NSString*)sendId
{
    NSString *select = [NSString stringWithFormat:@"select desc, create_time from public_number_message where status = 1 and send_id = '%@' and user_phone = '%@' order by create_time DESC", sendId,[self userPhone]];
    __block BOOL success = YES;
    [self select:select withSuccessBlock:^(sqlite3_stmt *stmt) {
        NSString* content = @"";
        NSInteger createTime = 0;
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            content = [self safeStringFromCString:sqlite3_column_text(stmt, 0)];
            createTime = sqlite3_column_int64(stmt, 1);
            success = [PublicNumberProvider forceUpdatePublicInfoWithSendId:sendId content:content andCreateTime:createTime];
        } else {
            success = [PublicNumberProvider forceUpdatePublicInfoWithSendId:sendId  content:@"" andCreateTime:0];
        }
    } andFailBlock: ^ {
        success = NO;
    }];
    
    return success;
}

+ (BOOL)insertOneMessage:(PublicNumberMessage *)msg andPreviousMsg:(NSString *)prevMsgId andIfNoah:(BOOL)ifNoah{
    __block BOOL success = YES;
    int currentTime = [[NSDate date] timeIntervalSince1970];
    NSString *sqlInsert = @"insert into public_number_message values ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', %d, %d, %d, '%@', '%@', '%@', '%@', %d, '%@')";
    NSString *insert = [NSString stringWithFormat:sqlInsert, safe(msg.msgId), safe( msg.userPhone), safe( msg.type), safe( msg.notifyType), safe(msg.title), safe( msg.desc), safe(msg.notification), safe(msg.remark), safe(msg.keynotes),  safe( msg.sendId), [msg.createTime integerValue], currentTime, 1, safe( msg.source), ifNoah?safe(msg.msgId):safe(prevMsgId), safe(msg.url), safe(msg.nativeUrl), ifNoah, safe(msg.statKey)];
    [self execute:insert withSuccessBlock:^(void) {
        cootek_log(@"insert success with prev_msgId: %@", prevMsgId);
    } andFailBlock:^ {
        success = NO;
    }];
    if (!ifNoah && !success && prevMsgId && msg.msgId.length > 0) {
        [self updateTheBeforeMsg:msg.msgId withPrevMsg:prevMsgId];
    }
    return success;
}


+ (void)select:(NSString *)sql withSuccessBlock:(void(^)(sqlite3_stmt *stmt))sucessBlock andFailBlock:(void(^)(void))failBlock {
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        sqlite3_stmt *stmt;
        NSUInteger result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            if (sucessBlock) {
                sucessBlock(stmt);
            }
        } else {
            if (failBlock) {
                failBlock();
            }
            cootek_log(@"excute %@ failed!!!! %d", sql, result);
        }
        sqlite3_finalize(stmt);
    }];
}

+ (void)execute:(NSString *)sql withSuccessBlock:(void(^)(void))sucessBlock andFailBlock:(void(^)(void))failBlock {
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        char *errorMsg = NULL;
        NSUInteger result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg);
        if (result == SQLITE_OK) {
            if (sucessBlock) {
                sucessBlock();
            }
        } else {
            if (failBlock) {
                failBlock();
            }
            cootek_log(@"excute %@ failed!!!! %s", sql, errorMsg);
        }
        sqlite3_free(errorMsg);
    }];
}


+ (BOOL)getPublicNumberMsgs:(NSMutableArray *)array withNoahArray:(NSMutableArray *)noahArray withSendId:(NSString *)sendId count:(int)count fromMsgId:(NSString *)msgId{
    //if msgId is nil, get the lattest msgs
    __block NSString *newMsgId = nil;
    __block BOOL success = YES;
    __block NSString *wantedMsg = nil;
    
    [noahArray removeAllObjects];
    NSString *noahSelect = [NSString stringWithFormat:@"select * from public_number_message where if_noah = 1 and send_id = '%@' and user_phone = '%@' order by create_time ASC", sendId, [self userPhone]];
    [self select:noahSelect withSuccessBlock:^(sqlite3_stmt *stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            PublicNumberMessage *msg = [PublicNumberMessage new];
            msg.msgId = [self safeStringFromCString:sqlite3_column_text(stmt, 0)];
            msg.userPhone = [self safeStringFromCString:sqlite3_column_text(stmt, 1)];
            msg.type = [self safeStringFromCString:sqlite3_column_text(stmt, 2)];
            msg.notifyType = [self safeStringFromCString:sqlite3_column_text(stmt, 3)];
            msg.title = [self safeStringFromCString:sqlite3_column_text(stmt, 4)];
            msg.desc = [self safeStringFromCString:sqlite3_column_text(stmt, 5)];
            msg.notification = [self safeStringFromCString:sqlite3_column_text(stmt, 6)];
            msg.remark = [self safeStringFromCString:sqlite3_column_text(stmt, 7)];
            msg.keynotes = [self safeStringFromCString:sqlite3_column_text(stmt, 8)];
            msg.sendId = [self safeStringFromCString:sqlite3_column_text(stmt, 9)];
            msg.createTime = [NSNumber numberWithInteger:sqlite3_column_int64(stmt, 10)];
            msg.receiveTime = [NSNumber numberWithInteger:sqlite3_column_int64(stmt, 11)];
            msg.status = sqlite3_column_int(stmt, 12);
            msg.source = [self safeStringFromCString:sqlite3_column_text(stmt, 13)];
            msg.prevMsg = [self safeStringFromCString:sqlite3_column_text(stmt, 14)];
            msg.url = [self safeStringFromCString:sqlite3_column_text(stmt, 15)];
            msg.nativeUrl = [self safeStringFromCString:sqlite3_column_text(stmt, 16)];
            msg.ifNoah = sqlite3_column_int(stmt, 17);
            msg.statKey = [self safeStringFromCString:sqlite3_column_text(stmt, 18)];
            if ( msg.status == 1 )
                [noahArray addObject:msg];
        }
    } andFailBlock: ^ {
        success = NO;
    }];
    
    if (msgId == nil) {
        NSString *select = [NSString stringWithFormat:@"select message_id, create_time from public_number_message where send_id = '%@' and if_noah = 0 and user_phone = '%@' order by create_time DESC limit 1", sendId, [self userPhone]];
        [self select:select withSuccessBlock:^(sqlite3_stmt *stmt) {
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                newMsgId = [self safeStringFromCString:sqlite3_column_text(stmt, 0)];
            }
        } andFailBlock: ^ {
            success = NO;
        }];
        if (newMsgId == nil) {
            return success;
        }
    }
    if (newMsgId) {
        wantedMsg = newMsgId;
    }
    __block BOOL needBreak = NO;
    while (!needBreak) {
        NSString *select = [NSString stringWithFormat:@"select * from public_number_message where message_id = '%@' and if_noah = 0 and user_phone = '%@'", wantedMsg ? wantedMsg : msgId, [self userPhone]];
        [self select:select withSuccessBlock:^(sqlite3_stmt *stmt) {
            if (sqlite3_step(stmt) != SQLITE_ROW) {
                needBreak = YES;
                success = NO;
                return;
            }
            PublicNumberMessage *msg = [PublicNumberMessage new];
            msg.msgId = [self safeStringFromCString:sqlite3_column_text(stmt, 0)];
            msg.userPhone = [self safeStringFromCString:sqlite3_column_text(stmt, 1)];
            msg.type = [self safeStringFromCString:sqlite3_column_text(stmt, 2)];
            msg.notifyType = [self safeStringFromCString:sqlite3_column_text(stmt, 3)];
            msg.title = [self safeStringFromCString:sqlite3_column_text(stmt, 4)];
            msg.desc = [self safeStringFromCString:sqlite3_column_text(stmt, 5)];
            msg.notification = [self safeStringFromCString:sqlite3_column_text(stmt, 6)];
            msg.remark = [self safeStringFromCString:sqlite3_column_text(stmt, 7)];
            msg.keynotes = [self safeStringFromCString:sqlite3_column_text(stmt, 8)];
            msg.sendId = [self safeStringFromCString:sqlite3_column_text(stmt, 9)];
            msg.createTime = [NSNumber numberWithInteger:sqlite3_column_int64(stmt, 10)];
            msg.receiveTime = [NSNumber numberWithInteger:sqlite3_column_int64(stmt, 11)];
            msg.status = sqlite3_column_int(stmt, 12);
            msg.source = [self safeStringFromCString:sqlite3_column_text(stmt, 13)];
            msg.prevMsg = [self safeStringFromCString:sqlite3_column_text(stmt, 14)];
            msg.url = [self safeStringFromCString:sqlite3_column_text(stmt, 15)];
            msg.nativeUrl = [self safeStringFromCString:sqlite3_column_text(stmt, 16)];
            msg.ifNoah = sqlite3_column_int(stmt, 17);
            msg.statKey = [self safeStringFromCString:sqlite3_column_text(stmt, 18)];
            if (wantedMsg && msg.status == 1) {
                [array insertObject:msg atIndex:0];
            }
            if (array.count == count) {
                needBreak = YES;
            }
            if ([msg.msgId isEqualToString:msg.prevMsg]) {
                msg.prevMsg = nil;
            }
            wantedMsg = msg.prevMsg;
            if (wantedMsg.length == 0) {
                needBreak = YES;
            }
        } andFailBlock:^{
            needBreak = YES;
            success = NO;
        }];
    }
    return success;
}

+ (BOOL)saveDownloadLinks:(NSDictionary *)linkPaths {
    __block BOOL success = YES;
    NSString *update = @"update public_number_icons set path= '%@' where link= '%@'";
    for (NSString * link in [linkPaths allKeys]) {
        [self execute:[NSString stringWithFormat:update,[linkPaths objectForKey:link],link] withSuccessBlock:nil andFailBlock:^{
            success = NO;
        }];
    }
    return success;
}

+ (BOOL)getNeedDownloadLinks:(NSMutableArray *)links {
    __block BOOL success = YES;
    NSString *select = [NSString stringWithFormat:@"select link from public_number_icons where path is null"];
    [self select:select withSuccessBlock:^(sqlite3_stmt *stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            [links addObject:[self safeStringFromCString:sqlite3_column_text(stmt, 0)]];
        }
    } andFailBlock:^{
        success = NO;
    }];
    return success;
}

+ (BOOL)deleteAllPublicNumberByServiceId:(NSString *)serviceId
{
    __block BOOL success = YES;
    NSString* update = @"update public_number_message set status='%d' where send_id='%@' and user_phone='%@'";
    [self execute:[NSString stringWithFormat:update, 0, serviceId,[PublicNumberProvider userPhone]] withSuccessBlock:nil andFailBlock:^{
        success = NO;
    }];
    return success;
}

+ (BOOL)deletePublicNumberMsg:(PublicNumberMessage *)message
{
    __block BOOL success = YES;
    NSString* update = @"update public_number_message set status='%d' where message_id='%@'";
    [self execute:[NSString stringWithFormat:update, 0, message.msgId] withSuccessBlock:nil andFailBlock:^{
        success = NO;
    }];
    
    return success;
}

+ (int) getNewMsgCount
{
    __block int count = 0;
    long long lastClickRedDotTime = (long long) [UserDefaultsManager doubleValueForKey:PUBLIC_NUMBER_RED_DOT_LAST_CLICK defaultValue:0];
    NSString *select = [NSString stringWithFormat:@"select sum(new_msg_count) from public_number_info where available = 1 and user_phone='%@' and new_msg_time > %ld", [PublicNumberProvider userPhone], lastClickRedDotTime];
    [self select:select withSuccessBlock:^(sqlite3_stmt *stmt) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int64(stmt, 0);
        }
    } andFailBlock:nil];
    cootek_log(@"new_msg, new_count= %d, lastClickRedDotTime= %ld", count, lastClickRedDotTime);
    return count;
}
@end
