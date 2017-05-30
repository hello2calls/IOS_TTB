//
//  NumberPersonMappingModel.h
//  Untitled
//
//  Created by Alice on 11-8-11.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneDataModel.h"
#import "PhoneNumber.h"
#import "ContactCacheDataModel.h"


@interface NumberPersonMappingModel : NSObject 

+ (NSInteger)queryContactIDByNumber:(NSString *)number;

+ (void)refreshLocalCache;

+ (void)setPersonID:(NSInteger)personID forNumber:(NSString *)number;

+ (void)setContactNumberMapping:(ContactCacheDataModel *)contact;

+ (void)removePersonIDForNumber:(NSString *)number;

+ (NSInteger)getCachePersonIDByNumber:(NSString *)number;

@end
