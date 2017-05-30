//
//  DataRequest.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/17.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataRequest : NSObject

- (id)initWithDataName:(NSString *)dataName andDataConf:(NSDictionary *)dataConf;
- (void)buildRequestWithBlock:(void(^)(NSString *requestStr, NSDictionary *attrData, long long time))block;
- (long)getCheckIntervalTime;
- (NSString *)getAssignedValue:(NSString *)name;
- (BOOL)canSendRequest;

@end
