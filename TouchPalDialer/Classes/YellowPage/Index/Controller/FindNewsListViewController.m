//
//  FindNewsListControllerViewController.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/17.
//
//

#import "FindNewsListViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "ImageUtils.h"
#import "UITableView+TP.h"
#import "IndexConstant.h"
#import "LoadMoreTableFooterView.h"
#import "TouchPalDialerAppDelegate.h"
#import "UpdateService.h"
#import "TouchPalVersionInfo.h"
#import "CootekNotifications.h"
#import "UIDataManager.h"
#import "IndexData.h"
#import "SectionFindNews.h"
#import "FindNewsRowView.h"
#import "SectionCoupon.h"
#import "FindRowView.h"
#import "EdurlManager.h"
#import "Reachability.h"
#import "NSTimer+Addition.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "TPShareController.h"
#import "FeedsRedPacketManager.h"
#import "FindNewsBonusResult.h"
#import "FeedsRedPacketShowPopUpView.h"
#import "DialogUtil.h"
#import "YPUIView.h"
#import "UserDefaultsManager.h"
#import "YPFeedsTask.h"
#import "YellowPageMainQueue.h"
#import "FeedsSigninManager.h"
#import "FeedsHeaderView.h"
#import "VerticallyAlignedLabel.h"
#import "FeedsRedPacketLoginController.h"
#import "FeedsSignPopupView.h"
#import <BlocksKit.h>
#import "TPDLib.h"
#import "FindNewsUpdateRecordView.h"
#import "TPFilterRecorder.h"
#import "FeedsBtnRefreshManager.h"
#import "UsageConst.h"
#import "UIView+TPDExtension.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NewsFeedsCellTableViewCell.h"
#import "UITableViewCell+TPDExtension.h"
#import "TPDDiscoverViewController.h"
#import "TPDialerResourceManager.h"

#define REFRESH_HEADER_HEIGHT 52.0f
#define VALIDATE_INTERVAL 60

#define REPEAT_TIME_INTERVAL 60
#define REFRES_FEEDS_TIME_INTERVAL  10 * 60


#define kRefreshTableViewDoneNotification @"kRefreshTableViewDoneNotification"
#define kChangeTabBarStatus               @"kChangeTabBarStatus"




@interface FindNewsListViewController () {
    TPHeaderButton* gobackBtn;
    NSMutableArray* _findNewsData;
    NSString* _queryId;
    BOOL _loadMore;
    BOOL isDragging;
    BOOL isLoading;
    NSTimer* repeatingTimer;
    YPUIView* redpacketView;
    int feedsUpdatCount;
    YPUIView* loginBar;
    FindNewsItem* updateRecItem;
    BOOL fromTabIconClick;
    
    //welcome
    NSTimer* timer;
    UIButton * rightTopTimerView;
    int count;
    UIImageView* fullScreenView;
}


@property (nonatomic, retain) FeedsHeaderView *refreshHeaderView;
@property(nonatomic, retain) LoadMoreTableFooterView* load_more_foot_view;
@property(nonatomic, strong) FindNewsBonusResult* queryResult;
@property(nonatomic, strong) NSMutableDictionary* stickDic;
@property(nonatomic, strong) NSMutableArray* feedsCopy;
@property(nonatomic, assign) NSTimeInterval lastUpdateTime;
@property(nonatomic, assign) NSTimeInterval forceRefreshTime;
@property(atomic, assign) BOOL isRefreshHeader;
@end

@implementation FindNewsListViewController

@synthesize contentTableView;
@synthesize contentView;
@synthesize refreshHeaderView;
@synthesize load_more_foot_view;
@synthesize isRefreshHeader;
@synthesize feedsCopy;
@synthesize lastUpdateTime;
@synthesize forceRefreshTime;

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.isTabSelected = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* title = @"天天头条";
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    self.headerView = headerBar;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:titleLabel];
    
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if(isVersionSix) {
        // back button
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        gobackBtn = backBtn;
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        
    } else {
        //Back Button
        gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
        [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:gobackBtn];
    }

    
    

    if(!self.contentView) {
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    }
    
    
    self.contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height) style:UITableViewStylePlain];
    [contentTableView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    contentTableView.separatorStyle = UITableViewCellAccessoryNone;
    contentTableView.backgroundColor = [ImageUtils colorFromHexString: SERVICE_CELL_BG_COLOR andDefaultColor:nil];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    contentTableView.showsVerticalScrollIndicator = NO;
    [contentTableView setExtraCellLineHidden];
    
    [NewsFeedsCellTableViewCell registerCellForUITableView:contentTableView];
    
    [self.view addSubview:contentView];
    [contentView addSubview:contentTableView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addPullToRefreshHeader];
    
    _findNewsData = [NSMutableArray new];
    _stickDic = [NSMutableDictionary new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCouponData) name:N_COUPON_REQUEST_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCouponDataFailed) name:N_COUPON_REQUEST_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCouponDataIgnore) name:N_COUPON_REQUEST_IGNORE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTab:) name:N_TOP_TAB_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDiscoverEnterBackground) name:kDiscoverTabSelectedToBackground object:nil];
    
    isRefreshHeader = NO;
    [self startLoading];
    self.contentTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    
    [self resetGetMoreFooter];
    
    WEAK(self)
    repeatingTimer = [NSTimer bk_scheduledTimerWithTimeInterval:VALIDATE_INTERVAL block:^(NSTimer *timer) {
        [weakself newsTimeUpdate];
    } repeats:YES];
    
    [weakself newsTimeUpdate];
//    [NSTimer scheduledTimerWithTimeInterval:VALIDATE_INTERVAL target:self selector:@selector(newsTimeUpdate) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:repeatingTimer forMode:NSDefaultRunLoopMode];
    
    //weixin register!
    [TPShareController registerWeiXinApp];
    
    [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_FIND_NEWS_ITEM kvs:Pair(@"action", @"show"),Pair(@"tu",self.tu),Pair(@"class", @"FindNewsListViewController"), nil];
    
    __block __weak FindNewsListViewController* wController = self;
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME]) {
        redpacketView = [[YPUIView alloc] init];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:redpacketView.bounds];
        icon.image= [TPDialerResourceManager getImage:@"feeds_red_packet@2x.png"];
        [redpacketView addSubview:icon];
        [self.contentView addSubview:redpacketView];
        
        [redpacketView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-13);
        }];
        [icon makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(redpacketView);
        }];
    } else {
        redpacketView = [[YPUIView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 77, 57, 67)];
        NSString *redPacktePath = [[NSBundle mainBundle] pathForResource:FEEDS_RED_PACKET_FLOAT_ICON ofType:@"png"];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:redpacketView.bounds];
        icon.image=  [UIImage imageWithContentsOfFile:redPacktePath];
        [redpacketView addSubview:icon];
        [self.contentView addSubview:redpacketView];
    }
    
   __block __weak YPUIView* weakView = redpacketView;
    
    redpacketView.block = ^(){
        [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_CLICK_RED_PACKET_LIST];
        [FeedsRedPacketManager showRedPacket: weakView withType:YP_RED_PACKET_FEEDS_LIST withQueryResult:wController.queryResult withLoginBlock:^{
            weakView.hidden = YES;
            [wController queryFeedsRedPacket];
            if ([FeedsSigninManager shouldShowSignin]) {
                [FeedsSigninManager showSigninGuideDialog:nil];
            }
        }];
    };
    
    updateRecItem = [FindNewsItem new];
    updateRecItem.category = CategoryUpdateRec;

    [[NSNotificationCenter defaultCenter]addObserverForName:N_FEEDS_REFRESH object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary* userinfo = [note userInfo];
        NSNumber* changTab = [userinfo objectForKey:@"feeds_icon_click"];
        fromTabIconClick = [changTab boolValue];
        isRefreshHeader = YES;
        [self refreshStart];
        [[FeedsBtnRefreshManager instance] hideRefreshBtn:self];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:N_FEEDS_REFRESH_FROMOTHER object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       
        NSDictionary* userinfo = [note userInfo];
        NSNumber* changTab = [userinfo objectForKey:@"feeds_icon_click"];
        fromTabIconClick = [changTab boolValue];
        [self refreshFeeds];
    }];
    
    lastUpdateTime  = [[NSDate date] timeIntervalSince1970];
}

- (void) onDiscoverEnterBackground {
    lastUpdateTime = [[NSDate date] timeIntervalSince1970];
}

- (void) refreshFeeds
{
    isRefreshHeader = NO;
    if ([[NSDate date] timeIntervalSince1970] > lastUpdateTime + REFRES_FEEDS_TIME_INTERVAL) {
        if (!_isTabSelected) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFeedsTabSelectedToRefresh object:nil];
        }
        [self refreshStart];
    } else {
        if  (_isTabSelected) {
            [[FeedsBtnRefreshManager instance] show: self];
        }
    }
}

- (void) queryFeedsRedPacket
{
    redpacketView.hidden = YES;
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        redpacketView.hidden = NO;
        return;
    }
    
    [[FeedsRedPacketManager new] queryFeedsRedPacketByType:YP_RED_PACKET_FEEDS_LIST withBlock:^(FindNewsBonusResult * result) {
        self.queryResult = result;
        if ([result checkBonus]) {
            [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_SHOW_RED_PACKET_LIST];
            redpacketView.hidden = NO;
        }
    }];
}
- (void) showWelcomeViews
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:FEEDS_DATE_FORMAT];
    NSString* current = [df stringFromDate:[NSDate date]];
    
    if ([current isEqualToString:[UserDefaultsManager stringForKey:FEEDS_WELCOME_SHOW]]) {
        return;
    }
    [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name", FEEDS_SHOW_WELCOME), nil];
    [UserDefaultsManager setObject:current forKey:FEEDS_WELCOME_SHOW];
    
     fullScreenView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    
    NSString *bgPath = [[NSBundle mainBundle] pathForResource:FEEDS_WELCOME_BG_PATH ofType:@"png"];
    fullScreenView.image = [UIImage imageWithContentsOfFile:bgPath];
    
    [self.view addSubview: fullScreenView];
    
    rightTopTimerView = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - FEEDS_WELCOME_TIMER_RIGHT_MARGIN - FEEDS_WELCOME_TIMER_WIDTH, FEEDS_WELCOME_TIMER_TOP_MARGIN, FEEDS_WELCOME_TIMER_WIDTH, FEEDS_WELCOME_TIMER_HEIGHT)];
    rightTopTimerView.layer.cornerRadius = 18.0f;
    rightTopTimerView.layer.borderWidth = 1.0f;
    rightTopTimerView.layer.masksToBounds = YES;
    rightTopTimerView.layer.borderColor = [ImageUtils colorFromHexString:FEEDS_WELCOME_TIMER_BORDER_COLOR andDefaultColor:nil].CGColor;
    [rightTopTimerView setTitle:@"3" forState:UIControlStateNormal];
    [rightTopTimerView setTitleColor: [ImageUtils colorFromHexString:FEEDS_WELCOME_TIMER_TEXT_COLOR andDefaultColor:nil] forState:UIControlStateNormal];
    rightTopTimerView.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightTopTimerView addTarget:self action:@selector(hideFullScreenView) forControlEvents:UIControlEventTouchUpInside];
    [fullScreenView addSubview:rightTopTimerView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:REPEAT_TIME_INTERVAL target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    count = 3;

}

- (void) hideFullScreenView
{
    [timer invalidate];
    timer = nil;
    fullScreenView.hidden = YES;
}

- (void) timeUpdate
{
    if (count > 1) {
        count --;
        [rightTopTimerView setTitle:[NSString stringWithFormat:@"%d", count]  forState:UIControlStateNormal];
    } else {
        [timer invalidate];
        timer = nil;
        fullScreenView.hidden = YES;
    }

}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[FeedsHeaderView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, TPScreenWidth(), REFRESH_HEADER_HEIGHT)];
    [self.contentTableView addSubview:refreshHeaderView];
}



- (void)loadRequestDataFailed
{
    self.contentTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, self.contentTableView.contentInset.left, self.contentTableView.contentInset.bottom, self.contentTableView.contentInset.right);
    [refreshHeaderView loadRequestDataFailed];
}

- (BOOL) refreshHeaderOrShowError
{
    if (isLoading) {
        return NO;
    }
    
    if ([Reachability network] < network_2g) {
        [self loadRequestDataFailed];
        return YES;
    }
    return NO;
}

- (void)startLoading {
    if ([self refreshHeaderOrShowError]) {
        return;
    };
    
    isLoading = YES;
    [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_START_PULL_REFRESH];
    [refreshHeaderView startLoading];
//    self.contentTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    [self query];
    
}


- (void)stopLoading {
    if ([self refreshHeaderOrShowError] || !isLoading) {
        return;
    };
    
    isLoading = NO;
    
    if (feedsUpdatCount > 0) {
        self.contentTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        [refreshHeaderView stopLoadingwithRefresh:YES andBlock:^{
            // Hide the header
            [UIView animateWithDuration:0.3 animations:^{
                self.contentTableView.contentInset = UIEdgeInsetsZero;
                [refreshHeaderView.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            } completion:^(BOOL finished) {
                [self stopLoadingComplete];
            }];
        } andFeedsCount:feedsUpdatCount];
        feedsUpdatCount = 0;
    } else {
        // Hide the header
        [UIView animateWithDuration:0.3 animations:^{
            self.contentTableView.contentInset = UIEdgeInsetsZero;
            [refreshHeaderView.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        } completion:^(BOOL finished) {
            [self stopLoadingComplete];
        }];
    }
}

- (void)stopLoadingComplete {
    if ([self refreshHeaderOrShowError]) {
        return;
    };
     self.contentTableView.contentInset = UIEdgeInsetsZero;
    [refreshHeaderView stopLoadingComplete];
}

- (void) changeTab: (NSNotification *)notification
{
    isRefreshHeader = NO;
    NSDictionary *dict = [notification userInfo];
    NSString* indexStr = [dict objectForKey:@"tabChange"];
    if (indexStr.intValue != 0) {
        if (self.isTabSelected) {
            forceRefreshTime = [[NSDate date] timeIntervalSince1970];
        }
        self.isTabSelected = NO;
        [[FeedsBtnRefreshManager instance] saveRefresStatus: self];
        
    } else {
        if (!self.isTabSelected  && [[NSDate date] timeIntervalSince1970] > forceRefreshTime + REFRES_FEEDS_TIME_INTERVAL) {
            [self refreshStart];
        }
        [self updateSignAndRefresh];
        self.isTabSelected = YES;

    }
}

- (void) refreshStart
{
     [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_START_REFRESH];
    if  (!isRefreshHeader && _findNewsData.count > 0) {
        _findNewsData = [NSMutableArray new];
        [self.contentTableView reloadData];
//        [adRequestManager setQueryId:@""];
    }
    
    if ([self numberOfSectionsInTableView:self.contentTableView ]> 0 &&  [self.contentTableView numberOfRowsInSection:0] > 0) {
        [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self.contentTableView setContentOffset:CGPointMake(0, -REFRESH_HEADER_HEIGHT) animated:YES];
        [self startLoading];
    } else {
        [self startLoading];
        self.contentTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    }
}

- (void)query {
    _queryId = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self initCouponFromNetwork:isRefreshHeader];
    });
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self showLoginBar];
    [super viewDidAppear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (repeatingTimer) {
        [repeatingTimer pauseTimer];
    }
     lastUpdateTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isTabSelected) {
        [self updateSignAndRefresh];
    }
  
    if (repeatingTimer) {
        [self newsTimeUpdate];
        [repeatingTimer resumeTimerAfterTimeInterval:VALIDATE_INTERVAL];
    }
    
}

- (void) updateSignAndRefresh
{
    [[FeedsBtnRefreshManager instance] show:self];
    [FeedsSigninManager showSigninGuideDialog:nil];
    [self queryFeedsRedPacket];
    [FeedsSigninManager updateSignTime];
}

-(void) newsTimeUpdate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTableView reloadData];
    });
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[EdurlManager instance] removeNewsRecord:(UITableView *)scrollView tu:[NSString stringWithFormat:@"%d", self.tu.integerValue]];
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
            self.contentTableView.contentInset = UIEdgeInsetsMake(0.0f, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.contentTableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        [refreshHeaderView srcollViewWithOffset:scrollView.contentOffset.y];
    }
    
    //预加载
    if (!_loadMore && scrollView.contentOffset.y > 0) {
        NSArray<NSIndexPath *> * indexPArray = [self.contentTableView indexPathsForVisibleRows];
        if (indexPArray && indexPArray.count > 0) {
            NSIndexPath* indexPath = [indexPArray objectAtIndex:indexPArray.count - 1];
            if (indexPath.section == [self.contentTableView numberOfSections] - 1) {
                int rowCount = [self tableView:self.contentTableView numberOfRowsInSection:indexPath.section];
                
                if (rowCount - indexPath.row > 0 && rowCount - indexPath.row < 10) {
                    [self reloadTableViewDataSource];
                }
            }
            
            //TODO 滑动5个新闻及以上，底部tab显示为刷新icon，并且有小红点，点击后自动刷新新闻列表，并跳转至头部。
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
     if (scrollView.contentOffset.y > 500) {
         if (isLoading) {
             isLoading = NO;
             [self stopLoadingComplete];
         }
     }
    
    isDragging = NO;
    fromTabIconClick = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        isRefreshHeader = YES;
        [self startLoading];
    } else {
    
        if (scrollView.contentOffset.y > 1000) {
            [[FeedsBtnRefreshManager instance] showRefreshBtnWithAnimation: self];
        }
//        if (scrollView.contentOffset.y > 1500) {
//            [[FeedsBtnRefreshManager instance] showLargeBalloonWithAnimation];
//        }
    }
    [self.load_more_foot_view loadMoreScrollViewDidEndDragging:scrollView];
    
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[EdurlManager instance] removeNewsRecord:(UITableView *)scrollView tu:[NSString stringWithFormat:@"%d", self.tu.integerValue]];
}

- (void)updateToUIData:(IndexData *)data
{
    if (data.groupArray.count > 0) {
        SectionGroup* group = [data.groupArray objectAtIndex:0];
        SectionFindNews* section = [group.sectionArray objectAtIndex:0];
        if (!_loadMore) {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                   NSMakeRange(0,[section.items count])];
            [_findNewsData insertObjects:section.items atIndexes:indexes];
        } else {
            [_findNewsData addObjectsFromArray:section.items];
        }
        
        _queryId = section.queryId;
    }
    
}


- (void)updateData:(NSArray *)data

{
    
    if (!_loadMore) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                               NSMakeRange(0,data.count)];
        [_findNewsData insertObjects:data atIndexes:indexes];
    } else {
        [_findNewsData addObjectsFromArray:data];
    }
    
    //    if (data.groupArray.count > 0) {
    //        SectionGroup* group = [data.groupArray objectAtIndex:0];
    //        SectionFindNews* section = [group.sectionArray objectAtIndex:0];
    //        if (!_loadMore) {
    //            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
    //                                   NSMakeRange(0,[section.items count])];
    //            [_findNewsData insertObjects:section.items atIndexes:indexes];
    //        } else {
    //            [_findNewsData addObjectsFromArray:section.items];
    //        }
    //        
    //        _queryId = section.queryId;
    //    }
    
}


- (NSMutableArray *) dealWithStickData:(NSArray *) finds {
    feedsCopy = [NSMutableArray new];
    feedsCopy = [NSMutableArray arrayWithArray:_findNewsData];
    
    NSMutableArray* topArr = [NSMutableArray new];
    NSMutableArray *normalNews = [[NSMutableArray alloc] initWithCapacity:finds.count];
    
    for (FindNewsItem* item in finds) {
        if (item.topIndex.integerValue >= 0){
            if ([[_stickDic allKeys] containsObject:item.newsId]){
                feedsUpdatCount--;
                [feedsCopy removeObject:[_stickDic objectForKey:item.newsId]];
                [_stickDic removeObjectForKey:item.newsId];
            }
            [topArr addObject:item];
        } else {
            [normalNews addObject:item];
        }
    }
    NSUInteger normalNewsCount = normalNews.count;
    if (normalNewsCount > 0) {
        NSRange range = NSMakeRange(0, normalNewsCount);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [feedsCopy insertObjects:[normalNews copy] atIndexes:indexSet];
    }
                                
    for (FindNewsItem* item in [_stickDic allValues]) {
        item.topIndex = [NSNumber numberWithInteger:-1];
    }
    
    [_stickDic removeAllObjects];
    
    if (topArr.count > 0) {
        NSArray *sortedArray;
        sortedArray = [topArr sortedArrayUsingSelector:@selector(compare:)];
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                               NSMakeRange(0, sortedArray.count)];
        [feedsCopy insertObjects:sortedArray atIndexes:indexes];
        for (FindNewsItem* item in sortedArray) {
            [_stickDic setObject:item forKey:item.newsId];
        }
    }
    
    return feedsCopy;
}

- (void)loadCouponData:(NSArray *)finds isRefresh:(BOOL)isRefresh
{
    if (!isLoading && !_loadMore) {
        return;
    }
    
    if (finds.count > 0) {
        if (isRefresh) {
            if (isRefreshHeader) {
                feedsUpdatCount = finds.count;
            }
            NSRange range = NSMakeRange(0, [finds count]);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            FindNewsItem* item = [finds objectAtIndex:[indexSet lastIndex]];
            item.noBottomBorder = YES;
            if (_findNewsData.count > 0) {
                if(updateRecItem) {
                    updateRecItem.noBottomBorder = YES;
                }
                updateRecItem = [FindNewsItem new];
                updateRecItem.category = CategoryUpdateRec;
                [_findNewsData insertObject:updateRecItem atIndex:0];
               
            }
            _findNewsData = [self dealWithStickData:finds];
//            [_findNewsData insertObjects:finds atIndexes:indexSet];
        } else {
            if (_findNewsData.count <= 0) {
                _findNewsData = [self dealWithStickData:finds];
            } else {
                [_findNewsData addObjectsFromArray:finds];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
             [self.contentTableView reloadData];
             [self stopLoading];
            if (isRefresh) {
                [[FeedsBtnRefreshManager instance] hideRefreshBtn:self];
                self.load_more_foot_view.frame = CGRectMake(0.0f, self.contentTableView.contentSize.height, self.contentTableView.frame.size.width, self.contentTableView.bounds.size.height);
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:.3];
                [self.contentTableView setContentInset:UIEdgeInsetsMake(self.contentTableView.contentInset.top, self.contentTableView.contentInset.left, 0.0f, self.contentTableView.contentInset.right)];
                [UIView commitAnimations];
            } else {
                self.load_more_foot_view.frame = CGRectMake(0.0f, self.contentTableView.contentSize.height, self.contentTableView.frame.size.width, self.contentTableView.bounds.size.height);
            }
            [self doneLoadingTableViewData];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoading];
            [self doneLoadingTableViewData];
        });
    }
    
}

- (void) loadCouponDataIgnore
{
    _loadMore = NO;
    [self.load_more_foot_view loadMoreScrollViewDataSourceDidFinishedLoading:self.contentTableView];
}

- (void) resetGetMoreFooter
{
    if (self.load_more_foot_view == nil) {
        LoadMoreTableFooterView *view = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0.0f, self.contentTableView.contentSize.height, self.contentTableView.frame.size.width, self.contentTableView.bounds.size.height)];
        view.delegate = self;
        view.scrView = self.contentTableView;
        [self.contentTableView addSubview:view];
        self.load_more_foot_view = view;
    } else {
        self.load_more_foot_view.frame = CGRectMake(0.0f, self.contentTableView.contentSize.height, self.contentTableView.frame.size.width, self.contentTableView.bounds.size.height);
    }
}

- (void)initCouponFromNetwork:(BOOL)refresh
{
//    @synchronized(self) {
//        if (!adRequestManager) {
//            adRequestManager = [AdRequestManager new];
//        }
//        [adRequestManager registerController:self];
//        [adRequestManager generateTasksWithTu:self.tu.integerValue withBlock:^(NSMutableArray * result) {
//            cootek_log(@" ------ task finish -------");
//            [self loadCouponData:result isRefresh:refresh];
//        } isRefresh:refresh];
//    }
}

- (NewsFeedsCellTableViewCell* ) createViewWithIndexPath:(NSIndexPath *)path andIdentifier:(NSString *)identifier
{
    FindNewsItem* item = [_findNewsData objectAtIndex:path.row];
    
    
    
    NewsFeedsCellTableViewCell *fCell = [[NewsFeedsCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
     float rowHeight = [self tableView:self.contentTableView heightForRowAtIndexPath:path];
    if (item.category == CategoryUpdateRec) {
        [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_REFRESH_BAR_LOAD_SUCCESS];
        __weak FindNewsListViewController* weakself = self;
        FindNewsUpdateRecordView* view = [[FindNewsUpdateRecordView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), rowHeight)];
        view.block = ^{
            isRefreshHeader = YES;
            [weakself.contentTableView setContentOffset:CGPointMake(0, -REFRESH_HEADER_HEIGHT) animated:NO];
             [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_REFRESH_BAR_CLICK_SUCCESS];
//            [weakself.contentTableView scrollRectToVisible:CGRectMake(0, -weakself.refreshHeaderView.frame.size.height, 1, 1) animated:NO];
            [weakself startLoading];
        };
        [fCell addSubview:view];
    } else {
        
        int screenWidth = TPScreenWidth();
        int startX = 0;
        
        
        FindNewsRowView *findNewsView = [[FindNewsRowView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) andData:item andIndexPath:path isV6:[UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]];
        
        if (item.category == CategoryADBaidu) {
//            BaiduMobAdNativeAdView* nativeAdView = [[BaiduMobAdNativeAdView alloc]initWithFrame:CGRectMake(startX, 0, screenWidth, rowHeight) brandName:nil title:nil text:nil icon:nil mainImage:nil];
//            
//            [nativeAdView addSubview:findNewsView];
//            [nativeAdView loadAndDisplayNativeAdWithObject:item.baiduAdNativeObject completion:^(NSArray *errors) {
//                if (!errors) {
//                    if (nativeAdView) {
//                        [nativeAdView trackImpression];
//                    }
//                }
//            }];
//            [fCell addSubview:nativeAdView];
        } else {
            [fCell addSubview:findNewsView];
        }
    }
    
    return fCell;
}

+ (CGFloat) heightForFindNewsRow:(FindNewsItem *)item withHeader:(BOOL)hasHeader
{
    if  (item.category == CategoryUpdateRec) {
        return INDEX_ROW_HEIGHT_FIND_NEWS_UPDATE_REC;
    }
    
    CGFloat height = -1.0f;
    CGFloat topMargin =  FIND_NEWS_TOP_MARGIN;
    CGFloat topMargin2 = FIND_NEWS_MARGIN_TO_IMAGE;
    CGFloat leftMargin = FIND_NEWS_LEFT_MARGIN;
    CGFloat threeHeight = INDEX_ROW_HEIGHT_FIND_NEWS_THREE_IMAGE;
    
    if (isIPhone6Resolution()) {
        if (WIDTH_ADAPT <= 1.01) {
            topMargin = topMargin - 4;
            topMargin2 = topMargin2 - 4;
            leftMargin = leftMargin - 4;
            threeHeight = threeHeight - 4;
        }
    }

    switch (item.type.intValue) {
        case FIND_NEWS_TYPE_BIG_IMAGE:
        {
            CGFloat width = TPScreenWidth() - 2 * leftMargin;
            CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width withLines:2];
            CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.subTitle withWidth:width];
            height =  INDEX_ROW_HEIGHT_FIND_NEWS_BIG_IMAGE + heightTitle +  topMargin + heightSubTitle + 3 * topMargin2;
            break;
        }
        case FIND_NEWS_TYPE_NO_IMAGE:
        {
            CGFloat width = TPScreenWidth() - 2 * leftMargin;
            CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width withLines:2];
            CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.subTitle withWidth:width];
            height =  heightTitle + 2 * topMargin2 + heightSubTitle + 20;
            break;
        }
        case FIND_NEWS_TYPE_ONE_IMAGE:{
            height = INDEX_ROW_HEIGHT_FIND_NEWS_ONE_IMAGE + 2 * topMargin2; 
            break;
        }
        case FIND_NEWS_TYPE_THREE_IMAGE:
        {
            CGFloat width = TPScreenWidth() - 2 * leftMargin;
            CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width withLines:2];
            CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.subTitle withWidth:width];
            height = threeHeight + heightTitle + 3 * topMargin2 + heightSubTitle +  topMargin;
            break;
        }
        case FIND_NEWS_TYPE_VIDEO:
        {
            CGFloat width = TPScreenWidth() - 2 * leftMargin;
            CGFloat heightTitle = [FindNewTitleView getHeightByTitle:item.title withWidth:width withLines:2];
            CGFloat heightSubTitle = [FindNewsSubTitleView getHeightByTitle:item.subTitle withWidth:width];
            height =  INDEX_ROW_HEIGHT_FIND_NEWS_VIDEO + heightTitle + topMargin + heightSubTitle + 3 * topMargin2;
            break;
        }
        default:
            break;
    }
    if (hasHeader) {
        height = height + INDEX_ROW_HEIGHT_FIND_NEWS_HEADER;
    }
    return height;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void) gobackBtnPressed
{
    [[EdurlManager instance] removeAllNewsRecordWithCloseType:BACK];
    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
    
}

- (int) tagFromItem:(FindNewsItem*) item
{
    switch (item.category) {
        case CategoryADBaidu: {
            return FIND_NEWS_BAIDU_TAG;
        case CategoryUpdateRec: {
            return FIND_NEWS_UPDATE_TAG;
        }
        default:
            return FIND_NEWS_TAG;
        }
    }
}
    
#pragma mark tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _findNewsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cootek_log(@" ---------------- cellForRowAtIndexPath row: %d --------------", indexPath.row);
    
     FindNewsItem* item = [_findNewsData objectAtIndex:indexPath.row];
    
     [[EdurlManager instance] addNewsRecord:indexPath andNewsInfo:item];
    NSString* identifier = [NewsFeedsCellTableViewCell identifierFromItem:item];
    
    NewsFeedsCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell.tpd_label1) {
        [cell setFindnewsItem:item withIndexPath:indexPath];
        if (item.category == CategoryUpdateRec) {
                [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_REFRESH_BAR_LOAD_SUCCESS];
        }
        return cell;
    }
    cell = [cell createCellViewsFromItem:item];
    [cell setFindnewsItem:item withIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindNewsItem* item = [_findNewsData objectAtIndex:indexPath.row];
    
    NSString* identifier = [NewsFeedsCellTableViewCell identifierFromItem:item];
    if (item.category == CategoryUpdateRec) {
        if (item.noBottomBorder) {
            return 1;
        } else {
            return INDEX_ROW_HEIGHT_FIND_NEWS_UPDATE_REC;
        }
    }
    return  [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(id cell) {
        NewsFeedsCellTableViewCell* newsCell = cell;
        [newsCell setFindnewsItem:item withIndexPath:indexPath];
        newsCell.fd_enforceFrameLayout= YES;
    }];
}

#pragma mark -
#pragma mark LoadMoreTableFooterDelegate Methods

- (void)loadMoreTableFooterDidTriggerRefresh:(LoadMoreTableFooterView *)view {
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)loadMoreTableFooterDataSourceIsLoading:(LoadMoreTableFooterView *)view {
    return _loadMore;
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    
    _loadMore = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self initCouponFromNetwork:NO];
    });
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _loadMore = NO;
    [self.load_more_foot_view loadMoreScrollViewDataSourceDidFinishedLoading:self.contentTableView];
}

- (void) loadNewsDataFailed
{
    _loadMore = NO;
    [self.contentTableView reloadData];
    self.load_more_foot_view.frame = CGRectMake(0.0f, self.contentTableView.contentSize.height, self.contentTableView.frame.size.width, self.contentTableView.bounds.size.height);
    [self.load_more_foot_view loadMoreScrollViewDataSourceFailed:self.contentTableView];
}

- (void) showLoginBar
{
    if ([UserDefaultsManager boolValueForKey:FEEDS_SHOW_LOGIN_BAR defaultValue:YES] && (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN])) {
        [UserDefaultsManager setBoolValue:NO forKey:FEEDS_SHOW_LOGIN_BAR];
        loginBar = [[YPUIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 30)];
        loginBar.backgroundColor = [ImageUtils colorFromHexString:@"#66000000" andDefaultColor:nil];
        UIImageView* gift = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 25, 20)];
        NSString *giftPath = [[NSBundle mainBundle] pathForResource:FEEDS_LOGIN_GIFT_PATH ofType:@"png"];
        gift.image = [UIImage imageWithContentsOfFile:giftPath];
        [loginBar addSubview:gift];
        
        VerticallyAlignedLabel* textLabel = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(30, 0, TPScreenWidth() - 70, 30)];
        textLabel.text = @"登录后才有5分钟签到时长奖励哦!";
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.verticalAlignment = VerticalAlignmentMiddle;
        [loginBar addSubview:textLabel];
        
        UIImageView* arrow = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth() - 30, 8,  20, 14)];
        NSString *arrowPath = [[NSBundle mainBundle] pathForResource:FEEDS_LOGIN_ARROW_PATH ofType:@"png"];
        arrow.image = [UIImage imageWithContentsOfFile:arrowPath];
        [loginBar addSubview:arrow];
        
        [self.contentView addSubview:loginBar];
        
        __weak FindNewsListViewController* wController =self;
        loginBar.block = ^{
            if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
                [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_FROM, LOGIN_FROM_FEEDS_RED_PACKET), nil];
                FeedsRedPacketLoginController *feedRedPacketLogin = [FeedsRedPacketLoginController new];
                feedRedPacketLogin.afterLoginBlock = ^{
                    [FeedsSigninManager showSigninGuideDialog:nil];
                };
                [LoginController checkLoginWithDelegate:feedRedPacketLogin];
                [DialerUsageRecord recordYellowPage:PATH_FEEDS kvs:Pair(@"module", FEEDS_MODULE), Pair(@"name",FEEDS_CLICK_NEWS_LOGIN_BAR), Pair(@"isLogined", @"false"), nil];
                return;
            }
        };
        
        contentTableView.frame = CGRectMake(0, loginBar.frame.origin.y + 30, self.contentTableView.frame.size.width, TPHeightFit(415) - 30);
        [self resetGetMoreFooter];
    } else {
        if (loginBar) {
            [loginBar removeFromSuperview];
            loginBar = nil;
            contentTableView.frame = CGRectMake(0, contentTableView.frame.origin.y - 30, self.contentTableView.frame.size.width, TPHeightFit(415));
            [self resetGetMoreFooter];
        }
    }
}


@end
