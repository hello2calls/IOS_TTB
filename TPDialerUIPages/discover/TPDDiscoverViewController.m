
//  TPDDiscoverViewController.m
//  TouchPalDialer
//
//  Created by weyl on 16/10/10.
//
//

#import "TPDDiscoverViewController.h"
#import "TPDLib.h"
#import "FindNewsListViewController.h"
#import "YellowPageWebViewController.h"
#import <Masonry.h>
#import "SeattleFeatureExecutor.h"
#import "LocalStorage.h"
#import "HandlerWebViewControllerForV6.h"
#import "PersonInfoDescViewController.h"
#import "AllServiceViewController.h"
#import <TPDTabBarItem.h>

#import "IndexConstant.h"
#import "IndexJsonUtils.h"
#import "UIDataManager.h"
#import "IndexData.h"
#import "UpdateService.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
#import "SignBtnManager.h"
#import "FeedsSigninManager.h"
#import "FeedsBtnRefreshManager.h"
#import "CootekNotifications.h"
#import "UIViewController+TPDExtension.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

#define kRefreshTableViewDoneNotification @"kRefreshTableViewDoneNotification"
#define kChangeTabBarStatus               @"kChangeTabBarStatus"

@interface TPDDiscoverViewController ()
@property (nonatomic,strong) UIImageView* topBar;
@property (nonatomic,strong) NSArray* vcArr;
@property (nonatomic,strong) NSMutableArray* vcViewHolderArr;
@property (nonatomic,strong) NSArray* headerViewArr;
@property (nonatomic,strong) NSArray* pageContainerViewArr;
@property (nonatomic,strong) UIView* tmpHolder;
@property (nonatomic, strong) UIScrollView* selectionTab;
@property (nonatomic, strong) UIView* tabPageSuite;

@property (nonatomic, strong) NSMutableArray* titleArr;
@end

@implementation TPDDiscoverViewController
-(void)loadAllServiceData{
        BOOL indexRequestSuccess = NO;
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
            
            [[UIDataManager instance] updateWithLocalData:data];
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
        [[UIDataManager instance] updateToUIData];
}

-(void)setupTitle{
    UILabel* l1 = [[UILabel tpd_commonLabel] tpd_withText:@"推荐" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l1.alpha = 0.8f;
    
    UILabel* l2 = [[UILabel tpd_commonLabel] tpd_withText:@"赚钱" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l2.alpha = 0.8f;
    
    UILabel* l3 = [[UILabel tpd_commonLabel] tpd_withText:@"招聘" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l3.alpha = 0.8f;
    
    UILabel* l4 = [[UILabel tpd_commonLabel] tpd_withText:@"游戏" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l4.alpha = 0.8f;
    
    UILabel* l5 = [[UILabel tpd_commonLabel] tpd_withText:@"生活" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l5.alpha = 0.8f;
    
    UILabel* l6 = [[UILabel tpd_commonLabel] tpd_withText:@"房产" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l6.alpha = 0.8f;
    
    UILabel* l7 = [[UILabel tpd_commonLabel] tpd_withText:@"买车" color:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] font:16];
    l7.alpha = 0.8f;
    
    self.titleArr = [@[l1,l2,l3,l4,l5,l6,l7] mutableCopy];
}

-(void)setupVC{
    FindNewsListViewController* vc1 = [[FindNewsListViewController alloc] init];
    vc1.tu = @"116";
    vc1.contentView = [[UIView alloc] init];
    vc1.tu = @"116";
    [vc1.contentView setFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(415) - self.rdv_tabBarController.tabBar.frame.size.height)];
    
    NSString *string = [@"http://search.cootekservice.com/page_v3/profit_center.html?_city=全国&_token=auth_token" stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
    if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
        string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
    }
    HandlerWebViewControllerForV6  *vc2 = [[HandlerWebViewControllerForV6 alloc]init];
    vc2.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    vc2.header_title = @"赚钱中心";
    
    HandlerWebViewControllerForV6  *vc3 = [[HandlerWebViewControllerForV6 alloc]init];
    string = @"http://jump.luna.58.com/i/28yB";
    vc3.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    vc3.header_title = @"招聘";
    
    
    string = [@"http://touchlife.cootekservice.com/page_v3/game_center.html?_city=全国&_token=auth_token" stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
    if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
        string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
    }
    HandlerWebViewControllerForV6  *vc4 = [[HandlerWebViewControllerForV6 alloc] init];
    vc4.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    vc4.header_title = @"游戏中心";
    
    AllServiceViewController *vc5 = [[AllServiceViewController alloc] init];
    //    vc5.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT + TPHeaderBarHeightDiff());
    
    HandlerWebViewControllerForV6  *vc6 = [[HandlerWebViewControllerForV6 alloc]init];
    string = [@"http://touchlife.cootekservice.com/native_index/redirect?_city=全国&type=ganjizf&_token=auth_token" stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
    if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
        string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
    }
    vc6.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    vc6.header_title = @"房产";
    
    HandlerWebViewControllerForV6  *vc7 = [[HandlerWebViewControllerForV6 alloc]init];
    string = [@"http://touchlife.cootekservice.com/native_index/redirect?_city=全国&type=ganji2sc&_token=auth_token" stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
    if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
        string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
    }
    vc7.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    vc7.header_title = @"买车";
    
    
    
    self.vcArr = @[vc1,vc2,vc3,vc4,vc5,vc6,vc7];
    
    
    self.tmpHolder = vc1.view;
    self.tmpHolder = vc5.view;
    self.vcViewHolderArr = [@[vc1.view,@"",@"",vc4.view,vc5.contentView,@"",@""] mutableCopy];
    self.pageContainerViewArr = @[vc1.contentView,[[UIView alloc] init],[[UIView alloc] init],vc4.containerView,vc5.contentView,[[UIView alloc] init],[[UIView alloc] init]];

    for (UIViewController* vc in self.vcArr) {
        [self addChildViewController:vc];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    WEAK(self)
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;

//    [self loadAllServiceData];
    
    self.topBar = [[UIImageView alloc] initWithImage:[TPDialerResourceManager getImage:@"common_header_bg@2x.png"]];

    [self setupTitle];
    [[NSNotificationCenter defaultCenter] addObserverForName:N_SKIN_DID_CHANGE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakself.topBar setImage:[TPDialerResourceManager getImage:@"common_header_bg@2x.png"]];
        for (UILabel* label in weakself.titleArr) {
            label.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        }
    }];
    [self setupVC];

    
    
    
    
    
    self.tabPageSuite = [UIView tpd_horizontalTabsPagesSuite2:self.titleArr pages:self.pageContainerViewArr tabSelectBlock:^(UIButton *btn) {
        if (btn.selected) {
            [DialerUsageRecord recordpath:PATH_DISCOVER_SUB_PAGE
                                      kvs:Pair(@"page_index", @(btn.tag)), nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_TOP_TAB_CHANGE_NOTI object:nil userInfo:[NSDictionary  dictionaryWithObject:[NSString  stringWithFormat:@"%d", btn.tag] forKey:@"tabChange"]];
            if ([weakself.vcViewHolderArr[btn.tag] isKindOfClass:[NSString class]]) {
                // 对应的vc的viewdidload尚未执行过
                weakself.tmpHolder = ((UIViewController*)weakself.vcArr[btn.tag]).view;
                
                // 取出yellowpagewebVC的webview
                weakself.vcViewHolderArr[btn.tag]= [self.vcArr[btn.tag] containerView];
                UIView* child = weakself.vcViewHolderArr[btn.tag];
                UIView* parent = self.pageContainerViewArr[btn.tag];
                [parent addSubview:child];
                
                [child makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(parent);
                }];
            }
            
            UILabel* label = weakself.titleArr[btn.tag];
//            label.font = [UIFont systemFontOfSize:20];
            label.alpha = 1.f;
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                label.layer.transform = CATransform3DMakeScale(1.25,1.25,1.0);

            } completion:^(BOOL finished){
                CGPoint p = [btn convertPoint:CGPointMake(0, 0) toView:btn.superview];
                NSLog(@"%lf",p.x);
                UIScrollView* scroll = weakself.selectionTab;
                double width  = [UIScreen mainScreen].bounds.size.width / 2;
                if (p.x < width) {
                    [scroll setContentOffset:CGPointMake(0, 0) animated:YES];
                }else if(p.x > scroll.contentSize.width - width){
                    [scroll setContentOffset:CGPointMake(scroll.contentSize.width - width*2, 0) animated:YES];
                }else{
                    [scroll setContentOffset:CGPointMake(p.x-width, 0) animated:YES];
                }
                
            }];
        }else{
            UILabel* label = weakself.titleArr[btn.tag];
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                label.layer.transform = CATransform3DMakeScale(1,1,1.0);
                
            } completion:^(BOOL finished){
                
            }];
            label.alpha = .8f;
        }
        
        

    }];

    NSArray* widthArr = @[@60,@60,@60,@60,@60,@60,@60];
    for (int i=0; i<weakself.titleArr.count; i++) {
        UIButton* b = self.tabPageSuite.tpd_horizontalTab.tpd_btnArrInGroup[i];
        UILabel* l = weakself.titleArr[i];
        [b updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(l);
            make.width.equalTo(widthArr[i]);
            
        }];
    }
    self.selectionTab = (UIScrollView*)self.tabPageSuite.tpd_horizontalTab;
//    self.selectionTab.backgroundColor = RGB2UIColor2(3, 169, 244);
    self.selectionTab.bounces = NO;
    

    
    
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.tabPageSuite.tpd_horizontalTab];
    [self.view addSubview:self.tabPageSuite.tpd_horizontalPages];
    
    

    
    [self.topBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(64.f);
    }];
    [self.tabPageSuite.tpd_horizontalTab makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.topBar.bottom);
        make.height.equalTo(44);
    }];
    
    [self.tabPageSuite.tpd_horizontalPages makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tabPageSuite.tpd_horizontalTab.bottom);
    }];
    
    UIButton *b = self.tabPageSuite.tpd_horizontalTab.tpd_btnArrInGroup[0]  ;
    EXEC_BLOCK(b.tpd_whenClicked,b);
    
    
    UIButton *button = [UIButton tpd_buttonStyleCommon];
    button.backgroundColor = [UIColor clearColor];
    RDVTabBarItem *item = [self rdv_tabBarController].tabBar.items[2];
    button.frame = item.frame;
    [item.superview addSubview:button];
    [button addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:[NSString stringWithFormat:@"%@_%d", FEEDS_ICON_CLICKED, [FeedsBtnRefreshManager instance].status]];
        if (self.rdv_tabBarController.selectedIndex == 2) {
            [[NSNotificationCenter defaultCenter]postNotificationName:N_FEEDS_REFRESH object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:weakself.tabPageSuite.currentPage == 0] forKey:@"feeds_icon_click"]];
            [self isChangeTabBarImage:NO];
        }else {
            [self.rdv_tabBarController setSelectedIndex:2];
             [[NSNotificationCenter defaultCenter]postNotificationName:N_FEEDS_REFRESH_FROMOTHER object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:weakself.tabPageSuite.currentPage == 0] forKey:@"feeds_icon_click"]];
        }
    }];
    
       [[FeedsBtnRefreshManager instance] createRefreshBtn: button];


    
    [[NSNotificationCenter defaultCenter]addObserverForName:kFeedsTabSelectedToRefresh object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self changeToTabFeeds];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnterBackground) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive) name:N_APP_ACTIVE_SHWO_PASTEBOARD object:nil];
}

- (void)changeToTabFeeds{
    self.tabPageSuite.tpd_horizontalPages.contentOffset = CGPointZero;
    [self.tabPageSuite tpd_horizontalTabsPagesJumpToPage:0];
//    UIButton *b = self.tabPageSuite.tpd_horizontalTab.tpd_btnArrInGroup[0]  ;
//    EXEC_BLOCK(b.tpd_whenClicked,b);
}

- (void) onAppDidBecomeActive
{
    if (self.rdv_tabBarController.selectedIndex == 2 && [[UIViewController tpd_topViewController] isKindOfClass:[TPDDiscoverViewController class]]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:N_FEEDS_REFRESH_FROMOTHER object:nil];
         [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:[NSString stringWithFormat:@"%@_%d", FEEDS_ICON_CLICKED, [FeedsBtnRefreshManager instance].status]];
    }
}

- (void) onAppEnterBackground
{
    if (self.rdv_tabBarController.selectedIndex == 2 && [[UIViewController tpd_topViewController] isKindOfClass:[TPDDiscoverViewController class]]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kDiscoverTabSelectedToBackground object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    for (int i=0; i<self.vcArr.count; i++) {
        UIViewController* vc = [self.vcArr objectAtIndex:i];
        if (![self.vcViewHolderArr[i] isKindOfClass:[NSString class]]){
            [vc viewWillAppear:animated];
        }
    }
    [self rdv_tabBarController].tabBarHidden = NO;
    [FunctionUtility updateStatusBarStyle];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [GlobalVariables getInstance].lastExitTimeFromDiscoverTab = [NSDate date];
    [self rdv_tabBarController].tabBarHidden = YES;
    
    [[FeedsBtnRefreshManager instance] saveRefresStatus:self];
    for (int i=0; i<self.vcArr.count; i++) {
        UIViewController* vc = [self.vcArr objectAtIndex:i];
        if (![self.vcViewHolderArr[i] isKindOfClass:[NSString class]]){
            [vc viewWillDisappear:animated];
        }
    }
    
    

}

- (void)isChangeTabBarImage:(BOOL)isChange{
 
    TPDTabBarItem *item = [self rdv_tabBarController].tabBar.items[2];
    [item reconfig];
    [self.rdv_tabBarController.tabBar layoutSubviews];

}


@end
