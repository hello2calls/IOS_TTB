//
//  UsageInfoProvider.h
//  Usage_iOS
//
//  Created by SongchaoYuan on 16/2/16.
//  Copyright © 2016年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    kUsageInfoContact = 0,
    kUsageInfoCallVOIPHistory = 1
} UsageInfoType;
extern NSString * const UsageTypeInfo;
extern NSString * const NoahInfoSpecificKey;

@class UsageRecord;

@interface UsageInfoData : NSObject

@property (nonatomic, strong) UsageRecord *data;
@property (nonatomic, assign) long long lastId;
@property (nonatomic, strong) NSString *infoPath;
@property (nonatomic, assign) BOOL hasData;

@end

@interface UsageInfoProvider : NSObject
- (NSString *)getType;
- (NSInteger)getLength;
- (NSString *)getPath:(NSInteger)i;
- (UsageInfoData *)getData:(NSInteger)i;
@end
