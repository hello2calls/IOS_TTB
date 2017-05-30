//
//  PresentStatistic.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/15.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

@protocol PresentStatisticDelegate <NSObject>

@required
//Usage接口
- (void)saveToUsageWithDictionary:(NSDictionary *)dict andUsagePath:(NSString *)usagePath;
@optional

@end
