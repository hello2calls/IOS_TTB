//
//  DataChannel.h
//  Ararat_iOS
//
//  Created by Cootek on 15/8/17.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataConf.h"
#import "DataRequest.h"
#import "DataResult.h"
#import "DataVersionManager.h"

@interface AraratData : NSObject

@property (nonatomic, strong) NSMutableDictionary *dataConfDict;
@property (nonatomic, strong) NSMutableDictionary *dataRequestDict;
@property (nonatomic, strong) NSMutableDictionary *dataResultDict;
@property (nonatomic, strong) NSMutableDictionary *dataVersionManagerDict;

- (void)addDataWithDataName:(NSString *)dataName
                  DataConf:(NSDictionary *)dataConf
               DataRequest:(DataRequest *)dataRequest
                DataResult:(DataResult *)dataResult
        DataVersionManager:(DataVersionManager *)dataVersionManager;

@end

@interface DataChannel : NSObject

+ (id)sharedInstance;
- (void)registerDataManagerWithAraratData:(AraratData *)araratData;
- (void)cancelDataManager;
- (void)runDataChannelWithCompletion:(void(^)(BOOL receiveNewData, NSString *dataName))handler andReceiveNotification:(BOOL)receiveNotification;
- (void)rollBackWithDataName:(NSString *)dataName;

@end


