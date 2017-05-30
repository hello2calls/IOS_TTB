//
//  PresentationUpdater.h
//  Ararat_iOS
//
//  Created by SongchaoYuan on 15/8/25.
//  Copyright (c) 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentationUpdater : NSObject

- (void)initializePresentationUpdater;
- (void)checkPresentationUpdater;
+ (void)addPresentationCheckFIds:(NSArray *)fids;
- (void)clearAllPresentations;

@end
