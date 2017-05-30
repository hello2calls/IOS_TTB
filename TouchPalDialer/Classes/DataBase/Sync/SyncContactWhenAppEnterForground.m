//
//  SynContract.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-15.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "SyncContactWhenAppEnterForground.h"
#import "PersonDBA.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "OrlandoEngine.h"
#import "consts.h"
#import "CallLogDBA.h"
#import "CootekNotifications.h"
#import "NumberPersonMappingModel.h"
#import "AttributeModel.h"
#import "TPAddressBookWrapper.h"
#import "OrlandoEngine+Contact.h"
#import "ContactCacheChangeCommand.h"
#import "SyncTouchPalAccount.h"

static BOOL NeedsRespondToABChange_;

@implementation SyncContactWhenAppEnterForground

+ (void)initialize
{
    NeedsRespondToABChange_ = NO;
}

+ (BOOL)needsRespondToABChange
{
    return NeedsRespondToABChange_;
}

+ (void)setNeedsRespondToABChange:(BOOL)need
{
    NeedsRespondToABChange_ = need;
}

+ (void)SyncDBAndABAdressBookConsistency
{
    ABAddressBookRef addrBookRef = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    if(addrBookRef)
    {
        NSArray * changeModels = [self mergeConactsABAddressBookToDBCache:[[ContactCacheDataManager instance] getAllCacheContact]
                                                                  current:[PersonDBA getAsyncAllContactWhenAddressBookChanged:addrBookRef]];
        if ([changeModels count] == 0) {
            return;
        }
        [ContactCacheChangeCommandManager executeChangeModels:changeModels];
        [PersonDBA getAllios9IdDic];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:N_SYSTEM_CONTACT_DATA_CHANGED object:nil userInfo:nil];
            if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                [SyncContactWhenAppEnterForground setNeedsRespondToABChange:YES];
            }
        });
    }
}

//数据库发生变化时，改变缓存的搜索数据
+(void)SynContractCacheWhenAdreessBookChange{	
    [self SyncDBAndABAdressBookConsistency];
}

+ (NSArray *)mergeConactsABAddressBookToDBCache:(NSArray *)oldContacts current:(NSArray *)currentContacts
{
    NSMutableArray *cacheContactsChanged = [NSMutableArray arrayWithCapacity:1];
    NSUInteger currentPersonCount = [currentContacts count];
    NSUInteger oldPersonCount = [oldContacts count];
    
    //新的的联系人列表存入字典
    NSMutableDictionary *newCacheDict = [NSMutableDictionary dictionaryWithCapacity:currentPersonCount];
    for (int i=0; i < currentPersonCount; i++) {
        ContactCacheDataModel *person=[currentContacts objectAtIndex:i];
        [newCacheDict setObject:person forKey:[NSNumber numberWithInteger:person.personID]];
    }
    //旧的的联系人列表存入字典
    NSMutableDictionary *oldCacheDict=[NSMutableDictionary dictionaryWithCapacity:oldPersonCount];
    for (int i=0; i < oldPersonCount; i++) {
        ContactCacheDataModel *person=[oldContacts objectAtIndex:i];
        [oldCacheDict setObject:person forKey:[NSNumber numberWithInteger:person.personID]];
    }
    
    //查找旧的的缓存
    for(ContactCacheDataModel *oldPerson in oldContacts)
    {
        ContactCacheDataModel *newPerson=[newCacheDict objectForKey:[NSNumber numberWithInteger:oldPerson.personID]];
        if (newPerson) {
            if (newPerson.lastUpdateTime > oldPerson.lastUpdateTime) {
                DeleteContactCacheChangeCommand *changeDelete = [[DeleteContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:oldPerson];
                [cacheContactsChanged addObject:changeDelete];
                AddContactCacheChangeCommand *changeAdd = [[AddContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:newPerson];
                [cacheContactsChanged addObject:changeAdd];
            }
        }else {
            DeleteContactCacheChangeCommand *change = [[DeleteContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:oldPerson];
            [cacheContactsChanged addObject:change];
        }
    }
    //查找新的缓存
    for(ContactCacheDataModel *newPerson in currentContacts)
    {
        ContactCacheDataModel *old_person=[oldCacheDict objectForKey:[NSNumber numberWithInteger:newPerson.personID]];
        if (!old_person) {
            AddContactCacheChangeCommand *change = [[AddContactCacheChangeCommand alloc] initContactCacheChangeModelWithCacheItem:newPerson];
            [cacheContactsChanged addObject:change];
        }
    }
    return cacheContactsChanged;
}

//注册数据库监听
+(void)registerAddressBooKListener
{	
	ABAddressBookRegisterExternalChangeCallback([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread],addressBookChanged,(__bridge void *)(self));
}

//数据库发生变化
void addressBookChanged(ABAddressBookRef address_book, CFDictionaryRef info, void *context)
{
    @autoreleasepool {
        if([SyncContactWhenAppEnterForground needsRespondToABChange]) {
            [SyncContactWhenAppEnterForground setNeedsRespondToABChange:NO];
            ABAddressBookRevert(address_book);
            [SyncContactWhenAppEnterForground startThreadToAsynContact];
        }
    }
}

//注销数据库监听
+(void)unregisterAddressBooKListener
{
	ABAddressBookUnregisterExternalChangeCallback([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread], addressBookChanged,nil);
}

+(void)startSyncUpdateCache
{
    @autoreleasepool {
        [TPAddressBookWrapper CreateAddressBookRefForCurrentThread];
        [SyncContactWhenAppEnterForground SynContractCacheWhenAdreessBookChange];
        [SyncTouchPalAccount updateAllContactTouchPalAccount];
        [TPAddressBookWrapper ReleaseAddressBookForCurrentThread];
    }
}

//开启线程监听数据库变化
+(void)startThreadToAsynContact
{
	[NSThread detachNewThreadSelector:@selector(startSyncUpdateCache) toTarget:self withObject:nil];
}
@end
