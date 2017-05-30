//
//  AraratDatabase.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/22.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoahKeyValueStore.h"

@interface AraratDatabase : NSObject

+ (id)sharedInstance;
- (NoahKeyValueStore *)getDataStore;
- (void)initializeDefaultData;

@end
