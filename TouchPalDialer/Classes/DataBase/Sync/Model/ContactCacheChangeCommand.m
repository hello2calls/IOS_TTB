//
//  ContactCacheChangeModel.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-28.
//
//

#import "ContactCacheChangeCommand.h"
#import "ContactCacheDataManager.h"
#import "OrlandoEngine+Contact.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheProvider.h"
#import "ContactPropertyCacheManager.h"
#import "PersonDBA.h"

@implementation ContactCacheChangeCommand

@synthesize contact;

- (id)initContactCacheChangeModelWithCacheItem:(ContactCacheDataModel *)item
{
    self = [super init];
    if (self) {
        self.contact = item;
    }
    return self;
}

- (void)executeDB
{

}

- (void)excuteCache
{
    
}

- (void)excuteEngine
{

}

- (void)excuteMapping
{
}

- (void)executeSearchCache
{
    [[ContactPropertyCacheManager shareManager] updateSearchCache:self.contact.personID
                                                             Type:[self changeType]];
}

- (void)onExecute
{
    NotiPersonChangeData* changeData = [[NotiPersonChangeData alloc] initWithPersonId:self.contact.personID
                                                                           changeType:[self changeType]
                                                                          displayName:self.contact.displayName];
    [self excuteCache];
    [self executeSearchCache];
    [self excuteEngine];
    [self excuteMapping];
    [self executeDB];
    
    [PersonDBA getAllios9IdDic];
    
    //Delay is to make sure The UI is display first and then refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_DATA_CHANGED
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:changeData
                                                                                           forKey:KEY_PERSON_CHANGED]];
}

- (void)onExecuteMulti
{
    [self excuteCache];
    [self executeSearchCache];
    [self excuteEngine];
    [self excuteMapping];
    [self executeDB];
}


- (ContactChangeType )changeType
{
    return ContactChangeTypeAdd;
}

@end


@implementation DeleteContactCacheChangeCommand

- (void)executeDB
{
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        sqlite3_exec(db,[@"BEGIN TRANSACTION;" UTF8String],NULL, NULL, NULL);
        NSString *contactSql = @"DELETE FROM contact where personID = ?;";
        NSString *numbersSql = @"DELETE FROM numbers where personID = ?;";
        sqlite3_stmt *stmtContacts = NULL;
        sqlite3_stmt *stmtNumbers = NULL;
        NSInteger resultContact = sqlite3_prepare_v2(db,[contactSql UTF8String], -1, &stmtContacts, NULL);
        NSInteger resultNumber = sqlite3_prepare_v2(db,[numbersSql UTF8String], -1, &stmtNumbers, NULL);
        
        if (resultContact == SQLITE_OK) {
            sqlite3_bind_int(stmtContacts,1,self.contact.personID);
            sqlite3_step(stmtContacts);
            sqlite3_reset(stmtContacts);
        }
        
        if (resultNumber == SQLITE_OK) {
            sqlite3_bind_int(stmtNumbers,1,self.contact.personID);
            sqlite3_step(stmtNumbers);
            sqlite3_reset(stmtNumbers);
        }
        
        sqlite3_exec(db,[@"COMMIT;" UTF8String], NULL, NULL, NULL);
        sqlite3_finalize(stmtContacts);
        sqlite3_finalize(stmtNumbers);
    }];

}

- (void)excuteCache
{
    [[ContactCacheDataManager instance] removeItemByID:self.contact.personID];
}

- (void)excuteEngine
{
    [self.contact removeToEngine:[OrlandoEngine instance]];
}

- (void)excuteMapping
{
    for (PhoneDataModel *phone in self.contact.phones) {
        [NumberPersonMappingModel removePersonIDForNumber:phone.normalizedNumber];
    }
}

- (ContactChangeType )changeType
{
    return ContactChangeTypeDelete;
}

@end

@interface UpdateContactCacheChangeCommand()

@property(nonatomic,retain) DeleteContactCacheChangeCommand *delete;
@property(nonatomic,retain) AddContactCacheChangeCommand *add;

@end

@implementation UpdateContactCacheChangeCommand

- (id)initUpdateContactCacheDeleteModel:(DeleteContactCacheChangeCommand *)deleteModel
                               addModel:(AddContactCacheChangeCommand *)addModel
{
    self = [super init];
    if (self) {
        self.delete = deleteModel;
        self.add = addModel;
        self.contact = self.add.contact;
    }
    return self;
}

- (void)executeDB
{
    [self.delete executeDB];
    [self.add executeDB];
}

- (void)excuteCache
{
    [self.delete excuteCache];
    [self.add excuteCache];
}

- (void)excuteEngine
{
    [self.delete excuteEngine];
    [self.add excuteEngine];
}

- (void)excuteMapping
{
    [self.delete excuteMapping];
    [self.add excuteMapping];
}

- (ContactChangeType )changeType
{
    return ContactChangeTypeModify;
}


@end

@implementation AddContactCacheChangeCommand

- (void)executeDB
{
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        sqlite3_exec(db,[@"BEGIN TRANSACTION;" UTF8String],NULL, NULL, NULL);
        NSString *contactSql = @"INSERT INTO contact(personID,name,lastUpdateTime) VALUES(?,?,?);";
        NSString *numbersSql = @"INSERT OR IGNORE INTO numbers(personID,number,normalizedNumber) VALUES(?,?,?);";
        sqlite3_stmt *stmtContacts = NULL;
        sqlite3_stmt *stmtNumbers = NULL;
        NSInteger resultContact = sqlite3_prepare_v2(db,[contactSql UTF8String], -1, &stmtContacts, NULL);
        NSInteger resultNumber = sqlite3_prepare_v2(db,[numbersSql UTF8String], -1, &stmtNumbers, NULL);

        if (resultContact == SQLITE_OK) {
            sqlite3_bind_int(stmtContacts,1,self.contact.personID);
            sqlite3_bind_text(stmtContacts,2,[self.contact.fullName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stmtContacts,3,self.contact.lastUpdateTime);
            sqlite3_step(stmtContacts);
            sqlite3_reset(stmtContacts);
        }
        
        NSArray *phones = self.contact.phones;
        for (PhoneDataModel *phone in phones) {
            if ([phone.number length] > 0) {
                if (resultNumber == SQLITE_OK) {
                    sqlite3_bind_int(stmtNumbers,1,self.contact.personID);
                    sqlite3_bind_text(stmtNumbers,2,[phone.number UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_bind_text(stmtNumbers,3,[phone.normalizedNumber UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_step(stmtNumbers);
                    sqlite3_reset(stmtNumbers);
                }
            }
        }

        sqlite3_exec(db,[@"COMMIT;" UTF8String], NULL, NULL, NULL);
        sqlite3_finalize(stmtContacts);
        sqlite3_finalize(stmtNumbers);
    }];
}

- (void)excuteCache
{
    [[ContactCacheDataManager instance] addItemByID:self.contact];
}

- (void)excuteEngine
{
   [self.contact addToEngine:[OrlandoEngine instance]];
}

- (void)excuteMapping
{
    [NumberPersonMappingModel setContactNumberMapping:self.contact];
}

- (ContactChangeType )changeType
{
    return ContactChangeTypeAdd;
}

@end

@interface SimNormalizedContactCacheChangeCommand()

@property(nonatomic,copy) void (^action)();
@property(nonatomic,retain) NSDictionary *changes;

@end

@implementation SimNormalizedContactCacheChangeCommand


- (id)initWithExecuteAction:(void(^)())executeEngine
{
    self = [super init];
    if (self) {
        self.action = executeEngine;
    }
    return self;
}

- (void)executeDB
{
    [DataBaseModel execute:DataBaseExecutionModeNew inDatabase:^(sqlite3* db) {
        sqlite3_exec(db,[@"BEGIN TRANSACTION;" UTF8String],NULL, NULL, NULL);
        NSString *numbersSql = @"UPDATE numbers SET normalizedNumber = ? WHERE normalizedNumber = ?;";
        sqlite3_stmt *stmtNumbers = NULL;
        NSInteger resultContact = sqlite3_prepare_v2(db,[numbersSql UTF8String], -1, &stmtNumbers, NULL);
        NSArray *keys = [self.changes allKeys];
        for (NSString *key in keys) {
            if (resultContact == SQLITE_OK) {
                sqlite3_bind_text(stmtNumbers,1,[[self.changes objectForKey:key] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(stmtNumbers,2,[key UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_step(stmtNumbers);
                sqlite3_reset(stmtNumbers);
            }
        }
        sqlite3_exec(db,[@"COMMIT;" UTF8String], NULL, NULL, NULL);
        sqlite3_finalize(stmtNumbers);
    }];
}

- (void)excuteCache
{
    self.changes = [[ContactCacheDataManager instance] updateNormalizeNumberCacheWhenSimChange];
}

- (void)excuteEngine
{
    if (self.action) {
        self.action();
    }
}

- (void)excuteMapping
{
    [NumberPersonMappingModel refreshLocalCache];
}

- (void)onExecute
{
    @autoreleasepool {
        [self excuteEngine];
        [self excuteMapping];
        [self excuteCache];
        [self executeDB];
    }
}


@end

@implementation ContactCacheChangeCommandManager

+ (void)excuteAdd:(sqlite3_stmt *)stmtContacts
             item:(ContactCacheDataModel *)item
    resultContact:(NSInteger)resultContact
      stmtNumbers:(sqlite3_stmt *)stmtNumbers
     resultNumber:(NSInteger)resultNumber
{
    if (resultContact == SQLITE_OK) {
        sqlite3_bind_int(stmtContacts,1,item.personID);
        sqlite3_bind_text(stmtContacts,2,[item.fullName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmtContacts,3,item.lastUpdateTime);
        sqlite3_step(stmtContacts);
        sqlite3_reset(stmtContacts);
    }
    NSArray *phones = item.phones;
    for (PhoneDataModel *phone in phones) {
        if ([phone.number length] > 0) {
            if (resultNumber == SQLITE_OK) {
                sqlite3_bind_int(stmtNumbers,1,item.personID);
                sqlite3_bind_text(stmtNumbers,2,[phone.number UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(stmtNumbers,3,[phone.normalizedNumber UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_step(stmtNumbers);
                sqlite3_reset(stmtNumbers);
            }
        }
    }
}

+ (void)excuteDelete:(sqlite3_stmt *)stmtContacts
                item:(ContactCacheDataModel *)item
       resultContact:(NSInteger)resultContact
         stmtNumbers:(sqlite3_stmt *)stmtNumbers
        resultNumber:(NSInteger)resultNumber
{
    
    if (resultContact == SQLITE_OK) {
        sqlite3_bind_int(stmtContacts,1,item.personID);
        sqlite3_step(stmtContacts);
        sqlite3_reset(stmtContacts);
    }
    
    if (resultNumber == SQLITE_OK) {
        sqlite3_bind_int(stmtNumbers,1,item.personID);
        sqlite3_step(stmtNumbers);
        sqlite3_reset(stmtNumbers);
    }
}

+ (void)executeChangeModels:(NSArray *)changes
{
    if ([changes count] == 0) {
        return;
    }
    [DataBaseModel execute:DataBaseExecutionModeNew inDatabase:^(sqlite3* db) {
        sqlite3_exec(db,[@"BEGIN IMMEDIATE TRANSACTION;" UTF8String],NULL, NULL, NULL);
        
        NSString *contactAddSql = @"INSERT INTO contact(personID,name,lastUpdateTime) VALUES(?,?,?);";
        NSString *numbersAddSql = @"INSERT OR IGNORE INTO numbers(personID,number,normalizedNumber) VALUES(?,?,?);";
        sqlite3_stmt *stmtContacts = NULL;
        sqlite3_stmt *stmtNumbers = NULL;
        NSInteger resultContact = sqlite3_prepare_v2(db,[contactAddSql UTF8String], -1, &stmtContacts, NULL);
        NSInteger resultNumber = sqlite3_prepare_v2(db,[numbersAddSql UTF8String], -1, &stmtNumbers, NULL);
        
        NSString *contactDelSql = @"DELETE FROM contact where personID = ?;";
        NSString *numbersDelSql = @"DELETE FROM numbers where personID = ?;";
        sqlite3_stmt *stmtDelContacts = NULL;
        sqlite3_stmt *stmtDelNumbers = NULL;
        NSInteger resultDelContact = sqlite3_prepare_v2(db,[contactDelSql UTF8String], -1, &stmtDelContacts, NULL);
        NSInteger resultDelNumber = sqlite3_prepare_v2(db,[numbersDelSql UTF8String], -1, &stmtDelNumbers, NULL);
        
        for (ContactCacheChangeCommand *change in changes) {
            @autoreleasepool {
                [change excuteCache];
                [change executeSearchCache];
                [change excuteEngine];
                [change excuteMapping];
                
                ContactCacheDataModel *item = change.contact;
                switch ([change changeType]) {
                    case ContactChangeTypeAdd:
                        [self excuteAdd:stmtContacts
                                   item:item
                          resultContact:resultContact
                            stmtNumbers:stmtNumbers
                           resultNumber:resultNumber];
                        break;
                    case ContactChangeTypeDelete:
                        [self excuteDelete:stmtDelContacts
                                      item:item
                             resultContact:resultDelContact
                               stmtNumbers:stmtDelNumbers
                              resultNumber:resultDelNumber];
                        break;
                        
                    default:
                        break;
                }
            }
        }
        sqlite3_exec(db,[@"COMMIT;" UTF8String], NULL, NULL, NULL);
    
        sqlite3_finalize(stmtContacts);
        sqlite3_finalize(stmtNumbers);
        sqlite3_finalize(stmtDelContacts);
        sqlite3_finalize(stmtDelNumbers);
    }];
}

@end
