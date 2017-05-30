//
//  ContractCacheModel.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-2.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataModel.h"

@interface ContactPropertyCacheModel : NSObject

@property(nonatomic,retain) NSMutableArray *contactPropertyValues;

- (id)initWithPersonList:(NSArray *)person_list
           AttributeName:(NSInteger)attr;

- (void)editWithPerson:(NSInteger)personID
        AttributeName:(NSInteger)attr
             withType:(NSInteger)typ;

@end
