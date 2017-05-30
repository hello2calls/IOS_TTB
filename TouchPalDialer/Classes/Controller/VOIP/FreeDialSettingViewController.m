//
//  FreeDialSettingViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/2.
//
//

#import "FreeDialSettingViewController.h"
#import "FunctionUtility.h"
#import "SettingTableView.h"
#import "SwitchSettingItem.h"
#import "UserDefaultsManager.h"
#import "AppSettingsModel.h"
#import "NormalSettingItem.h"
#import "CommonSettingItem.h"
#import "SettingPageModel.h"
#import "SettingsModelCreator.h"
#import "DefaultSettingViewController.h"
#import "VoipInvitationCodeView.h"
#import "TPDialerResourceManager.h"
#import "MarketLoginController.h"

#define INVITATION_URL_STRING  @"http://oss.aliyuncs.com/cootek-dialer-download/dialer/free-call/international/oversea_main/index.html"

@interface FreeDialSettingViewController ()<SettingTableViewDelegate>

@property (nonatomic,weak) SettingTableView *tableView;
@property (nonatomic,strong) NSMutableArray *settingArr;

@end

@implementation FreeDialSettingViewController

- (NSMutableArray *)settingArr{
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FunctionUtility setAppHeaderStyle];
    self.headerTitle = @"免费电话设置";
    
    [self setupUI];
    
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self fetchData];
}

- (void)setupUI{
    CGFloat tableViewX = 0;
    CGFloat tableViewY = TPHeaderBarHeight();
    CGFloat tableViewW = TPScreenWidth();
    CGFloat tableViewH = TPScreenHeight() - TPHeaderBarHeight();
    
    SettingTableView *tableView = [[SettingTableView alloc] initWithFrame:CGRectMake(tableViewX, tableViewY, tableViewW, tableViewH)];
    self.tableView = tableView;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}

- (void)fetchData{
    
    [self.settingArr removeAllObjects];
    [self.settingArr addObject:[self buildSectionFirst]];
    [self.settingArr addObject:[self buildSectionSecond]];
    
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]){
        [self.settingArr addObject:[self buildSectionThird]];
    }
    
    self.tableView.settingArr = _settingArr;
}

- (NSArray *)buildSectionFirst{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    SwitchSettingItem *firstItem = [SwitchSettingItem itemWithTitle:NSLocalizedString(@"voip_open_free_phone", "开启免费电话")
        subTitle:NSLocalizedString(@"voip_open_voip_hint", "用触宝打电话,省钱省心")
        appModelKey:IS_VOIP_ON
        closeAlert:@"关闭后将无法再使用免费电话功能，您确定要关闭么？"
        switchHandle:^(BOOL isSwitchOn) {
            [weakSelf fetchData];
        }];
    
    [sectionArr addObject:firstItem];
    
    return sectionArr;
}

- (NSArray *)buildSectionSecond{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    BOOL ififParticipate = [UserDefaultsManager boolValueForKey:have_participated_voip_oversea defaultValue:NO];
    NSString *rightTitle = nil;
    UIColor *color = nil;
    if (ififParticipate) {
        color = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        rightTitle = NSLocalizedString(@"voip_international_call_Join_OK_normal", "");
    }else{
        rightTitle = NSLocalizedString(@"voip_international_call_Join_immediately_normal", "");
        color = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_500"];
    }
    CommonSettingItem *firstItem = [CommonSettingItem itemWithTitle:@"免费国际长途" subTitle:@"消耗分钟数,免费拨打国际长途" rightTitle:rightTitle handle:^{
        MarketLoginController *marketLoginController = [MarketLoginController withOrigin:@"personal_center_market"];
        marketLoginController.url = INVITATION_URL_STRING;
        
        [LoginController checkLoginWithDelegate:marketLoginController];
        }];
    firstItem.rightTitleColor = color;

    [sectionArr addObject:firstItem];
    
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        SwitchSettingItem *secondItem = [SwitchSettingItem
                                         itemWithTitle:NSLocalizedString(@"voip_allow_cellular_data", "使用3G/4G接听")
                                         subTitle:NSLocalizedString(@"voip_allow_cellular_data_sub", "未连接WIFI时，优先使用流量接听")
                                         openAlert:@"开启该选项表明您同意触宝使用手机流量接听来电。"
                                         appModelKey:VOIP_ENABLE_CELL_DATA
                                         switchHandle:^(BOOL isSwitchOn) {
                                             [weakSelf fetchData];

                                         }];
        
        [sectionArr addObject:secondItem];
        
        if ([UserDefaultsManager boolValueForKey:VOIP_ENABLE_CELL_DATA]) {
            
            SwitchSettingItem *thirdItem = [SwitchSettingItem
                                            itemWithTitle:NSLocalizedString(@"voip_inter_cellular_receiving", "国际漫游时使用3G/4G接听")
                                            subTitle:NSLocalizedString(@"voip_inter_cellular_receiving_sub", "国际漫游时，允许使用流量接听")
                                            openAlert:@"开启该选项表明您同意触宝在国际漫游时使用流量接听来电。"
                                            appModelKey:VOIP_INTERNATIONAL_ENABLE_CELL_DATA
                                            switchHandle:^(BOOL isSwitchOn) {
                
                                            }];
            
            [sectionArr addObject:thirdItem];
        }
        
        SwitchSettingItem *fourthItem = [SwitchSettingItem
                                         itemWithTitle:NSLocalizedString(@"voip_backcall_on", "允许自动回拨")
                                         subTitle:NSLocalizedString(@"voip_backcall_on2gor3gMobile", "")
                                         appModelKey:VOIP_AUTO_BACK_CALL_ENABLE
                                         switchHandle:^(BOOL isSwitchOn) {
            
                                         }];
        [sectionArr addObject:fourthItem];
        
         DialerModeType dialerModeType = [[[AppSettingsModel appSettings] settingValueForKey:APP_SET_KEY_DIALER_MODE] integerValue];
        
        NSString *subtitle = nil;
        switch (dialerModeType) {
            case DialerModeAlwaysAsk:
                subtitle = NSLocalizedString(@"dialer_mode_ask", "");
                break;
            case DialerModeNormal:
                subtitle = NSLocalizedString(@"dialer_mode_normal", "");
                break;
            case DialerModeVoip:
                subtitle = NSLocalizedString(@"dialer_mode_voip", "");
                break;
            default:
                break;
        }
        
        NormalSettingItem *fifthItem = [NormalSettingItem
                                        itemWithTitle:NSLocalizedString(@"dialer_mode", "拨号方式")
                                        subTitle:subtitle
                                        badgeTitle:nil
                                        vcClass:NSStringFromClass([DefaultSettingViewController class])];
        
        [sectionArr addObject:fifthItem];
    }
    
    return sectionArr;
}

- (NSArray *)buildSectionThird{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    CommonSettingItem *firstItem = [CommonSettingItem
                                    itemWithTitle:@"使用兑换码"
                                    subTitle:@"输入免费兑换码(10位)领取奖励"
                                    rightTitle:nil
                                    handle:^{
                                        VoipInvitationCodeView *invitationCodeView = [[VoipInvitationCodeView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
                                        invitationCodeView.useOldInterface = YES;
                                        [weakSelf.view addSubview:invitationCodeView];
                                    }];
   
    [sectionArr addObject:firstItem];
    
    return sectionArr;
}

- (void)settingTableView:(SettingTableView *)tableView didSelectSettingItem:(SettingItem *)settingModel{
    UIViewController *vc = [[NSClassFromString(settingModel.vcClass) alloc] init];
    if (settingModel.handle) {
        settingModel.handle();
    }
    
    if (vc == nil) {
        return;
    }
    
    if ([vc isMemberOfClass:[DefaultSettingViewController class]]) {
        SettingPageModel* page = [[SettingsCreator creator] modelForPage:SETTING_PAGE_DIALER_MODE];
        vc = [DefaultSettingViewController controllerWithPageModel:page];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
