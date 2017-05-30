//
//  ContactPropertyCache.h
//  Untitled
//
//  Created by Alice on 11-8-2.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttributeModel.h"
#import "ContractResultModel.h"
#import "CootekNotifications.h"

@interface ContactPropertyCacheManager : NSObject

+ (id)shareManager;

- (void)initContactsPropertyCache;

- (void)initWithAllSearchAttrInPersons;

- (NSArray *)valuesByPropertyID:(NSInteger)attr;

- (NSDictionary *)allCachePropertyValuesDict;

- (void)updateSearchCache:(NSInteger)personID
                     Type:(ContactChangeType)type;

- (BOOL)isPersonDetailInit;

@end

