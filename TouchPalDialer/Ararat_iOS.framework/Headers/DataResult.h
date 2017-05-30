//
//  DataResult.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/17.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AraratDatabase.h"

@interface DataResult : NSObject

@property (nonatomic, strong) NSString *dataName;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NoahKeyValueStore *dataStore;

- (id)initWithDataName:(NSString *)dataName;
- (void)resetAllData;
- (BOOL)setResult:(NSDictionary *)result;
- (void)saveToDB;
- (BOOL)checkData;
- (BOOL)checkFormat;


@end
