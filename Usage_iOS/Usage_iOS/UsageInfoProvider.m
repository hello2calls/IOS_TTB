//
//  UsageInfoProvider.m
//  Usage_iOS
//
//  Created by SongchaoYuan on 16/2/16.
//  Copyright © 2016年 Cootek. All rights reserved.
//

#import "UsageInfoProvider.h"
#import "UsageData.h"
#import <Contacts/Contacts.h>
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import <FMDB/FMDatabaseQueue.h>
#import "UsageSettings.h"

@class ContactItem;
@class EmailItem;
@class OrganizationItem;
@class IMItem;
@class AddressItem;
@class EventItem;
@class RelationItem;
@class SocialProfileItem;

static const NSInteger UsageInfoLength = 2;
NSString * const UsageTypeInfo = @"noah_info";
NSString * const NoahInfoSpecificKey = @"__noah_info_specific_key";

#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface ContactItem : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray<NSString *> *phone;
@property (nonatomic, strong) NSMutableArray<EmailItem *> *email;
@property (nonatomic, strong) NSMutableArray<OrganizationItem *> *organization;
@property (nonatomic, strong) NSMutableArray<IMItem *> *im;
@property (nonatomic, strong) NSMutableArray<AddressItem *> *address;
@property (nonatomic, strong) NSMutableArray<EventItem *> *event;
@property (nonatomic, strong) NSMutableArray<RelationItem *> *relation;
@property (nonatomic, strong) NSMutableArray<SocialProfileItem *> *socialProfile;
@end

@implementation ContactItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.phone = [[NSMutableArray<NSString *> alloc] init];
        self.email = [[NSMutableArray<EmailItem *> alloc] init];
        self.organization = [[NSMutableArray<OrganizationItem *> alloc] init];
        self.im = [[NSMutableArray<IMItem *> alloc] init];
        self.address = [[NSMutableArray<AddressItem *> alloc] init];
        self.event = [[NSMutableArray<EventItem *> alloc] init];
        self.relation = [[NSMutableArray<RelationItem *> alloc] init];
        self.socialProfile = [[NSMutableArray<SocialProfileItem *> alloc] init];
    }
    return self;
}
@end

@interface EmailItem : NSObject
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *type;
@end

@implementation EmailItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end

@interface OrganizationItem : NSObject
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *department;
- (BOOL)isEmpty;
@end

@implementation OrganizationItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isEmpty {
    return [self.company length] == 0 && [self.title length] == 0 && [self.department length] == 0;
}
@end

@interface IMItem : NSObject
@property (nonatomic, strong) NSString *im;
@property (nonatomic, strong) NSString *protocol;
@end

@implementation IMItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end

@interface AddressItem : NSObject
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *type;
@end

@implementation AddressItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end

@interface EventItem : NSObject
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *type;
@end

@implementation EventItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end

@interface RelationItem : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@end

@implementation RelationItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end

@interface SocialProfileItem : NSObject
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *type;
@end

@implementation SocialProfileItem
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end

@implementation UsageInfoData
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end


#pragma mark Usage Info Provider
@interface UsageInfoProvider()

@property (strong, nonatomic) FMDatabaseQueue * dbQueue;

@end

@implementation UsageInfoProvider

static NSString *const DEFAULT_DB_NAME = @"data.sqlite";
static NSString *const DEFAULT_CALL_TABLE_NAME = @"calllog";
static NSString *const SELECT_ALL_SQL = @"SELECT * from %@";
static NSString *const SELECT_CALLLOG_SQL = @"SELECT * from %@ where rowId > %@ ORDER BY rowId ASC LIMIT 300";

+ (BOOL)checkTableName:(NSString *)tableName {
    if (tableName == nil || tableName.length == 0 || [tableName rangeOfString:@" "].location != NSNotFound) {
#ifdef DEBUG
        NSLog(@"ERROR, table name: %@ format error.", tableName);
#endif
        return NO;
    }
    return YES;
}

- (instancetype)init {
    return [self initDBWithName:DEFAULT_DB_NAME];
}

- (id)initDBWithName:(NSString *)dbName {
    self = [super init];
    if (self) {
        NSString * dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:dbName];
#ifdef DEBUG
        NSLog(@"dbPath = %@", dbPath);
#endif
        if (_dbQueue) {
            [self close];
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (void)close {
    [_dbQueue close];
    _dbQueue = nil;
}

- (NSString *)getType {
    return UsageTypeInfo;
}

- (NSInteger)getLength {
    return UsageInfoLength;
}

- (NSString *)getPath:(NSInteger)i {
    switch (i) {
        case kUsageInfoContact:
            return @"noah_reserve_00";
        case kUsageInfoCallVOIPHistory:
            return @"noah_reserve_04";
    }
    return nil;
}

- (UsageInfoData *)getData:(NSInteger)i {
    switch (i) {
        case kUsageInfoContact:
            return [self getContact];
        case kUsageInfoCallVOIPHistory:
            return [self getCallVoipHistory];
    }
    return nil;
}

#pragma mark Contact Info
- (UsageInfoData *)getContact {
//    别的App可能要申请通讯录权限，但是最好不要用ABAddressBookRef
//    BOOL __block flag = NO;
//    ABAddressBookRef addBook=ABAddressBookCreateWithOptions(NULL, NULL);
//    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
//    if (authStatus != kABAuthorizationStatusAuthorized) {
//        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
//        ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error) {
//            if (!greanted) {
//                flag = YES;
//            }
//            dispatch_semaphore_signal(sema);
//        });
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    }
//    if (flag) {
//        return nil;
//    }
    UsageInfoData *ret = [[UsageInfoData alloc] init];
    NSMutableArray __block *array = [[NSMutableArray alloc] init];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc]
                                      initWithKeysToFetch:@[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],            CNContactPhoneNumbersKey,
                                        CNContactEmailAddressesKey,
                                        CNContactOrganizationNameKey,
                                        CNContactDepartmentNameKey,
                                        CNContactJobTitleKey,
                                        CNContactInstantMessageAddressesKey,
                                        CNContactPostalAddressesKey,
                                        CNContactBirthdayKey,
                                        CNContactNonGregorianBirthdayKey,
                                        CNContactDatesKey,
                                        CNContactRelationsKey,
                                        CNContactSocialProfilesKey]];
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        ContactItem *item = [[ContactItem alloc] init];
        //Name
        item.name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
#ifdef DEBUG
        NSLog(@"name = %@",item.name);
#endif
        
        //Phone
        NSArray *phoneArray = [contact phoneNumbers];
        for (CNLabeledValue *labeledValue in phoneArray) {
            [item.phone addObject:[(CNPhoneNumber *)[labeledValue value] stringValue]];
        }
#ifdef DEBUG
        NSLog(@"phones = %@",item.phone);
#endif
        
        //Email
        NSArray *emailArray = [contact emailAddresses];
        for (CNLabeledValue *labeledValue in emailArray) {
            EmailItem *emailItem = [[EmailItem alloc] init];
            emailItem.email = (NSString *)[labeledValue value];
            emailItem.type = [self getFormattedType:[labeledValue label]];
#ifdef DEBUG
            NSLog(@"email = %@",emailItem.email);
            NSLog(@"type = %@",emailItem.type);
#endif
            [item.email addObject:emailItem];
        }
        
        //Organization
        OrganizationItem *organizationItem = [[OrganizationItem alloc] init];
        organizationItem.company = [contact organizationName];
        organizationItem.department = [contact departmentName];
        organizationItem.title = [contact jobTitle];
        if (![organizationItem isEmpty]) {
#ifdef DEBUG
            NSLog(@"company = %@", organizationItem.company);
            NSLog(@"department = %@", organizationItem.department);
            NSLog(@"title = %@", organizationItem.title);
#endif
            [item.organization addObject:organizationItem];
        }
        
        //IM
        NSArray *imArray = [contact instantMessageAddresses];
        for (CNLabeledValue *labeledValue in imArray) {
            IMItem *imItem = [[IMItem alloc] init];
            imItem.im = [(CNInstantMessageAddress *)[labeledValue value] username];
            imItem.protocol = [(CNInstantMessageAddress *)[labeledValue value] service];
#ifdef DEBUG
            NSLog(@"im = %@",imItem.im);
            NSLog(@"protocol = %@",imItem.protocol);
#endif
            [item.im addObject:imItem];
        }
        
        //Address
        NSArray *addressArray = [contact postalAddresses];
        for (CNLabeledValue *labeledValue in addressArray) {
            AddressItem *addressItem = [[AddressItem alloc] init];
            addressItem.address = [CNPostalAddressFormatter stringFromPostalAddress:(CNPostalAddress *)[labeledValue value] style:CNPostalAddressFormatterStyleMailingAddress];
            addressItem.type = [self getFormattedType:[labeledValue label]];
#ifdef DEBUG
            NSLog(@"address = %@",addressItem.address);
            NSLog(@"type = %@",addressItem.type);
#endif
            [item.address addObject:addressItem];
        }
        
        //Event
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        
        NSDateComponents *birthday = [contact birthday];
        if (birthday != nil) {
            EventItem *birthdayEvent = [[EventItem alloc] init];
            NSDate *birthdayDate = [birthday.calendar dateFromComponents:birthday];
            birthdayEvent.date = [dateFormatter stringFromDate:birthdayDate];
            birthdayEvent.type = @"BIRTHDAY";
#ifdef DEBUG
            NSLog(@"date = %@",birthdayEvent.date);
            NSLog(@"type = %@",birthdayEvent.type);
#endif
            [item.event addObject:birthdayEvent];
        }
        
        NSDateComponents *nonGregorianBirthday = [contact nonGregorianBirthday];
        if (nonGregorianBirthday != nil) {
            EventItem *nonGregorianBirthdayEvent = [[EventItem alloc] init];
            NSDate *nonGregorianBirthdayDate = [nonGregorianBirthday.calendar dateFromComponents:nonGregorianBirthday];
            nonGregorianBirthdayEvent.date = [dateFormatter stringFromDate:nonGregorianBirthdayDate];
            nonGregorianBirthdayEvent.type = [self getBirthdayCalendarType:nonGregorianBirthday.calendar.calendarIdentifier];
#ifdef DEBUG
            NSLog(@"date = %@",nonGregorianBirthdayEvent.date);
            NSLog(@"type = %@",nonGregorianBirthdayEvent.type);
#endif
            [item.event addObject:nonGregorianBirthdayEvent];
        }
        
        NSArray *dateArray = [contact dates];
        for (CNLabeledValue *labeledValue in dateArray) {
            EventItem *dateEvent = [[EventItem alloc] init];
            NSDateComponents *dateComponents = (NSDateComponents *)[labeledValue value];
            NSDate *date = [[dateComponents calendar] dateFromComponents:dateComponents];
            dateEvent.date = [dateFormatter stringFromDate:date];
            dateEvent.type = [self getFormattedType:[labeledValue label]];
#ifdef DEBUG
            NSLog(@"date = %@",dateEvent.date);
            NSLog(@"type = %@",dateEvent.type);
#endif
            [item.event addObject:dateEvent];
        }
        
        //Relation
        NSArray *relationArray = [contact contactRelations];
        for (CNLabeledValue *labeledValue in relationArray) {
            RelationItem *relationItem = [[RelationItem alloc] init];
            relationItem.name = [(CNContactRelation *)[labeledValue value] name];
            relationItem.type = [self getRelationType:[labeledValue label]];
#ifdef DEBUG
            NSLog(@"name = %@",relationItem.name);
            NSLog(@"type = %@",relationItem.type);
#endif
            [item.relation addObject:relationItem];
        }
        
        //SocialProfile
        NSArray *socialProfileArray = [contact socialProfiles];
        for (CNLabeledValue *labeledValue in socialProfileArray) {
            SocialProfileItem *spItem = [[SocialProfileItem alloc] init];
            spItem.account = [(CNSocialProfile *)[labeledValue value] username];
            spItem.type = [(CNSocialProfile *)[labeledValue value] service];
#ifdef DEBUG
            NSLog(@"account = %@",spItem.account);
            NSLog(@"type = %@",spItem.type);
#endif
            [item.socialProfile addObject:spItem];
        }
        
        [array addObject:item];
        
    }];
    
    if ([array count] == 0) {
        ret.hasData = NO;
        return ret;
    }
    
    //转换成Array
    NSMutableArray *dataArray =[[NSMutableArray alloc] init];
    for (ContactItem *item in array) {
        if ([item.name length] == 0) {
            continue;
        }
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        [tmp setObject:item.name forKey:@"name"];
        if ([item.phone count] > 0) {
            [tmp setObject:[item.phone copy] forKey:@"phone"];
        }
        if ([item.email count] > 0) {
            NSMutableArray *tmpEmailArray = [[NSMutableArray alloc] init];
            for (EmailItem *tmpEmail in item.email) {
                NSMutableDictionary *tmpEmailDict = [[NSMutableDictionary alloc] init];
                if ([tmpEmail.email length] > 0) {
                    [tmpEmailDict setObject:tmpEmail.email forKey:@"address"];
                } else {
                    continue;
                }
                if ([tmpEmail.type length] > 0) {
                    [tmpEmailDict setObject:tmpEmail.type forKey:@"type"];
                }
                [tmpEmailArray addObject:tmpEmailDict];
            }
            if ([tmpEmailArray count] > 0) {
                [tmp setObject:tmpEmailArray forKey:@"email"];
            }
        }
        if ([item.organization count] > 0) {
            NSMutableArray *tmpOrgArray = [[NSMutableArray alloc] init];
            for (OrganizationItem *tmpOrg in item.organization) {
                NSMutableDictionary *tmpOrgDict = [[NSMutableDictionary alloc] init];
                BOOL valid = NO;
                if ([tmpOrg.company length] > 0) {
                    [tmpOrgDict setObject:tmpOrg.company forKey:@"company"];
                    valid = YES;
                }
                if ([tmpOrg.title length] > 0) {
                    [tmpOrgDict setObject:tmpOrg.title forKey:@"title"];
                    valid = YES;
                }
                if ([tmpOrg.department length] > 0) {
                    [tmpOrgDict setObject:tmpOrg.department forKey:@"department"];
                    valid = YES;
                }
                if (valid) {
                    [tmpOrgArray addObject:tmpOrgDict];
                }
            }
            if ([tmpOrgArray count] > 0) {
                [tmp setObject:tmpOrgArray forKey:@"organization"];
            }
        }
        if ([item.im count] > 0) {
            NSMutableArray *tmpIMArray = [[NSMutableArray alloc] init];
            for (IMItem *tmpIM in item.im) {
                NSMutableDictionary *tmpIMDict = [[NSMutableDictionary alloc] init];
                if ([tmpIM.im length] > 0) {
                    [tmpIMDict setObject:tmpIM.im forKey:@"account"];
                } else {
                    continue;
                }
                if ([tmpIM.protocol length] > 0) {
                    [tmpIMDict setObject:tmpIM.protocol forKey:@"protocol"];
                }
                [tmpIMArray addObject:tmpIMDict];
            }
            if ([tmpIMArray count] > 0) {
                [tmp setObject:tmpIMArray forKey:@"im"];
            }
        }
        if ([item.address count] > 0) {
            NSMutableArray *tmpAddArray = [[NSMutableArray alloc] init];
            for (AddressItem *tmpAdd in item.address) {
                NSMutableDictionary *tmpAddDict = [[NSMutableDictionary alloc] init];
                if ([tmpAdd.address length] > 0) {
                    [tmpAddDict setObject:tmpAdd.address forKey:@"formatted_address"];
                } else {
                    continue;
                }
                if ([tmpAdd.type length] > 0) {
                    [tmpAddDict setObject:tmpAdd.type forKey:@"type"];
                }
                [tmpAddArray addObject:tmpAddDict];
            }
            if ([tmpAddArray count] > 0) {
                [tmp setObject:tmpAddArray forKey:@"address"];
            }
        }
        if ([item.event count] > 0) {
            NSMutableArray *tmpEventArray = [[NSMutableArray alloc] init];
            for (EventItem *tmpEvent in item.event) {
                NSMutableDictionary *tmpEventDict = [[NSMutableDictionary alloc] init];
                if ([tmpEvent.date length] > 0) {
                    [tmpEventDict setObject:tmpEvent.date forKey:@"date"];
                } else {
                    continue;
                }
                if ([tmpEvent.type length] > 0) {
                    [tmpEventDict setObject:tmpEvent.type forKey:@"type"];
                }
                [tmpEventArray addObject:tmpEventDict];
            }
            if ([tmpEventArray count] > 0) {
                [tmp setObject:tmpEventArray forKey:@"event"];
            }
        }
        if ([item.relation count] > 0) {
            NSMutableArray __block *tmpReArray = [[NSMutableArray alloc] init];
            [item.relation enumerateObjectsUsingBlock:^(RelationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *tmpReDict = [[NSMutableDictionary alloc] init];
                if ([obj.name length] > 0) {
                    [tmpReDict setObject:obj.name forKey:@"name"];
                } else {
                    return;
                }
                if ([obj.type length] > 0) {
                    [tmpReDict setObject:obj.type forKey:@"type"];
                }
                [tmpReArray addObject:tmpReDict];
            }];
            if ([tmpReArray count] > 0) {
                [tmp setObject:tmpReArray forKey:@"relation"];
            }
        }
        if ([item.socialProfile count] > 0) {
            NSMutableArray __block *tmpSPArray = [[NSMutableArray alloc] init];
            [item.socialProfile enumerateObjectsUsingBlock:^(SocialProfileItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *tmpSPDict = [[NSMutableDictionary alloc] init];
                if ([obj.account length] > 0) {
                    [tmpSPDict setObject:obj.account forKey:@"account"];
                } else {
                    return;
                }
                if ([obj.type length] > 0) {
                    [tmpSPDict setObject:obj.type forKey:@"type"];
                }
                [tmpSPArray addObject:tmpSPDict];
            }];
            if ([tmpSPArray count] > 0) {
                [tmp setObject:tmpSPArray forKey:@"social_profile"];
            }
        }
        [dataArray addObject:tmp];
        ret.hasData = YES;
    }
    UsageRecord *ur = [[UsageRecord alloc] init];
    ur.type = [self getType];
    ur.path = [self getPath:kUsageInfoContact];
    ur.values = [NSDictionary dictionaryWithObjectsAndKeys:dataArray, NoahInfoSpecificKey,nil];
    ret.data = ur;
    ret.infoPath = [self getPath:kUsageInfoContact];
    return ret;
}

- (NSString *)getFormattedType:(NSString *)labelType {
    if ([labelType isEqualToString:CNLabelHome]) {
        return @"HOME";
    } else if ([labelType isEqualToString:CNLabelWork]) {
        return @"WORK";
    } else if ([labelType isEqualToString:CNLabelOther]) {
        return @"OTHER";
    } else if ([labelType isEqualToString:CNLabelEmailiCloud]) {
        return @"ICLOUD";
    } else if ([labelType isEqualToString:CNLabelDateAnniversary]) {
        return @"ANNIVERSARY";
    } else {
        return labelType.uppercaseString;
    }
}

- (NSString *)getBirthdayCalendarType:(NSString *)calendarIdentifier {
    if ([calendarIdentifier isEqualToString:NSBuddhistCalendar]) {
        return @"BUDDHIST_BIRTHDAY";
    } else if ([calendarIdentifier isEqualToString:NSChineseCalendar]) {
        return @"CHINESE_BIRTHDAY";
    } else if ([calendarIdentifier isEqualToString:NSIslamicCalendar]) {
        return @"ISLAMIC_BIRTHDAY";
    } else if ([calendarIdentifier isEqualToString:NSHebrewCalendar]) {
        return @"HEBREW_BIRTHDAY";
    } else if ([calendarIdentifier isEqualToString:NSIslamicCivilCalendar]) {
        return @"ISLAMIC_CIVIL_BIRTHDAY";
    }
    return [NSString stringWithFormat:@"%@_BIRTHDAY",calendarIdentifier.uppercaseString];
}

- (NSString *)getRelationType:(NSString *)labelType {
    if ([labelType isEqualToString:CNLabelContactRelationFather]) {
        return @"FATHER";
    } else if ([labelType isEqualToString:CNLabelContactRelationMother]) {
        return @"MOTHER";
    } else if ([labelType isEqualToString:CNLabelContactRelationParent]) {
        return @"PARENT";
    } else if ([labelType isEqualToString:CNLabelContactRelationBrother]) {
        return @"BROTHER";
    } else if ([labelType isEqualToString:CNLabelContactRelationSister]) {
        return @"SISTER";
    } else if ([labelType isEqualToString:CNLabelContactRelationChild]) {
        return @"CHILD";
    } else if ([labelType isEqualToString:CNLabelContactRelationFriend]) {
        return @"FRIEND";
    } else if ([labelType isEqualToString:CNLabelContactRelationSpouse]) {
        return @"SPOUSE";
    } else if ([labelType isEqualToString:CNLabelContactRelationPartner]) {
        return @"PARTNER";
    } else if ([labelType isEqualToString:CNLabelContactRelationAssistant]) {
        return @"ASSISTANT";
    } else if ([labelType isEqualToString:CNLabelContactRelationManager]) {
        return @"MANAGER";
    } else if ([labelType isEqualToString:CNLabelOther]) {
        return @"OTHER";
    } else {
        return labelType.uppercaseString;
    }
}

#pragma mark Call VOIP History Info
- (UsageInfoData *)getCallVoipHistory {
    if (![self isTableExists:DEFAULT_CALL_TABLE_NAME]) {
        return nil;
    }
    __block UsageInfoData *ret = [[UsageInfoData alloc] init];
    NSString *lastId = [NSString stringWithFormat:@"%lld",[[UsageSettings getInst] getLastInfoSuccessId:[self getPath:kUsageInfoCallVOIPHistory]]];
    NSString * sql = [NSString stringWithFormat:SELECT_CALLLOG_SQL, DEFAULT_CALL_TABLE_NAME, lastId];
    __block NSMutableArray * result = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            ret.lastId = [rs unsignedLongLongIntForColumn:@"rowId"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[rs stringForColumn:@"phoneNumber"] forKey:@"other_phone"];
            [dict setObject:[NSNumber numberWithLongLong:[rs longForColumn:@"callTime"]*1000] forKey:@"date"];
            [dict setObject:[NSNumber numberWithLongLong:[rs longForColumn:@"duration"]] forKey:@"duration"];
            [dict setObject:[NSNumber numberWithLongLong:[rs longForColumn:@"personID"]] forKey:@"contact"];
            [dict setObject:[rs longForColumn:@"callType"]?@"incoming":@"outgoing" forKey:@"type"];
            [dict setObject:[rs longForColumn:@"ifVoip"]?@"c2p":@"p2p" forKey:@"call_type"];
            [result addObject:dict];
        }
        [rs close];
    }];
    if ([result count] == 0) {
        ret.hasData = NO;
        return ret;
    } else {
        ret.hasData = YES;
    }
    UsageRecord *ur = [[UsageRecord alloc] init];
    ur.type = [self getType];
    ur.path = [self getPath:kUsageInfoCallVOIPHistory];
    ur.values = [NSDictionary dictionaryWithObjectsAndKeys:result, NoahInfoSpecificKey,nil];
    ret.data = ur;
    ret.infoPath = [self getPath:kUsageInfoCallVOIPHistory];
    return ret;
}

- (BOOL)isTableExists:(NSString *)tableName{
    if ([UsageInfoProvider checkTableName:DEFAULT_CALL_TABLE_NAME] == NO) {
        return NO;
    }
    __block BOOL result;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    return result;
}

@end