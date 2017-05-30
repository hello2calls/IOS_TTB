//
//  centerOperateModel.m
//  TouchPalDialer
//
//  Created by game3108 on 15/5/12.
//
//

#import "CenterOperateManager.h"
#import "CenterOperateSectionAction.h"
#import "CenterOperateCellAction.h"
#import "CenterOperateInfo.h"
#import "TPDialerResourceManager.h"
#import "LoginController.h"
#import "FreeCallLoginController.h"
#import "CallFlowPacketLoginController.h"
#import "UserDefaultsManager.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "GestureSettingsViewController.h"
#import "SmartDailViewController.h"
#import "SkinSettingViewController.h"
#import "DefaultSettingViewController.h"
#import "SettingsModelCreator.h"
#import "MarketLoginController.h"
#import "UMFeedbackFAQController.h"
#import "UsageConst.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"
#import "TouchPalVersionInfo.h"
#import "CouponLoginController.h"
#import "AntiharassmentViewController.h"
#import "CenterOperateRectSectionAction.h"
#import "SeattleFeatureExecutor.h"
#import "EditVoipViewController.h"
#import "MyWalletViewController.h"
#import "PersonInfoDescViewController.h"
#import "DefaultJumpLoginController.h"
#import "TodayWidgetAnimationViewController.h"
#import "CootekNotifications.h"
#import "InviteLoginController.h"
#import "CenterOperationRectCellAction.h"
#import "UIView+Toast.h"
#import "FunctionUtility.h"
#import "Person.h"
#import "PersonDBA.h"
#import "ContactCacheDataModel.h"

@interface CenterOperateManager()<CenterOperateDelegate>{
    NSMutableArray *sectionArray;
    float contentHeight;
    __weak UIView *_hostView;
    NSDictionary *_savedAccountInfo;
    CGRect _area;
    CGFloat _contentY;
}

@end


@implementation CenterOperateManager

- (id)initWithHostView:(UIView *)view displayArea:(CGRect)frame{
    self = [super init];

    if ( self ){
        _area = frame;
        sectionArray = [NSMutableArray array];
        _hostView = view;
        [self generateSection];
        [self askNumbers];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCenterOperate) name:N_REFRESH_PERSONAL_INFO object:nil];
    }
    return self;
}

- (void)generateSection{
    [self addFirstSection];
    [self addSecondSection];
    [self addThirdSection];
    [self addFourthSection];
    [self adjustHeight];
    [self refreshNoahPush];
}

- (void) addFirstSection{
    CenterOperateSectionAction *section = [[CenterOperateSectionAction alloc]initWithHostView:_hostView];
    CenterOperateInfo *info = [[CenterOperateInfo alloc]init];
    info.type = WALLET_INFO;
    info.iconText = @"A";
    info.labelText =  @"我的钱包";
    info.iconTypeName = @"iPhoneIcon3";
    info.guidePointId = GUIDEPOINT_WALLET;
    info.subtitleHidden = YES;
    info.iconColor = @"personal_center_wallet_icon_color";
    info.delegate = self;
    info.lastItem = YES;
    info.dotType = PTHide;
    NSString *descText = @"卡券，兑换奖励";
//    NSRange range = [descText rangeOfString:@"卡券"];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:descText];
//    UIColor *color = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
//    [attrText addAttributes:@{NSForegroundColorAttributeName : color} range:range];
    info.rightAttrText = attrText;
    [section addOperateInfo:info];
    [sectionArray addObject:section];
}

- (void)addSecondSection {
    BOOL showNumber = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil;
    if (showNumber) {
        _savedAccountInfo = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO];
    } else {
        _savedAccountInfo = nil;
    }
    CenterOperateRectSectionAction *section = [[CenterOperateRectSectionAction alloc]initWithHostView:_hostView];
    [section addTopLine];
    [sectionArray addObject:section];
    CenterOperateInfo *info = [[CenterOperateInfo alloc]init];
    info.type = BACK_FEE_INFO;
    NSString *coins = _savedAccountInfo[@"coins"];
    info.iconText = showNumber ?  coins : @"j";
    info.labelText =  @"零钱";
    info.iconTypeName = showNumber ? nil : @"iPhoneIcon1";
    info.guidePointId = GUIDEPOINT_BACKFEE;
    info.iconColor = @"tp_color_orange_800";
    info.delegate = self;
    info.dotType = PTHide;
    [section addOperateInfo:info];



    info = [[CenterOperateInfo alloc]init];
    info.type = FREE_MINUTE_INFO;
    info.iconText = showNumber ? _savedAccountInfo[@"minutes"] : @"W";
    info.labelText =  @"免费时长";
    info.iconTypeName = showNumber ? nil : @"iPhoneIcon2";
    info.guidePointId = GUIDEPOINT_FREE_MINUTE;
    info.iconColor = @"tp_color_green_500";
    info.delegate = self;
    [section addOperateInfo:info];

    info = [[CenterOperateInfo alloc]init];
    info.type = TRAFFIC_INFO;
    info.iconText = showNumber ? _savedAccountInfo[@"bytes_f"] : @"m";
    info.labelText =  @"免费流量";
    info.guidePointId = GUIDEPOINT_TRAFFIC;
    info.iconTypeName = showNumber ? nil : @"iPhoneIcon1";
    info.iconColor = @"tp_color_orange_500";
    info.delegate = self;
    info.dotType = PTHide;
    [section addOperateInfo:info];



    section = [[CenterOperateRectSectionAction alloc]initWithHostView:_hostView];
    [sectionArray addObject:section];

    info = [[CenterOperateInfo alloc]init];
    info.type = RED_BAG_INFO;
    info.iconText = @"a";
    info.labelText =  @"邀请好友";
    info.iconTypeName = @"iPhoneIcon1";
    info.guidePointId = GUIDEPOINT_REDBAG;
    info.iconColor = @"tp_color_red_500";
    info.delegate = self;
    [section addOperateInfo:info];


    info = [[CenterOperateInfo alloc]init];
    info.type = SKIN_INFO;
    info.iconText = @"c";
    info.labelText =  @"个性换肤";
    info.iconTypeName = @"iPhoneIcon1";
    info.guidePointId = GUIDEPOINT_SKIN;
    info.iconColor = @"tp_color_pink_500";
    info.delegate = self;
    [section addOperateInfo:info];
    if ( [UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] ){
        info = [[CenterOperateInfo alloc]init];
        info.type = ANTIHARASS_INFO;
        info.iconText = @"H";
        info.labelText = @"骚扰识别";
        info.iconTypeName = @"iPhoneIcon2";
        info.guidePointId = GUIDEPOINT_ANTIHARASS;
        info.delegate = self;
        info.iconColor = @"tp_color_light_blue_500";
        info.dotType = PTHide;
        [section addOperateInfo:info];
    }

    if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil) {
        info = [[CenterOperateInfo alloc]init];
        info.type = VOIP_INFO;
        info.iconText = @"U";
        info.labelText =  @"通话设置";
        info.iconTypeName = @"iPhoneIcon2";
        info.guidePointId = GUIDEPOINT_VOIP;
        info.iconColor = @"tp_color_green_500";
        info.delegate = self;
        [section addOperateInfo:info];
    }

    info = [[CenterOperateInfo alloc]init];
    info.type = DIALER_SETTING;
    info.iconText = @"V";
    info.labelText = @"拨号设置";
    info.iconTypeName = @"iPhoneIcon2";
    info.guidePointId = GUIDEPOINT_DIALER_SETTING;
    info.iconColor = @"tp_color_light_blue_500";
    info.delegate = self;
    [section addOperateInfo:info];
}

- (void)addThirdSection{
    NSString *registerNumber =[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    CenterOperateSectionAction *section = [[CenterOperateSectionAction alloc]initWithHostView:_hostView];
    [sectionArray addObject:section];
    CenterOperateInfo *info;
    if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]) {
        info = [[CenterOperateInfo alloc]init];
        info.type = LOG_OUT_INFO;
        info.iconText = @"C";
        info.labelText = @"解除绑定";
        info.labelSubText =  [registerNumber substringFromIndex:(registerNumber.length - 11)];
        info.iconTypeName = @"iPhoneIcon2";
        info.dotType = PTHide;
        info.guidePointId = @"";
        info.delegate = self;
        info.iconColor = @"tp_color_grey_600";
        [section addOperateInfo:info];
    }

    info = [[CenterOperateInfo alloc]init];
    info.type = HELP_INFO;
    info.iconText = @"k";
    info.labelText = @"帮助与反馈";
    info.iconTypeName = @"iPhoneIcon1";
    info.dotType = PTHide;
    info.guidePointId = GUIDEPOINT_HELP;
    info.delegate = self;
    info.iconColor = @"tp_color_grey_600";
    info.lastItem = YES;
    [section addOperateInfo:info];

}

- (void) addFourthSection {
    CenterOperateSectionAction *section = [[CenterOperateSectionAction alloc]initWithHostView:_hostView];
    [sectionArray addObject:section];

    CenterOperateInfo *info = [[CenterOperateInfo alloc]init];
    info.type = TOUCHPAL_FAN_INFO;
    info.iconText = @"r";
    info.labelText = NSLocalizedString(@"subscribe_touchpal_in_wexin", @"关注微信");
    info.labelSubText = @"touchpal-fan";
    info.iconTypeName = @"iPhoneIcon3";
    info.dotType = PTHide;
    info.guidePointId = GUIDEPOINT_TOUCHPAL_FAN;
    info.delegate = self;
    info.iconColor = @"tp_color_green_500";
    info.lastItem = YES;
    [section addOperateInfo:info];
}

- (CenterOperateCellAction *)getCellWithType:(OperationCellType)type {
    for (CenterOperateSectionAction *section in sectionArray) {
        for (CenterOperateCellAction *cell in section.operateArray) {
            if (cell.type == type) {
                return cell;
            }
        }
    }
    return nil;
}

- (void)adjustHeight{
    float originY = _area.origin.y;
    for ( CenterOperateSectionAction *action in sectionArray ){
        // adjust the margin of views
        CenterOperateInfo *info = [action getInfo];
        if (info) {
            switch (info.type) {
                case TOUCHPAL_FAN_INFO: {
                    originY += GUTTER_LENGTH;
                    break;
                }
                default:
                    break;
            }
        }
        [action setOriginY:originY];
        CGFloat height = [action getSectionHeight];
        originY += height;
    }
    originY += GUTTER_LENGTH; // always add a gutter at the bottom, required by UI
    _contentY = originY;
}

- (CGFloat)contentHeight  {
    return _contentY;
}

- (void)setDotType:(PointType)dotType withNum:(NSInteger)num operateType:(OperationCellType)type{
    [[self getCellWithType:type] setDotType:dotType withNum:num];
}

#pragma mark CenterOperateDelegate
- (void) onOperatePress:(OperationCellType)type{
    switch (type) {
        case VOIP_INFO:
            [self jumpToVOIP];
            break;
        case ACTIVITY_INFO:
            [self jumpToMarket];
            break;
        case SKIN_INFO:
            [self skin];
            break;
        case LOG_OUT_INFO:
            [self logout];
            break;
        case HELP_INFO:
            [self help];
            break;
        case ANTIHARASS_INFO:
            [self antiharass];
            break;
        case WALLET_INFO:
            [self jumpToWallet];
            break;
        case BACK_FEE_INFO:
            [self jumpToBackFee];
            break;
        case FREE_MINUTE_INFO:
            [self jumpToFreeMinute];
            break;
        case RED_BAG_INFO:
            [self jumpToRedbag];
            break;
        case CARD_INFO:
            [self jumpToCard];
            break;
        case TRAFFIC_INFO:
            [self jumpToByte];
            break;
        case TOUCHPAL_FAN_INFO: {
            [self openWX];
            break;
        }
        case DIALER_SETTING:
            [self jumpToDialerSetting];
            break;
        default:
            cootek_log(@"default");
            break;
    }
    CenterOperateCellAction *cell = [self getCellWithType:type];
    if (cell.guidePointId) {
        [[NoahManager sharedPSInstance]getGuidePointClicked:cell.guidePointId];
        [cell setDotType:PTHide withNum:0];
    }
}

- (void) openWX {
    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"已为您复制公众号，搜索时可直接粘贴。是否立即前往微信？" message:nil okButtonActionBlock:^(){
        BOOL canOpenWX = [[TouchPalApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
        if (canOpenWX) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = @"touchpal-fan";
            [[TouchPalApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
        }
        else {
            [[[UIApplication sharedApplication].delegate window]
            makeToast:NSLocalizedString(@"wexin_not_found", @"未检测到安装微信，若已安装，建议手动打开") duration:3.0 position:nil];
                    }
    }cancelActionBlock:^{

    }];
}

- (void)jumpToCard {
    NSString *url = [NSString stringWithFormat:@"http://search.cootekservice.com/page_v3/activity_recharge_price.html?_token=%@", [SeattleFeatureExecutor getToken]];
    MarketLoginController *market = [MarketLoginController withOrigin:@"personal_center_card"];
    market.url = url;
    market.title = @"我的卡券";
    [LoginController checkLoginWithDelegate:market];
//    DefaultJumpLoginController *loginController = [DefaultJumpLoginController withOrigin:@"personal_center_wallet"];
//    loginController.destination = NSStringFromClass([MyWalletViewController class]);
//    [LoginController checkLoginWithDelegate:loginController];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_CARD];
}

- (void)jumpToByte{
    PersonInfoDescViewController *controller = [[PersonInfoDescViewController alloc] init];
    [LoginController checkLoginWithDelegate:controller];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_TRAFFIC];

}

- (void)jumpToRedbag {
    InviteLoginController *loginController = [InviteLoginController withOrigin:@"personal_center_redbag"];
    loginController.shareFrom = @"PersonalCenter";
    [LoginController checkLoginWithDelegate:loginController];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_REDBAG];
    
    [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(1)), nil];
}

- (void)jumpToWallet {
    DefaultJumpLoginController *loginController = [DefaultJumpLoginController withOrigin:@"personal_center_wallet"];
    loginController.destination = NSStringFromClass([MyWalletViewController class]);
    [LoginController checkLoginWithDelegate:loginController];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_WALLET];
}

- (void) jumpToVOIP {
    [UserDefaultsManager setBoolValue:YES forKey:have_show_voip_oversea_point ];
    EditVoipViewController *controller = [[EditVoipViewController alloc] init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_VOIP];
}

- (void) jumpToMarket {
    [LoginController checkLoginWithDelegate:[MarketLoginController withOrigin:@"personal_center_market"]];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_MARKET];
}

- (void) gestureDial {
    GestureSettingsViewController *gesController = [[GestureSettingsViewController alloc] init];
    if (gesController == nil) {
        return;
    }
    [[TouchPalDialerAppDelegate naviController] pushViewController:gesController animated:YES];
}

- (void)dialAssistant {
    SmartDailViewController *sdController = [[SmartDailViewController alloc] init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:sdController animated:YES];
}

- (void)grace {
    [LoginController checkLoginWithDelegate:[CouponLoginController withOrigin:@"personal_center_coupon"]];
}

- (void)help
{
    UMFeedbackFAQController *feedback = [[UMFeedbackFAQController alloc]init];
    feedback.url_string = FAQ_URL;
    feedback.header_title = NSLocalizedString(@"umeng_feedback_title", @"");
    [[TouchPalDialerAppDelegate naviController] pushViewController:feedback animated:YES];
    [UserDefaultsManager setBoolValue:NO forKey:UMFEEDBACK_NEW_HINT];
}

- (void)antiharass{
    AntiharassmentViewController *con = [[AntiharassmentViewController alloc]init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:con animated:YES];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_ANTIHARASS];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_OPENED_FROM, @"center_cell"), nil];
    CenterOperateCellAction *cell = [self getCellWithType:(OperationCellType)ANTIHARASS_INFO];
    switch ([cell getInfo].dotType) {
        case PTNew:
            [DialerUsageRecord recordpath:PATH_ANTIHARASS
                kvs:Pair(ANTIHARASS_CLICK_DOT_TYPE, @"new"), nil];
            break;
        case PTUpdate:
            [DialerUsageRecord recordpath:PATH_ANTIHARASS
                kvs:Pair(ANTIHARASS_CLICK_DOT_TYPE, @"update"), nil];
            break;
        default:
            break;
    }
}

- (void) skin {
    SkinSettingViewController *vc = [[SkinSettingViewController alloc] init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_SKIN];
}

- (void) setting {
    DefaultSettingViewController *vc = [DefaultSettingViewController controllerWithPageModel:
                                        [[SettingsCreator creator] modelForPage:SETTING_PAGE_MAIN]];
    [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
}

- (void) logout {
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"personal_center_logout_hint", @"") message:nil cancelTitle:NSLocalizedString(@"personal_center_logout_cancel", @"") okTitle:NSLocalizedString(@"personal_center_logout_confirm", @"") okButtonActionBlock:^ {
        [LoginController removeLoginDefaultKeys];
        [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(CENTER_CLICK_LOGOUT_CONFIRM,@(1)), nil];
        if (self.delegate) {
            [self.delegate onLogout];
        }
        [self refreshSettingData];
    } cancelActionBlock:^{
        [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(CENTER_CLICK_LOGOUT_CONFIRM,@(0)), nil];
    }];
}

- (void)refreshNoahPush {
    for (CenterOperateSectionAction *action in sectionArray ){
        [action refreshNoahPush];
    }
}

- (void)refreshSettingData {
    for (UIView *view in [_hostView subviews]) {
        [view removeFromSuperview];
    }
    [sectionArray removeAllObjects];
    [self generateSection];
}

- (void)askNumbers {
    if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] == nil) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] != nil) {
            [SeattleFeatureExecutor queryVOIPAccountInfo];
            NSDictionary *accountInfo = [SeattleFeatureExecutor getAccountNumbersInfo];
            if (accountInfo != nil && ![accountInfo isEqual:_savedAccountInfo]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self refreshNumbers:accountInfo];
                });
            }
        }
    });
}

- (void)refreshNumbers:(NSDictionary *)accountInfo{
    NSString *oldCoins = _savedAccountInfo[@"coins"];
    NSString *coins = accountInfo[@"coins"];
    if (![oldCoins isEqual:coins] && coins.length >= 3) {
        [self refreshCell:[self getCellWithType:BACK_FEE_INFO] withNewDisplay:[coins substringToIndex:coins.length - 3] andDotType:PTDot];
    }
    if (![accountInfo[@"cards"] isEqualToString:_savedAccountInfo[@"cards"]]) {
        [self refreshCell:[self getCellWithType:CARD_INFO] withNewDisplay:accountInfo[@"cards"] andDotType:PTDot];
    }

    [self refreshCell:[self getCellWithType:FREE_MINUTE_INFO] withNewDisplay:accountInfo[@"minutes"] andDotType:PTHide];
    _savedAccountInfo = accountInfo;
}

- (void)refreshCell:(CenterOperateCellAction *)cell withNewDisplay:(NSString *)newDisplay andDotType:(PointType)dotType{
    CenterOperateInfo *info = [cell getInfo];
    if ([info.labelText isEqualToString:@"免费时长"])  {
        [cell setDotType:0 withNum:0];
    }
    if ([newDisplay isEqual:info.iconText]) {
        return;
    }
    info.dotType = dotType;
    info.iconTypeName = nil;
    info.iconText = newDisplay;
    [cell setContent];
}

- (void)clearHighlightState {
    for (CenterOperateSectionAction *action in sectionArray) {
        [action clearHighlightState];
    }
}

- (void)jumpToBackFee {
    DefaultJumpLoginController *controller = [DefaultJumpLoginController withOrigin:@"personal_center_backfee"];
    controller.yourDestination = ^ {
        return [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel backFeeModel]];
    };
    [LoginController checkLoginWithDelegate:controller];
//    DefaultJumpLoginController *loginController = [DefaultJumpLoginController withOrigin:@"personal_center_wallet"];
//    loginController.destination = NSStringFromClass([MyWalletViewController class]);
//    [LoginController checkLoginWithDelegate:loginController];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_BACKFEE];
}

- (void)jumpToFreeMinute {
    DefaultJumpLoginController *controller = [DefaultJumpLoginController withOrigin:@"personal_center_freeminute"];
    controller.yourDestination = ^ {
        return [[PersonInfoDescViewController alloc] initWithModel:[PersonInfoDescModel freeFeeModel]];
    };
    [LoginController checkLoginWithDelegate:controller];
//    DefaultJumpLoginController *loginController = [DefaultJumpLoginController withOrigin:@"personal_center_wallet"];
//    loginController.destination = NSStringFromClass([MyWalletViewController class]);
//    [LoginController checkLoginWithDelegate:loginController];
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_FREE_MINUTE];
}

- (void)jumpToDialerSetting {
    DefaultSettingViewController *vc = [DefaultSettingViewController controllerWithPageModel:[[SettingsCreator creator] modelForPage:SETTING_PAGE_DIALER]];
    [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
}

- (void)refreshAntiharass{
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return;
    PointType type = [[NoahManager sharedPSInstance]getGuidePointType:GUIDEPOINT_ANTIHARASS];
    if (type > PTHide) {
        [self setDotType:type withNum:0 operateType:ANTIHARASS_INFO];
        [[NoahManager sharedPSInstance]getGuidePointShown:GUIDEPOINT_ANTIHARASS];
    }else{
        BOOL showDot = [UserDefaultsManager boolValueForKey:ANTIHARASS_SHOW_DOT defaultValue:NO];
        BOOL ifAntiharass = [UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON defaultValue:NO];
        if ( showDot && ifAntiharass ){
            [self setDotType:PTUpdate withNum:0 operateType:ANTIHARASS_INFO];
        }else{
            [self setDotType:PTHide withNum:0 operateType:ANTIHARASS_INFO];
        }
    }
}


- (void)refreshCenterOperate{
    if (self) {
        [self refreshNumbers:[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO]];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
