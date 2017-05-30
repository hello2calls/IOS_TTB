//
//  UsageData.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-24.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsageRecord : NSObject<NSCoding>
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSDictionary *values;
@end
