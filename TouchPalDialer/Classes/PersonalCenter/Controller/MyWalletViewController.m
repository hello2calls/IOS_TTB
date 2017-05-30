//
//  MyWalletViewController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/5.
//
//

#import "MyWalletViewController.h"
#import "VoipTopSectionHeaderBar.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "CenterOperateSectionAction.h"
#import "UsageConst.h"
#import "PersonInfoDescViewController.h"
#import "VoipInvitationCodeView.h"
#import "LoginController.h"
#import "MarketLoginController.h"
#import "SeattleFeatureExecutor.h"
#import "CootekNotifications.h"
#import "TPHeaderButton.h"
#import "YellowPageWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "HandlerWebViewController.h"
#import "FunctionUtility.h"

@interface MyWalletViewController () <VoipTopSectionHeaderBarProtocol,CenterOperateDelegate, UIScrollViewDelegate>

@end

@implementation MyWalletViewController {
    VoipTopSectionHeaderBar *_headBar;
    NSMutableArray *_sectionArray;
    NSDictionary *_infos;
    UIScrollView *_settingsBg;
    UIColor *_themeColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _infos = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO];
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];

    CGFloat topHeight = TPHeaderBarHeight();
   
    UIView *topBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), topHeight)];
    _themeColor = [TPDialerResourceManager getColorForStyle:@"personal_center_wallet_icon_color"];
    topBackgroundView.backgroundColor = _themeColor;
    [self.view addSubview:topBackgroundView];

    _headBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , TPHeaderBarHeight())];
    _headBar.delegate = self;
    _headBar.headerTitle.text = @"我的钱包";
    _headBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_headBar];

    // top-right button
    TPHeaderButton *rightButton = [[TPHeaderButton alloc]
                                   initWithFrame:CGRectMake(TPScreenWidth() - 50, 0, 50, 45)];
    NSString *buttonString = @"a";
    rightButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    [rightButton setTitle:buttonString forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
    [_headBar addSubview:rightButton];

    UIScrollView *settingsBg = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topBackgroundView.frame.size.height, TPScreenWidth(), TPScreenHeight() - topBackgroundView.frame.size.height)];
    settingsBg.delegate = self;
    settingsBg.showsVerticalScrollIndicator = NO;
    [self.view addSubview:settingsBg];
    _settingsBg = settingsBg;

    [self addSettingSection];
    [self adjustHeight];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWalletController) name:N_REFRESH_PERSONAL_INFO object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FunctionUtility setStatusBarStyleToDefault:NO]; // set to light content
}

- (void) rightButtonAction {
    HandlerWebViewController *webController = [[HandlerWebViewController alloc] init];
    webController.url_string = @"http://dialer-voip.cootekservice.com/voip/user_account_details_view";
    [webController setRefreshButton:NO];
    webController.header_title = @"";
    [[TouchPalDialerAppDelegate naviController] pushViewController:webController animated:YES];
}

- (void) gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addSettingSection{
    _sectionArray = [[NSMutableArray alloc] initWithCapacity:1];
    CenterOperateSectionAction *section = [[CenterOperateSectionAction alloc]initWithHostView:_settingsBg];
    [_sectionArray addObject:section];

    CenterOperateInfo *info = [[CenterOperateInfo alloc]init];
    info.type = VIP_INFO;
    info.iconText = @"S";
    info.labelText =  @"VIP";
    info.iconTypeName = @"iPhoneIcon2";
    info.dotType = PTHide;
    info.subtitleHidden = YES;
    info.iconColor = @"tp_color_yellow_500";
    info.delegate = self;
    NSString *text = [NSString stringWithFormat:@"%d天", [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY]];
    info.rightAttrText = [[NSAttributedString alloc] initWithString:text];
    [section addOperateInfo:info];
    
    info = [[CenterOperateInfo alloc]init];
    info.type = WALLET_INFO;
    info.iconText = @"j";
    info.labelText =  @"零钱";
    info.iconTypeName = @"iPhoneIcon1";
    info.dotType = PTHide;
    info.subtitleHidden = YES;
    info.iconColor = @"tp_color_orange_800";
    info.delegate = self;
    text = [NSString stringWithFormat:@"%@元", _infos[@"coins"]];
    info.rightAttrText = [[NSAttributedString alloc] initWithString:text];
    [section addOperateInfo:info];

    info = [[CenterOperateInfo alloc]init];
    info.type = CARD_INFO;
    info.iconText = @"o";
    info.labelText =  @"我的卡券";
    info.iconTypeName = @"iPhoneIcon1";
    info.dotType = PTHide;
    info.subtitleHidden = YES;
    info.iconColor = @"tp_color_light_blue_500";
    info.delegate = self;
    text = [NSString stringWithFormat:@"%@张", _infos[@"cards"]];
    info.rightAttrText = [[NSAttributedString alloc] initWithString:text];
    [section addOperateInfo:info];

    info = [[CenterOperateInfo alloc]init];
    info.type = FREE_MINUTE_INFO;
    info.iconText = @"D";
    info.labelText =  @"免费时长";
    info.iconTypeName = @"iPhoneIcon3";
    info.dotType = PTHide;
    info.subtitleHidden = YES;
    info.iconColor = @"tp_color_green_500";
    info.delegate = self;
    text = [NSString stringWithFormat:@"%@分钟", _infos[@"minutes"]];
    info.rightAttrText = [[NSAttributedString alloc] initWithString:text];
    [section addOperateInfo:info];

    info = [[CenterOperateInfo alloc]init];
    info.type = TRAFFIC_INFO;
    info.iconText = @"m";
    info.labelText =  @"免费流量";
    info.iconTypeName = @"iPhoneIcon1";
    info.dotType = PTHide;
    info.subtitleHidden = YES;
    info.iconColor = @"tp_color_orange_500";
    info.delegate = self;
    text = [NSString stringWithFormat:@"%@MB", _infos[@"bytes_f"]];
    info.rightAttrText = [[NSAttributedString alloc] initWithString:text];
    [section addOperateInfo:info];

    info = [[CenterOperateInfo alloc]init];
    info.type = EXCHANGE_INFO;
    info.iconText = @"f";
    info.labelText =  NSLocalizedString(@"16_card_exchange_main_title", @"输入免费兑换码，领取奖励");
    info.iconTypeName = @"iPhoneIcon1";
    info.dotType = PTHide;
    info.subtitleHidden = YES;
    info.iconColor = @"tp_color_pink_300";
    info.delegate = self;
    info.lastItem = YES;
    [section addOperateInfo:info];
}

- (void)onOperatePress:(OperationCellType)type {
    switch (type) {
        case WALLET_INFO:
        {
            PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel backFeeModel]];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case FREE_MINUTE_INFO:
        {
            PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel freeFeeModel]];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case TRAFFIC_INFO:
        {
            PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel trafficModel]];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case EXCHANGE_INFO:
        {
            [self showInvitationCodeView];
            break;
        }
        case CARD_INFO:
        {
            [self jumpToCard];
            break;
        }
        case VIP_INFO:
        {
            UIViewController *controller = [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel PrivilegaModel]];
            [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
            dispatch_async([SeattleFeatureExecutor getQueue], ^{
                [SeattleFeatureExecutor getAccountNumbersInfo];
            });
            break;
        }
        default:
            break;
    }
}

- (void)jumpToCard {
    NSString *url = [NSString stringWithFormat:@"http://search.cootekservice.com/page_v3/activity_recharge_price.html?_token=%@", [SeattleFeatureExecutor getToken]];
    MarketLoginController *market = [MarketLoginController withOrigin:@"personal_center_wallet_card"];
    market.url = url;
    market.title = @"我的卡券";
    [LoginController checkLoginWithDelegate:market];
}


- (void)showInvitationCodeView{
    VoipInvitationCodeView *invitationCodeView = [[VoipInvitationCodeView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    [self.view addSubview:invitationCodeView];
}

- (void)adjustHeight{
    float originY = 0;
    //float height = 0;
    for ( CenterOperateSectionAction *action in _sectionArray ){
        [action setOriginY:originY];
        CGFloat height = [action getSectionHeight];
        originY += height;
    }
    if (originY >= _settingsBg.frame.size.height) {
        _settingsBg.contentSize = CGSizeMake(_settingsBg.frame.size.width, originY + 20 - TPHeaderBarHeightDiff());
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (CenterOperateSectionAction *section in _sectionArray) {
        [section clearHighlightState];
    }
}

- (void)refreshWalletController{
    _infos = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO];
    [self refreshWalletView];
}

- (void)refreshWalletView{
    for (UIView *view in [_settingsBg subviews]) {
        [view removeFromSuperview];
    }
    [_sectionArray removeAllObjects];
    [self addSettingSection];
    [self adjustHeight];
}

@end
