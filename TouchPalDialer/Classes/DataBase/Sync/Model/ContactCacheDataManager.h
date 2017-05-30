//
//  ContactCacheDataManager.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-25.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBaseModel.h"
#import "PhoneDataModel.h"
#import "ContactCacheDataModel.h"
#import "OrlandoEngine.h"
#import "CallCountModel.h"
#import "NumberPersonMappingModel.h"

@interface ContactCacheDataManager : NSObject

@property (retain) NSMutableDictionary *contactsCacheDict;

+ (ContactCacheDataManager *)instance;

+ (void)setEngineInited:(BOOL)isInited;;

+ (BOOL)isEngineInited;

- (void)loadInitialData;

- (void)removeItemByID:(NSInteger)personID;

- (void)addItemByID:(ContactCacheDataModel *)item;

//获取item根据personID
- (ContactCacheDataModel *)contactCacheItem:(NSInteger)personID;

//是否存在
- (BOOL)isCacheItem:(NSInteger)personID;

//某人是否存在电话号码
- (BOOL)isCacheItemNumber:(NSInteger)personID
               withNumber:(NSString *)number;


//获取所有联系人
- (NSArray *)getAllCacheContact;
- (NSArray *)getAllCacheContactID;
- (NSArray *)getAllCacheContactGroups;

- (NSDictionary *)updateNormalizeNumberCacheWhenSimChange;


@end
