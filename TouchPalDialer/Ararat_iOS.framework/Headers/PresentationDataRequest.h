//
//  PresentationDataRequest.h
//  Ararat_iOS
//
//  Created by SongchaoYuan on 15/9/28.
//  Copyright © 2015年 Cootek. All rights reserved.
//

#import "DataRequest.h"

@interface PresentationDataRequest : DataRequest

- (id)initWithDataConf:(NSDictionary *)dataConf;
- (NSString *)getAssignedValue:(NSString *)name;

@end
