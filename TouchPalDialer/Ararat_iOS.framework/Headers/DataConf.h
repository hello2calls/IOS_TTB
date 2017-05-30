//
//  DataConf.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/17.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AraratDatabase.h"

@interface DataConf : NSObject

@property (nonatomic, strong) NoahKeyValueStore *confStore;
@property (nonatomic, strong) NSDictionary *confDict;

- (NSDictionary *)loadConfData;

@end
