//
//  ContactCacheDataManager.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-25.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "ContactCacheDataManager.h"
#import "Person.h"
#import "CallLog.h"
#import "FunctionUtility.h"
#import "LangUtil.h"
#import "ContactModelNew.h"
#import "PhoneNumber.h"
#import "UserDefaultsManager.h"
#import "NSString+PhoneNumber.h"
#import "OrlandoEngine+Contact.h"
#import "ContactCacheProvider.h"
#import "SyncContactWhenAppEnterForground.h"
#import "CootekNotifications.h"
#import "VoipUtils.h"
#import "TouchpalMembersManager.h"
#import "TPDContactGroupModel.h"

static ContactCacheDataManager  *_sharedSingletonModel = nil;
static BOOL engineInited;

@interface ContactCacheDataManager()
@property(nonatomic,assign) BOOL needSyncCacheContactsToDBAfterRestart;
@end

@implementation ContactCacheDataManager

@synthesize contactsCacheDict;

+ (void)initialize
{
    _sharedSingletonModel = [[ContactCacheDataManager alloc] init];
}

+ (ContactCacheDataManager *)instance
{
	return _sharedSingletonModel;
}

+ (void)setEngineInited:(BOOL)isInited {
    engineInited = isInited;
}

+ (BOOL)isEngineInited {
    return engineInited;
}

- (id)init
{
	self = [super init];
	if(self != nil){
		contactsCacheDict = [[NSMutableDictionary alloc] init];
	}
	return self;
}
- (NSArray *)allContacts
{
    cootek_log(@"loadInitialData allContacts start");
    NSArray *contacts = [ContactCacheProvider allCacheConacts];
    if ([contacts count] == 0) {
        contacts = [Person queryAllContactsWhenNonCache];
        self.needSyncCacheContactsToDBAfterRestart = YES;
    }
    cootek_log(@"loadInitialData allContacts end");
    return contacts;
}

- (void) loadInitialData
{
    NSArray *person_list = [self allContacts];
    NSUInteger count=[person_list count];
    OrlandoEngine *initContact = [OrlandoEngine instance];
    for (int i=0 ; i<count; i++) {
        ContactCacheDataModel *person = [person_list objectAtIndex:i];
        [self initCacheContact:person withEngine:initContact];
    }
    [TouchpalMembersManager generateInitialData];
    [VoipUtils checkBackCallNumberPerson];
    [[ContactModelNew getSharedContactModel] buildAZtoAllContacts];
    [NSThread detachNewThreadSelector:@selector(synConactsToDBAfterInit)
                             toTarget:self
                           withObject:nil];
    [initContact excuteOperateEngine:^(){
        for (ContactCacheDataModel *enginePerson in person_list) {
            [enginePerson initNameToEngine:[OrlandoEngine instance]];
        }
        for (ContactCacheDataModel *enginePerson in person_list) {
            [enginePerson initNumberToEngine:[OrlandoEngine instance]];
        }
        engineInited = YES;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ENGINE_INIT object:nil];
        });
    }];

    cootek_log(@"loadInitialData  end");
}

- (void)synConactsToDBAfterInit
{
    if ([self needSyncCacheContactsToDBAfterRestart]) {
        self.needSyncCacheContactsToDBAfterRestart = NO;
        NSArray *contacts = [self getAllCacheContact];
        if (contacts) {
            [ContactCacheProvider insertContactCacheData:contacts];
        }
    }else{
        [SyncContactWhenAppEnterForground SyncDBAndABAdressBookConsistency];
    }
}

//获取所有联系人
- (NSArray *)getAllCacheContact
{
   	@synchronized(self.contactsCacheDict)
    {
        if([[contactsCacheDict allValues] count] == 0){
            return nil;
        }else{
            return [NSArray arrayWithArray:[contactsCacheDict allValues]];
        }
    }
}

- (NSArray *)getAllCacheContactID
{
    @synchronized(self.contactsCacheDict)
    {
        if([[contactsCacheDict allValues] count] == 0){
            return nil;
        }else{
            return [NSArray arrayWithArray:[contactsCacheDict allKeys]];
        }
    }
}

//获取所有联系人
- (NSArray *)getAllCacheContactGroups
{
   	@synchronized(self.contactsCacheDict)
    {
        if([[contactsCacheDict allValues] count] == 0){
            return nil;
        }else{
            return [self generateContactsGroupWithContacts:[contactsCacheDict allValues]];
        }
    }
}

- (NSArray *)generateContactsGroupWithContacts:(NSArray *)contact {
    
    NSMutableDictionary *contactsDictionary = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < contact.count; i++) {
        ContactCacheDataModel * contactModel = contact[i];
        NSString *candidateKey = wcharToNSString(getFirstLetter(NSStringToFirstWchar(contactModel.fullName)));
        NSMutableArray *contactGroup = [contactsDictionary objectForKey:candidateKey];
        if (contactGroup == nil) {
            contactGroup = [NSMutableArray array];
        }
        [contactGroup addObject:contactModel];
        [contactsDictionary setObject:contactGroup forKey:candidateKey];
    }
    
    NSArray *sortCandidateKeyArr = [[contactsDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *contactArr = [NSMutableArray array];
    for (NSString *candidateKey in sortCandidateKeyArr) {
        TPDContactGroupModel *groupModel = [[TPDContactGroupModel alloc] init];
        NSArray *contactGroup = [contactsDictionary objectForKey:candidateKey] ;
        groupModel.candidateKey = [candidateKey copy];
        groupModel.contacts = [contactGroup sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            NSString *obj1_str = ((ContactCacheDataModel*)obj1).displayName;
            NSString *obj2_str = ((ContactCacheDataModel*)obj2).displayName;
            return [obj1_str localizedCompare:obj2_str];
        }];
        
        [contactArr addObject:groupModel];
    }
    
    return contactArr;
    
}

- (void)initCacheContact:(ContactCacheDataModel *)item
              withEngine:(OrlandoEngine *)engineInstance
{
    [contactsCacheDict setObject:item forKey:@(item.personID)];
    [NumberPersonMappingModel setContactNumberMapping:item];
}

- (void)removeItemByID:(NSInteger)personID;
{
    @synchronized(self.contactsCacheDict){
        [contactsCacheDict removeObjectForKey:[NSNumber numberWithInteger:personID]];
    }
}

- (void)addItemByID:(ContactCacheDataModel *)item
{
    @synchronized(self.contactsCacheDict){
        [contactsCacheDict setObject:item forKey:@(item.personID)];
    }
}

//获取item根据personID
- (ContactCacheDataModel *)contactCacheItem:(NSInteger)personID
{
	if (!personID||personID<0) {
		return nil;
	}
	ContactCacheDataModel *item=[contactsCacheDict objectForKey:[NSNumber numberWithInteger:personID]];
	if (item) {
		return item;
	}
	return nil;
}

//是否存在
- (BOOL)isCacheItem:(NSInteger)personID
{
	if (!personID||personID<0) {
		return NO;
	}
	ContactCacheDataModel *item=[contactsCacheDict objectForKey:[NSNumber numberWithInteger:personID]];
    if (item) {
		return YES;
	}else {
		return NO;
	}	
}

- (BOOL)isCacheItemNumber:(NSInteger)personID
               withNumber:(NSString *)number
{
	ContactCacheDataModel *item=[contactsCacheDict objectForKey:[NSNumber numberWithInteger:personID]];
    if (item) {
        if(item.phones){
            NSArray *phone_list = item.phones;
            for (PhoneDataModel *phone in phone_list) {
                NSString *numberTo =[[PhoneNumber sharedInstance] getNormalizedNumber:phone.number];
                NSString *numberCompare =[[PhoneNumber sharedInstance] getNormalizedNumber:number];
                if ([numberTo isEqualToString:numberCompare]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSDictionary *)updateNormalizeNumberCacheWhenSimChange
{
    NSMutableDictionary *changes = [NSMutableDictionary dictionaryWithCapacity:1];
     @synchronized(self.contactsCacheDict){
         NSArray *contacts = contactsCacheDict.allValues;
         for (ContactCacheDataModel *item in contacts) {
             for (PhoneDataModel *phone in item.phones) {
                 NSString *normalize = [[PhoneNumber sharedInstance] getNormalizedNumber:phone.number];
                 if (![normalize isEqualToString:phone.normalizedNumber]) {
                     [changes setObject:normalize forKey:phone.normalizedNumber];
                     phone.normalizedNumber = normalize;
                 }
             }
         }
     }
    return changes;
}
@end
