//
//  EditVoipViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-6.
//
//

#import "EditVoipViewController.h"
#import "TPDialerResourceManager.h"
#import "VoipTopSectionView.h"
#import "SwitchSettingCellView.h"
#import "UserDefaultsManager.h"
#import "WithBottomLineView.h"
#import "VoipShareView.h"
#import "TPShareController.h"
#import "SeattleFeatureExecutor.h"
#import "VoipInvitationCodeView.h"
#import "DefaultUIAlertViewHandler.h"
#import "TouchPalVersionInfo.h"
#import "ScheduleInternetVisit.h"
#import "VOIPCall.h"
#import "CootekNotifications.h"
#import "VoipCallAlertView.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"
#import "HighlightTip.h"
#import "UserStreamViewController.h"
#import "PJSIPManager.h"
#import "Reachability.h"
#import "WaveTopSectionView.h"
#import "HandlerWebViewController.h"
#import "TouchPalVersionInfo.h"
#import "VoipShareAllView.h"
#import "FunctionUtility.h"
#import "MarketLoginController.h"
#import "SeattleFeatureExecutor.h"
#import "DialerViewController.h"
#import "TPAnalyticConstants.h"

#define WIDTH_ADAPT TPScreenWidth()/375
#define SETTING_TAG 1
#define MAX_BALANCE_WAVE 1000

#define TAG_VOIP_CONTROL 0
#define TAG_INTERNATIONAL_CALL 1
#define TAG_CELL_DATA_ACCEPT 2
#define TAG_INTER_CELL_DATA_ACCEPT 3
#define TAG_AUTO_BACK_CALL 4
#define TAG_USE_CODE 5
//#define TAG_EARN_MORE_MINUTE 6


#define TAG_START TAG_VOIP_CONTROL
#define TAG_END TAG_USE_CODE

@interface EditVoipViewController() <VoipTopSectionHeaderBarProtocol, UIGestureRecognizerDelegate>{
    VoipShareView *_shareView;
    UILabel *_timeLabel;
    VoipTopSectionHeaderBar *_headBar;
    UIView *settingRectLayout;
    
    UIButton *headerButton;
    UserSettingHighlightTip *tipForSuperDial_;
    
    NSMutableDictionary *_cells;
    CGFloat _heightExceptSettings;
    
}
@end

@implementation EditVoipViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FunctionUtility setAppHeaderStyle];
    self.headerTitle = @"免费电话设置";
    settingRectLayout =
    [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPScreenHeight())];
    [self.view addSubview:settingRectLayout];
    settingRectLayout.backgroundColor = [UIColor whiteColor];
    _cells = [NSMutableDictionary dictionaryWithCapacity:TAG_END+1];
    [self displaySettingCells];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self refreshSettingCells];
}

- (void)displaySettingCells {
    for (int i= TAG_START; i <= TAG_END; i++) {
        UIView *cell = [self cellViewWithTag:i];
        cell.frame = [self cellFrameForTag:i];
        cell.hidden = [self hiddenStateForCellTag:i];
        [settingRectLayout addSubview:cell];
    }
}

- (void)refreshSettingCells {
    for (int i= TAG_START + 1; i <= TAG_END; i++) {
        UIView *cell = [self cellViewWithTag:i];
        cell.frame = [self cellFrameForTag:i];
        cell.hidden = [self hiddenStateForCellTag:i];
    }
}

- (void)refreshCellsLayout {
    for (int i= TAG_START + 1; i <= TAG_END; i++) {
        UIView *cell = [self cellViewWithTag:i];
        cell.frame = [self cellFrameForTag:i];
    }
}

- (void)refreshCellsHiddenState {
    for (int i= TAG_START + 1; i <= TAG_END; i++) {
        UIView *cell = [self cellViewWithTag:i];
        cell.hidden = [self hiddenStateForCellTag:i];
    }
}

- (CGFloat)heightForSettingsCell {
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        return VOIP_CELL_HEIGHT;
    }
    if ([UserDefaultsManager boolValueForKey:VOIP_ENABLE_CELL_DATA]) {
        return (TAG_END + 1)*VOIP_CELL_HEIGHT;
    }
    return TAG_END*VOIP_CELL_HEIGHT;
}

- (CGRect)cellFrameForTag:(int)tag {
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
    BOOL enableCellData = [UserDefaultsManager boolValueForKey:VOIP_ENABLE_CELL_DATA];
    CGRect rect = CGRectZero;
    switch (tag) {
        case TAG_VOIP_CONTROL:
            rect = CGRectMake(0, 0, TPScreenWidth(), VOIP_CELL_HEIGHT);
            break;
        case TAG_INTERNATIONAL_CALL:
                rect = CGRectMake(0, VOIP_CELL_HEIGHT, TPScreenWidth(), VOIP_CELL_HEIGHT);
            break;
        case TAG_CELL_DATA_ACCEPT: {
            if (isVoipOn) {
                rect = CGRectMake(0, 2*VOIP_CELL_HEIGHT, TPScreenWidth(), VOIP_CELL_HEIGHT);
            } else {
                rect = CGRectMake(0, 0, TPScreenWidth(), VOIP_CELL_HEIGHT);
            }
            break;
        }
        case TAG_INTER_CELL_DATA_ACCEPT:
        case TAG_AUTO_BACK_CALL:
//        case TAG_EARN_MORE_MINUTE:
        case TAG_USE_CODE:
            rect = [self generateRectForTag:tag withVoipState:isVoipOn andCellDataEnable:enableCellData];
            break;
        default:
            break;
    }
    return rect;
}

- (CGRect)generateRectForTag:(int)tag withVoipState:(BOOL)isVoipOn andCellDataEnable:(BOOL)enableCellData{
    CGRect rect;
    if (isVoipOn && enableCellData) {
        rect = CGRectMake(0, tag*VOIP_CELL_HEIGHT, TPScreenWidth(), VOIP_CELL_HEIGHT);
    } else if (isVoipOn) {
        rect = CGRectMake(0, (tag -1) * VOIP_CELL_HEIGHT, TPScreenWidth(), VOIP_CELL_HEIGHT);
    } else {
        rect = CGRectMake(0, 0, TPScreenWidth(), VOIP_CELL_HEIGHT);
    }
    return rect;
}

- (UIView *)cellViewWithTag:(int)tag {
    UIView *view = nil;
    NSNumber *tagKey = [NSNumber numberWithInt:tag];
    view = [_cells objectForKey:tagKey];
    if (view){
        if (tag == TAG_INTERNATIONAL_CALL && [view isKindOfClass:[WithBottomLineView class]] && [((WithBottomLineView *)view).mainTitle.text rangeOfString:@"免费国际长途"].length>0) {
            if ([UserDefaultsManager boolValueForKey:have_participated_voip_oversea] ) {
                [(WithBottomLineView *)view refreshWithTitle:NSLocalizedString(@"voip_international_call_Join_OK", "")];
            }else{
                [(WithBottomLineView *)view refreshWithTitle:NSLocalizedString(@"voip_international_call_Join_immediately", "")];  
            }
          ((WithBottomLineView *)view).dotLabel.hidden = [UserDefaultsManager boolValueForKey:hide_voip_oversea_lable_point defaultValue:NO];
        }
        return view;
    }
    switch (tag) {
        case TAG_VOIP_CONTROL: {
            view = [self createCellWithmainText:NSLocalizedString(@"voip_open_voip", "") subText:NSLocalizedString(@"voip_open_voip_hint", "") settingKey:IS_VOIP_ON];
            SwitchSettingCellView *settingView = (SwitchSettingCellView *)[view viewWithTag:SETTING_TAG];
            __weak EditVoipViewController *bself = self;
            settingView.closeAlertStr = @"关闭后将无法再使用免费电话功能，您确定要关闭么？";
            settingView.actionBlock = ^(){
                [bself pressVoipButton];
            };
            break;
        }
        case TAG_INTERNATIONAL_CALL:{//voip_international_call
            BOOL ififParticipate = [UserDefaultsManager boolValueForKey:have_participated_voip_oversea defaultValue:NO];
            if (ififParticipate){
                view = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth() , VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_international_call_Join_OK", "") withDescription:@"消耗分钟数，免费拨打国际长途" ifParticipate:ififParticipate];
            }else{
                view = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth() , VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_international_call_Join_immediately", "") withDescription:@"消耗分钟数，免费拨打国际长途" ifParticipate:ififParticipate];
            }
            view.backgroundColor = [UIColor whiteColor];
            UIButton *invitationCodeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
            [view addSubview:invitationCodeButton];
            [invitationCodeButton addTarget:self action:@selector(checkToInternationalInviteView) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case TAG_CELL_DATA_ACCEPT: {
            view = [self createCellWithmainText:@"允许使用3G/4G接听电话" subText:@"未连接WIFI时，优先使用流量接听" settingKey:VOIP_ENABLE_CELL_DATA];
            SwitchSettingCellView *settingView = (SwitchSettingCellView *)[view viewWithTag:SETTING_TAG];
            __weak EditVoipViewController *bself = self;
            settingView.openAlertStr = @"开启该选项表明您同意触宝使用手机流量接听来电。";
            settingView.actionBlock = ^(){
                [bself onCellDataStatePressed];
            };
            break;
        }
        case TAG_INTER_CELL_DATA_ACCEPT: {
            view = [self createCellWithmainText:@"国际漫游时使用3G/4G接听" subText:@"国际漫游时，允许使用流量接听" settingKey:VOIP_INTERNATIONAL_ENABLE_CELL_DATA];
            SwitchSettingCellView *settingView = (SwitchSettingCellView *)[view viewWithTag:SETTING_TAG];
            settingView.openAlertStr = @"开启该选项表明您同意触宝在国际漫游时使用流量接听来电。";
            break;
        }
        case TAG_AUTO_BACK_CALL: {
            view = [self createCellWithmainText:NSLocalizedString(@"voip_backcall_on", "") subText:NSLocalizedString(@"voip_backcall_on2gor3gMobile", "") settingKey:VOIP_AUTO_BACK_CALL_ENABLE];
            break;
        }
//        case TAG_EARN_MORE_MINUTE: {
//            view = [[WithBottomLineView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_earn_more_minutes", "") withDescription:NSLocalizedString(@"voip_earn_more_minutes_hint", "") ifParticipate:NO];
//            UIButton *earnMoreButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//            [view addSubview:earnMoreButton];
//            [earnMoreButton addTarget:self action:@selector(earnMoreMinutes) forControlEvents:UIControlEventTouchUpInside];
//            break;
//        }
        case TAG_USE_CODE: {
            view = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth() , VOIP_CELL_HEIGHT) withTitle:NSLocalizedString(@"voip_use_invitation_code", "") withDescription:@"输入免费兑换码（10位）领取奖励" ifParticipate:NO];
            view.backgroundColor = [UIColor whiteColor];
            UIButton *invitationCodeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
            [view addSubview:invitationCodeButton];
            [invitationCodeButton addTarget:self action:@selector(showInvitationCodeView) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        default:
            break;
    }
    if (view) {
        [_cells setObject:view forKey:tagKey];
    }
    return view;
}

- (void)onCellDataStatePressed{
    UIView *view = [self cellViewWithTag:TAG_CELL_DATA_ACCEPT];
    [settingRectLayout bringSubviewToFront:view];
    BOOL cellDataEnabled = [UserDefaultsManager boolValueForKey:VOIP_ENABLE_CELL_DATA];
    view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (cellDataEnabled) {
            [self refreshSettingCells];
        } else {
            [self refreshCellsLayout];
        }
    } completion:^(BOOL finished) {
        if (!cellDataEnabled) {
            [self refreshCellsHiddenState];
        }
        view.userInteractionEnabled = YES;
    }];
}

- (BOOL)hiddenStateForCellTag:(int)tag {
    if (tag == TAG_VOIP_CONTROL || tag == TAG_INTERNATIONAL_CALL) {
        return NO;
    }
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        return YES;
    }
    if (tag == TAG_INTER_CELL_DATA_ACCEPT && ![UserDefaultsManager boolValueForKey:VOIP_ENABLE_CELL_DATA]) {
        return YES;
    }
    return NO;
}

- (void)leftButtonAction{
    HandlerWebViewController *con = [[HandlerWebViewController alloc]init];
    con.url_string = URL_NEWER_WIZARD;
    __weak id weakCon = con;
    [con setFinishLoadAction:^(UIView<FLWebViewProvider> *webView){
        [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nonnull ret, NSError * _Nonnull error) {
            if (!error) {
                NSString *theTitle = ret;
                if (theTitle && theTitle.length > 0 && ([theTitle rangeOfString:@"新手教程"].location != NSNotFound)) {
                    [UserDefaultsManager setBoolValue:YES forKey:NEWER_WIZARD_READ];
                }
            }
            if (weakCon) {
                [self.navigationController pushViewController:weakCon animated:YES];
            }
            
        }];
    }];
}

- (void)rightButtonAction{
    VoipShareAllView *view = [[VoipShareAllView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    view.fromWhere = @"editView";
    [self.view addSubview:view];
}

- (WithBottomLineView *)createCellWithmainText:(NSString *)mainText subText:(NSString *)subText settingKey:(NSString *)key{
    WithBottomLineView *shownView = [[WithBottomLineView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), VOIP_CELL_HEIGHT) withTitle:mainText withDescription:subText ifParticipate:NO];
    shownView.backgroundColor = [UIColor whiteColor];
    [settingRectLayout addSubview:shownView];
    
    SwitchSettingCellView *switchView = [SwitchSettingCellView switchCellWithData:[SwitchSettingItemModel itemWithTitle:@"" settingKey:key inSettings:[AppSettingsModel appSettings]] forPosition:RoundedCellBackgroundViewPositionMiddle];
    switchView.actionBlock = nil;
    switchView.backgroundColor = [UIColor clearColor];
    switchView.frame = CGRectMake( TPScreenWidth() - 106 ,0, 100 , VOIP_CELL_HEIGHT);
    switchView.tag = SETTING_TAG;
    [shownView addSubview:switchView];
    return shownView;
}

- (void) earnMoreMinutes {
    HandlerWebViewController* webVC = [[HandlerWebViewController alloc] init];
    webVC.url_string = [MarketLoginController getActivityCenterUrlString];
    webVC.header_title = NSLocalizedString(@"personal_center_setting_activity_center", @"");
    [self.navigationController pushViewController:webVC animated:YES];
    [DialerUsageRecord recordpath:EV_ACTIVITY_MARKET_EDIT_VOIP_ENTER kvs:Pair(@"count", @(1)), nil];
}

-(void)checkToInternationalInviteView{
    [UserDefaultsManager setBoolValue:YES forKey:hide_voip_oversea_lable_point];
    [self refreshCellsLayout];
    MarketLoginController *marketLoginController = [MarketLoginController withOrigin:@"personal_center_market"];
    marketLoginController.url = INVITATION_URL_STRING;

    [LoginController checkLoginWithDelegate:marketLoginController];
}

- (void)showInvitationCodeView{
    VoipInvitationCodeView *invitationCodeView = [[VoipInvitationCodeView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    invitationCodeView.useOldInterface = YES;
    [self.view addSubview:invitationCodeView];
}

- (void)pressVoipButton{
    UIView *cellView = [self cellViewWithTag:TAG_VOIP_CONTROL];
    [settingRectLayout bringSubviewToFront:cellView];
    cellView.userInteractionEnabled = NO;
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if (isVoipOn) {
                             [self refreshSettingCells];
                         } else {
                             [self refreshCellsLayout];
                         }
                     }
                     completion:^(BOOL finished){
                         if ( finished ){
                             cellView.userInteractionEnabled = YES;
                             if (!isVoipOn) {
                                 [self refreshCellsHiddenState];
                             }
                         }
                     }];
}

- (void)refreshHeaderButton{
    tipForSuperDial_ = [[UserSettingHighlightTip alloc] initWithUserSetting:VOIP_STREAM_HEADER_BUTTON expectedValue:[NSNumber numberWithBool:YES]];
    UIImage *icon = [[TPDialerResourceManager sharedManager] getImageByName:@"dialerView_newPoint@2x.png"];
    [tipForSuperDial_ attachToButton:headerButton atPosition:CGPointMake(headerButton.frame.size.width-icon.size.width-12,12) image:icon];
}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headerButtonAction{
    //话费红包为2
    UserStreamViewController *controller = [[UserStreamViewController alloc]initWithBonusType:VOIP_HISTORY andHeaderTitle:NSLocalizedString(@"voip", "") bgColor:[TPDialerResourceManager getColorForStyle:@"voip_top_view_green_bg_color"]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goBackToRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
