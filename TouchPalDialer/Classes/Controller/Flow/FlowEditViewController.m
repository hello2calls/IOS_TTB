//
//  FlowEditViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/22.
//
//

#import "FlowEditViewController.h"
#import "VoipScrollView.h"
#import "VoipTopSectionHeaderBar.h"
#import "WaveTopSectionView.h"
#import "TPDialerResourceManager.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "HighlightTip.h"
#import "UserStreamViewController.h"
#import "FlowExtractViewController.h"
#import "CommonWebView.h"
#import "CootekWebHandler.h"
#import "ScheduleInternetVisit.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "HandlerWebViewController.h"
#import "WithBottomLineView.h"
#import "TaeClient.h"
#import "Reachability.h"
#import "FlowInputNameView.h"
#import "DefaultUIAlertViewHandler.h"
#import "TouchPalVersionInfo.h"
#import "DialogUtil.h"
#import "FlowEditDialog.h"
#import "ShowAlertViewManager.h"
#import "MarketLoginController.h"

#define WIDTH_ADAPT TPScreenWidth()/375

@interface FlowEditViewController()<VoipTopSectionHeaderBarProtocol>{
    VoipScrollView *_frontView;
    
    VoipTopSectionHeaderBar *_headBar;
    UserSettingHighlightTip *tipForSuperDial_;
    
    UIButton *headerButton;
    
    WaveTopSectionView *topSectionView;
    UIButton *flowStreamButton;
    
    int _lastFlow;
}

@end

@implementation FlowEditViewController


- (void)viewWillAppear:(BOOL)animated {
    [self getFlowNumber];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self voipDefaultFunc];
    
    //    self.headerTitle = NSLocalizedString(@"免费电话", @"");
    //self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultBackground_color"];
    self.view.backgroundColor = [UIColor whiteColor];
    _headBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , 45+TPHeaderBarHeightDiff())];
    _headBar.delegate = self;
    _headBar.headerTitle.text = NSLocalizedString(@"personal_center_flow", "");
    _headBar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"];
    [self.view addSubview:_headBar];
    
    [_headBar setButtonText:@"a"];
    headerButton = _headBar.headerButton;
    
    tipForSuperDial_ = [[UserSettingHighlightTip alloc] initWithUserSetting:FLOW_STREAM_HEADER_BUTTON expectedValue:[NSNumber numberWithBool:YES]];
    UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"dialerView_newPoint@2x.png"];
    [tipForSuperDial_ attachToButton:headerButton atPosition:CGPointMake(headerButton.frame.size.width-icon.size.width-12,12) image:icon];
    
    //scrollview调整位置
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _frontView = [[VoipScrollView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    [self.view addSubview:_frontView];
    
    topSectionView = [[WaveTopSectionView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 296*WIDTH_ADAPT) andBgColor:[TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"] andIfWave:YES andUnitType:FLOW_UNIT];
    [topSectionView setTitle:@"剩余流量"];
    [topSectionView setMaxValue:100];
    [_frontView addSubview:topSectionView];
    [topSectionView startWave:[UserDefaultsManager intValueForKey:FLOW_BONUS defaultValue:0]];
    
    float globalY = 296*WIDTH_ADAPT - 1;
    
    UILabel *hint1View = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), (int)(WIDTH_ADAPT * FONT_SIZE_3_5 * 2))];
    hint1View.backgroundColor = [TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"];
    hint1View.textColor = [UIColor whiteColor];
    hint1View.textAlignment = NSTextAlignmentCenter;
    hint1View.font = [UIFont systemFontOfSize:WIDTH_ADAPT * FONT_SIZE_3_5];
    hint1View.text = @"流量需提取到手机上才能使用";
    [_frontView addSubview:hint1View];
    globalY += hint1View.frame.size.height - 1;
    
    UILabel *hint2View = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), WIDTH_ADAPT * FONT_SIZE_3_5)];
    hint2View.backgroundColor = [TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"];
    hint2View.textColor = [UIColor whiteColor];
    hint2View.textAlignment = NSTextAlignmentCenter;
    hint2View.font = [UIFont systemFontOfSize:WIDTH_ADAPT * FONT_SIZE_3_5];
    hint2View.text = @"流量提取前永久有效，提取后当月有效";
    [_frontView addSubview:hint2View];
    globalY += hint2View.frame.size.height;
    
    UIView *extraView = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), WIDTH_ADAPT * FONT_SIZE_3_5 * 2)];
    extraView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"];
    [_frontView addSubview:extraView];
    globalY += extraView.frame.size.height;
    
    WithBottomLineView *earnMoreView = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth() , VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_earn_more_flow", "") withDescription:NSLocalizedString(@"voip_earn_more_flow_hint", "") ifParticipate:NO];
    [_frontView addSubview:earnMoreView];
    globalY += earnMoreView.frame.size.height;
    
    UIButton *earnMoreButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, earnMoreView.frame.size.width, earnMoreView.frame.size.height)];
    earnMoreButton.backgroundColor = [UIColor clearColor];
    [earnMoreView addSubview:earnMoreButton];
    [earnMoreButton addTarget:self action:@selector(earnMoreFlow) forControlEvents:UIControlEventTouchUpInside];
    
    WithBottomLineView *flowStreamView = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth() , VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_flow_stream", "") withDescription:NSLocalizedString(@"voip_flow_stream_hint", "") ifParticipate:NO];
    [_frontView addSubview:flowStreamView];
    globalY += flowStreamView.frame.size.height;
    
    flowStreamButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, flowStreamView.frame.size.width, flowStreamView.frame.size.height)];
    flowStreamButton.enabled = NO;
    flowStreamButton.backgroundColor = [UIColor clearColor];
    [flowStreamView addSubview:flowStreamButton];
    [flowStreamButton addTarget:self action:@selector(getFlow) forControlEvents:UIControlEventTouchUpInside];

    WithBottomLineView *helpView = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth() , VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_flow_help", "") withDescription:NSLocalizedString(@"voip_flow_help_hint", "") ifParticipate:NO];
    [_frontView addSubview:helpView];
    globalY += helpView.frame.size.height;
    
    UIButton *helpButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, helpView.frame.size.width, helpView.frame.size.height)];
    helpButton.backgroundColor = [UIColor clearColor];
    [helpView addSubview:helpButton];
    [helpButton addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
    
    [_frontView setContentSize:CGSizeMake(TPScreenWidth() , globalY + 30)];
    
//    _con = [[HandlerWebViewController alloc]init];
//    _con.url_string = @"http://www.chubao.cn/s/flowwallet_debug/liuliang_inapp_ios/task.html";
//    _con.ifHideHeaderBar = YES;
//    _con.viewFrame = CGRectMake(0, topSectionView.frame.size.height, TPScreenWidth(), TPScreenHeight()-topSectionView.frame.size.height);
//    _con.view.frame = _con.viewFrame;
//    [_frontView addSubview:_con.view];
//    [self addChildViewController:_con];
    [self.view bringSubviewToFront:_headBar];
    [DialerUsageRecord recordpath:EV_FLOW_ENTER kvs:Pair(@"count", @(1)), nil];
    
    if (![UserDefaultsManager boolValueForKey:FLOW_HINT_SHOWN]) {
        [DialogUtil showDialogWithContentView:[[FlowEditDialog alloc]init] inRootView:self.view];
        [UserDefaultsManager setBoolValue:YES forKey:FLOW_HINT_SHOWN];
    }
}

- (void) earnMoreFlow {
    HandlerWebViewController* webVC = [[HandlerWebViewController alloc] init];
    webVC.url_string = [MarketLoginController getActivityCenterUrlString];
    webVC.header_title = NSLocalizedString(@"personal_center_setting_activity_center", @"");
    [self.navigationController pushViewController:webVC animated:YES];
    [DialerUsageRecord recordpath:EV_ACTIVITY_MARKET_FLOW_EDIT_ENTER kvs:Pair(@"count", @(1)), nil];
}

- (void)getFlow{
    HandlerWebViewController *con = [[HandlerWebViewController alloc]init];
    con.url_string = USE_DEBUG_SERVER ? TEST_FLOW_WALLET_URL : FLOW_WALLET_URL;
    con.header_title = @"免费流量提取";
    [con setHeaderBarBackgroundColor:[TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"]];
    [self.navigationController pushViewController:con animated:YES];
}

- (void) help {
    [DialogUtil showDialogWithContentView:[[FlowEditDialog alloc]init] inRootView:self.view];
}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)voipDefaultFunc{
    //[ScheduleInternetVisit getStreamHistory:NO onlyVoip:NO onlyFlow:YES];
    //[self getHistory];
}

- (void)refreshController{
    [self getFlowNumber];
}

- (void)headerButtonAction{
    //流量红包是1
    UserStreamViewController *controller = [[UserStreamViewController alloc]initWithBonusType:FLOW_HISTORY andHeaderTitle:NSLocalizedString(@"flow", "") bgColor:[TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)refreshHeaderButton{
    tipForSuperDial_ = [[UserSettingHighlightTip alloc] initWithUserSetting:FLOW_STREAM_HEADER_BUTTON expectedValue:[NSNumber numberWithBool:YES]];
    UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"dialerView_newPoint@2x.png"];
    [tipForSuperDial_ attachToButton:headerButton atPosition:CGPointMake(headerButton.frame.size.width-icon.size.width-12,12) image:icon];
}

- (void)getFlowNumber{
//    dispatch_async([SeattleFeatureExecutor getQueue], ^{
//        [SeattleFeatureExecutor getFlowAccount];
//        int currentFlow = [UserDefaultsManager intValueForKey:FLOW_BONUS defaultValue:0];
//        if (currentFlow == 0 || currentFlow != _lastFlow) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [topSectionView adjustWave:currentFlow];
//                flowStreamButton.enabled = YES;
//                _lastFlow = currentFlow;
//            });
//        }
//        
//    });
}

@end
