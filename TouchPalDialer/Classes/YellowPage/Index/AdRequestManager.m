//
//  AdRequestManager.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/26.
//
//

#import "AdRequestManager.h"
#import "NSOperationQueue+Completion.h"
#import "YPTaskBase.h"
#import "YPAdTaskDavinci.h"
#import "YPAdTaskNews.h"
#import "YPAdTaskBaidu.h"
#import "YPAdTaskGDT.h"
#import "UIDataManager.h"
#import "GDTNativeAd.h"
#import "FindNewsItem.h"
#import "SSPStat.h"
#import "DialerUsageRecord.h"
#import "FindNewsRowView.h"
#import "TPAnalyticConstants.h"
#import "IndexConstant.h"
#import "TPAdControlRequestParams.h"
#import "FunctionUtility.h"
#import "TPAdControlStrategy.h"
#import "TPAdDSPController.h"
#import "AdMessageModel.h"
#import "TouchPalVersionInfo.h"
#import "NewsFeedsCellTableViewCell.h"
#import "TPDialerResourceManager.h"

AdRequestManager *ad_instance_ = nil;

@interface AdRequestManager()
{
    NSOperationQueue* managerQueue;
    UIViewController* __weak _controller;
    NSMutableDictionary* adShows;
    YPAdTaskBaidu* baiduTask;
    BOOL isRequest;
    
    
    
}
@end

@implementation AdRequestManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        managerQueue = [NSOperationQueue new];
        managerQueue.maxConcurrentOperationCount = 4;
        adShows = [NSMutableDictionary new];;
        isRequest = NO;
        _queryId = @"";
    }
    return self;
}


- (void) registerController:(UIViewController *)controller
{
    _controller = controller;
}

- (void) generateTasksWithTu:(NSInteger)tu withBlock:(void (^)(NSMutableArray *))block isRefresh:(BOOL)refresh
{
    NSString* gdtSsps;
    NSString* baiduSsps;
    NSString* davinciSsps;
    NSString* ssps;
    
    if (isRequest) {
        cootek_log(@"  in request  --> frank.tang");
        return;
    }
    
    isRequest = YES;
    
    // 获取controller数据
    TPAdControlStrategy *strategy = [[TPAdDSPController sharedController] getCachedStrategy:[NSString stringWithFormat:@"%d", tu]];
    
    TPAdControlRequestParams *params = [[TPAdControlRequestParams alloc] init];
    params.tu = [NSString stringWithFormat:@"%d", TU_FEEDS];
    params.feedsId = tu;
    params.supportedPlatformIds = @[@(DSP_TYPE_TP_DAVINCI), @(DSP_TYPE_BAIDU_MOBADS_SDK), @(DSP_TYPE_TECENT_GDT_SDK)];
    // 异步请求
    [[TPAdDSPController sharedController] asyncRequestForStrategyByParams:params completitionBlock:nil];
    
    //    self.result = [NSMutableArray new];
    NSMutableDictionary* adTasks = [NSMutableDictionary new];
    
    ADStyle style = ADStyleSmall;
    if (strategy.dataId.count > 0) {
        for (int i = 0; i < strategy.dataId.count; i++) {
            NSDictionary* dic = [strategy.dataId objectAtIndex:i];
            NSNumber* sspid = [dic objectForKey:TP_AD_PLATFORM_ID];
            
            NSString* styleStr = [dic objectForKey:TP_AD_STYLE];
            if ([TP_AD_STYLE_SMALL isEqualToString:styleStr]) {
                style = ADStyleSmall;
            } else if ([TP_AD_STYLE_LARGE isEqualToString:styleStr]){
                style = ADStyleLarge;
            } else {
                style = ADStyleMulti;
            }
            
            switch (sspid.intValue) {
                case SSPID_DAVINCI:
                {
                    //是否需要请求davinci
                    //managerQueue add davinciTask
                    YPAdTaskDavinci* taskDavinci = [YPAdTaskDavinci new];
                    [taskDavinci setQueryId:_queryId];
                    [taskDavinci setRefresh:refresh];
                    [taskDavinci setSSPid:[NSNumber numberWithInt: SSPID_DAVINCI]];
                    [taskDavinci setFtu:[NSString stringWithFormat:@"%d", tu]];
                    [taskDavinci setStyle:style];
                    davinciSsps = [[SSPStat instance] requestWithSSPid:SSPID_DAVINCI andTu:TU_FEEDS andADN:3 andPlacementId:taskDavinci.placementId andFtu:tu];
                    [managerQueue addOperation:taskDavinci timeout:3];
                    [adTasks setObject:taskDavinci forKey:taskDavinci.sspid];
                    if (![[adShows allKeys] containsObject:[NSNumber numberWithInt:taskDavinci.type]]) {
                        [adShows setObject:[NSMutableSet new] forKey:[NSNumber numberWithInt:taskDavinci.type]];
                    }
                    break;
                }
                case SSPID_GDT:
                {
                    NSString* placementid = [dic objectForKey:TP_AD_PLACEMENT_ID];
                    //是否需要请求GDT
                    YPAdTaskGDT* taskGDT = [YPAdTaskGDT new];
                    [taskGDT registerAd:_controller withPlacementId:placementid];
                    [taskGDT setSSPid:[NSNumber numberWithInt: SSPID_GDT]];
                    [taskGDT setStyle:style];
                    [managerQueue addOperation:taskGDT timeout:3];
                    [adTasks setObject:taskGDT forKey:taskGDT.sspid];
                    gdtSsps = [[SSPStat instance] requestWithSSPid:SSPID_GDT andTu:TU_FEEDS andADN:0 andPlacementId:taskGDT.placementId andFtu:tu];
                    if (![[adShows allKeys] containsObject:[NSNumber numberWithInt:taskGDT.type]]) {
                        [adShows setObject:[NSMutableSet new] forKey:[NSNumber numberWithInt:taskGDT.type]];
                    }
                }
                    break;
                case SSPID_BAIDU:
                {
                    //是否需要请求Baidu
                    NSString* placementid = [dic objectForKey:TP_AD_PLACEMENT_ID];
                    baiduTask = [YPAdTaskBaidu new];
                    [baiduTask setBaiduDelegate:self];
                    if (placementid) {
                        baiduTask.placementId = placementid;
                    }
                    [baiduTask setStyle:style];
                    [baiduTask setSSPid:[NSNumber numberWithInt: SSPID_BAIDU]];
                    [managerQueue addOperation:baiduTask timeout:3];
                    [adTasks setObject:baiduTask forKey:baiduTask.sspid];
                    baiduSsps = [[SSPStat instance] requestWithSSPid:SSPID_BAIDU andTu:TU_FEEDS andADN:0 andPlacementId:baiduTask.placementId andFtu:tu];
                    if (![[adShows allKeys] containsObject:[NSNumber numberWithInt:baiduTask.type]]) {
                        [adShows setObject:[NSMutableSet new] forKey:[NSNumber numberWithInt:baiduTask.type]];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    } else if (!strategy.dataId){
        // 默认请求davinci
        //managerQueue add davinciTask
        YPAdTaskDavinci* taskDavinci = [YPAdTaskDavinci new];
        [taskDavinci setQueryId:_queryId];
        [taskDavinci setRefresh:refresh];
        [taskDavinci setSSPid:[NSNumber numberWithInt: SSPID_DAVINCI]];
        [taskDavinci setFtu:[NSString stringWithFormat:@"%d", tu]];
        [taskDavinci setStyle:style];
        davinciSsps = [[SSPStat instance] requestWithSSPid:SSPID_DAVINCI andTu:TU_FEEDS andADN:3 andPlacementId:taskDavinci.placementId andFtu:tu];
        [managerQueue addOperation:taskDavinci timeout:3];
        [adTasks setObject:taskDavinci forKey:taskDavinci.sspid];
        if (![[adShows allKeys] containsObject:[NSNumber numberWithInt:taskDavinci.type]]) {
            [adShows setObject:[NSMutableSet new] forKey:[NSNumber numberWithInt:taskDavinci.type]];
        }
    }
    
    
    //news 请求
    YPAdTaskNews* taskNews = [YPAdTaskNews new];
    
    [taskNews setQueryId:_queryId];
    [taskNews setRefresh:refresh];
    [taskNews setTu:tu];
    
    // 因为视频新闻使用了autolayout，限制在ios8及其以上，防止crash
    if ([FunctionUtility systemVersionFloat] >= 8.0) {
        [taskNews setLayout:31];
    }
    
    [managerQueue addOperation:taskNews timeout:7];
    
    if (adTasks.count > 0) {
        ssps = [[SSPStat instance] requestWithSSPid:SSPID_ALL andTu:TU_FEEDS andADN:0 andPlacementId:@"" andFtu:tu];
    }
    
    //处理请求全部成功时的结果
    __weak __block NSMutableDictionary* temAdShowed = adShows;
    [managerQueue setCompletion:^{
        NSMutableArray* temRet = [NSMutableArray new];
        isRequest = NO;
        cootek_log(@" complete called !!!!");
        NSArray* newsItem = [taskNews getResult];
        if (newsItem.count > 0) {
            
            //set QueryId
            FindNewsItem* tmpItem = [newsItem objectAtIndex:0];
            _queryId = tmpItem.queryId;
            
            TPAdControlStrategy *strategyRes = [[TPAdDSPController sharedController] getCachedStrategy:[NSString stringWithFormat:@"%d", tu]];
            
            NSArray* platformIds = strategyRes.effectivePlatformIds;
            NSMutableArray* adItems = [NSMutableArray new];
            for (int i = 0; i < platformIds.count; i++) {
                NSNumber* sspid = [platformIds objectAtIndex:i];
                YPTaskBase* task = [adTasks objectForKey:sspid];
                if (task && task.result.count > 0 && [platformIds containsObject:task.sspid]) {
                    [adItems addObjectsFromArray:task.result];
                    switch (task.type) {
                        case ADTaskDavinci: {
                            [[SSPStat instance] filledWithSSPid:SSPID_DAVINCI andTu:TU_FEEDS andADN:task.result.count andS:davinciSsps andFtu:tu];
                            break;
                        }
                        case ADTaskBaidu: {
                            [[SSPStat instance] filledWithSSPid:SSPID_BAIDU andTu:TU_FEEDS andADN:task.result.count andS:baiduSsps andFtu:tu];
                            break;
                        }
                        case ADTaskGDT: {
                            [[SSPStat instance] filledWithSSPid:SSPID_GDT andTu:TU_FEEDS andADN:task.result.count andS:gdtSsps andFtu:tu];
                            break;
                        case ADTaskNews:
                            break;
                        }
                    }
                }
            }
            
            if (newsItem.count > 0) {
                //只要有任何一个广告方有数据返回，发送总控请求的sspstat数据统计;
                [[SSPStat instance] filledWithSSPid:SSPID_ALL andTu:TU_FEEDS andADN:0 andS:ssps andFtu:tu];
            }
            
            int rank = 1;
            for (FindNewsItem* item in newsItem) {
                [temRet addObject:item];
                int followAdn = item.followAdn.intValue;
                if (followAdn > 0 && adItems.count > 0) {
                    followAdn--;
                    NSMutableSet* showedAdSet = nil;
                    FindNewsItem* adItem = nil;
                    NSString* uniqueAdKey = nil;
                    while ((!uniqueAdKey || [showedAdSet containsObject:uniqueAdKey])) {
                        if (adItems.count <= 0) {
                            adItem = nil;
                            break;
                        }
                        adItem = [adItems objectAtIndex:0];
                        [adItems removeObject:adItem];
                        showedAdSet = [temAdShowed objectForKey:adItem.type];
                        if (!showedAdSet) {
                            showedAdSet = [NSMutableSet new];
                        }
                        uniqueAdKey = [NSString stringWithFormat:@"%@%@", adItem.title, adItem.subTitle];
                    }
                    
                    if (adItem) {
                        adItem.rank = [NSNumber numberWithInteger: rank++];
                        adItem.timestamp = item.timestamp;
                        adItem.hotKeys = [NSArray arrayWithObject:@"广告"];
                        adItem.highlightFlags = [NSArray arrayWithObject:[NSNumber numberWithInt:0]];
                        adItem.ftu = [NSString stringWithFormat:@"%d", tu];
                        if (adItem.category == CategoryADDavinci) {
                            adItem.sspS = davinciSsps;
                        } else if (adItem.category == CategoryADGDT) {
                            adItem.sspS = gdtSsps;
                            adItem.adid = [NSString stringWithFormat:@"%@%d", adItem.sspS, adItem.rank];
                        } else if (adItem.category == CategoryADBaidu) {
                            adItem.sspS = baiduSsps;
                            adItem.adid = [NSString stringWithFormat:@"%@%d", adItem.sspS, adItem.rank];
                        }
                        //set Control server expid
                        adItem.expid = [NSNumber numberWithLong:strategyRes.expId];
                        
                        [showedAdSet addObject:uniqueAdKey];
                        [temRet addObject:adItem];
                        [temAdShowed setObject:showedAdSet forKey:adItem.type];
                    }
                }
            }
        }
        block(temRet);
        
    }];
}


//由于百度的回调比较恶心，只好绑定到manager
#pragma mark - 广告相关设置
//创建后获得的应用id
-(NSString*)publisherId
{
    return @"bdf87ab7";
}

//创建后获得的baidu信息流广告位id
-(NSString*)apId
{
    return baiduTask.placementId;
}

//广告返回成功
//nativeAds为成功返回的广告数组,个数可能少于请求的数量.
-(void)nativeAdObjectsSuccessLoad:(NSArray *)nativeAds
{
    NSMutableArray* remResult = [NSMutableArray new];
    cootek_log(@"nativeAdObjectsSuccessLoad:%ld",nativeAds.count);
    for (int i = 0; i<nativeAds.count; i++)
    {
        FindNewsItem* item = [FindNewsItem new];
        item.isAd = YES;
        BaiduMobAdNativeAdObject* object = [nativeAds objectAtIndex:i];
        item.title = object.title;
        
        item.baiduAdNativeObject = object;
        item.adid = [NSString stringWithFormat:@"%@%@", object.title, object.text];
        if (baiduTask.style == ADStyleMulti && object.morepics.count >= 3) {
            item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_THREE_IMAGE];
            item.images = object.morepics;
        } else {
            if (baiduTask.style == ADStyleLarge && object.mainImageURLString.length > 0) {
                item.images = [NSArray arrayWithObject:object.mainImageURLString];
                item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_BIG_IMAGE];
            } else {
                if (object.morepics.count >= 3) {
                    item.images = object.morepics;
                    item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_THREE_IMAGE];
                } else {
                    if (object.morepics.count > 0) {
                        item.images = object.morepics;
                        item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_ONE_IMAGE];
                    } else {
                        if  (object.iconImageURLString) {
                            item.images = [NSArray arrayWithObject:object.iconImageURLString];
                        } else if (object.mainImageURLString) {
                            item.images = [NSArray arrayWithObject:object.mainImageURLString];
                        } else {
                            continue;
                        }
                        item.type = [NSNumber numberWithInt:FIND_NEWS_TYPE_ONE_IMAGE];
                    }
                    
                }
                
            }
        }
        item.topIndex = [NSNumber numberWithInteger:-1];
        
        item.category = CategoryADBaidu;
        item.subTitle = object.text;
        if (item.title.length < item.subTitle.length) {
            NSString* temp = item.title;
            item.title = item.subTitle;
            item.subTitle = temp;
        }
        item.tu = [NSString stringWithFormat:@"%d", SSPID_BAIDU];


        [remResult addObject:item];
    }
    
    [baiduTask setResults:remResult];
}

//广告返回失败
-(void)nativeAdsFailLoad:(BaiduMobFailReason)reason
{
    cootek_log(@"nativeAdsFailLoad,reason = %d",reason);
    
    NSString * reasonStr = [NSString stringWithFormat:@"%d", reason];
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"request"), Pair(@"type", @"baidu"), Pair(@"failed_reason", reasonStr), nil];
}

//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
-(void)nativeAdClicked:(BaiduMobAdNativeAdView *)nativeAdView
{
    NewsFeedsCellTableViewCell* view = [nativeAdView viewWithTag:FIND_NEWS_BAIDU_TAG];
    
    if (view != nil) {
        FindNewsItem* item = view.item;
        item.isClicked = YES;
        if ([view isKindOfClass:[NewsFeedsCellTableViewCell class]]) {
            view.tpd_label1.textColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_500"];
        }
        [[SSPStat instance] clickWithSSPid:SSPID_BAIDU andTu:TU_FEEDS andRank:[item.rank intValue] andS:item.sspS andFtu:[item.ftu integerValue]];
    }
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"click"), Pair(@"type", @"baidu"), Pair(@"tu",view.item.tu), Pair(@"ftu",view.item.ftu), nil];
    
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
-(void)didDismissLandingPage:(BaiduMobAdNativeAdView *)nativeAdView
{
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"close"), Pair(@"type", @"baidu"), nil];
    cootek_log(@"didDismissLandingPage");
}

- (void)dealloc
{
    cootek_log(@" ---- frank.tang ----");
}
@end
