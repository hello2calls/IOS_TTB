//
//  CommonSettingViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/3.
//
//

#import "CommonSettingViewController.h"
#import "SettingTableView.h"
#import "TPDialerResourceManager.h"
#import "NormalSettingItem.h"
#import "AppSettingsModel.h"
#import "SwitchSettingItem.h"
#import "DefaultSettingViewController.h"
#import "SettingsModelCreator.h"
#import "SmartDailViewController.h"
#import "TouchPalVersionInfo.h"
#import "TPBuildTime.h"
#import "DateTimeUtil.h"

@interface CommonSettingViewController ()<SettingTableViewDelegate>

@property (nonatomic,weak) SettingTableView *tableView;
@property (nonatomic,strong) NSMutableArray *settingArr;

@end

@implementation CommonSettingViewController

- (NSMutableArray *)settingArr{
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSettingItems];

    self.headerTitle = NSLocalizedString(@"General","通用设置");
    
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    SettingTableView *tableView = [[SettingTableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(),TPScreenHeight() - TPHeaderBarHeight())];
    tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupSettingItems];
}

- (void)setupSettingItems{
    [self.settingArr removeAllObjects];
    
    [self.settingArr addObject:[self setupFirstSection]];
    [self.settingArr addObject:[self setupSecondSection]];
    [self.settingArr addObject:[self setupThirdSection]];
    [self.settingArr addObject:[self setupFourthSection]];

    self.tableView.settingArr = _settingArr;

}

- (NSArray *)setupFirstSection{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    __weak typeof(self)weakSelf = self;
    
    Language language = [[[AppSettingsModel appSettings] settingValueForKey:APP_SET_KEY_MUTI_LANGUAGE] integerValue];
    
    NSString *subtitle = nil;
    switch (language) {
        case LanguageStandard:
            subtitle = @"跟随系统";
            break;
        case ChineseSimplified:
            subtitle = @"简体中文";
            break;
        case ChineseTraditional:
            subtitle = @"繁体中文";
            break;
        case English:
            subtitle = @"English";
            break;
        default:
            break;
    }

    
    NormalSettingItem *firstItem = [NormalSettingItem
                                    itemWithTitle:NSLocalizedString(@"Language Setting","多语言设置")
                                    subTitle:subtitle
                                    badgeTitle:nil
                                    handleBlock:^{
                                        DefaultSettingViewController *vc = [DefaultSettingViewController controllerWithPageModel:[[SettingsCreator creator] modelForPage:SETTING_PAGE_MUTI_LANGUAGE]];
                                        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    [sectionArr addObject:firstItem];
    
    return sectionArr;
}

- (NSArray *)setupSecondSection{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
//    APP_SET_KEY_MUTI_LANGUAGE
    
    __weak typeof(self)weakSelf = self;
 
    NSString *secondItemSubtitle = [[AppSettingsModel appSettings] actionName:[AppSettingsModel appSettings].listClick];
    NormalSettingItem *secondItem = [NormalSettingItem
                                     itemWithTitle:NSLocalizedString(@"Click the item","点击列表条目")
                                     subTitle:secondItemSubtitle
                                     badgeTitle:nil
                                     handleBlock:^{
                                         DefaultSettingViewController *vc = [DefaultSettingViewController controllerWithPageModel:[[SettingsCreator creator] modelForPage:SETTING_PAGE_CUSTOMIZE_CLICK]];
                                         [weakSelf.navigationController pushViewController:vc animated:YES];
                                     }];

    [sectionArr addObject:secondItem];
    return sectionArr;
}

- (NSArray *)setupThirdSection{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    
    SwitchSettingItem *firstItem = [SwitchSettingItem
                                    itemWithTitle:NSLocalizedString(@"Dial tone","拨号按键音")
                                    subTitle:nil
                                    appModelKey:APP_SET_KEY_DIAL_TONE
                                    switchHandle:^(BOOL isSwitchOn) {
                                        [AppSettingsModel appSettings].dial_tone = isSwitchOn;
                                    
                                    }];
    
    [sectionArr addObject:firstItem];
    
    SwitchSettingItem *secondItem = [SwitchSettingItem
                                     itemWithTitle:NSLocalizedString(@"Dial Vibrate","去电x振动")
                                     subTitle:TPScreenWidth() > 350 ? NSLocalizedString(@"Dial Vibrate Subtitle","请确认打开系统设置->声音->振动") : NSLocalizedString(@"Dial Vibrate Subtitle In Iphone 4","请确认打开系统振动设置")
                                     appModelKey:APP_SET_KEY_VIBRATE_WHEN_CONNECTED
                                     switchHandle:^(BOOL isSwitchOn) {
        
                                         [AppSettingsModel appSettings].vibrate_when_connected = isSwitchOn;

                                         
                                     }];
    
    [sectionArr addObject:secondItem];
    
    SwitchSettingItem *thirdItem = [SwitchSettingItem
                                    itemWithTitle:NSLocalizedString(@"Display caller number location in list","显示号码归属地")
                                    subTitle:nil
                                    appModelKey:APP_SET_KEY_DISPLAY_LOCATION
                                    switchHandle:^(BOOL isSwitchOn) {
        
                                        [AppSettingsModel appSettings].display_location = isSwitchOn;
                                        
                                    }];
    
    [sectionArr addObject:thirdItem];
    
    return sectionArr;
}

- (NSArray *)setupFourthSection{
    
    NSMutableArray *sectionArr = [NSMutableArray array];
    
    NormalSettingItem *firstItem = [NormalSettingItem
                                    itemWithTitle:NSLocalizedString(@"Dialing assistant","IP智能拨号")
                                    subTitle:nil
                                    badgeTitle:nil
                                    vcClass:NSStringFromClass([SmartDailViewController class])];
    
    [sectionArr addObject:firstItem];
#ifdef DEBUG
      // 完整版本号，比如 5448
    NSString *debugVersion = [CURRENT_TOUCHPAL_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""];
    debugVersion = [NSString stringWithFormat:@"(DEBUG) %@", debugVersion];
    [sectionArr addObject:[NormalSettingItem itemWithTitle:@"版本"  subTitle:debugVersion badgeTitle:nil vcClass:nil]];
    
#ifdef TP_DEBUG_BUILD_TIME
    // 编译时刻, 比如 2016-07-14 11:14:22
    NSDate *buildDate = [NSDate dateWithTimeIntervalSince1970:TP_DEBUG_BUILD_TIME];
    NSString *buildTimeString = [DateTimeUtil dateStringByFormat:@"yyyy-MM-dd HH:mm:ss" fromDate:buildDate];
    [sectionArr addObject:[NormalSettingItem itemWithTitle:@"编译时刻"  subTitle:buildTimeString badgeTitle:nil vcClass:nil]];
    
    // 编译时的分支
    [sectionArr addObject:[NormalSettingItem itemWithTitle:@"编译分支"  subTitle:TP_DEBUG_CURRENT_BRANCH badgeTitle:nil vcClass:nil]];
    
    // 编译时的commit号
      [sectionArr addObject:[NormalSettingItem itemWithTitle:@"编译commit"  subTitle:TP_DEBUG_CURRENT_COMMIT badgeTitle:nil vcClass:nil]];
#endif
    
#endif
    
    return sectionArr;
}

#pragma mark - PersonalCenterTableViewDelegate

- (void)settingTableView:(SettingTableView *)tableView didSelectSettingItem:(SettingItem *)settingModel{
    UIViewController *vc = [[NSClassFromString(settingModel.vcClass) alloc] init];
    
    if (settingModel.handle) {
        settingModel.handle();
    }
    
    if (vc == nil) {
        return;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc{

}
@end
