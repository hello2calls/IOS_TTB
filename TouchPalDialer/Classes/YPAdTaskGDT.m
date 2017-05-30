//
//  YPAdTaskGDT.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPAdTaskGDT.h"
#import "FindNewsItem.h"
#import "IndexConstant.h"
#import "SSPStat.h"

@interface YPAdTaskGDT()
{
    GDTNativeAd *_nativeAd;     //原生广告实例
    NSArray *_data;             //原生广告数据数组
    GDTNativeAdData *_currentAd;//当前展示的原生广告数据对象
    
}

@end
@implementation YPAdTaskGDT

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = ADTaskGDT;
    }
    return self;
}

- (void) executeTask
{
    cootek_log(@" --- generate task GDT -----");
    [_nativeAd loadAd:10]; //这里以一次拉取30条原生广告为例
}

- (void) registerAd:(UIViewController *)controller withPlacementId:(NSString *)placementId
{
    if (!placementId) {
        placementId = @"1080215124193862";
    }
    _nativeAd = [[GDTNativeAd alloc] initWithAppkey:@"appkey" placementId:placementId];
    
    _nativeAd.controller = controller;
    _nativeAd.delegate = self;
    self.placementId = placementId;
}

- (void)dealloc
{
    //    _nativeAd.controller = nil;
    _nativeAd.delegate = nil;
    _nativeAd = nil;
}

#pragma ADProtrol

/**
 *  原生广告加载广告数据成功回调，返回为GDTNativeAdData对象的数组
 */
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray
{
    cootek_log(@" ---- GDT load success ---");
    
    NSMutableArray* remResult = [NSMutableArray new];
    for (GDTNativeAdData* data in nativeAdDataArray) {
        FindNewsItem* item = [FindNewsItem new];
        item.isAd = YES;
        item.gdtAdNativeObject = _nativeAd;
        item.gdtAdNativeData = data;
        NSString* title = [data.properties objectForKey: GDTNativeAdDataKeyTitle];
        NSString* des = [data.properties objectForKey: GDTNativeAdDataKeyDesc];
        item.title = title;
        item.subTitle = des;
        if (item.title.length < item.subTitle.length) {
            NSString* temp = item.title;
            item.title = item.subTitle;
            item.subTitle = temp;
        }
        item.adid = [NSString stringWithFormat:@"%@%@", title, des];
        item.category = CategoryADGDT;
        if (self.style == ADStyleLarge) {
            item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_BIG_IMAGE];
            item.images = [NSArray arrayWithObject:[data.properties objectForKey:GDTNativeAdDataKeyImgUrl]];
        } else if(self.style == ADStyleSmall) {
            item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_ONE_IMAGE];
            item.images = [NSArray arrayWithObject:[data.properties objectForKey:GDTNativeAdDataKeyIconUrl]];
        } else {
            item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_ONE_IMAGE];
            item.images = [NSArray arrayWithObject:[data.properties objectForKey:GDTNativeAdDataKeyIconUrl]];
        }
        item.topIndex = [NSNumber numberWithInteger: -1];
        item.tu = [NSString stringWithFormat:@"%d", SSPID_GDT];
        [remResult addObject:item];
    }
    
    [self setResults:remResult];
}

/**
 *  原生广告加载广告数据失败回调
 */
-(void)nativeAdFailToLoad:(NSError *)error
{
    cootek_log(@" ---- GDT load failed ---");
    [self setResults:nil];
}

/**
 *  原生广告点击之后将要展示内嵌浏览器或应用内AppStore回调
 */
- (void)nativeAdWillPresentScreen
{
    cootek_log(@" aaaaa ");
}

/**
 *  原生广告点击之后应用进入后台时回调
 */
- (void)nativeAdApplicationWillEnterBackground
{
    
}

/**
 * 原生广告点击以后，内置AppStore或是内置浏览器被关闭时回调
 */
- (void)nativeAdClosed
{
    cootek_log(@" close ");
}

@end
