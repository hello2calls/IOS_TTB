//
//  YellowPageMainTabController.m
//  TouchPalDialer
//
//  Created by tanglin on 15-3-31.
//
//
#import "YellowPageMainTabController.h"
#import "UITableView+TP.h"
#import "UIView+WithSkin.h"
#import "UserDefaultsManager.h"
#import "TPAddressBookWrapper.h"
#import "UIDataManager.h"
#import "TPDialerResourceManager.h"
#import "HeaderBar.h"
#import "IndexConstant.h"
#import "CootekNotifications.h"
#import "EntranceIcon.h"
#import "PersonalCenterController.h"
#import "LocalStorage.h"
#import "ZipDataDownloadJob.h"
#import "IndexJsonUtils.h"
#import "IndexData.h"
#import "UpdateService.h"
#import "ScheduleTaskManager.h"
#import "TouchPalVersionInfo.h"
#import "TPShareController.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "PublicNumberCenterView.h"
#import "PublicNumberProvider.h"
#import "PublicNumberListController.h"
#import "XinGePushManager.h"
#import "PushConstant.h"
#import "CTUrl.h"
#import "YellowPageLocationManager.h"
#import "CitySelectViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "NoahManager.h"
#import "YellowPageMainQueue.h"
#import "Reachability.h"
#import "FindNewsHeaderView.h"
#import "SectionFindNews.h"
#import "EdurlManager.h"
#import "ImageUtils.h"
#import "FullScreenAdItem.h"
#import "YPFullScreenAdView.h"
#import "NSTimer+Addition.h"
#import "FindNewsRowView.h"
#import "AdRequestManager.h"
#import "TouchLifeTabBarAdManager.h"
#import "TPAdControlRequestParams.h"
#import "SeattleFeatureExecutor.h"
#import "AccountInfoManager.h"
#import "PersonInfoDescViewController.h"
#import "NSDictionary+Default.h"
#import "TaskAnimationManager.h"
#import "FeedsRedPacketManager.h"
#import "FindNewsBonusResult.h"

#import "FunctionUtility.h"

#define UPDATE_INTERVAL_DURATION 30
#define REFRESH_HEADER_HEIGHT 52.0f
#define VALIDATE_INTERVAL 60

@interface YellowPageMainTabController (){
    BOOL _loadMore;
    long loadTime;
    BOOL flag_start_city_page;
    NSObject* couponObj;
    BOOL isDragging;
    BOOL isLoading;
    NSTimer* repeatingTimer;
    AdRequestManager* adRequestManager;
    BOOL isCurrentTab;
    BOOL requestMsg;
}

@property(nonatomic, retain) EntranceIcon *personalCenterButton;
@property(nonatomic, retain) IndexData* localData;
@property(nonatomic, assign) BOOL displayed;
@property(nonatomic, retain) UIButton* accessoryView;

@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@end

@implementation YellowPageMainTabController

@synthesize all_content_view;
@synthesize load_more_foot_view;
@synthesize notHome;
@synthesize pnCenter;
@synthesize refreshHeaderView;
@synthesize refreshLabel;
@synthesize refreshArrow;
@synthesize refreshSpinner;
@synthesize textPull;
@synthesize textLoading;
@synthesize textRelease;

- (void)loadView
{
    cootek_log(@"YellowPageMainTabController->loadView");
    
    [super loadView];
    flag_start_city_page = NO;
    
    NSString* title = NSLocalizedString(@"YellowPage_", @"钱包");
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    self.headerView = headerBar;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:titleLabel];
    
    return;

    //    [self addCitySelectView];
    
    // 双击的Recognizer
    UITapGestureRecognizer* doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapTitle:)];
    doubleRecognizer.numberOfTapsRequired = 2; // 双击
    doubleRecognizer.numberOfTouchesRequired = 1;
    [titleLabel addGestureRecognizer:doubleRecognizer];
    
    
    EntranceIcon *tmpCenter = [[EntranceIcon alloc]initWithFrame:CGRectMake(TPScreenWidth() - 90, TPHeaderBarHeightDiff(), 50, 45)];
    [tmpCenter setSkinStyleWithHost:self forStyle:@""];
    tmpCenter.delegate = self;
    [self.headerView addSubview:tmpCenter];
    self.personalCenterButton = tmpCenter;
    
    
    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    gobackBtn.hidden = YES;
    

    pnCenter = [[PublicNumberCenterView alloc]initWithFrame:CGRectMake(TPScreenWidth() - 45, TPHeaderBarHeightDiff(), 40, 45)];
    [self.headerView addSubview:pnCenter];
    
    //add for zip deploy
    [[UpdateService instance] checkDeployForLocalZip];
    self.displayed = NO;
    loadTime = -1;
    
    [self addUITableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataAndClearEdurl) name:N_INDEX_REQUEST_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRequestDataFailed) name:N_INDEX_REQUEST_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRequestServerFailed) name:N_INDEX_REQUEST_SERVER_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadIndexData) name:N_INDEX_JSON_REQUEST_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (loadIndexDataFailed) name:N_INDEX_JSON_REQUEST_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:N_ZIP_DEPLOY_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLoad) name:N_SELECTED_YELLOWPAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unSelectTab) name:N_UNSELECTED_YELLOWPAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateYPRedHint) name:N_PUBLIC_NUMBER_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountInfoChangeShouldReload) name:SHOULD_REFRESH_PC_HEADVIEW object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCouponData) name:N_COUPON_REQUEST_SUCCESS object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCouponDataFailed) name:N_COUPON_REQUEST_FAILED object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCouponDataIgnore) name:N_COUPON_REQUEST_IGNORE object:nil];
    //    在iOS534之后黄页首页不再广播天气，注释下面代码
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:N_WEATHER_REQUEST_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadIndexFontData) name:N_INDEX_FONT_REQUEST_SUCCESS object:nil];
    
    [[ScheduleTaskManager scheduleManager] addScheduleTask:[UpdateZipScheduleTask task]];
    
    if (![UserDefaultsManager boolValueForKey:ZIP_INIT_UNZIP]) {
        [self performSelectorInBackground:@selector(initZipFromLocal) withObject:nil];
    }
    
    
    
    NSString* user_tag = [UserDefaultsManager stringForKey:YP_USER_TAG];
    if(user_tag == nil || [user_tag isEqualToString:@"new"]) {
        [UserDefaultsManager setObject:@"old" forKey:YP_USER_TAG];
    }
    
    [UserDefaultsManager setObject:nil forKey:INDEX_CATEGORY_BLIST];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNoahToast) name:N_NOAH_LOAD_CONFIG_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiBecomeActive) name:N_APPLICATION_BECOME_ACTIVE object:nil];
    
    if (notHome) {
        gobackBtn.hidden = NO;
        pnCenter.hidden = YES;
    } else {
        [[UIDataManager instance] setViewController:self];
    }
    
    //yellowpage message center
    if ([PublicNumberProvider getNewMsgCount] == 0) {
        [self performSelectorInBackground:@selector(getNewMsgcount) withObject:nil];
    }
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(initMiniBannerFromNetwork) object: nil];
    [thread start];
    
    //init user Agent
    [[UIDataManager instance] addUserAgent];
    
    repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:VALIDATE_INTERVAL target:self selector:@selector(newsTimeUpdate) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
    
    [self performSelectorInBackground:@selector(removeFindNewsImages) withObject:nil];
    
    [[TouchLifeTabBarAdManager instance] remoteReqAd];
    
    [[AccountInfoManager instance] setRequestAccountInfo:YES];
    
    [TaskAnimationManager instance].requestFlg = 0;
    
    [[FeedsRedPacketManager new] queryFeedsRedPacketByType:YP_RED_PACKET_FEEDS_ALL withBlock:nil];
}

-(void) getNewMsgcount
{
    [PublicNumberListController requestForPublicNumberInfos];
    [PublicNumberListController requestForPublicNumberMsgs:1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:N_PUBLIC_NUMBER_UPDATE object:nil];
        requestMsg = NO;
    });
}

-(void) newsTimeUpdate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uiTableViewReload];
    });
}

- (void)updateYPRedHint {
    [pnCenter setNeedsDisplay];
}

- (void) doubleTapTitle:(UITapGestureRecognizer *)sender
{
    [self.all_content_view scrollsToTop];
}

- (void) removeFindNewsImages
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* path = [ImageUtils getFilePathWithTag:FIND_NEWS_PATH_TAG];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    long currentTime = [[NSDate date] timeIntervalSince1970];
    while ((filename = [e nextObject])) {
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:[path stringByAppendingPathComponent:filename]
                                    error:nil];
        if (properties && properties.count > 0) {
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            long fileDate = [modDate timeIntervalSince1970];
            if (ABS(fileDate - currentTime) > 2 * 24 * 60 * 60) {
                [fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
            }
        }
        
    }
    
    
}

- (void) addUITableView
{
    if (self.all_content_view) {
        return;
    }
    
    // content view
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:CGRectMake(0,TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(365)) style:UITableViewStylePlain];
    
    [tmp_view_content setExtraCellLineHidden];
    tmp_view_content.delegate = self;
    tmp_view_content.dataSource = self;
    tmp_view_content.separatorStyle = UITableViewCellSeparatorStyleNone;
    tmp_view_content.backgroundColor = [UIColor whiteColor];
    tmp_view_content.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:tmp_view_content];
    [[UIDataManager instance] setTableView:tmp_view_content];
    self.all_content_view = tmp_view_content;
    
    [self setupStrings];
    [self addPullToRefreshHeader];
    
    if ([self.all_content_view respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        self.all_content_view.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGesture];
    
    self.accessoryView = [[UIButton alloc]initWithFrame:CGRectMake(0,TPHeaderBarHeight() + INDEX_ROW_HEIGHT_SEARCH, TPScreenWidth(), TPHeightFit(365))];
    [self.accessoryView setBackgroundColor:[UIColor blackColor]];
    [self.accessoryView setAlpha:0.0f];
    [self.accessoryView addTarget:self action:@selector(ClickControlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.accessoryView];
    
}


- (void)setupStrings{
    textPull = @"下拉可以刷新...";
    textRelease = @"释放开始刷新...";
    textLoading = @"";
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, TPScreenWidth(), REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor whiteColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth() / 2, 0, TPScreenWidth() / 2, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentLeft;
    
    NSString *arrowPath = [[NSBundle mainBundle] pathForResource:@"webpages/res/image/arrow" ofType:@"png"];
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:arrowPath]];
    refreshArrow.frame = CGRectMake(TPScreenWidth() / 2 - 50,
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    22, 36);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(TPScreenWidth() / 2 - 10, floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.all_content_view addSubview:refreshHeaderView];
}


- (void) ClickControlAction:(id)sender{
    [self controlAccessoryView:@(0)];
}

- (void)controlAccessoryView:(NSNumber *)alphaValue{
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.accessoryView setAlpha:[alphaValue floatValue]];
    }completion:^(BOOL finished){
        if (alphaValue<=0) {
            [[[UIDataManager instance] searchBar]  resignFirstResponder];
        }
    }];
}

- (void) cityChanged
{
    [[UIDataManager instance] removeCoupons];
    [self performSelectorInBackground:@selector(initIndexFromNetwork) withObject:nil];
    
    //    在iOS534之后黄页首页不再广播天气，注释下面代码
    //    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getWeatherData) object: nil];
    //    [thread start];
}
- (void) getWeatherData
{
    //    在iOS534之后黄页首页不再广播天气，注释下面代码
    //    comment this function since new yellowpage_v4
    //    [[UpdateService instance] requestForWeatherData];
}
+ (void) startCityPage {
    if ([[UIDataManager instance] checkDoubleClick]) {
        return;
    }
    CitySelectViewController* controller = [[CitySelectViewController alloc]init];
    [[TouchPalDialerAppDelegate naviController]pushViewController:controller animated:YES];
}

- (void)yellowpageLocate
{
    int locTime = [[LocalStorage getItemWithKey:QUERY_LAST_CACHE_TIME_CITY] intValue];
    int now = [[NSDate date] timeIntervalSince1970];
    if (now - locTime > LOCATE_INTERVAL_TIME) {
        __weak typeof(self) weakSelf = self;
        void(^locationBlock)(BOOL isLocation, CLLocationCoordinate2D location) = ^(BOOL isLocation, CLLocationCoordinate2D location) {
            if (isLocation) {
                //走更新城市逻辑
                [weakSelf updateCity];
            } else {
                if (!flag_start_city_page && [UserDefaultsManager boolValueForKey:@"LOCATE_FIRST" defaultValue:YES]) {
                    [YellowPageMainTabController startCityPage];
                    flag_start_city_page = YES;
                }
            }
            if ([UserDefaultsManager boolValueForKey:@"LOCATE_FIRST" defaultValue:YES]) {
                [UserDefaultsManager setBoolValue:NO forKey:@"LOCATE_FIRST"];
            }
        };
        [[YellowPageLocationManager instance] addCallBackBlock:locationBlock];
        [[YellowPageLocationManager instance] locate:YES checkPermission:NO];
    }
    
}

- (void)updateCity
{
    NSString * _city = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];
    NSString * city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    
    int now = [[NSDate date] timeIntervalSince1970];
    int locTime = [[LocalStorage getItemWithKey:QUERY_LAST_CACHE_TIME_CITY] intValue];
    
    NSString * lastCity = [LocalStorage getItemWithKey:QUERY_LAST_PARAM_CITY];
    
    if ((now - locTime > 24 * 60 * 60) || ![_city isEqualToString:lastCity])
    {
        //保存最后一次定位成功的时间和城市
        [LocalStorage setItemForKey:QUERY_LAST_CACHE_TIME_CITY andValue:[NSString stringWithFormat:@"%d", now]];
        [LocalStorage setItemForKey:QUERY_LAST_PARAM_CITY andValue:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        
        //替换当前选择城市为当前定位城市
        [LocalStorage setItemForKey:QUERY_PARAM_CITY andValue:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
        
        //刷新页面
        if (![city isEqualToString:_city])
        {
            [UserDefaultsManager setObject:_city forKey:INDEX_CITY_SELECTED];
            [self cityChanged];
        }
    }
}

- (void)initLoad
{

    //SHOULD_REFRESH_PC_HEADVIEW
    isCurrentTab = YES;
    if (repeatingTimer) {
        [repeatingTimer resumeTimerAfterTimeInterval:VALIDATE_INTERVAL];
    }
    
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_INDEX_TAB_SELECTED kvs:Pair(@"action", @"selected"), nil];
    
    if ([UIDataManager instance].showAdItem) {
        UIImage *adImg = [ImageUtils getImageFromLocalWithUrl:[UIDataManager instance].showAdItem.adImage];
        CGFloat adImgWidth = adImg.size.width;
        CGFloat adImgHeight = adImg.size.height;
        CGFloat imgRatio = adImgHeight / adImgWidth;
        CGFloat imgShowHeight = imgRatio * (TPScreenWidth() - 4);
        YPFullScreenAdView *fullScreenAds = [[YPFullScreenAdView alloc] initWithSelfFrameScale:CGRectMake(0, 0, TPScreenWidth(),TPScreenHeight()) image1:[ImageUtils getImageFromLocalWithUrl:[UIDataManager instance].showAdItem.adImage] andFrame1:CGRectMake(2, (TPScreenHeight() - imgShowHeight) / 2, TPScreenWidth() - 4, imgShowHeight) image2:[TPDialerResourceManager getImage:@"full_ad_close@2x.png"] andFrame2:CGRectMake(TPScreenWidth() - 2 - 29, (TPScreenHeight() - imgShowHeight) / 2, 29, 29) ifRemoveSelf:YES];
        [DialogUtil showDialogWithContentView:fullScreenAds inRootView:nil];
    }
    
    //先走定位判断
    [self yellowpageLocate];
    
    cootek_log(@"start initLoad");
    if (self.displayed) {
        if (loadTime > 0 && ([[NSDate date] timeIntervalSince1970] - loadTime) < UPDATE_INTERVAL_DURATION) {
        } else {
            loadTime = [[NSDate date] timeIntervalSince1970];
            dispatch_async([SeattleFeatureExecutor getQueue], ^{
                [SeattleFeatureExecutor getAccountNumbersInfo];
                [SeattleFeatureExecutor queryVOIPAccountInfo];
            });
            [self performSelectorInBackground:@selector(initIndexFromNetwork) withObject:nil];
            if (![[AccountInfoManager instance] shouldRequestAccountInfo]) {
                [[AccountInfoManager instance] setRequestAccountInfo:YES];
            }
            
        }
        return;
    }
    
    self.displayed = YES;
    
    if (loadTime > 0 && ([[NSDate date] timeIntervalSince1970] - loadTime) < UPDATE_INTERVAL_DURATION) {
        return;
    }
    
    loadTime = [[NSDate date] timeIntervalSince1970];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getAccountNumbersInfo];
    });
    
    //weixin register
    //why wx share not work ,so add this!!
    [TPShareController registerWeiXinApp];
    
    [self loadData];
    
    [self performSelectorOnMainThread:@selector(initIndexFromNetwork) withObject:nil waitUntilDone:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NoahManager sharedPSInstance] startNotificationRegistration];
    });
    
}

- (void)initZipFromLocal
{
    [[UpdateService instance]initZipFromLocal];
}

- (void)initIndexFromNetwork
{
    [self startLoading];
}

-(void) requestCoupon
{
    [self initCouponFromNetwork: YES];
    [[UIDataManager instance] removeCoupons];
}


- (void) refreshLoad
{
    NSMutableDictionary* edurlSendDic = [NSMutableDictionary  dictionaryWithDictionary:[UserDefaultsManager dictionaryForKey:EDURL_SEND_DIC]];
    [edurlSendDic removeAllObjects];
    [UserDefaultsManager setObject:edurlSendDic forKey:EDURL_SEND_DIC];
    [UserDefaultsManager synchronize];
    [self initActivityFromNetwork];
    [self initMiniBannerFromNetwork];
}

- (void)initActivityFromNetwork
{
    if (USE_DEBUG_SERVER) {
        [[UpdateService instance] requestForIndexData:[NSString stringWithFormat:@"%@%@", YP_DEBUG_SERVER, ACTIVITY_REQUEST_PATH]];
    } else {
        [[UpdateService instance] requestForIndexData:[NSString stringWithFormat:@"%@%@", TOUCHLIFE_SITE, ACTIVITY_REQUEST_PATH]];
        
    }
    //    在iOS534之后黄页首页不再广播天气，注释下面代码
    //    NSString* city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    //    if ([city length] > 0) {
    //        [[UpdateService instance] requestForWeatherData];
    //    }
    
    @try {
        NSString* indexPath = @"";
        NSString* indexFontPath = @"";
        if (!NO_INDEX_UPDATE) {
            if(USE_DEBUG_SERVER) {
                indexPath = [NSString stringWithFormat:@"%@%@", YP_DEBUG_SERVER, INDEX_JSON_PATH];
            } else {
                indexPath = [NSString stringWithFormat:@"%@%@", TOUCHLIFE_SITE, INDEX_JSON_PATH];
            }
            [IndexJsonUtils saveJsonToFile:indexPath];
        }
        if (!NO_INDEX_FONT_UPDATE) {
            if (USE_DEBUG_SERVER) {
                indexFontPath = [NSString stringWithFormat:@"%@%@", YP_DEBUG_SERVER, INDEX_FONT_PATH];
            } else {
                indexFontPath = [NSString stringWithFormat:@"%@%@", SEARCH_SITE, INDEX_FONT_PATH];
            }
            [IndexJsonUtils saveIndexFontToFile:indexFontPath];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        [self requestCoupon];
    }
    
}

- (void) requestAccountInfos
{
    if([[AccountInfoManager instance] shouldRequestAccountInfo]) {
            if ([AccountInfoManager instance].accountInfos.count > 0) {
                NSString* vip = [[AccountInfoManager instance].accountInfos objectForKey:PROPERTY_VIP];
                NSInteger vipT = [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY];
                if (vip.intValue < vipT) {
                    [FunctionUtility setDicInUserManageWithObject:@(1) withObjectKey:PROPERTY_VIP withDicKey:ACCOUNTINFOUPDATEFLAGS];
                    [[AccountInfoManager instance].accountInfos setValue:[NSString stringWithFormat:@"%d", [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY]] forKey:PROPERTY_VIP];
                    [UserDefaultsManager setBoolValue:YES forKey:FIND_WALLET_PROPERTY_VIP_KEY];
                }
                
                NSString* traffic = [[AccountInfoManager instance].accountInfos objectForKey:PROPERTY_TRAFFIC];
                NSString* trafficT = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"bytes_f"];
                
                if(traffic.floatValue < trafficT.floatValue) {
                    [FunctionUtility setDicInUserManageWithObject:@(1) withObjectKey:PROPERTY_TRAFFIC withDicKey:ACCOUNTINFOUPDATEFLAGS];
                    [[AccountInfoManager instance].accountInfos setValue:trafficT forKey:PROPERTY_TRAFFIC];
                    [UserDefaultsManager setBoolValue:YES forKey:FIND_WALLET_PROPERTY_TRAFFIC_KEY];
                }
                
                NSString* minutes = [[AccountInfoManager instance].accountInfos objectForKey:PROPERTY_MINUTES];
                NSString* minutesT = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"minutes"];
                if(minutes.floatValue < minutesT.floatValue) {
                    [FunctionUtility setDicInUserManageWithObject:@(1) withObjectKey:PROPERTY_MINUTES withDicKey:ACCOUNTINFOUPDATEFLAGS];
                    [[AccountInfoManager instance].accountInfos setValue:minutesT forKey:PROPERTY_MINUTES];
                    [UserDefaultsManager setBoolValue:YES forKey:FIND_WALLET_PROPERTY_MINUTES_KEY];
                }
                
                NSString* coins = [[AccountInfoManager instance].accountInfos objectForKey:PROPERTY_WALLET];
                NSString* coinsT = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"coins"];
                if(coins.floatValue < coinsT.floatValue) {
                    [FunctionUtility setDicInUserManageWithObject:@(1) withObjectKey:PROPERTY_WALLET withDicKey:ACCOUNTINFOUPDATEFLAGS];
                    [[AccountInfoManager instance].accountInfos setValue:coinsT forKey:PROPERTY_WALLET];
                    [UserDefaultsManager setBoolValue:YES forKey:FIND_WALLET_PROPERTY_WALLET_KEY];
                }
                
                NSString* cards = [[AccountInfoManager instance].accountInfos objectForKey:PROPERTY_CARDS];
                NSString* cardsT = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO][@"cards"];
                if(cards.floatValue < cardsT.floatValue) {
                    [FunctionUtility setDicInUserManageWithObject:@(1) withObjectKey:PROPERTY_CARDS withDicKey:ACCOUNTINFOUPDATEFLAGS];
                    [[AccountInfoManager instance].accountInfos setValue:cardsT forKey:PROPERTY_CARDS];
                    [UserDefaultsManager setBoolValue:YES forKey:FIND_WALLET_PROPERTY_CARDS_KEY];
                }
                
            } else {
                [[AccountInfoManager instance] updateAccountInfos];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.all_content_view) {
                    [self uiTableViewReload];
                }
            });
    }
}

- (void)initCouponFromNetwork:(BOOL)isRefresh
{
    
    if (!adRequestManager) {
        adRequestManager = [AdRequestManager new];
    }
    
    [adRequestManager generateTasksWithTu:DSP_FEEDS_YP withBlock:^(NSMutableArray * result) {
        if (isRefresh) {
            [[EdurlManager instance] removeAllNewsRecordWithCloseType:UNKNOW];
            [[EdurlManager instance] clear];
        }
        [self loadCouponData:result isRefresh:isRefresh];
    } isRefresh:isRefresh];
}

- (void)initMiniBannerFromNetwork
{
    if (USE_DEBUG_SERVER) {
        [[UpdateService instance] requestForMiniBannerData:[NSString stringWithFormat:@"%@%@", YP_DEBUG_SERVER, MINI_BANNER_REQUEST_PATH]];
    } else {
        [[UpdateService instance] requestForMiniBannerData:[NSString stringWithFormat:@"%@%@", TOUCHLIFE_SITE, MINI_BANNER_REQUEST_PATH]];
    }
}

- (void)showDownloadToast:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NetworkDataDownloaderWrapper *downloader = [notification object];
        if(downloader.downloadStatus == NetworkDataDownloadDownloading) {
            [self.headerView makeToast:[NSString stringWithFormat:@"download percent : %.f",downloader.downloadPercent]];
        }
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (void) stopTimer
{
    if (repeatingTimer) {
        [repeatingTimer pauseTimer];
    }
    
}

- (void) unSelectTab
{
    isCurrentTab = NO;
    [self updatePublicMessage];
    [self stopTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getAccountNumbersInfo];
        [SeattleFeatureExecutor queryVOIPAccountInfo];
    });
    if (repeatingTimer && isCurrentTab) {
        [self newsTimeUpdate];
        [repeatingTimer resumeTimerAfterTimeInterval:VALIDATE_INTERVAL];
    }
    
    [[NoahManager sharedPSInstance] registerDevice:[UserDefaultsManager stringForKey:APPLE_PUSH_TOKEN]];
    NSString* newCity = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    NSString* oldCity = [UserDefaultsManager stringForKey:INDEX_CITY_SELECTED];
    if ( newCity.length>0 &&
        [newCity isEqualToString:oldCity] == NO) {
        [UserDefaultsManager setObject:newCity forKey:INDEX_CITY_SELECTED];
        [self cityChanged];
    } else {
        [self uiTableViewReload];
        self.load_more_foot_view.frame = CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height);
    }
    [pnCenter setNeedsDisplay];
    [_personalCenterButton refresh];
}

- (void)accountInfoChangeShouldReload {
    [self requestAccountInfos];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
    
    [self updatePublicMessage];
    
}

- (void)updatePublicMessage
{
    if (requestMsg) {
        return;
    }
    requestMsg = YES;
    //yellowpage message center
    if ([PublicNumberProvider getNewMsgCount] == 0) {
        [self performSelectorInBackground:@selector(getNewMsgcount) withObject:nil];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)loadIndexData
{
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_INDEX_JSON;
    [self loadData];
    [self performSelectorInBackground:@selector(requestCoupon) withObject:nil];
}

- (void)loadIndexDataFailed
{
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_INDEX_JSON;
    [self performSelectorInBackground:@selector(requestCoupon) withObject:nil];
}

- (void)loadData
{
    if (self.displayed == NO) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block BOOL indexRequestSuccess = NO;
        @synchronized(self) {
            NSString* localIndexFilePath = INDEX_REQUEST_FILE;
            NSDictionary* localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:localIndexFilePath];
            if (!localIndexDict) {
                localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:INDEX_FILE];
            }
            
            NSString* localIndexFontFilePath = INDEX_FONT_FILE;
            [IndexJsonUtils getIndexFontFromLocalFile:localIndexFontFilePath];
            
            if (localIndexDict == nil || localIndexDict.count <= 0) {
                [[UpdateService instance] initZipFromLocal];
                localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:localIndexFilePath];
            }
            
            
            [UIDataManager instance].recommends = nil;
            
            IndexData* data = [[IndexData alloc]initWithJson:localIndexDict];
            self.localData = data;
            
            [[UIDataManager instance] updateWithLocalData:self.localData];
            [[UIDataManager instance] updateWithNetworkError];
            //            [[UIDataManager instance] updateWithMyPhone];
            [[UIDataManager instance] updateWithMyProperty];
            [[UIDataManager instance] updateWithMyTaskBtn];
            [[UIDataManager instance] updateWithHotChannel];
            NSDictionary* index_data_request = (NSDictionary*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA];
            if (index_data_request && index_data_request.count > 0) {
                indexRequestSuccess = YES;
                IndexData* data = [[IndexData alloc]initWithJson:index_data_request];
                [[UIDataManager instance] updateWithNetData:data];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cootek_log(@"------> back main thread time:%ld", [[NSDate date] timeIntervalSince1970]);
            [[UIDataManager instance] updateToUIData];
            [self addUITableView];
            [self uiTableViewReload];
            
            cootek_log(@"------> back main thread finish load time:%ld", [[NSDate date] timeIntervalSince1970]);
            if (indexRequestSuccess) {
                if (self.load_more_foot_view == nil) {
                    LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height)];
                    view.delegate = self;
                    view.scrView = self.all_content_view;
                    [self.all_content_view addSubview:view];
                    self.load_more_foot_view = view;
                } else {
                    self.load_more_foot_view.frame = CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height);
                }
            } else {
                self.load_more_foot_view = nil;
            }
            
        });
    });
    
}

- (void)loadDataAndClearEdurl
{
    [[UIDataManager instance] removeCoupons];
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_INDEX_ACTIVITY;
    [self loadData];
    [[EdurlManager instance] removeAllNewsRecordWithCloseType:UNKNOW];
    [[EdurlManager instance] clear];
    [self showAnimationAndStopLoading];
}

- (void)showAnimationAndStopLoading
{
    
    if ([[[TaskAnimationManager instance] taskSection] isValid] && ![UIDataManager instance].myTask &&  ([TaskAnimationManager instance].requestFlg & FLG_REQ_ALL) == FLG_REQ_ALL) {
        
        int section = [[UIDataManager instance] updateWithMyDummyTask];
        if (section >= 0) {
            @try {
                [self.all_content_view beginUpdates];
                [self.all_content_view insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
                [self.all_content_view endUpdates];
            }
            @catch (NSException *exception) {
                cootek_log(@"uitable view is not ready");
            }
        }
        
        
        [TaskAnimationManager instance].requestFlg = 0;
    }
    [self stopLoading];
}

- (void)loadRequestDataFailed
{
    //    self.all_content_view.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, self.all_content_view.contentInset.left, self.all_content_view.contentInset.bottom, self.all_content_view.contentInset.right);
    //    refreshLabel.textColor = [UIColor redColor];
    //    refreshLabel.text = @"请确认网络连接是否正常后下拉重试";
    //    refreshLabel.textAlignment = NSTextAlignmentCenter;
    //    refreshLabel.frame = CGRectMake(0, refreshLabel.frame.origin.y, TPScreenWidth(), refreshLabel.frame.size.height);
    refreshArrow.hidden = YES;
}

- (void)loadRequestServerFailed
{
    self.all_content_view.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, self.all_content_view.contentInset.left, self.all_content_view.contentInset.bottom, self.all_content_view.contentInset.right);
    refreshLabel.text = @"服务器返回异常，请稍后再试";
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.frame = CGRectMake(0, refreshLabel.frame.origin.y, TPScreenWidth(), refreshLabel.frame.size.height);
    refreshArrow.hidden = YES;
    [refreshSpinner stopAnimating];
    [self performSelector:@selector(stopLoadingServer) withObject:nil afterDelay:1.0f];
}

- (void) stopLoadingServer
{
    
    
    [UIView animateWithDuration:0.3 animations:^{
        isLoading = NO;
        NSLog(@"in animation");
        CGRect scrollBounds = self.all_content_view.bounds;
        scrollBounds.origin = CGPointMake(0, 0);
        self.all_content_view.bounds = scrollBounds;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }];
}

- (void)loadCouponData:(NSArray *)finds isRefresh:(BOOL) isRefresh
{
    if (finds.count > 0) {
        cootek_log(@"franktang data returned !!");
        [[UIDataManager instance] updateWithFindNewsData:finds isRefresh:isRefresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIDataManager instance] updateToUIData];
            [TaskAnimationManager instance].requestFlg |= FLG_REQ_FIND_NEWS;
            [self uiTableViewReload];
            [self doneLoadingTableViewData];
            [self showAnimationAndStopLoading];
        });
    } else {
        cootek_log(@"franktang -> no data");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadCouponDataFailed];
        });
    }
    
}


- (void) loadCouponDataFailed
{
    _loadMore = NO;
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_FIND_NEWS;
    [self uiTableViewReload];
    self.load_more_foot_view.frame = CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height);
    [self.load_more_foot_view loadMoreScrollViewDataSourceFailed:self.all_content_view];
}

- (void) uiTableViewReload
{
    [self.all_content_view reloadData];
}

- (void) loadCouponDataIgnore
{
    _loadMore = NO;
    [self uiTableViewReload];
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_FIND_NEWS;
    self.load_more_foot_view.frame = CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height);
    [self.load_more_foot_view loadMoreScrollViewDataSourceDidFinishedLoading:self.all_content_view];
}

- (void) loadIndexFontData
{
    [self loadData];
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_INDEX_FONT;
    [self showAnimationAndStopLoading];
}

- (void)gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[UIDataManager instance] sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[UIDataManager instance] rowCountWithSectionIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.superview.clipsToBounds = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* identifier = [[UIDataManager instance] getIdentifierWithIndexPath:indexPath];
    
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell) {
        BOOL reused = [[UIDataManager instance] resetDataWithCell:cell andIndexPath:indexPath];
        if (reused) {
            return cell;
        } else {
            [cell removeFromSuperview];
        }
    }
    
    cell = [[UIDataManager instance] createViewWithIndexPath:indexPath andIdentifier:identifier];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UIDataManager instance] heightForRowWithIndexPath:indexPath];
}

-(void) hideKeyboard
{
    if([[UIDataManager instance] searchBar] && [[[UIDataManager instance] searchBar] canResignFirstResponder]) {
        [[[UIDataManager instance] searchBar] resignFirstResponder];
    }
}

- (void) onEntranceClick
{
    PersonalCenterController *controller = [[PersonalCenterController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark Noah
- (void)onNotiBecomeActive{
    [self getNoahToast];
}

- (void)getNoahToast{
    if (![NoahManager isReady]) {
        cootek_log(@"Dialer trying to get toast but not noah not ready");
        return;
    }
    cootek_log(@"Yellow page is going to get noah toast");
    [_personalCenterButton refresh];
}

- (void)dealloc
{
    [[UIDataManager instance] deallocUI];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    
    _loadMore = YES;
    [self initCouponFromNetwork:NO];
    
    
}

- (void)doneLoadingTableViewData{
    
    self.load_more_foot_view.frame = CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height);
    //  model should call this when its done loading
    _loadMore = NO;
    [self.load_more_foot_view loadMoreScrollViewDataSourceDidFinishedLoading:self.all_content_view];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[EdurlManager instance] removeNewsRecord:(UITableView *)scrollView tu: [NSString stringWithFormat:@"%d" , DSP_FEEDS_YP]];
    if (_loadMore) {
        return;
    }
    [self.load_more_foot_view loadMoreScrollViewDidScroll:scrollView];
    
    if ([self refreshHeaderOrShowError]) {
        return;
    };
    
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.all_content_view.contentInset = UIEdgeInsetsMake(0.0f, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.all_content_view.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        refreshArrow.hidden = NO;
        refreshLabel.textAlignment = NSTextAlignmentLeft;
        refreshLabel.frame = CGRectMake(TPScreenWidth() / 2, 0, TPScreenWidth() / 2, REFRESH_HEADER_HEIGHT);
        refreshLabel.textColor = [UIColor blackColor];
        
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
    
    //预加载
    if (!_loadMore && scrollView.contentOffset.y > 0) {
        NSArray<NSIndexPath *> * indexPArray = [self.all_content_view indexPathsForVisibleRows];
        if (indexPArray && indexPArray.count > 0) {
            NSIndexPath* indexPath = [indexPArray objectAtIndex:indexPArray.count - 1];
            if (indexPath.section == [self.all_content_view numberOfSections] - 1) {
                int rowCount = [self tableView:self.all_content_view numberOfRowsInSection:indexPath.section];
                
                if (rowCount - indexPath.row > 0 && rowCount - indexPath.row < 10) {
                    [self reloadTableViewDataSource];
                }
            }
        }
    }
    
    
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.frame.size.height){
    }
    
    if (isLoading) {
        return;
    }
    
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [TaskAnimationManager instance].requestFlg = 0;
        [UIDataManager instance].myTask = nil;
        [self startLoading];
    }
    [self.load_more_foot_view loadMoreScrollViewDidEndDragging:scrollView];
    
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[EdurlManager instance] removeNewsRecord:(UITableView *)scrollView tu: [NSString stringWithFormat:@"%d" , DSP_FEEDS_YP]];
}

- (void)startLoading {
    if ([self refreshHeaderOrShowError]) {
        return;
    };
    
    isLoading = YES;
    
    __weak __block YellowPageMainTabController* contrl = self;
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        if (contrl) {
            refreshArrow.hidden = YES;
            refreshLabel.text = contrl.textLoading;
            [refreshSpinner startAnimating];
            contrl.all_content_view.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        }
    }];
    
    // Refresh action!
    [self refresh];
    
}

- (void)stopLoading {
    if ([self refreshHeaderOrShowError]) {
        return;
    };
    
    isLoading = NO;
    
    
    __weak __block YellowPageMainTabController* contrl = self;
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        if (contrl) {
            self.all_content_view.contentInset = UIEdgeInsetsZero;
            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        
    } completion:^(BOOL finished) {
        if (contrl) {
            [self performSelector:@selector(stopLoadingComplete)];
        }
    }];
}

- (void)stopLoadingComplete {
    if ([self refreshHeaderOrShowError]) {
        return;
    };
    
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)viewWillLayoutSubviews {
}
- (void)refresh {
    
    [self doneLoadingTableViewData];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getAccountNumbersInfo];
        [SeattleFeatureExecutor queryVOIPAccountInfo];
    });
    [self performSelectorInBackground:@selector(refreshLoad) withObject:nil];
}

- (BOOL) refreshHeaderOrShowError
{
    if (isLoading) {
        return NO;
    }
    
    if ([Reachability network] < network_2g) {
        [self loadRequestServerFailed];
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark LoadMoreTableFooterDelegate Methods

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view {
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
    return _loadMore;
}

@end
