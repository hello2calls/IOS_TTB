//
//  ContactGroupDBA.m
//  TouchPalDialer
//
//  Created by Sendor on 12-2-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContactGroupDBA.h"
#import "DataBaseModel.h"
#import "Group.h"
#import "Person.h"
#import "TPAddressBookWrapper.h"
#import "ContactCacheDataManager.h"

@implementation ContactGroupDBA

+ (NSArray*)getAllGroups {
    __block NSMutableArray* groupIDs = nil;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        NSString* sql = @"SELECT group_id FROM contact_group ORDER BY row_id";
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            groupIDs = [NSMutableArray arrayWithCapacity:1];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                [groupIDs addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
            }
            sqlite3_finalize(stmt);
            return;
        }
        return;
    }];
    
    return groupIDs;
}

+ (NSArray*)getMembersInGroup:(NSInteger)groupID {
    return [self getMembersInGroup:groupID exceptSource:-1];
}


+ (NSArray*)getMembersInGroup:(NSInteger)groupID exceptSource:(NSInteger)sourceType {
    __block NSMutableArray* memberIDs = nil;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        NSString *sql = nil;
        if (sourceType < 0) {
            sql = [NSString stringWithFormat:@"SELECT person_id FROM group_member WHERE group_id=%d ORDER BY row_id", groupID];
        } else {
            sql = [NSString stringWithFormat:@"SELECT person_id FROM group_member WHERE group_id=%d AND source_type<>%d ORDER BY row_id", groupID, sourceType];
        }
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            memberIDs = [NSMutableArray arrayWithCapacity:1];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                [memberIDs addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
            }
            sqlite3_finalize(stmt);
            return;
        }
        return;
    }];
    
    return memberIDs;
}

+ (NSArray*)getAllMembersInAllGroups {
    __block NSMutableArray* memberIDs = nil;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        NSString* sql = @"SELECT person_id FROM group_member";
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            memberIDs = [NSMutableArray arrayWithCapacity:1];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                [memberIDs addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
            }
            sqlite3_finalize(stmt);
            return;
        }
        return;
    }];
    
    return memberIDs;
}

+ (NSArray*)getMemberGroups:(NSInteger)memberID {
    __block NSMutableArray* groupIDs = nil;
   [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        NSString* sql = [NSString stringWithFormat:@"SELECT group_id FROM group_member WHERE person_id=%d", memberID];
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            groupIDs = [NSMutableArray arrayWithCapacity:1];
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                [groupIDs addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
            }
            sqlite3_finalize(stmt);
            return;
        }
        return;
   }];  
    
    return groupIDs;
}

+ (void)addGroup:(NSInteger)groupID {
    [self addGroupInner:groupID];
}

+ (void)addGroups:(NSArray*)groupIDs {
    for (NSNumber* item in groupIDs) {
        [self addGroupInner:[item intValue]];
    }
}

+ (void)deleteGroup:(NSInteger)groupID {
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSString* sql = [NSString stringWithFormat:@"DELETE FROM contact_group WHERE group_id=%d", groupID];
        if (SQLITE_OK == sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) ) {
            if (SQLITE_DONE != sqlite3_step(stmt) ) {
                cootek_log(@"ContactGroupDBA::deleteGroup SQLITE_DONE != sqlite3_step(stmt)");
            }
            sqlite3_finalize(stmt);
        } else {
            cootek_log(@"ContactGroupDBA::deleteGroup: sqlite3_prepare_v2() != SQLITE_OK");
        }
        sql = [NSString stringWithFormat:@"DELETE FROM group_member WHERE group_id=%d", groupID];
        if (SQLITE_OK == sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) ) {
            if (SQLITE_DONE != sqlite3_step(stmt) ) {
                cootek_log(@"ContactGroupDBA::deleteGroup:delete group member SQLITE_DONE != sqlite3_step(stmt)");
            }
            sqlite3_finalize(stmt);
        } else {
            cootek_log(@"ContactGroupDBA::deleteGroup::delete group member sqlite3_prepare_v2() != SQLITE_OK");
        }
    }];
}

+ (void)addGroupMember:(NSInteger)memberID sourceType:(NSInteger)sourceType toGroup:(NSInteger)groupID {
    [self innerAddGroupMember:memberID sourceType:sourceType toGroup:groupID];
}


+ (void)addGroupMembers:(NSArray*)memberIDs sourceType:(NSInteger)sourceType toGroup:(NSInteger)groupID {
    for (NSNumber* item in memberIDs) {
        [self innerAddGroupMember:[item intValue] sourceType:sourceType toGroup:groupID];
    }
}

+ (void)deleteGroupMember:(NSInteger)memberID fromGroup:(NSInteger)groupID {
    [self innerDeleteGroupMember:memberID fromGroup:groupID];
}

+ (void)deleteGroupMembers:(NSArray*)memberIDs fromGroup:(NSInteger)groupID {
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        for (NSNumber* item in memberIDs) {
            sqlite3_stmt *stmt = nil;
            NSString* sql = [NSString stringWithFormat:@"DELETE FROM group_member WHERE group_id=%d AND person_id=%d", groupID, [item intValue]];
            if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
                if (sqlite3_step(stmt) != SQLITE_DONE) {
                    cootek_log(@"ContactGroupDBA::resetGroups: sqlite3_step(stmt) != SQLITE_DONE");
                }
            } else {
                cootek_log(@"ContactGroupDBA::resetGroups: sqlite3_prepare_v2() != SQLITE_OK");
            }
            sqlite3_finalize(stmt);
        }
    }];
}

+ (void)resetGroups:(NSArray*)groups {
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = nil;
        NSString* sql = @"DELETE FROM contact_group";
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                cootek_log(@"ContactGroupDBA::resetGroups: sqlite3_step(stmt) != SQLITE_DONE");
            }
        } else {
            cootek_log(@"ContactGroupDBA::resetGroups: sqlite3_prepare_v2() != SQLITE_OK");
        }
        sqlite3_finalize(stmt);
        for (NSNumber* item in groups) {
            [self addGroupInner:[item intValue]];
        }
    }];
}

+ (void)mergeAddressbookAllGroups:(NSArray*)groupIDs
{
    NSString *abExistedIDs = @"";
    for (NSNumber *item in groupIDs) {
        abExistedIDs = [NSString stringWithFormat:@"%@%d, ", abExistedIDs, [item intValue]];
    }
    if ([abExistedIDs length] > 2) {
        abExistedIDs = [abExistedIDs substringToIndex:[abExistedIDs length] - 2];
    }
    // delete group not in system address book
    NSMutableString* sql = [NSMutableString string];
    if ([abExistedIDs length] > 0) {
        [sql appendFormat:@"DELETE FROM contact_group WHERE group_id NOT IN (%@);\n", abExistedIDs];
        [sql appendFormat:@"DELETE FROM group_member WHERE group_id NOT IN (%@);\n", abExistedIDs];
    } else {
        [sql appendString:@"DELETE FROM contact_group;\n"];
        [sql appendString:@"DELETE FROM group_member;\n"];
    }
    
    // insert new group in abbress book into contact_group
    for (NSNumber *item in groupIDs) {
        [sql appendFormat:@"INSERT INTO contact_group(group_id) SELECT %d WHERE NOT EXISTS (SELECT * FROM contact_group WHERE group_id = %d);\n", [item intValue],[item intValue]];
        
    }
    if ([sql length] > 0) {
        sql = [NSMutableString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sql];
        [DataBaseModel execute:DataBaseExecutionModeNew inDatabase:^(sqlite3* db) {
            char *errorMsg = NULL;
            int result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg);
            cootek_log(@"excuteSqlStr mergeAddressbookAllGroups, sql: ,%d",result);
            sqlite3_free(errorMsg);
        }];
    }
}

+ (void)copyAddressbookAllGroupMembers:(NSArray*)groupIDs
{
    [DataBaseModel execute:DataBaseExecutionModeNew inDatabase:^(sqlite3* db) {
        // delete source type == 0
        sqlite3_stmt *stmt = NULL;
        NSString* sql = @"DELETE FROM group_member WHERE source_type = 0;";
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            if (sqlite3_step(stmt) != SQLITE_DONE) {
            }
        }
        sqlite3_finalize(stmt);
        
        // delete person id(source type != 0) when he is not in address book
        NSMutableArray* notLocalMembers = [[NSMutableArray alloc] init];
        stmt = NULL;
        sql = [NSString stringWithFormat:@"SELECT person_id FROM group_member WHERE source_type <> 0"];
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                [notLocalMembers addObject:[NSNumber numberWithInt:sqlite3_column_int(stmt, 0)]];
            }
            sqlite3_finalize(stmt);
        }
        
        ABAddressBookRef abRef = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        if (!abRef) {
            return;
        }
        NSMutableString* sqlExecute = [NSMutableString string];
        for (NSNumber *item in notLocalMembers) {
            NSInteger personID = [item intValue];
            if (![[ContactCacheDataManager instance] isCacheItem:personID]) {
                [sqlExecute appendFormat:@"DELETE FROM group_member WHERE person_id = %d", personID];
            }
        }
        
        // sync group member from address book to group_member
        for (NSNumber *groupIDItem in groupIDs) {      
            NSArray *groupMemberIDs = [Group getMemberIDListByGroupID:[groupIDItem intValue] addressbookRef:abRef];
            for (NSNumber* memberIDItem in groupMemberIDs) {
                stmt = NULL;
                [sqlExecute appendFormat:@"INSERT INTO group_member(group_id, person_id, source_type) VALUES(%d, %d, %d);", [groupIDItem intValue], [memberIDItem intValue], 0];
            }
        }
        
        if ([sqlExecute length] > 0) {
            char *errorMsg = NULL;
            sqlExecute = [NSMutableString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sqlExecute];
            int result = sqlite3_exec(db, [sqlExecute UTF8String], NULL, NULL, &errorMsg);
            cootek_log(@"excuteSqlStr copyAddressbookAllGroupMembers, sql: %d",result);
            sqlite3_free(errorMsg);
        }
    }];
}

+ (void)addGroupInner:(NSInteger)groupID
{
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        BOOL isExisted = NO;
        NSString* sql = [NSString stringWithFormat:@"SELECT group_id FROM contact_group WHERE group_id=%d", groupID];
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                isExisted = YES;
                break;
            }
        }
        sqlite3_finalize(stmt);
        stmt = NULL;
        if (!isExisted) {
            sql = [NSString stringWithFormat:@"INSERT INTO contact_group(group_id) VALUES(%d)", groupID];
            if (SQLITE_OK == sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) ) {
                if (SQLITE_DONE != sqlite3_step(stmt) ) {
                    cootek_log(@"ContactGroupDBA::addGroupInner: SQLITE_DONE != sqlite3_step(stmt)");
                }
            }
        } else {
            cootek_log(@"[ContactGroupDBA::addGroupInner SQLITE_OK != sqlite3_prepare_v2");
        }
        sqlite3_finalize(stmt);
    }];
}

+ (void)innerAddGroupMember:(NSInteger)memberID sourceType:(NSInteger)sourceType toGroup:(NSInteger)groupID {
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        BOOL isExisted = NO;
        NSString* sql = [NSString stringWithFormat:@"SELECT row_id FROM group_member WHERE group_id=%d AND person_id=%d", groupID, memberID];
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                isExisted = YES;
                break;
            }
        }
        sqlite3_finalize(stmt);
        
        if (!isExisted) {
            stmt = NULL;
            sql = [NSString stringWithFormat:@"INSERT INTO group_member(group_id, person_id, source_type) VALUES(%d, %d, %d)", groupID, memberID, sourceType];
            if (SQLITE_OK == sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) ) {
                if (SQLITE_DONE != sqlite3_step(stmt) ) {
                    cootek_log(@"[ContactGroupDBA::innerAddGroupMember] SQLITE_DONE != sqlite3_step(stmt)");
                }
                sqlite3_finalize(stmt);    
            } else {
                cootek_log(@"[ContactGroupDBA::innerAddGroupMember] SQLITE_OK != sqlite3_prepare_v2");
            }
        }
    }];
}

+ (void)innerDeleteGroupMember:(NSInteger)memberID fromGroup:(NSInteger)groupID {
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM group_member WHERE group_id=%d AND person_id=%d", groupID, memberID];
        if (SQLITE_OK == sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) ) {
            if (SQLITE_DONE != sqlite3_step(stmt) ) {
                cootek_log(@"[ContactGroupDBA::innerDeleteGroupMember] SQLITE_DONE != sqlite3_step(stmt)");
            }
            sqlite3_finalize(stmt);    
        } else {
            cootek_log(@"[ContactGroupDBA::innerDeleteGroupMember] SQLITE_OK != sqlite3_prepare_v2");
        }
    }];
}

@end
