//
//  YPAdTaskBaidu.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPAdTaskBaidu.h"
#import "FindNewsItem.h"
#import "BaiduMobAdNativeAdObject.h"
#import "IndexConstant.h"
#import "SSPStat.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "FindNewsRowView.h"

@implementation YPAdTaskBaidu

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = ADTaskBaidu;
        self.native = [[BaiduMobAdNative alloc]init];
        self.placementId = @"2623422";
    }
    return self;
}

- (void) executeTask
{
    cootek_log(@" --- generate task baidu -----");
    
    __weak YPAdTaskBaidu* task = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (task) {
            [self.native requestNativeAds];
        }
    });
    
    
}
- (void) setBaiduDelegate:(id) delegate
{
    self.native.delegate = delegate;
}


@end
