//
//  TPDPersonalCenterController.m
//  TouchPalDialer
//
//  Created by siyi on 16/9/19.
//  Attention: This is a copy of YellowPageMainTabController, for V6 testing
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
#import "TouchLifeTabBarAdManager.h"
#import "TPAdControlRequestParams.h"
#import "SeattleFeatureExecutor.h"
#import "AccountInfoManager.h"
#import "PersonInfoDescViewController.h"
#import "NSDictionary+Default.h"
#import "TaskAnimationManager.h"
#import "FeedsRedPacketManager.h"
#import "FindNewsBonusResult.h"
#import "TPDPersonalCenterController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FunctionUtility.h"
#import "TPDLib.h"
#import "NSString+TPHandleNil.h"
#import "Masonry.h"
#import "YPADItem.h"
#import "PersonalCenterUtility.h"
#import "AvatarSelectView.h"
#import "DefaultJumpLoginController.h"
#import "TouchPalDialerAppDelegate+RDVTabBar.h"
#import "FunctionUtility.h"
#import "PersonalCenterController.h"
#import <ReactiveCocoa.h>
#import "CommonLoginViewController.h"
#import "LocalStorage.h"
#import "NSString+TPHandleNil.h"
#import "PersonalInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ControllerManager.h"
#import "HandlerWebViewController.h"
#import "AntiharassmentViewController.h"

#define UPDATE_INTERVAL_DURATION 30
#define REFRESH_HEADER_HEIGHT 52.0f
#define VALIDATE_INTERVAL 60

// top margin or bottom margin of the ad cell view
#define YP_AD_CELL_MARGIN (15)


#define SEPERATOR_LINE_COLOR_STYLE @"tp_color_grey_50"

#define ACTION_START @"start"
#define ACTION_STOP @"stop"

#define NAME_ACTION @"action"

@interface TPDPersonalCenterController (){
    BOOL _loadMore;
    long loadTime;
    BOOL flag_start_city_page;
    NSObject* couponObj;
    BOOL isDragging;
    BOOL isLoading;
    NSTimer* repeatingTimer;
    BOOL isCurrentTab;
    BOOL requestMsg;
    YPPropertyNotLogginView *_welcomeView;
    NSIndexPath *_bannerIndexPath;
    BOOL _tableLoaded; // determine whether the talbe is once loaded
    UIButton *_tabRedDotButton;
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




@implementation TPDPersonalCenterController {
}

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



void log_view_by_color(UIView *view, UIColor *color) {
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = 1;
}

void log_view(UIView *view) {
    return;
    log_view_by_color(view, [UIColor redColor]);
}

- (void)loadView
{
    cootek_log(@"YellowPageMainTabController->loadView");
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    flag_start_city_page = NO;
    _tableLoaded = NO;
    
    //add for zip deploy
    [[UpdateService instance] checkDeployForLocalZip];
    self.displayed = NO;
    loadTime = -1;
    
    TouchPalDialerAppDelegate * tpDelegate = (TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate;
    _tabRedDotButton = [tpDelegate.tabBarController customizeOverlayTabBarItemAtIndex:3 whenClick:^(id sender) {}
    ];
    RedPointLabel *antiharassUpdateLabel = [[RedPointLabel alloc] init];
    [_tabRedDotButton addSubview:antiharassUpdateLabel];
    [antiharassUpdateLabel setSize:CGSizeMake(8, 8)];
    [antiharassUpdateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_tabRedDotButton.centerX).offset(10);
        make.top.mas_equalTo(_tabRedDotButton).offset(4);
    }];
    _tabRedDotButton.hidden = ![AntiharassmentViewController hasNewDBVersion];
    _tabRedDotButton.userInteractionEnabled = NO;
    
    [self addUITableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataAndClearEdurl) name:N_INDEX_REQUEST_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRequestDataFailed) name:N_INDEX_REQUEST_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRequestServerFailed) name:N_INDEX_REQUEST_SERVER_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadIndexData) name:N_INDEX_JSON_REQUEST_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (loadIndexDataFailed) name:N_INDEX_JSON_REQUEST_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:N_ZIP_DEPLOY_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLoad) name:N_SELECTED_YELLOWPAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unSelectTab) name:N_UNSELECTED_YELLOWPAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountInfoChangeShouldReload) name:SHOULD_REFRESH_PC_HEADVIEW object:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:N_APP_ACTIVE_SHWO_PASTEBOARD object:nil];
    
    [[UIDataManager instance] setViewController:self];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self);
        [self initMiniBannerFromNetwork];
    });
    
    //init user Agent
    [[UIDataManager instance] addUserAgent];
    
    [[AccountInfoManager instance] setRequestAccountInfo:YES];
    [TaskAnimationManager instance].requestFlg = 0;
    
    [self initLoad];
}

- (void) addUITableView
{
    if (self.all_content_view) {
        return;
    }
    // content view
    TouchPalDialerAppDelegate *appDelegate = (TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate;
    CGFloat tabHeight = appDelegate.tabBarController.tabBar.frame.size.height;
    CGFloat tableHeight = TPScreenHeight() - tabHeight;// - TPHeaderBarHeightDiff() ;
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:
        CGRectMake(0, 0, TPScreenWidth(), tableHeight)
        style:UITableViewStylePlain]; // tableview has a instrict top padding of 20dp
    
    [tmp_view_content setExtraCellLineHidden];
    tmp_view_content.delegate = self;
    tmp_view_content.dataSource = self;
    tmp_view_content.separatorStyle = UITableViewCellSeparatorStyleNone;
    tmp_view_content.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    tmp_view_content.showsVerticalScrollIndicator = NO;
    tmp_view_content.bounces = YES;
    tmp_view_content.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    [self.view addSubview:tmp_view_content];
    [[UIDataManager instance] setTableView:tmp_view_content];
    self.all_content_view = tmp_view_content;
    
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
//    [self.view addSubview:self.accessoryView];
    
    self.all_content_view.bounces = YES;
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
    
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_INDEX_TAB_SELECTED
                                    kvs:Pair(@"action", @"selected"), nil];
    
    //先走定位判断
    [self yellowpageLocate];
    
    cootek_log(@"start initLoad");
    if (self.displayed) {
        if (loadTime > 0 && ([[NSDate date] timeIntervalSince1970] - loadTime) < UPDATE_INTERVAL_DURATION) {
        } else {
            loadTime = [[NSDate date] timeIntervalSince1970];
            dispatch_async([SeattleFeatureExecutor getQueue], ^{
                [SeattleFeatureExecutor getAccountNumbersInfo];
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

- (void) refreshLoad
{
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
//        [self requestCoupon];
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

- (void) unSelectTab
{
    isCurrentTab = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self rdv_tabBarController].tabBarHidden = YES;
    [FunctionUtility setStatusBarStyleToDefault:NO];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [self rdv_tabBarController].tabBarHidden = NO;
    [FunctionUtility setStatusBarStyleToDefault:YES];
    
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
    [self startWelcomeAnimation];
    
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getAccountNumbersInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ASSET_CHANGE" object:nil];
        });
    });
    
}

- (void)accountInfoChangeShouldReload {
    [self requestAccountInfos];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopWelcomeAnimation];
}

- (void)loadIndexData
{
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_INDEX_JSON;
    [self loadData];
}

- (void)loadIndexDataFailed
{
    [TaskAnimationManager instance].requestFlg |= FLG_REQ_INDEX_JSON;
}

- (void)loadData
{
    if (self.displayed == NO) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @synchronized(self) {
            [UIDataManager instance].recommends = nil;
            self.localData = [self loadLocalData];
            [self updateIndexData];
            [[UIDataManager instance] updateWithLocalData:self.localData];
//            [[UIDataManager instance] updateWithNetworkError];
            //            [[UIDataManager instance] updateWithMyPhone];
            [[UIDataManager instance] updateWithMyProperty];
            [[UIDataManager instance] updateWithLocalSettings];
//            [[UIDataManager instance] updateWithMyTaskBtn];
//            [[UIDataManager instance] updateWithHotChannel];
            NSDictionary* index_data_request = (NSDictionary*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA];
            if (index_data_request && index_data_request.count > 0) {
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
        });
    });
    
}

- (IndexData *) loadLocalData {
    // 读取本地数据
    // 依次读取以下文件
    // 1. index.request.json (如果有)
    // 2. index.v2.json （如果有）
    // 3. webpages目录copy到cache目录中，然后读取
    //
    
    NSString* localIndexFilePath = INDEX_REQUEST_FILE;
    NSDictionary* localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:localIndexFilePath];
    if (!localIndexDict) {
        localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:INDEX_FILE];
        
        // .. important::
        //index.v2.json不应该含有"v6_sections"的信息
        // 如果含有（有一版错误的添加了），去掉
        if(localIndexDict != nil
           && [localIndexDict.allKeys containsObject:SECTION_TYPE_V6_SECTIONS]) {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:localIndexDict];
            [tmpDict removeObjectForKey:SECTION_TYPE_V6_SECTIONS];
            localIndexDict = [tmpDict copy];
        }
    }
    
    NSString* localIndexFontFilePath = INDEX_FONT_FILE;
    [IndexJsonUtils getIndexFontFromLocalFile:localIndexFontFilePath];
    
    if (localIndexDict == nil || localIndexDict.count <= 0) {
        [[UpdateService instance] initZipFromLocal];
        localIndexDict = [IndexJsonUtils getDictoryFromLocalFile:localIndexFilePath];
    }
    
    return [[IndexData alloc] initWithJson:localIndexDict];
}

- (void) updateIndexData {
    [[UIDataManager instance] updateWithLocalData:self.localData];
    //            [[UIDataManager instance] updateWithNetworkError];
    //            [[UIDataManager instance] updateWithMyPhone];
    [[UIDataManager instance] updateWithMyProperty];
    //            [[UIDataManager instance] updateWithMyTaskBtn];
    //            [[UIDataManager instance] updateWithHotChannel];
    NSDictionary* index_data_request = (NSDictionary*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA];
    
    if (index_data_request && index_data_request.count > 0) {
        IndexData* data = [[IndexData alloc]initWithJson:index_data_request];
        [[UIDataManager instance] updateWithNetData:data];
    }
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

- (void)loadRequestDataFailed {
}

- (void)loadRequestServerFailed {
}

- (void) stopLoadingServer {

}

#pragma mark - Animation Welcome
- (void) stopWelcomeAnimation {
    BOOL loggedIn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO];
    if (loggedIn) return;
    
    NSDictionary *info = @{NAME_ACTION: ACTION_STOP};
    [[NSNotificationCenter defaultCenter] postNotificationName:N_UPDATE_WELCOME_ANIMATION object:nil userInfo:info];
}

- (void) startWelcomeAnimation {
    BOOL loggedIn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO];
    if (loggedIn) {
        NSDictionary *info = @{NAME_ACTION: ACTION_START};
        [[NSNotificationCenter defaultCenter] postNotificationName:N_UPDATE_WELCOME_ANIMATION object:nil userInfo:info];
    }
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
            self.load_more_foot_view.frame = CGRectMake(0.0f, self.all_content_view.contentSize.height, self.all_content_view.frame.size.width, self.all_content_view.bounds.size.height);
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
    
    _tableLoaded = YES;
    if ([UserDefaultsManager boolValueForKey:INDEX_REQUEST_DOWNLOADED_NEW_BANNER defaultValue:NO]
        && _bannerIndexPath != nil) {
        [UserDefaultsManager setBoolValue:NO forKey:INDEX_REQUEST_DOWNLOADED_NEW_BANNER];
        UITableViewCell *cell = [self.all_content_view cellForRowAtIndexPath:_bannerIndexPath];
        if (cell != nil) {
            [self.all_content_view reloadRowsAtIndexPaths:@[_bannerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
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
    NSUInteger sectionCount = [[UIDataManager instance] sectionCount];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rowCount = [[UIDataManager instance] rowCountWithSectionIndex:section];
    return rowCount;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.superview.clipsToBounds = NO;
    _bannerIndexPath = indexPath;
    
    if (_tableLoaded
        && ![UserDefaultsManager boolValueForKey:INDEX_REQUEST_ANIMATED_NEW_BANNER defaultValue:NO]) {
        NSString *identifier = [[UIDataManager instance] getIdentifierWithIndexPath:indexPath];
        if ([SECTION_TYPE_BANNER isEqualToString:identifier]) {
            [UserDefaultsManager setBoolValue:YES forKey:INDEX_REQUEST_ANIMATED_NEW_BANNER];
            _tableLoaded = NO;
            _bannerIndexPath = nil;
            
            UIView *bannerView = [cell viewWithTag:BANNER_TAG];
            if (bannerView != nil) {
                bannerView.hidden = YES;
                bannerView.center = CGPointMake(cell.bounds.size.width * 0.5, 80 * 0.5 + 7.5);
                bannerView.hidden = NO;
                
                cell.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
                cell.alpha = 0;
                [UIView animateWithDuration:0.4
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     cell.layer.transform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
                                     cell.alpha = 1;
                                 }
                                 completion:^(BOOL finished) {
                }];
            }
        }
    }
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
    
    if (_bannerIndexPath == nil
        && [SECTION_TYPE_BANNER isEqualToString:identifier]) {
        _bannerIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    }
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
//    [self initCouponFromNetwork:NO];
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _loadMore = NO;
    [self.load_more_foot_view loadMoreScrollViewDataSourceDidFinishedLoading:self.all_content_view];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    return;
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    return;
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
    //
    //    if (scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.frame.size.height){
    //    }
    //
    //    if (isLoading) {
    //        return;
    //    }
    //
    //    isDragging = NO;
    //    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
    //        // Released above the header
    //        [TaskAnimationManager instance].requestFlg = 0;
    //        [UIDataManager instance].myTask = nil;
    //        [self startLoading];
    //    }
    //    [self.load_more_foot_view loadMoreScrollViewDidEndDragging:scrollView];
    //
    
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
    
//    @weakify(self);
//    // Show the header
//    [UIView animateWithDuration:0.3 animations:^{
//        @strongify(self);
//        if (self) {
//            refreshArrow.hidden = YES;
//            refreshLabel.text = self.textLoading;
//            [refreshSpinner startAnimating];
//            self.all_content_view.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
//        }
//    }];
    
    // Refresh action!
    [self refresh];
    
}

- (void)stopLoading {
    if ([self refreshHeaderOrShowError]) {
        return;
    };
    
    isLoading = NO;
    
//    
//    __weak __block typeof(self) contrl = self;
//    
//    // Hide the header
//    [UIView animateWithDuration:0.3 animations:^{
//        if (contrl) {
//            self.all_content_view.contentInset = UIEdgeInsetsZero;
//            [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
//        }
//        
//    } completion:^(BOOL finished) {
//        if (contrl) {
//            [self performSelector:@selector(stopLoadingComplete)];
//        }
//    }];
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

//#pragma mark -
//#pragma mark LoadMoreTableFooterDelegate Methods
//
//- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view {
//    
//    [self reloadTableViewDataSource];
//    
//}
//
//- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
//    return _loadMore;
//}
//

#pragma mark - Notifications
- (void) appDidEnterBackground {
    cootek_log(@"%s", __func__);
    if ([self selectedRootViewController] == self) {
        [_welcomeView endAnimation];
    }
    [self stopWelcomeAnimation];
}

- (void) appDidBecomeActive {
    cootek_log(@"%s", __func__);
    if ([self selectedRootViewController] == self) {
        [_welcomeView beginAnimation];
    }
    [self startWelcomeAnimation];
    _tabRedDotButton.hidden = ![AntiharassmentViewController hasNewDBVersion];
}

- (UIViewController *) selectedRootViewController {
    UIViewController *rootController = nil;
    RDVTabBarController *tabController = [self rdv_tabBarController];
    if ([tabController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *selectedController = (UINavigationController *)tabController.selectedViewController;
        NSArray *controllers = selectedController.viewControllers;
        if (controllers.count > 0
            && controllers[0] == self) {
            rootController = controllers[0];
        }
    }
    return rootController;
}

@end



#pragma mark - Class YPAdCellView
@implementation YPAdCellView {
    UIImageView *_iconImageView;
    UILabel *_iconLabel;
    
    UILabel *_rightTextLabel;
    RedPointLabel *_rightDotLabel;
    RedPointLabel *_titleAlertLabel;
}

- (instancetype) initWithData:(YPAdItem *)data andSection:(SectionAD *)section{
    self = [super init];
    if (self) {
        _adItem = data;
        _section = section;
        
        _iconContainer = [self iconContainerView];
        _rightContainer = [self rightContainerView];
        
        _titleLabel = [UILabel tpd_commonLabel];
        [_titleLabel tpd_withText:_adItem.title color:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] font:16];
        
        _subTitleLabel = [UILabel tpd_commonLabel];
        [_subTitleLabel tpd_withText:_adItem.subTitle color:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] font:16];
        
        _titleAlertLabel = [[RedPointLabel alloc] init];
        _titleAlertLabel.hidden = NO;
        [_titleAlertLabel setShadowColor:[UIColor blackColor] offset:CGSizeMake(0, 3) opacity:0.09];
        [_titleAlertLabel setSize:CGSizeMake(8, 8)];
        
        [self addSubview:_iconContainer];
        [self addSubview:_titleLabel];
        [self addSubview:_titleAlertLabel];
        [self addSubview:_subTitleLabel];
        [self addSubview:_rightContainer];
        
        [@[_iconContainer, _titleLabel, _subTitleLabel, _rightContainer] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
        }];
        
        [_iconContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(20);
        }];
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(60);
            make.height.mas_equalTo(self);
        }];
        
        [_titleAlertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_titleLabel.right).offset(2);
            make.centerY.mas_equalTo(self).offset(-2);
        }];
        
        [_rightContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-15);
        }];
        [_subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-33);
        }];
        
        [_iconContainer tpd_withSize:CGSizeMake(28, 28)];
        [_rightContainer tpd_withSize:CGSizeMake(16, 16)];
        
        self.backgroundColor =
            [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_900"];
        
        [self updateUIWithData:data];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_50"];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor whiteColor];
    [self doClick];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    cootek_log(@"touch canceled");
    self.backgroundColor = [UIColor whiteColor];
}

- (void) updateUIWithData:(YPAdItem *)data {
    self.adItem = data;
    
    _subTitleLabel.text = self.adItem.subTitle;
    _titleLabel.text = self.adItem.title;
    // right
    _rightDotLabel.text = self.adItem.rightDotCount;
    
    NSDictionary *leftTextInfo = [YPAdUtil deserializedFontString:self.adItem.leftFont];
    if (leftTextInfo != nil) {
        _iconLabel.text = leftTextInfo[@"text"];
        _iconLabel.font = leftTextInfo[@"font"];
    }
    
    if ([AntiharassmentViewController hasNewDBVersion]) {
        self.adItem.titleAlertText = NSLocalizedString(@"Update", @"更新");
    } else {
        self.adItem.titleAlertText = nil;
    }
    
    if (self.adItem.titleAlertText != nil) {
        _titleAlertLabel.text = self.adItem.titleAlertText;
        [_titleAlertLabel setSize:CGSizeMake(34, 16)];
        [_titleAlertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(_titleLabel.right).offset(2);
        }];
        
    } else {
        _titleAlertLabel.text = nil;
        [_titleAlertLabel setSize:CGSizeMake(8, 8)];
        [_titleAlertLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self).offset(-2);
            make.left.mas_equalTo(_titleLabel.right).offset(2);
        }];
    }
    if (self.adItem.alertVisible) {
        [self updateLeftShowInfo];
        [self updateRightShowInfo];
        // middel alert only supports the red point
        _titleAlertLabel.hidden = ![self.adItem.highlightItem.type isEqualToString:@"redpoint"];
        
    } else {
        _iconImageView.hidden = YES; // left hide icon image
        _rightDotLabel.hidden = YES; // right hide dot
        _titleAlertLabel.hidden = YES;
        
        _iconLabel.hidden = NO;   // left show text
        _rightTextLabel.hidden = NO; // right show text
        
    }
    
    
}

- (void) updateLeftShowInfo {
    switch (self.adItem.leftAlertType) {
        case AlertTypeVector: {
            _iconImageView.hidden = YES;
            _iconLabel.hidden = NO;
            break;
        }
        case AlertTypeIcon: {
            UIImage *iconImage = [ImageUtils getImageFromLocalWithUrl:_adItem.iconLink];
            if (iconImage != nil) {
                _iconImageView.image = iconImage;
            }
            _iconImageView.hidden = (iconImage == nil);
            _iconLabel.hidden = !_iconImageView.hidden;
            break;
        }
        default: {
            break;
        }
    }
}

- (void) updateRightShowInfo {
    switch (_adItem.rightAlertType) {
        case AlertTypeVector: {
            _rightTextLabel.hidden = NO;
            _rightDotLabel.hidden = YES;
            break;
        }
        case AlertTypeDot: {
            _rightDotLabel.text = self.adItem.rightDotCount;
            if ([_rightDotLabel.text intValue] > 0) {
                _rightDotLabel.hidden = NO;
                _rightTextLabel.hidden = YES;
            } else {
                _rightDotLabel.hidden = YES;
                _rightTextLabel.hidden = NO;
            }
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - Actions
- (void) doClick {
    CTUrl *cturl = self.adItem.ctUrl;
    if (cturl != nil) {
        BOOL hasLogin = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN
                                                defaultValue:NO];
        if (cturl.needLogin
            && !hasLogin) {
            DefaultJumpLoginController *loginController = [DefaultJumpLoginController
                                                           withOrigin:@"personal_center_wallet"];
            loginController.destination = nil;
            [LoginController checkLoginWithDelegate:loginController];
            
        } else {
            [cturl startWebView];
        }
    }
    [YPAdItem hideClickHiddenInfo:_adItem.identifier];
    [self updateUIWithData:_adItem];
    return;
    
//    if ([[self.adItem.ctUrl.nativeUrl allKeys] containsObject:@"ios"]) {
//        [ControllerManager pushAndGetController:[cturl.nativeUrl objectForKey:@"ios"]];
//    } else {
//        NSString *url = [cturl urlWrapper];
//        HandlerWebViewController *vipWebViewVC = [[HandlerWebViewController alloc]init];
//        vipWebViewVC.url_string = [url  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        [[TouchPalDialerAppDelegate naviController] pushViewController:vipWebViewVC animated:YES];
//    }
//    [YPAdItem hideClickHiddenInfo:_adItem.identifier];
//    [self updateUIWithData:_adItem];
    
}

- (void) pushController:(UIViewController *)controller shouldCheckLogin:(BOOL)shouldCheck{
    BOOL hasLogin = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO];
    if (shouldCheck && !hasLogin) {
        DefaultJumpLoginController *loginController = [DefaultJumpLoginController
                                                       withOrigin:@"personal_center_wallet"];
        NSString *sourceClass = nil;
        if (controller != nil) {
            sourceClass = NSStringFromClass(controller.class);
        }
        loginController.destination = nil;
        [LoginController checkLoginWithDelegate:loginController];
        //    [self.navigationController pushViewController:controller animated:YES];
    } else {
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
}

#pragma mark - Views
- (UIView *) rightContainerView {
    UIView *container = [[UIView alloc] init];
    
    _rightTextLabel = [UILabel tpd_commonLabel];
    NSDictionary *rightTextInfo = [YPAdUtil deserializedFontString:DEFAULT_RIGHT_LABEL_TEXT];
    if (rightTextInfo != nil) {
        _rightTextLabel.text = rightTextInfo[@"text"];
        _rightTextLabel.font = rightTextInfo[@"font"];
    }
    
    _rightDotLabel = [[RedPointLabel alloc] init];
    _rightDotLabel.hidden = YES;
    
    [container addSubview:_rightTextLabel];
    [container addSubview:_rightDotLabel];
    
    CGSize commonSize = CGSizeMake(16, 16);
    [_rightTextLabel tpd_withSize:commonSize];
    _rightTextLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
    
    [_rightDotLabel tpd_withSize:commonSize];
    
    UILabel *dotLabel = _rightDotLabel.dotLabel;
    dotLabel.font = [UIFont systemFontOfSize:10];
    dotLabel.textAlignment = NSTextAlignmentCenter;
    dotLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_900"];
    dotLabel.clipsToBounds = YES;
    dotLabel.layer.cornerRadius = commonSize.width / 2;
    dotLabel.backgroundColor = [UIColor redColor];
    
    _rightDotLabel.layer.shadowOffset = CGSizeMake(0, 3);
    _rightDotLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _rightDotLabel.layer.shadowOpacity = 0.09;
    
    [@[_rightTextLabel, _rightDotLabel] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(container);
    }];
    
    
    return container;
}

- (UIView *) iconContainerView {
    UIView *container = [[UIView alloc] init];
    
    _iconLabel = [UILabel tpd_commonLabel]; // model.iconLink
    NSArray* arr = [self.adItem.leftFont componentsSeparatedByString:@":"];
    if (arr.count == 5) {
        NSDictionary *textInfo = [YPAdUtil deserializedFontString:self.adItem.leftFont];
        _iconLabel.text = textInfo[@"text"];
        _iconLabel.textColor = textInfo[@"textColor"];
        _iconLabel.font = textInfo[@"font"];
        
        _iconLabel.backgroundColor = [UIColor clearColor];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.hidden = NO;
        
    } else {
        _iconLabel.hidden = YES;
    }
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconImageView.hidden = YES;
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [container addSubview:_iconLabel];
    [container addSubview:_iconImageView];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(28, 28));
        make.center.mas_equalTo(container);
    }];
    
    [_iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(container);
    }];
    
    return container;
}

@end


#pragma mark - Class YPAdUtil
@implementation YPAdUtil
+ (NSDictionary *) deserializedFontString:(NSString *)tpFontString {
    if ([NSString isNilOrEmpty:tpFontString]) {
        return nil;
    }
    NSArray* arr = [tpFontString componentsSeparatedByString:@":"];
    if (arr.count < 4) {
        return nil;
    }
    UIFont *font = [UIFont fontWithName:arr[1] size:[(NSString *)arr[3] floatValue]];
    NSString *text = arr[2];
    UIColor *textColor =[TPDialerResourceManager getColorForStyle:arr[4]];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    if (font != nil) {
        [info setObject:font forKey:@"font"];
    }
    if (text != nil) {
        [info setObject:text forKey:@"text"];
    }
    if (textColor != nil) {
        [info setObject:textColor forKey:@"textColor"];
    }
    return [info copy];
}

@end


#pragma mark - Class YPAdRowView

@implementation YPAdRowView
- (instancetype) initWithData:(SectionAD *)data {
    return [self initWithData:data contentInsets:UIEdgeInsetsZero];
}

- (instancetype) initWithData:(SectionAD *)data contentInsets:(UIEdgeInsets)insets {
    self = [super init];
    if (self != nil) {
        
        NSMutableArray *subViews = [[NSMutableArray alloc] initWithCapacity:data.items.count];
        for(int i = 0, dataCount = data.items.count; i < dataCount; i++) {
            
            YPAdItem *item = (YPAdItem *)data.items[i];
            YPAdCellView *cellView = [[YPAdCellView alloc] initWithData:item andSection:data];
            [subViews addObject:cellView];
            cellView.tag = data.sectionIndex + i;
            
            if (i < dataCount - 1) {
                UIView *line = [self addBottomLineForView:cellView];
                [line mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.bottom.mas_equalTo(cellView);
                    make.left.mas_equalTo(cellView.titleLabel.left);
                }];
            }
        }
        if (subViews.count > 0) {
            NSMutableArray *offsets = [[NSMutableArray alloc] initWithCapacity:subViews.count];
            int viewCount = subViews.count;
            if (viewCount == 1) {
                for(int j = 0; j < viewCount; j++) {
                    [offsets addObject:@(0)];
                }
                [self tpd_addSubviewsWithVerticalLayout:subViews offsets:offsets];
                
            } else {
                CGFloat verticalMargin = INDEX_ROW_AD_CELL_MARGIN / 2;
                UIView *lastSecondView = nil;
                for(int j = 0; j < viewCount; j++) {
//                    if (j == 0) {
//                        if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, insets)) {
//                            [offsets addObject:@(verticalMargin)];
//                        } else {
//                            [offsets addObject:@(insets.top)];
//                        }
//                    } else {
//                        [offsets addObject:@(0)];
//                    }
//                    if (j == viewCount - 2) {
//                        lastSecondView = [subViews objectAtIndex:j];
//                    }
                    [offsets addObject:@(0)];
                }
                [self tpd_addSubviewsWithVerticalLayout:subViews offsets:offsets];
//                [subViews.lastObject mas_updateConstraints:^(MASConstraintMaker *make) {
//                    if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, insets)) {
//                        make.bottom.mas_equalTo(self.bottom).mas_offset(-verticalMargin);
//                    } else {
//                        if (lastSecondView != nil) {
//                            make.bottom.mas_equalTo(self.bottom).mas_offset(-insets.bottom);
//                        }
//                    }
//                }];
            }
        }
        
        for(YPAdCellView *cell in subViews) {
            [cell mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@(INDEX_ROW_HEIGHT_AD_CELL));
            }];
        }
    }
    return self;
}

- (void) updateUIWithData:(SectionAD *)data {
    NSArray *subViews = self.subviews;
    int tag = data.sectionIndex;
    for(int i = 0, len = subViews.count; i < len; i++) {
        YPAdCellView *cellView = (YPAdCellView *)[self viewWithTag:(tag + i)];
        if (data.items.count > i) {
            [cellView updateUIWithData:data.items[i]];
        }
    }
}

#pragma mark - Helpers
- (UIView *) addBottomLineForView:(UIView *)container {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [TPDialerResourceManager getColorForStyle:SEPERATOR_LINE_COLOR_STYLE];
    [container addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(1));
    }];
    return line;
}

@end


#pragma mark - Class YPPropertyRowView
static const CGFloat sAvatarWidth = 90;

#define TAG_RED_DOT (101)

#define TAG_CHANGES (201)
#define TAG_FREE_MINUTES (202)
#define TAG_FREE_DATA (203)

#define SMALL_DOT_SIZE (8)
#define MEDIUM_DOT_SIZE (16)

@implementation YPPropertyRowView {
    UILabel *_voipDayLabel;
    UIButton *_avatarButton;
    NSArray *_profileButtons;
    
    UIColor *_separatorColor;
    BOOL _appearedOnce;
    UIButton *vipButtonContainer;
    
    UIView *_loggedInHeaderView;
    YPPropertyNotLogginView *_notLoggedInHeaderView;
}

- (void) baseInit {
    _separatorColor = [TPDialerResourceManager getColorForStyle:SEPERATOR_LINE_COLOR_STYLE];
    _appearedOnce = NO;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        [self baseInit];
        BOOL loggedIn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO];
        _loggedInHeaderView = [self loggedInHeaderViewByVipDays:0.0];
        _loggedInHeaderView.hidden = !loggedIn;
        
        _notLoggedInHeaderView = [[YPPropertyNotLogginView alloc] init];
        _notLoggedInHeaderView.hidden = loggedIn;
        
        UIView *headerContainer = [[UIView alloc] init];
        [headerContainer addSubview:_loggedInHeaderView];
        [headerContainer addSubview:_notLoggedInHeaderView];
        
        [_notLoggedInHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(headerContainer);
            make.height.mas_equalTo(180);
        }];
        
        [_loggedInHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(headerContainer);
            make.height.mas_equalTo(180);
        }];
        
        UIView *profileContainer = [self profileContainer];
        
        [self tpd_addSubviewsWithVerticalLayout:@[headerContainer, profileContainer] offsets:@[@(0), @(0)]];
        
        [profileContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(0);
            make.height.mas_equalTo(70);
        }];
        
        UIView *line = [self addBottomLineForView:self];
        [line mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self);
        }];
        
        
        // actions
        [[_notLoggedInHeaderView.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside]
            subscribeNext:^(id x) {
                [self pushController:nil shouldCheckLogin:YES];
            }
        ];
        self.backgroundColor = [UIColor whiteColor];
        [self update];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFromNotification:) name:N_VOIP_ACCOUNT_INFO_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFromNotification:) name:N_VOIP_LOGINOUT_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWelcomAnimation:) name:N_UPDATE_WELCOME_ANIMATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:@"ASSET_CHANGE" object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        cootek_log(@"%s, notification = %@", __func__, notification);
        [self update];
    });
}

- (void) update {
    cootek_log(@"v6_dev, cell update");
    BOOL loggedIn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO];
    [self updateAccountInfo:loggedIn];
    [self setPropertyViewVisible:loggedIn];
}

- (void) setPropertyViewVisible:(BOOL)loggedIn {
    cootek_log(@"%s", __func__);
    _loggedInHeaderView.hidden = !loggedIn;
    _notLoggedInHeaderView.hidden = loggedIn;
    if (_notLoggedInHeaderView.hidden) {
        [_notLoggedInHeaderView endAnimation];
    } else {
        [_notLoggedInHeaderView beginAnimation];
    }
}

- (void) updateWelcomAnimation:(NSNotification *)noti {
    NSString *action = (NSString *)[noti.userInfo objectForKey:NAME_ACTION];
    if ([action isEqualToString:ACTION_START]) {
        [_notLoggedInHeaderView beginAnimation];
    } else if ([action isEqualToString:ACTION_STOP]) {
        [_notLoggedInHeaderView endAnimation];
    }
}

- (void) updateAccountInfo:(BOOL)loggedIn {
    cootek_log(@"%s", __func__);
    if (loggedIn) {
        NSDictionary *profileInfo = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO defaultValue:nil];
        for(UIButton *button in _profileButtons) {
            UILabel *numberLabel = button.tpd_text1;
            NSString *accountKey = nil;
            switch (button.tag) {
                case TAG_CHANGES: {
                    accountKey = CENTER_DETAIL_COINS;
                    float changes = [[profileInfo objectForKey:CENTER_DETAIL_COINS] floatValue];
                    numberLabel.text = [self formatFloatNumber:changes];
                    break;
                }
                case TAG_FREE_MINUTES: {
                    accountKey = CENTER_DETAIL_MINUTES;
                    NSInteger minutes = [[profileInfo objectForKey:CENTER_DETAIL_MINUTES] integerValue];
                    numberLabel.text = [self formatBigNumber:minutes];
                    break;
                }
                case TAG_FREE_DATA: {
                    accountKey = CENTER_DETAIL_BYTES_F;
                    float bytes = [[profileInfo objectForKey:CENTER_DETAIL_BYTES_F] floatValue];
                    numberLabel.text = [self formatFloatNumber:bytes];
                    break;
                }
                default:
                    break;
            }
            if ([NSString isNilOrEmpty:numberLabel.text]) {
                numberLabel.text = @" ";
            }
            if (accountKey != nil) {
                NSString *prefKey = [NSString stringWithFormat:@"%@_%@", SHOW_DOT, accountKey];
                [button viewWithTag:TAG_RED_DOT].hidden =
                        ![UserDefaultsManager boolValueForKey:prefKey defaultValue:NO];
            }
        }
    } else {
        [self setFontToDefault];
    }
    NSString *day  = nil;
    BOOL isVip = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    vipButtonContainer.hidden = !isVip;
    if (isVip) {
        day = [NSString stringWithFormat:@"%d天",
               [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY defaultValue:0]];
    } else {
        day = @" ";
    }
    _voipDayLabel.text = day;
}

- (void) setFontToDefault {
    for(UIButton *button in _profileButtons) {
        switch (button.tag) {
            case TAG_FREE_DATA:
            case TAG_FREE_MINUTES:
            case TAG_CHANGES: {
                button.tpd_text1.text = @"0";
                button.tpd_text1.textColor =
                    [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                button.tpd_text1.font = [UIFont systemFontOfSize:22];
                break;
            }
            default:
                break;
        }
    }
}

- (UIView *) loggedInHeaderViewByVipDays:(double)days {
    @weakify(self);
    CGFloat vipContainerHeight = 24;
    UIView *headerView = [[UIView alloc] init];
    
    _voipDayLabel = [UILabel tpd_commonLabel];
    _voipDayLabel.font = [UIFont systemFontOfSize:12];
    _voipDayLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
    _voipDayLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *tagView = [UILabel tpd_commonLabel];
    tagView.text = @"Y";
    tagView.font = [UIFont fontWithName:@"iPhoneIcon5" size:30];
    tagView.textColor = [UIColor colorWithHexString:@"0XFF9933"];
    tagView.textAlignment = NSTextAlignmentCenter;
    
    vipButtonContainer = [UIButton tpd_buttonStyleCommon];
    vipButtonContainer.hidden = ![UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    
    
    [vipButtonContainer addSubview:tagView];
    [vipButtonContainer addSubview:_voipDayLabel];
    
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_voipDayLabel.left).offset(-3);
        make.top.bottom.mas_equalTo(vipButtonContainer);
        make.left.mas_equalTo(vipButtonContainer.left);
    }];
    
    [_voipDayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(vipButtonContainer.right);
        make.top.bottom.mas_equalTo(vipButtonContainer);
    }];
    
    _avatarButton = [UIButton tpd_buttonStyleCommon];
    _avatarButton.clipsToBounds = YES;
    _avatarButton.layer.masksToBounds = NO;
    _avatarButton.layer.cornerRadius = sAvatarWidth / 2;
    _avatarButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _avatarButton.layer.shadowOffset = CGSizeMake(0, 7);
    _avatarButton.layer.shadowOpacity = 0.09;
    [self updateAvatarImage];
    
    // view tree
    [headerView addSubview:vipButtonContainer];
    [headerView addSubview:_avatarButton];
    
    [_avatarButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(headerView);
        make.size.mas_equalTo(CGSizeMake(sAvatarWidth, sAvatarWidth));
    }];
    
    [vipButtonContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(headerView).offset(40);
        make.right.mas_equalTo(headerView).offset(-20);
        make.height.mas_equalTo(@(vipContainerHeight));
    }];
    
    // actions
    [vipButtonContainer tpd_withBlock:^(id sender) {
        @strongify(self);
        [self pushControllerWithDescModel:[PersonInfoDescModel PrivilegaModel]];
    }];
    
    [_avatarButton tpd_withBlock:^(id sender) {
        @strongify(self);
        UIViewController *controller = [[PersonalInfoViewController alloc] init];
        [self pushController:controller shouldCheckLogin:YES];
    }];
    
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (UIView *) profileContainer {
    @weakify(self);
    UIButton *changesButton = [UIButton tpd_buttonStyleVerticalLabel2:
                               @[@" ", NSLocalizedString(@"tpd_center_profile_my_changes", @"")]
                                                            withBlock:^(id sender){
                                                                @strongify(self);
                                                                [self hideRedDot:sender];
                                                                [self pushControllerWithDescModel:[PersonInfoDescModel backFeeModel]];
                                                            }];
    changesButton.tag = TAG_CHANGES;
    
    UIButton *freeMinutesButton = [UIButton tpd_buttonStyleVerticalLabel2:
                                   @[@" ", NSLocalizedString(@"tpd_center_profile_free_minutes", @"")]
        withBlock:^(id sender){
        @strongify(self);
        [self hideRedDot:sender];
        [self pushControllerWithDescModel:[PersonInfoDescModel freeFeeModel]];
        
    }];
    freeMinutesButton.tag = TAG_FREE_MINUTES;
    
    UIButton *freeDataButton = [UIButton tpd_buttonStyleVerticalLabel2:
                                @[@" ", NSLocalizedString(@"tpd_center_profile_free_data", @"")]
                                                             withBlock:^(id sender){
                                                                 @strongify(self);
                                                                 [self hideRedDot:sender];
                                                                 [self pushControllerWithDescModel:[PersonInfoDescModel trafficModel]];
                                                             }];
    freeDataButton.tag = TAG_FREE_DATA;
    
    _profileButtons = @[changesButton, freeMinutesButton, freeDataButton];
    for(int index = 0, len = _profileButtons.count; index < len; index++) {
        UIButton *button = _profileButtons[index];
        if (index != len - 1) {
            UIView *sepratorLine = [[UIView alloc] init];
            sepratorLine.backgroundColor = _separatorColor;
            
            [button addSubview:sepratorLine];
            
            [sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(button.right);
                make.centerY.mas_equalTo(button);
                make.width.mas_equalTo(@(1));
                make.height.mas_equalTo(40);
            }];
        }
        
        UILabel *upperLabel = button.tpd_text1;
        upperLabel.font = [UIFont systemFontOfSize:26];
        upperLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        
        button.tpd_text2.font = [UIFont systemFontOfSize:12];
        button.tpd_text2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        
        // red dot
        UILabel *redDotLabel = [self redDotByDiameter:SMALL_DOT_SIZE withString:nil];
        redDotLabel.tag = TAG_RED_DOT;
        redDotLabel.hidden = YES;
        
        [button addSubview:redDotLabel];
        
        [redDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(upperLabel).offset(-4);
            make.left.mas_equalTo(upperLabel.right).offset(4);
            make.size.mas_equalTo(CGSizeMake(SMALL_DOT_SIZE, SMALL_DOT_SIZE));
        }];
        
        [button.tpd_text2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(button.tpd_text1.bottom).offset(0);
        }];
        
        log_view((button));
        log_view(button.tpd_text1);
        log_view(button.tpd_text2);
    }
    UIView *container = [UIView tpd_horizontalGroupWith:_profileButtons
                                      horizontalPadding:0
                                        verticalPadding:0
                                           interPadding:0
                                              weightArr:@[@(1), @(1), @(1)]];
    container.backgroundColor = [UIColor whiteColor];
    log_view(container);
    
//    UIView *bottomLine = [[UIView alloc] init];
//    bottomLine.backgroundColor = _separatorColor;
//    
//    [container addSubview:bottomLine];
//    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.mas_equalTo(container);
//        make.height.mas_equalTo(@(1));
//    }];
    
    for(UIView *view in _profileButtons) {
        [self outlineView:view];
    }
    [self outlineView:container];
    [_profileButtons mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(container);
    }];
    
    return container;
}

- (void) pushControllerWithDescModel:(PersonInfoDescModel *)model {
    PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:model];
    if ([model.modelName isEqualToString:MODEL_FREE_FEE]) {
        controller.pageType = FIND_WALLET_PROPERTY_MINUTES_KEY;
    }
    [self pushController:controller shouldCheckLogin:YES];
}

- (void) updateAvatarImage {
    UIImage *avatarImage = [PersonalCenterUtility getHeadViewUIImage];
    if (avatarImage != nil) {
        [_avatarButton setBackgroundImage:avatarImage forState:UIControlStateNormal];
    }
}

- (void) hideRedDot:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIView *dotView = [button viewWithTag:TAG_RED_DOT];
    if (dotView == nil
        || dotView.hidden) {
        return;
    }
    
    dotView.hidden = YES;
    NSString *prefKey = [self stringifyTag:button.tag];
    if (prefKey != nil) {
        [UserDefaultsManager setBoolValue:NO forKey:prefKey];
    }
}

- (UILabel *) redDotByDiameter:(CGFloat)diameter withString:(NSString *)text {
    RedPointLabel *redPoint = [[RedPointLabel alloc] init];
    UILabel *dot = redPoint.dotLabel;
    dot.backgroundColor = [UIColor redColor];
    dot.text = text;
    dot.layer.cornerRadius = diameter / 2;
    dot.clipsToBounds = YES;
    
    redPoint.layer.cornerRadius = diameter / 2;
    redPoint.layer.shadowOffset = CGSizeMake(0, 3);
    redPoint.layer.shadowColor = [UIColor blackColor].CGColor;
    redPoint.layer.shadowOpacity = 0.09;
    
    return redPoint;
}

- (void) selectAvatar {
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO]) {
        @weakify(self);
        CGRect bounds = [UIScreen mainScreen].bounds;
        AvatarSelectView *avaterSelectView = [[AvatarSelectView alloc] initWithFrame:bounds];
        UINavigationController *navi = [TouchPalDialerAppDelegate naviController];
        [navi.viewControllers[0].view addSubview:avaterSelectView];
        [avaterSelectView setCompleteHandle:^{
            @strongify(self);
            [self updateAvatarImage];
        }];
    } else {
        [self pushController:nil shouldCheckLogin:YES];
    }
}

- (void) pushController:(UIViewController *)controller shouldCheckLogin:(BOOL)shouldCheck{
    BOOL hasLogin = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO];
    if (shouldCheck && !hasLogin) {
        DefaultJumpLoginController *loginController = [DefaultJumpLoginController
                                                       withOrigin:@"personal_center_wallet"];
        NSString *sourceClass = nil;
        if (controller != nil) {
            sourceClass = NSStringFromClass(controller.class);
        }
        loginController.destination = nil;
        [LoginController checkLoginWithDelegate:loginController];
        //    [self.navigationController pushViewController:controller animated:YES];
    } else {
        [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    }
}

- (void) outlineView:(UIView *)view {
    return;
    view.layer.borderColor = [UIColor redColor].CGColor;
    view.layer.borderWidth = 1;
}

#pragma mark Helpers
- (NSString *) formatBigNumber:(int) realNum {
    if (realNum >= 10000) {
        return @"9999+";
    }
    
    return [NSString stringWithFormat:@"%d", realNum];
}

- (NSString *) formatFloatNumber:(float) realNum {
    NSString *stringValue = nil;
    if (realNum <= 9999.99) {
        if (realNum>99.99) {
            float pointFloat = realNum-(int)realNum;
            if (pointFloat==0) {
                stringValue = [NSString stringWithFormat:@"%d", (int)realNum];
            } else {
                stringValue = [NSString stringWithFormat:@"%d+", (int)realNum];
            }
        } else {
            stringValue =  [NSString stringWithFormat:@"%.2f", realNum];
        }
    } else {
        stringValue = @"9999+";
    }
    
    return stringValue;
}

- (NSString *) stringifyTag:(int)tag {
    NSString *tagString = nil;
    switch (tag) {
        case TAG_CHANGES: {
            tagString = CENTER_DETAIL_COINS;
            break;
        }
        case TAG_FREE_DATA: {
            tagString = CENTER_DETAIL_BYTES_F;
            break;
        }
        case TAG_FREE_MINUTES: {
            tagString = CENTER_DETAIL_MINUTES;
            break;
        }
        default: {
            break;
        }
    }
    if (tagString == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@_%@", SHOW_DOT, tagString];
}

@end

#pragma mark - YPPropertyNotLogginView


#define LOGIN_BUTTON_HEIGHT (34)
#define LOGIN_BUTTON_MARGIN (24)

@implementation YPPropertyNotLogginView {
    NSTimer *_animationTimer;
    NSMutableArray *_recursiveFrames;
}

- (void) baseInit {
    _recursiveFrames = [[NSMutableArray alloc] initWithCapacity:2];
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        [self baseInit];
        
        // view initialization
        CGRect loginButtonRect = CGRectMake(0, 0, 120, 34);
        _loginButton = [[UIButton alloc] init];
        _loginButton.layer.cornerRadius = LOGIN_BUTTON_HEIGHT/ 2;
        _loginButton.clipsToBounds = YES;
        [_loginButton setTitle:NSLocalizedString(@"login_right_now", @"马上登录")
                     forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_light_blue_500" withFrame:loginButtonRect]
                                forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_light_blue_600" withFrame:loginButtonRect]
                                forState:UIControlStateHighlighted];
        
        UIImageView *welcomeImageView = [[UIImageView alloc] init];
        welcomeImageView.contentMode = UIViewContentModeRight;
        welcomeImageView.image = [TPDialerResourceManager getImage:@"tab_me_header_welcome_text@3x.png"];
        
        _animationImageView = [[UIImageView alloc] init];
        _animationImageView.contentMode = UIViewContentModeBottomRight;
        _animationImageView.image = [TPDialerResourceManager getImage:@"tab_me_header_frame_1@3x.png"];
        
        UIView *separatorBar = [[UIView alloc] init];
        separatorBar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
        
        // view tree
        [self addSubview:_loginButton];
        [self addSubview:welcomeImageView];
        [self addSubview:_animationImageView];
        [self addSubview:separatorBar];
        
        // view constraints
        [separatorBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(TPScreenWidth(), 15));
            make.left.right.bottom.mas_equalTo(self);
        }];
        
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.mas_equalTo(separatorBar).offset(-LOGIN_BUTTON_MARGIN);
            make.size.mas_equalTo(CGSizeMake(120, LOGIN_BUTTON_HEIGHT));
        }];
        
        [welcomeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_loginButton.top).offset(-16);
            make.right.mas_equalTo(_loginButton);
        }];
        
        [_animationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(welcomeImageView.left).offset(-30);
            make.bottom.mas_equalTo(separatorBar.mas_top);
            make.left.top.mas_equalTo(self);
        }];
        
        // actions
        self.backgroundColor = [UIColor clearColor];
        
        [self prepareAnimationFrames];
    }
    return self;
}

- (void) prepareAnimationFrames {
//    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_2@3x.png"] duration:0.2];
    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_3@3x.png"] duration:0.15];
    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_4@3x.png"] duration:0.15];
    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_3@3x.png"] duration:0.15];
    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_4@3x.png"] duration:0.15];
    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_3@3x.png"] duration:0.15];
    [self addFrameBlock:[self blockForImage:@"tab_me_header_frame_4@3x.png"] duration:0.15];
    [self addFrameBlock:[self blockForImage:nil] duration:2];
}

- (void (^)()) blockForImage:(NSString *)imageName {
    @weakify(self);
    return ^{
        @strongify(self);
        if ([NSString isNilOrEmpty:imageName]){
            return;
        }
        UIImage *image = [TPDialerResourceManager getImage:imageName];
        if (image != nil) {
            self.animationImageView.image = image;
        }
    };
}

- (void) setAnimationImageByName:(NSString *)imageName delay:(NSTimeInterval)delay{
    UIImage *image = [TPDialerResourceManager getImage:imageName];
    if (image != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _animationImageView.image = image;
        });
    }
}

- (void) loop {
    NSTimeInterval sum = 0;
    for (int i = 0, len = _recursiveFrames.count; i < len; i++) {
        NSArray *item = _recursiveFrames[i];
        if (item.count != 2) {
            continue;
        }
        void (^block)() = (void (^)()) item[0];
        NSTimeInterval interval = (NSTimeInterval)[item[1] doubleValue];
        if (block != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sum * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                block();
            });
            sum += interval;
        }
    }
}

- (NSTimeInterval) cycleTime {
    NSTimeInterval cycle = 0;
    for(NSArray *item in _recursiveFrames) {
        cycle += (NSTimeInterval)[item[1] doubleValue];
    }
    return cycle;
}

- (void) beginAnimation {
    if (_animating) {
        return;
    }
    
    _animating = YES;
    [self setAnimationImageByName:@"tab_me_header_frame_1@3x.png" delay:0];
    [self setAnimationImageByName:@"tab_me_header_frame_2@3x.png" delay:0.3];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_animationTimer == nil) {
            _animationTimer = [NSTimer scheduledTimerWithTimeInterval:[self cycleTime]
                                                               target:self
                                                             selector:@selector(loop)
                                                             userInfo:nil
                                                              repeats:YES];
            [_animationTimer fire];
        }
    });
}

- (void) endAnimation {
    if (!_animating) {
        return;
    }
    
    if (_animationTimer != nil) {
        [self setAnimationImageByName:@"tab_me_header_frame_1@3x.png" delay:0];
        [_animationTimer invalidate];
        _animationTimer = nil;
        _animating = NO;
    }
}

- (void) addFrameBlock:(void (^)())animationBlock duration:(NSTimeInterval)duration {
    if (animationBlock != nil) {
        [_recursiveFrames addObject:@[animationBlock, @(duration)]];
    }
}


@end


@implementation RedPointLabel {
}

- (instancetype) init{
    self = [super init];
    if (self != nil) {
        _dotLabel = [[UILabel alloc] init];
        _dotLabel.backgroundColor = [UIColor redColor];
        _dotLabel.font = [UIFont systemFontOfSize:10];
        _dotLabel.textColor = [UIColor whiteColor];
        _dotLabel.textAlignment = NSTextAlignmentCenter;
        _dotLabel.clipsToBounds = YES;
        
        [self addSubview:_dotLabel];
        [_dotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void) setText:(NSString *)text {
    _dotLabel.text = text;
}

- (NSString *) text {
    return _dotLabel.text;
}

- (void) setShadowColor:(UIColor *)shadowColor offset:(CGSize)offset opacity:(CGFloat)opacity {
    self.layer.shadowOffset = offset;
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = opacity;
}

- (void) setSize:(CGSize)size andCornorRadius:(CGFloat)radius {
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
    _dotLabel.layer.cornerRadius = radius;
}

- (void) setSize:(CGSize)tp_size {
    [self setSize:tp_size andCornorRadius:tp_size.height/2];
}

@end
