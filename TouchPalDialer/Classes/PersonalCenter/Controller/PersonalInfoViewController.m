//
//  PersonalInfoViewController.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "PersonalInfoViewController.h"
#import "SettingTableView.h"
#import "TPDialerResourceManager.h"
#import "NormalSettingItem.h"
#import "UserDefaultsManager.h"
#import "NSString+PhoneNumber.h"
#import "UnbindSettingItem.h"
#import "DefaultUIAlertViewHandler.h"
#import "LoginController.h"
#import "DialerUsageRecord.h"
#import "AvatarSelectView.h"
#import "SeattleFeatureExecutor.h"
#import "PersonalCenterUtility.h"
#import "IconSettingItem.h"
#import "FunctionUtility.h"

@interface PersonalInfoViewController ()<SettingTableViewDelegate,UIActionSheetDelegate>
@property (nonatomic,weak) SettingTableView *tableView;
@property (nonatomic,strong) NSMutableArray *settingArr;

@end

@implementation PersonalInfoViewController

#pragma mark - Setter / Getter

- (NSMutableArray *)settingArr{
    if (!_settingArr) {
        _settingArr = [NSMutableArray array];
    }
    return _settingArr;
}

#pragma mark - View Event

- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerTitle = NSLocalizedString(@"personal_infomation", @"个人信息");
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    SettingTableView *tableView = [[SettingTableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(),TPScreenHeight())];
    tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [self fetchData];
    [FunctionUtility setStatusBarStyleToDefault:NO];
}


#pragma mark - Private

- (void)fetchData{
    
    [self.settingArr removeAllObjects];
    [self.settingArr addObject:[self buildSectionFirst]];
    [self.settingArr addObject:[self buildSectionSecond]];
    
    self.tableView.settingArr = _settingArr;
}

- (NSArray *)buildSectionFirst{
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray *sectionFirstArr = [NSMutableArray array];
    IconSettingItem *firstItem = [[IconSettingItem alloc] initWithTitle:NSLocalizedString(@"Photo", @"头像") subTitle:nil vcClass:nil handle:^{
        [weakSelf selectAvater];

    }];
    firstItem.iconImage = [PersonalCenterUtility getHeadViewUIImage];
    [sectionFirstArr addObject:firstItem];
    
     NSString *account = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
     account = [account substringFromIndex:3];
     account = [account separatePhoneNumber];
    NormalSettingItem *secondItem = [NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_mobile", @"手机号") subTitle:account badgeTitle:nil vcClass:nil];
    secondItem.hiddenArrow = YES;
    [sectionFirstArr addObject:secondItem];
    
    NSString *genderSubtitle = nil;
    int gender = [UserDefaultsManager intValueForKey:PERSON_PROFILE_GENDER];

    if (gender == 2) {
        genderSubtitle = NSLocalizedString(@"personal_center_gender_male", @"男");
    }else if (gender == 3) {
        genderSubtitle = NSLocalizedString(@"personal_center_gender_female", @"女");
    } else{
        genderSubtitle = NSLocalizedString(@"personal_center_gender_chose", @"选择");
    }
    

    NormalSettingItem *thirdItem = [NormalSettingItem itemWithTitle:NSLocalizedString(@"personal_center_gender", @"性别") subTitle:genderSubtitle badgeTitle:nil handleBlock:^{
       
        [weakSelf showGenderSelectView];

    }];
    [sectionFirstArr addObject:thirdItem];
    
    return sectionFirstArr;
}

- (NSArray *)buildSectionSecond{
    
    NSMutableArray *sectionSecondArr = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    UnbindSettingItem *firstItem = [[UnbindSettingItem alloc] initWithTitle:@"解除绑定" subTitle:nil vcClass:nil handle:^{
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"personal_center_logout_hint", @"") message:nil cancelTitle:NSLocalizedString(@"personal_center_logout_cancel", @"") okTitle:NSLocalizedString(@"personal_center_logout_confirm", @"") okButtonActionBlock:^ {
            [LoginController removeLoginDefaultKeys];
            [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(CENTER_CLICK_LOGOUT_CONFIRM,@(1)), nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
           
        } cancelActionBlock:^{
            [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(CENTER_CLICK_LOGOUT_CONFIRM,@(0)), nil];
        }];
        
    }];
    
    firstItem.hiddenArrow = YES;
    [sectionSecondArr addObject:firstItem];
    
    return sectionSecondArr;
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

- (void)showGenderSelectView{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    [actionSheet showInView:self.view];
}

- (void)selectGender:(NSInteger)gender{
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        
        NSString *url = [UserDefaultsManager stringForKey:PERSON_PROFILE_URL];
;
        __weak typeof(self) weakSelf = self;
        if (url == nil) {
            url = @"";
        }
        NSInteger type = LOCAL_PHOTO;
        if (![SeattleFeatureExecutor setPersonProfile:url withType:type withGender:gender]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DefaultUIAlertViewHandler showAlertViewWithTitle:@"上传性别失败" message:nil];
                [weakSelf fetchData];
            });
        } else {
            [UserDefaultsManager setIntValue:gender forKey:PERSON_PROFILE_GENDER];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf fetchData];
            });

        }
    });

}

#pragma mark - PersonalCenterTableViewDelegate

- (void)settingTableView:(SettingTableView *)tableView didSelectSettingItem:(SettingItem *)settingModel{

    if (settingModel.handle) {
        settingModel.handle();
    }
    
    UIViewController *vc = [[NSClassFromString(settingModel.vcClass) alloc] init];

    if (vc == nil) {
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self selectGender:2]; //男
    }
    
    if (buttonIndex == 1) {
        [self selectGender:3]; //男
    }
}

- (void)dealloc{
    
}
@end
