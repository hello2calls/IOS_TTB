//
//  PresentHistoryManager.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/4.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentHistory.h"
@class Histories;
@interface PresentHistoryManager : NSObject

- (PresentHistory *)getHistoryWithFeatureId:(NSString *) featureId;
- (void)setHistoriesWithHistories:(Histories *)hs;
- (Histories *)restoreHistories;
- (void)save;
- (long)getFirstUsedTime;
- (void)setFirstUsedTime:(long)time;
- (long)getLastCheckTime;
- (void)setLastCheckTime:(long)time;
- (long)getLastWifiCheckSuccessTime;
- (void)setLastWifiCheckSuccessTime:(long)time;
- (long)getLastToolbarPresentTime;
- (void)setLastToolbarPresentTime:(long)time;
- (long)getLastStartupPresentTime;
- (void)setLastStartupPresentTime:(long)time;
@end

@interface Histories : NSObject

@property (nonatomic, strong) NSMutableDictionary *container;
@property (nonatomic, assign) BOOL changed;
- (void)onChanged;
- (BOOL)isChanged;
- (NSDictionary *)getHistories;
@end
