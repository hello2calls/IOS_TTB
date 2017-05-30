//
//  ContactCacheProvider.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-26.
//
//

#import "ContactCacheProvider.h"
#import "DataBaseModel.h"
#import "PhoneDataModel.h"
#import "ContactCacheChangeCommand.h"
#import "Person.h"

@implementation ContactCacheProvider

+ (NSArray *)allCacheConacts{
    NSString *sql = @"SELECT personID,name,lastUpdateTime FROM contact";
    NSMutableArray *contacts  = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *contactNumbers  = [self allConactsPhoneNumbers];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                ContactCacheDataModel *contact = [[ContactCacheDataModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    contact.fullName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,1)
                                                      encoding:NSUTF8StringEncoding];
                }
                contact.personID = sqlite3_column_int(stmt,0);
                contact.lastUpdateTime = sqlite3_column_int(stmt,2);
                contact.phones = [contactNumbers objectForKey:@(contact.personID)];
                [contacts addObject:contact];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return contacts;
}

+ (NSMutableDictionary *)allConactsPhoneNumbers{
    NSString *sql = @"SELECT personID,number,normalizedNumber FROM numbers";
    NSMutableDictionary *contactNumbers  = [NSMutableDictionary dictionaryWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                PhoneDataModel *phone = [[PhoneDataModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                   phone.number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,1)
                                                     encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    phone.normalizedNumber = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,2)
                                                                encoding:NSUTF8StringEncoding];
                }
                NSInteger phoneId = [ContactCacheDataModel getCurrentPhoneId];
                phone.phoneID = phoneId;
                NSInteger personID = sqlite3_column_int(stmt,0);
                NSMutableArray *phones = [contactNumbers objectForKey:@(personID)];
                if (phones) {
                    [phones addObject:phone];
                }else{
                    [contactNumbers setObject:[NSMutableArray arrayWithObject:phone]
                                       forKey:@(personID)];
                }
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return contactNumbers;
}

+ (void)insertContactCacheData:(NSArray *)contacts
{
     cootek_log(@"start insertContactCacheData");
    [DataBaseModel execute:DataBaseExecutionModeNew inDatabase:^(sqlite3* db) {
        sqlite3_exec(db,[@"BEGIN IMMEDIATE TRANSACTION;" UTF8String],NULL, NULL, NULL);
        NSString *contactSql = @"INSERT INTO contact(personID,name,lastUpdateTime) VALUES(?,?,?);";
        NSString *numbersSql = @"INSERT OR IGNORE INTO numbers(personID,number,normalizedNumber) VALUES(?,?,?);";
        sqlite3_stmt *stmtContacts = NULL;
        sqlite3_stmt *stmtNumbers = NULL;
        NSInteger resultContact = sqlite3_prepare_v2(db,[contactSql UTF8String], -1, &stmtContacts, NULL);
        NSInteger resultNumber = sqlite3_prepare_v2(db,[numbersSql UTF8String], -1, &stmtNumbers, NULL);
        for (ContactCacheDataModel *item in contacts){
            if (resultContact == SQLITE_OK) {
                NSString *fullName = item.fullName == nil ? @"" : item.fullName;
                sqlite3_bind_int(stmtContacts,1,item.personID);
                sqlite3_bind_text(stmtContacts,2,[fullName UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(stmtContacts,3,item.lastUpdateTime);
                sqlite3_step(stmtContacts);
                sqlite3_reset(stmtContacts);
            }
            NSArray *phones = item.phones;
            for (PhoneDataModel *phone in phones) {
                if ([phone.number length] > 0) {
                    if (resultNumber == SQLITE_OK) {
                        NSString *number = phone.number == nil ? @"" : phone.number;
                        NSString *normalizedNumber = phone.normalizedNumber == nil ? @"" : phone.normalizedNumber;
                        sqlite3_bind_int(stmtNumbers, 1, item.personID);
                        sqlite3_bind_text(stmtNumbers,2, [number UTF8String], -1, SQLITE_TRANSIENT);
                        sqlite3_bind_text(stmtNumbers,3, [normalizedNumber UTF8String], -1, SQLITE_TRANSIENT);
                        sqlite3_step(stmtNumbers);
                        sqlite3_reset(stmtNumbers);
                    }
                }
            }
        }
        int result = sqlite3_exec(db,[@"COMMIT;" UTF8String], NULL, NULL, NULL);
        cootek_log(@"insertContactCacheData result = %d",result);
        sqlite3_finalize(stmtContacts);
        sqlite3_finalize(stmtNumbers);
    }];
    cootek_log(@"end insertContactCacheData");
}
@end
