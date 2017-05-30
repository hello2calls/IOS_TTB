//
//  AntiharassmentViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "AntiharassmentViewController.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"

#import "TPDialerResourceManager.h"
#import "AntiHarassLogoCell.h"
#import "AntiHarassCell.h"
#import "AntiNormalItem.h"
#import "AntiSwitchItem.h"
#import "AntiLogoItem.h"

#import "TodayWidgetAnimationViewController.h"
#import "AntiharassChooseCityViewController.h"

#import "VoipShareAllView.h"
#import "CommonTipsWithBolckView.h"

#import "AntiharassUtil.h"
#import "Reachability.h"
#import "AntiharassManager.h"
#import "NSString+Color.h"
#import "AntiharassmentViewController_iOS10.h"

@interface AntiharassmentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *settingArr;
@property (nonatomic,assign) BOOL closeTips;

@end

@implementation AntiharassmentViewController

- (instancetype)init{
    if (self = [super init]) {
        self.headerTextColor = [UIColor whiteColor];
        self.skinDisabled = YES;
    }
    return self;
}

#pragma mark - Setter / Getter

- (NSMutableArray *)settingArr{
    
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupHeaderBar];

    [self setupTableView];

    [self setupAntiItems];
    
    [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_PERSONAL_ANTIHARASS];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_OPENED_FROM, @"center_cell"), nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupAntiItems) name:N_ANTIHARASS_VIEW_REFRESH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupAntiItems) name:N_ANTIHARASS_SWTICH_CHANGE object:nil];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self setupAntiItems];
    
}

- (void)setupHeaderBar{

    self.headerTitle = @"骚扰识别";

    UIView *headerBarBackView = [self.headerBar valueForKey:@"backView"];
    headerBarBackView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    
    UIView *headerBarBgView = [self.headerBar valueForKey:@"bgView"];
    headerBarBgView.hidden = YES;

}

- (void)setupTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) style:UITableViewStylePlain];
    tableView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    UIView *blueBgView = [[UIView alloc] initWithFrame:CGRectMake(0, -TPScreenHeight(), TPScreenWidth(), TPScreenHeight())];
    blueBgView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    [tableView insertSubview:blueBgView atIndex:1];
    
    [self.view insertSubview:tableView atIndex:1];
}

- (void)setupAntiItems{
    
    [self.settingArr removeAllObjects];
    
    [self.settingArr addObject:[self setupFirstSection]];
    
    [self.settingArr addObject:[self setupSecondSection]];

    [self.settingArr addObject:[self setupthirdSection]];

    [self.settingArr addObject:[self setupFourthSection]];
    
    [self.tableView reloadData];

}

- (NSArray *)setupFirstSection{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    
    UIImage *bgImage = [TPDialerResourceManager getImage:@"antiharass_top_view_bg@2x.png"];
    
    CGFloat logoHeight = bgImage.size.height / bgImage.size.width * TPScreenWidth() - 20;
    
    AntiLogoItem *firstItem = [AntiLogoItem itemWithHandle:^{
        
        TodayWidgetAnimationViewController *con = [[TodayWidgetAnimationViewController alloc]init];
        [weakSelf.navigationController pushViewController:con animated:YES];
        
    } height:logoHeight];
    
    [arr addObject:firstItem];
    
    return arr;
    
}

- (NSArray *)setupSecondSection{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;

    AntiSwitchItem *firstItem = [AntiSwitchItem itemWithTitle:@"开启骚扰识别" subtitle:nil settingKey:ANTIHARASS_IS_ON willSwitchHandle:^(BOOL on) {
        
        [weakSelf onAntiharassSwitch];
        
    }];
    
    [arr addObject:firstItem];
    
    return arr;
    
}

- (NSArray *)setupthirdSection{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;

    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON]) {
        
        AntiSwitchItem *firstItem = [AntiSwitchItem itemWithTitle:@"WiFi下自动更新" subtitle:nil settingKey:ANTIHARASS_AUTOUPDATEINWIFI_ON willSwitchHandle:^(BOOL on) {
            
            [weakSelf onAntiHarassUpInWifiSwitch];
            
        }];
        
        [arr addObject:firstItem];
        
        
        AntiNormalItem *secondItem = [AntiNormalItem itemWithTitle:@"更新骚扰识别库" attributedSubtitle:[self antiHarassVersionStatus] vcClass:nil clickHandle:^{
            
            [weakSelf onDatabasePressed];
            
        }];
        
        [arr addObject:secondItem];
        

    }
    
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_CITY_CHOOSED defaultValue:NO]) {
        NSString *city = [AntiharassUtil getStringName:[UserDefaultsManager intValueForKey:ANTIHARASS_TYPE]];
        AntiNormalItem *thirdItem = [AntiNormalItem itemWithTitle:@"我的常住城市" subtitle:city vcClass:nil clickHandle:^{
            [weakSelf onCityPressed];
        }];
        
        [arr addObject:thirdItem];
    }
    
   
    NSString *badge = [UserDefaultsManager boolValueForKey:ANTIHARASS_SHOULD_HIDE_READ_ME_DOT defaultValue:NO] ? nil : @"NEW";
    AntiNormalItem *fourthItem = [AntiNormalItem itemWithTitle:@"使用必读" subtitle:@"" vcClass:nil clickHandle:^{
        [weakSelf onHelpPressed];
    }];
    fourthItem.badge = badge;
    
    [arr addObject:fourthItem];

    
    return arr;
    
}

- (NSAttributedString *)antiHarassVersionStatus{
    
    NSString *status = nil;
    
    UIColor *statusColor = nil;
    
    NSString *dbVersion = (NSString *)[UserDefaultsManager objectForKey:ANTIHARASS_VERSION defaultValue:@""];
    NSString *removeVersion = (NSString *)[UserDefaultsManager objectForKey:ANTIHARASS_REMOTE_VERSION defaultValue:@""];

    if ( [AntiharassUtil ifDBTypeChanged] ){
        if (!([Reachability network] == network_none || [[Reachability shareReachability] currentReachabilityStatus] == NotReachable )&& [Reachability network]< network_wifi){
            status = @"检测到常住地更改,点击更新！";
            statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_300"];
            [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOW_DOT];
        }else{
            if([UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON defaultValue:YES]){
                if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
                    status = @"正在自动更新至最新版本！";
                    statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];

                }else{
                    status = @"检测到常住地更改,点击更新！";
                    statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_300"];
                }
                
            }else{
                status = @"检测到常住地更改,点击更新！";
                statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_300"];
                [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOW_DOT];
            }
        }
    }
    else{
        if ( ![dbVersion isEqualToString:removeVersion] && [removeVersion integerValue] > [dbVersion integerValue] ){
            if([UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON defaultValue:YES]){
                if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
                    
                    status = @"正在自动更新至最新版本！";
                    statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
                    
                    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOW_DOT];

                }else{
                    if (!([Reachability network] == network_none || [[Reachability shareReachability] currentReachabilityStatus] == NotReachable )&& [Reachability network]< network_wifi) {
                                        
                            status = @"检测到新版本，点击更新！";
                            statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_400"];
                            [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOW_DOT];

                      }else{
                            status = [NSString stringWithFormat:@"已是最新版本：%@",[AntiharassUtil translateVersionToString:dbVersion]];
                            statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
 
                                    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOW_DOT];
                                    [UserDefaultsManager setBoolValue:NO
                                                               forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
                      }
                    }
            }else{
                
                status = @"检测到新版本，点击更新！";
                statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_400"];
                
                [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOW_DOT];

            }
        }
        else{
            
            status = [NSString stringWithFormat:@"已是最新版本：%@",[AntiharassUtil translateVersionToString:dbVersion]];
            statusColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOW_DOT];
            [UserDefaultsManager setBoolValue:NO
                                       forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
            
        }
    }
    
    NSMutableAttributedString *attrString =
    
    [[NSMutableAttributedString alloc] initWithString:status];
    
    
    [attrString addAttribute:NSForegroundColorAttributeName
     
                       value:statusColor
     
                       range:NSMakeRange(0, status.length)];

    return attrString;
}


- (NSArray *)setupFourthSection{
    
    NSMutableArray *arr = [NSMutableArray array];
    
    
    AntiNormalItem *firstItem = [AntiNormalItem itemWithTitle:@"分享给iPhone小伙伴" subtitle:@"" vcClass:nil clickHandle:^{
        
        
        UIImage *image = [TPDialerResourceManager getImage:@"antiharass_share_weixin@2x.png"];
        [VoipShareAllView shareWithTitle:@"iPhone也能识别骚扰电话了！" msg:@"" url:@"http://www.chubao.cn/s/1015_ios530/xxxxxx.html" imageUrl:@"" andFrom:@"antiharass" image:image];
        
    }];
    
    [arr addObject:firstItem];
    
    return arr;
    
}


- (void)updateAntiharassVersion{
    
    BOOL ifAntiharass = [UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON];
    if ( !ifAntiharass )
        return;
    BOOL contactAccess = [UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY];
    if ( !contactAccess )
        return;
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
        return;
    }
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON defaultValue:YES]) {
        [[AntiharassManager instance]updateAntiharassInWifiInBackground];
    }else{
        [[AntiharassManager instance]checkUpdateInBackground];
    }
}

-(void)updateAntiharassVersionInDialerVC{
    
    [self onDatabasePressed];
    
}

#pragma mark - Event 

- (void) onCityPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_PRESS_UPDATE_BUTTON, @(2)), nil];
    if([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]){
        CommonTipsWithBolckView *tips = [[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:NSLocalizedString(@"Harassment numbers are automatically updated in the library, temporarily unable to replace permanent residence, please wait", @"") lable1textAlignment:NSTextAlignmentCenter lable2String:nil lable2textAlignment:NSTextAlignmentCenter leftString:nil rightString:@"我知道了" rightBlock:nil leftBlock:nil];
        [DialogUtil showDialogWithContentView:tips inRootView:nil];
        return;
    }
    AntiharassChooseCityViewController *con = [[AntiharassChooseCityViewController alloc]init];
    [self.navigationController pushViewController:con animated:YES];
}

- (void) onHelpPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CLICK_FAQ, @(1)), nil];
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOULD_HIDE_READ_ME_DOT];
//    dotLabel.hidden = [UserDefaultsManager boolValueForKey:ANTIHARASS_SHOULD_HIDE_READ_ME_DOT defaultValue:NO];
    [AntiharassUtil showGuidePage];
}

- (void) onDatabasePressed{

        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_PRESS_UPDATE_BUTTON, @(1)), nil];
        if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
            CommonTipsWithBolckView *tips = [[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:@"正在自动更新中，请稍候" lable1textAlignment:NSTextAlignmentCenter  lable2String:nil lable2textAlignment:NSTextAlignmentCenter leftString:nil rightString:@"我知道了" rightBlock:nil leftBlock:nil];
            [DialogUtil showDialogWithContentView:tips inRootView:nil];
            return;
        }
 
    [[AntiharassManager instance]updateAntiharass];
}


- (void) onAntiharassSwitch{
    
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_ON_SWITCH_PRESSED, @(1)), nil];
    
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
        CommonTipsWithBolckView *tips = [[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:NSLocalizedString(@"Harassment numbers are automatically updated in the library, temporarily unable to close, please wait", @"") lable1textAlignment:NSTextAlignmentCenter lable2String:nil lable2textAlignment:NSTextAlignmentCenter leftString:nil rightString:@"我知道了" rightBlock:nil leftBlock:nil];
        
        [DialogUtil showDialogWithContentView:tips inRootView:nil];
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_WANT_TO_CLOSE_UPDATE_IN_WIFI, @(1)), nil];
        return;
    }
    
    BOOL ifAntiharass = [UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON];
    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_AUTOUPDATEINWIFI_ON];
    if (ifAntiharass ){
        [[AntiharassManager instance]closeAntiharass];
    }else{
        BOOL ifFirstUsed = [UserDefaultsManager boolValueForKey:ANTIHARASS_CITY_CHOOSED defaultValue:NO];
        if ( ifFirstUsed ){
            [[AntiharassManager instance]openAntiharass];
        }else{
            AntiharassChooseCityViewController *con = [[AntiharassChooseCityViewController alloc]init];
            con.ifFirstChoose = YES;
            [self.navigationController pushViewController:con animated:YES];
        }
    }
}

- (void) onAntiHarassUpInWifiSwitch{
    
    if (![UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON defaultValue:YES]) {
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow makeToast:NSLocalizedString(@"Congratulations, open success", "") duration:1.0f position:CSToastPositionBottom];
        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_AUTOUPDATEINWIFI_ON];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_SWTICH_CHANGE object:nil];
        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
        [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW object:nil];
        [self updateAntiharassVersion];
        
    }
    else{
        if([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]){
            CommonTipsWithBolckView *tips = [[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:NSLocalizedString(@"Harassment numbers are automatically updated in the library, temporarily unable to close, please wait", @"") lable1textAlignment:NSTextAlignmentCenter lable2String:nil lable2textAlignment:NSTextAlignmentCenter leftString:nil rightString:@"我知道了" rightBlock:nil leftBlock:nil];
            
            [DialogUtil showDialogWithContentView:tips inRootView:nil];
            [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair( ANTIHARASS_AUTOUPDATE_WIFI, @(1)), nil];
            return;
        }
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair( ANTIHARASS_AUTOUPDATE_WIFI, @(0)), nil];
        CommonTipsWithBolckView *wifiTips = [[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:NSLocalizedString(@"After closing, will no longer automatically update harass number recognition library for new harassment will not be the caller's identification number, determine to close?", @"")  lable1textAlignment:0 lable2String:nil lable2textAlignment:NSTextAlignmentCenter leftString:@"取消" rightString:@"确定" rightBlock:^{
            [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_AUTOUPDATE_WIFI, @(2)), nil];
            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_AUTOUPDATEINWIFI_ON];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_SWTICH_CHANGE object:nil];
            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
            [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW object:nil];
        }
                                                                                       leftBlock:nil];
        [DialogUtil showDialogWithContentView:wifiTips inRootView:nil];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AntiNormalItem *item = [self.settingArr objectAtIndex:indexPath.section][indexPath.item];
    if (item.clickHandle) {
        item.clickHandle();
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return [[self.settingArr objectAtIndex:section] count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.settingArr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AntiHarassCell *cell = nil;
    
    AntiNormalItem *item = [self.settingArr objectAtIndex:indexPath.section][indexPath.item];
    
    cell = [AntiHarassCell cellWithTableView:tableView settingItem:item];
   
    if (indexPath.item == 0 && indexPath.item == [_settingArr[indexPath.section] count] - 1) {
        cell.separateLineType = SettingCellSeparateLineTypeSingle;
    }else if(indexPath.item == 0){
        cell.separateLineType = SettingCellSeparateLineTypeHeader;
    }else if(indexPath.item == [_settingArr[indexPath.section] count] - 1){
        cell.separateLineType = SettingCellSeparateLineTypeFooter;
    }else{
        cell.separateLineType = SettingCellSeparateLineTypeNormal;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AntiNormalItem *item = [self.settingArr objectAtIndex:indexPath.section][indexPath.item];
    
    return item.height;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (section == 0) {
        return CGFLOAT_MIN;
    } else if (section == 1 && self.closeTips != YES) {
        if (![FunctionUtility is64bit] && [UIDevice currentDevice].systemVersion.floatValue >= 10) {
            return 20;
        }
        return 40;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if (section == self.settingArr.count - 1) {
        return 20;
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
   
    UIView *footerView = [[UIView alloc] init];
    if (section == 0) {
        footerView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    } else {
        footerView.backgroundColor = [UIColor clearColor];
    }
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *headerView = [[UIView alloc] init];
    
    if (![FunctionUtility is64bit] && [UIDevice currentDevice].systemVersion.floatValue >= 10) {
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    
    if (section == 0) {
        headerView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    } else if(section == 1 && self.closeTips != YES) {
        [headerView addSubview:[self setupTipView]];
    } else {
        headerView.backgroundColor = [UIColor clearColor];
    }
    return headerView;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(UIView *)setupTipView{
    
    UIView *tipView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 40)];
    
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
    lable1.font = [UIFont fontWithName:@"iPhoneIcon3" size:20];
    lable1.text = @"5";
    lable1.userInteractionEnabled= NO;
    lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_400"];
    [tipView addSubview:lable1];
    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable1.backgroundColor = [UIColor clearColor];
    }
    
    UILabel *lable2 =[[UILabel alloc] initWithFrame:CGRectMake(35, 0, TPScreenWidth()-43-35, 40)];
    lable2.text = @"更新至iOS10实现云拦截,让您的通话更\"干净\"";
    lable2.userInteractionEnabled= NO;
    lable2.textColor=[TPDialerResourceManager
                      getColorForStyle:@"tp_color_black_transparency_800"];
    if ([UIScreen mainScreen].bounds.size.width > 320) {
        lable2.font =[UIFont systemFontOfSize:14];
    } else {
        lable2.font =[UIFont systemFontOfSize:12];
    }
    [tipView addSubview:lable2];
    
    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable2.backgroundColor = [UIColor clearColor];
    }
    
    UILabel *lable4 =[[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth()-33, 0, 40, 40)];
    lable4.font =[UIFont fontWithName:@"iPhoneIcon2" size:18];
    lable4.text = @"t";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCloseTips)];
    lable4.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_600"];
    [lable4 addGestureRecognizer:tapGesture];
    lable4.userInteractionEnabled = YES;
    [tipView addSubview:lable4];
    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable4.backgroundColor = [UIColor clearColor];
    }
    
    tipView.backgroundColor =[@"0xe5f4ff" color];
    return tipView;
}

- (void)clickCloseTips {
    self.closeTips = YES;
    [self.tableView reloadData];
}

+ (NSString *) controllerClassName {
    NSString *vcClassStr = nil;
    if ([FunctionUtility is64bitAndIOS10]) {
        vcClassStr = NSStringFromClass([AntiharassmentViewController_iOS10 class]);
    } else {
        vcClassStr = NSStringFromClass([AntiharassmentViewController class]);
    }
    return vcClassStr;
}

+ (BOOL) hasNewDBVersion {
    if ([FunctionUtility is64bitAndIOS10]) {
        ANTIHARASSTATUS status = [AntiharassmentViewController_iOS10 getStatus];
        return (status == ANTIHARASS_SWITCHON_VERSION_UPDATE)
        || (status == ANTIHARASS_SWITCHON_VERSIONNULL_UPDATE);
        
    } else {
        return [UserDefaultsManager boolValueForKey:ANTIHARASS_SHOW_DOT defaultValue:NO];
    }
}
@end
