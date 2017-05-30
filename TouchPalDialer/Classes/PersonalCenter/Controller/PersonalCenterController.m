//
//  PersonalCenterControllerNew.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/13.
//
//
#import "TPDSkinViewController.h"
#import "PersonalCenterController.h"
#import "TouchPalDialerAppDelegate.h"
#import "SettingTableView.h"
#import "SkinSettingViewController.h"
#import "AntiharassmentViewController.h"
#import "EditVoipViewController.h"
#import "GestureSettingsViewController.h"
#import "UMFeedbackFAQController.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "DefaultLoginController.h"
#import "NoahManager.h"
#import "UsageConst.h"
#import "NormalSettingItem.h"
#import "AvatarSettingItem.h"
#import "PersonalCenterUtility.h"
#import "PersonalInfoViewController.h"
#import "FunctionUtility.h"
#import "NSString+PhoneNumber.h"
#import "DialerUsageRecord.h"
#import "SettingsModelCreator.h"
#import "AbostUsViewController.h"
#import "FreeDialSettingViewController.h"
#import "CommonSettingViewController.h"
#import "AvatarSelectView.h"
#import "SeattleFeatureExecutor.h"
#import "TPFilterRecorder.h"

#import "AntiharassmentViewController.h"
#import "AntiharassmentViewController_iOS10.h"

#import "FunctionUtility.h"

@interface PersonalCenterController()<SettingTableViewDelegate>

@property (nonatomic,strong) NSMutableArray *settingArr;
@property (nonatomic,weak) SettingTableView *tableView;
@property (nonatomic,assign)  NSInteger pvInTime;

@end

@implementation PersonalCenterController

- (NSMutableArray *)settingArr{
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
}
+(instancetype  __nonnull )getPersonalCenterVC{
    BOOL personalCenterFound = NO;
    UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];

    UIViewController *personalCenterController = [[PersonalCenterController alloc] init];
    for(UIViewController *vc in navigationController.viewControllers) {
        if ([vc isKindOfClass:[PersonalCenterController class]]) {
            personalCenterController = vc;
            personalCenterFound = YES;
            break;
        }
    }
    
    if (personalCenterFound) {
        // romove the existed controller
        [navigationController popToViewController:personalCenterController animated:YES];
    } else {
        // push a new controller
        [navigationController pushViewController:personalCenterController animated:YES];
    }
    return (PersonalCenterController *)personalCenterController;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    self.headerTitle = NSLocalizedString(@"ab_access_hint_settings", @"设置");

    SettingTableView *tableView = [[SettingTableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(),TPScreenHeight() - TPHeaderBarHeight())];
    tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [self fetchData];
    
    [self checkNewHead];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIndexRecord) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setInTime) name:N_APPLICATION_BECOME_ACTIVE object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:N_CALLEXTENSION_STATUS_REFRESH object:nil];
}



- (void)checkNewHead {
    
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
            PersonInfo *info = [SeattleFeatureExecutor getPersonProfile];
            if (![info.photoUrl isEqual:[UserDefaultsManager stringForKey:PERSON_PROFILE_URL]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self fetchData];
                });
            }
        }
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchData];
    [self setSkin];
    [FunctionUtility setAppHeaderStyle];
}

- (void)viewDidAppear:(BOOL)animated{
    [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(KEY_ACTION , CLICK_PERSONAL_CENTER), nil];
    [super viewDidAppear:animated];
    [self setInTime];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self setIndexRecord];
}

- (void)setInTime{
    _pvInTime = [[NSDate date] timeIntervalSince1970];
}

- (void)setIndexRecord{
    int pvOutTime = [[NSDate date] timeIntervalSince1970];
    int secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
    [DialerUsageRecord recordPV:@"personalCenterPage" inTime:_pvInTime outTime:pvOutTime rawOffset:secondsFromGMT];
}

- (void)fetchData{
    
    [self.settingArr removeAllObjects];
    [self.settingArr addObject:[self buildAvatarSection]];
    [self.settingArr addObject:[self buildSectionFirst]];
    [self.settingArr addObject:[self buildSectionSecond]];
    [self.settingArr addObject:[self buildSectionThird]];
    
    self.tableView.settingArr = _settingArr;
}

- (NSArray *)buildAvatarSection{
    
    NSMutableArray *sectionFirstArr = [NSMutableArray array];
    
    NSString *account = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    HandleBlock hanleBlock = nil;
    AvatarSettingItem *settingModel = nil;
    UIImage *avatarImage = [PersonalCenterUtility getHeadViewUIImage];
    
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] && account.length <= 3) {
        [LoginController removeLoginDefaultKeys];
    }
    
    if (account.length > 3) {
        account = [account substringFromIndex:3];
        account = [account separatePhoneNumber];
        settingModel = [AvatarSettingItem itemWithTitle:account subTitle:@"在触宝电话,享受生活的便捷" avatarImage:avatarImage vcClass:NSStringFromClass([PersonalInfoViewController class])];
        
        __weak typeof(self) weakSelf = self;

        settingModel.avatarClickHandle = ^{
            
            [weakSelf selectAvater];
        };
        
    } else {
        account = @"点击绑定手机号";
        hanleBlock = ^{
            [TPFilterRecorder recordpath:PATH_LOGIN
                                      kvs:Pair(LOGIN_FROM, LOGIN_FROM_PERSONAL_CENTER_BIND_PHONE), nil];
            [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"personal_center_head"]];
        };
        settingModel = [AvatarSettingItem itemWithTitle:account subTitle:@"在触宝电话,享受生活的便捷" avatarImage:avatarImage handleBlock:hanleBlock];

    }
    
    [sectionFirstArr addObject:settingModel];
    
    return sectionFirstArr;
}

- (NSArray *)buildSectionFirst{
    
    NSMutableArray *sectionFirstArr = [NSMutableArray array];

    [sectionFirstArr addObject:[NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_change_skin", @"个性换肤") subTitle:nil
        badgeTitle:nil
        vcClass:NSStringFromClass([SkinSettingViewController class])]];

    NSString *vcClassStr;
    if ([FunctionUtility is64bitAndIOS10]) {
        vcClassStr = NSStringFromClass([AntiharassmentViewController_iOS10 class]);
    } else {
        vcClassStr = NSStringFromClass([AntiharassmentViewController class]);
    }
    
    NormalSettingItem *item = [NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_disturbance_identification", @"骚扰识别")
        subTitle:nil
        badgeTitle:nil
        vcClass:vcClassStr];

    if ([FunctionUtility is64bitAndIOS10]) {
        item.redDotHidden = [UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION];
    }
    [sectionFirstArr addObject:item];
    
     NSString *account = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];    
     if (account.length > 3) {
         [sectionFirstArr addObject:[NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_free_call", @"免费电话") subTitle:nil
             badgeTitle:nil
             vcClass:NSStringFromClass([FreeDialSettingViewController class])]];
     } else {
         [sectionFirstArr addObject:[NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_free_call", @"免费电话") subTitle:nil
             badgeTitle:nil
             handleBlock:^{
                [TPFilterRecorder recordpath:PATH_LOGIN
                                           kvs:Pair(LOGIN_FROM, LOGIN_FROM_PERSONAL_CENTER_FREE_CALL), nil];
                [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"personal_center_head"]];
                         }]];
     }
    
//    if (![UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        [sectionFirstArr addObject:[NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_gesture_dial", @"手势拔号") subTitle:nil
                                                         badgeTitle:nil
                                                            vcClass:NSStringFromClass([GestureSettingsViewController class])]];
//    }
    
    return sectionFirstArr;
}

- (NSArray *)buildSectionSecond{
    NSMutableArray *sectionFirstArr = [NSMutableArray array];
    
    [sectionFirstArr addObject:
     [NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_general", @"通用")
                   subTitle:nil
                   badgeTitle:nil
                   vcClass:NSStringFromClass([CommonSettingViewController class])]];
    
    return sectionFirstArr;
}

- (NSArray *)buildSectionThird{
    NSMutableArray *sectionFirstArr = [NSMutableArray array];
    [sectionFirstArr addObject:
     [NormalSettingItem itemWithTitle:NSLocalizedString(@"umeng_feedback_title", @"帮助与反馈")
                   subTitle:nil
                   badgeTitle:nil
                   vcClass:NSStringFromClass([UMFeedbackFAQController class])]];
//    [sectionFirstArr addObject:
//     [NormalSettingItem itemWithTitle:NSLocalizedString(@"subscribe_touchpal_in_wexin", @"关注微信")
//                  subTitle:@"touchpal-fan"
//                  badgeTitle:nil
//                  handleBlock:^{
//                      [DefaultUIAlertViewHandler showAlertViewWithTitle:@"已为您复制公众号，搜索时可直接粘贴。是否立即前往微信？" message:nil okButtonActionBlock:^(){
//                          BOOL canOpenWX = [[TouchPalApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
//                          if (canOpenWX) {
//                              UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//                              pasteboard.string = @"touchpal-fan";
//                              [[TouchPalApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
//                          }
//                          else {
//                              [[[UIApplication sharedApplication].delegate window]
//                               makeToast:NSLocalizedString(@"wexin_not_found", @"未检测到安装微信，若已安装，建议手动打开") duration:3.0 position:nil];
//                          }
//                      }cancelActionBlock:^{
//                          
//                      }];
//
//                  }]];
    [sectionFirstArr addObject:
     [NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_setting_aboat_us", @"关于触宝")
                   subTitle:nil
                   badgeTitle:nil
                   vcClass:NSStringFromClass([AbostUsViewController class])]];
    return sectionFirstArr;
}


#pragma mark - Event

- (void)selectAvater{
    
    __weak typeof(self) weakSelf = self;
    
    AvatarSelectView *avaterSelectView = [[AvatarSelectView alloc] initWithFrame:self.view.bounds];
    [avaterSelectView setCompleteHandle:^{
        [weakSelf fetchData];
    }];
    
    [self.view addSubview:avaterSelectView];
}

#pragma mark - PersonalCenterTableViewDelegate

- (void)settingTableView:(SettingTableView *)tableView didSelectSettingItem:(SettingItem *)settingModel{
    UIViewController *vc = [[NSClassFromString(settingModel.vcClass) alloc] init];
    if ([vc isKindOfClass:[UMFeedbackFAQController class]]) {
        UMFeedbackFAQController *feedBackvc = [[UMFeedbackFAQController alloc] init];
        feedBackvc.url_string = FAQ_URL;
        feedBackvc.header_title = NSLocalizedString(@"umeng_feedback_title", @"");
        vc = feedBackvc;
    }
    
    if ([vc isKindOfClass:[UMFeedbackFAQController class]]) {
        UMFeedbackFAQController *feedBackvc = [[UMFeedbackFAQController alloc] init];
        feedBackvc.url_string = FAQ_URL;
        feedBackvc.header_title = NSLocalizedString(@"umeng_feedback_title", @"");
        vc = feedBackvc;
    }
    
    if (settingModel.handle) {
        settingModel.handle();
    }
    
    if (vc == nil) {
        return;
    }
    
//    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO] && [vc isKindOfClass:[SkinSettingViewController class]]) {
//        //v5 -> v6 skin
//        
//        [self.navigationController pushViewController:[TPDSkinViewController new] animated:YES];
//    }else{
//        
        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    if ([vc isKindOfClass:[FreeDialSettingViewController class]]) {
        [UserDefaultsManager setBoolValue:YES forKey:have_show_voip_oversea_point ];
        [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_VOIP];
    }
    
    if ([vc isKindOfClass:[AntiharassmentViewController class]]) {
        [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_ANTIHARASS];
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_OPENED_FROM, @"center_cell"), nil];
        
        PointType type = [[NoahManager sharedPSInstance]getGuidePointType:GUIDEPOINT_ANTIHARASS];
        switch (type) {
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
    
    if ([vc isKindOfClass:[SkinSettingViewController class]]) {
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO] ) {
            //v6 skin
        }else {
        [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_SKIN];
        }
    }
  
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
