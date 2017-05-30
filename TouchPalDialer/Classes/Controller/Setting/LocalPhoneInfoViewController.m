//
//  LocalPhoneInfoViewController.m
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocalPhoneInfoViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "CootekTableViewCell.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "SelectCountryViewController.h"
#import "FeatureGuideSelectCarrierViewController.h"
#import "UITableView+TP.h"
#import "NSString+PhoneNumber.h"
#import "SmartDailerSettingModel.h"
#import "PhoneNumber.h"
#import "UserDefaultsManager.h"

@interface LocalPhoneInfoViewController ()
- (void)setSimInfoWithCountryCode:(NSString *)code carrier:(NSString *)carrier;
@end

@implementation LocalPhoneInfoViewController

@synthesize settingModel;
@synthesize localTableView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff()-TPHeightBetweenIP4AndIP5(), TPScreenWidth(), TPScreenHeight()-TPHeaderBarHeightDiff()+TPHeightBetweenIP4AndIP5())];
    [backGroundView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    [self.view addSubview:backGroundView];

    
	// HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar] ;
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headBar];
    
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    [headerTitle setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.text = NSLocalizedString(@"My phone", @"");
	[headBar addSubview:headerTitle];
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if(isVersionSix) {
        // back button
        UIColor *tColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:backBtn];
        
        headerTitle.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
    }
    else {
        // BackButton
        TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [cancel_but setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [cancel_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:cancel_but];
        
    }


    UITableView *tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight() , TPScreenWidth(), TPAppFrameHeight()-50) style:UITableViewStylePlain];
    tmpTableView.backgroundView = nil;
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    tmpTableView.rowHeight = 60;
    tmpTableView.tableFooterView = [[UIView alloc] init];
    [tmpTableView setSkinStyleWithHost:self forStyle:@"defaultUITableView_style"];
    tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tmpTableView];
    self.localTableView = tmpTableView;
    
    SmartDailerSettingModel *tmpSettingModel = [[SmartDailerSettingModel alloc] init];
    self.settingModel = tmpSettingModel;
}

- (void)reloadData
{
    [localTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [localTableView reloadData];
}

- (void)gotoBack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_KEYBOARD_TEXTFIELD
														object:nil
													  userInfo:nil];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([SmartDailerSettingModel isChinaSim]){
        carrier_ = [settingModel currentChinaCarrier];
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoundedCellBackgroundViewPosition position = [tableView cellPositionOfIndexPath:indexPath];
    SettingCellView  *cell = nil;
    int row = [indexPath row];
    SettingCellType type = Default_Cell;
    if (row == 1) {
        type = TextFieldTypeCell;
    }
    switch (row) {
        case 0: {
            cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"" withCellType:type cellPosition:position];
            cell.textLabel.text = NSLocalizedString(@"Country or region",@"");
            NSString *countryInfo =[[PhoneNumber sharedInstance] getAreaCountryInfo];
            cell.detailTextLabel.text = countryInfo;//NSLocalizedString(@"CN(+86)",@"");
            UIImage *accessoryImage = [[TPDialerResourceManager sharedManager] getImageByName:@"setting_listitem_detail@2x.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(TPScreenWidth() - accessoryImage.size.width - 16, (self.localTableView.rowHeight - accessoryImage.size.height ) / 2, accessoryImage.size.width, accessoryImage.size.height);
            button.frame = frame;
            [button setImage:accessoryImage forState:UIControlStateNormal];
            [button setImage:accessoryImage forState:UIControlStateHighlighted];
            button.backgroundColor= [UIColor clearColor];
            [cell addSubview:button];
            break;
        }
        case 1: {
            cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"" withCellType:type cellPosition:position];
            SettingCellView *settingCell = (SettingCellView *)cell;
            settingCell.textLabel.text = NSLocalizedString(@"Area code",@"");
            settingCell.cellKey = @"areacode";
            settingCell.rightTextField.text =[settingModel residentAreaCode]; //NSLocalizedString(@"021",@"");
            settingCell.rightTextField.placeholder =  NSLocalizedString(@"/",@"");
            settingCell.rightTextField.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
            [settingCell.rightTextField setValue:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"]
                                      forKeyPath:@"_placeholderLabel.textColor"];
            settingCell.delegate = self;
            settingCell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 2: {
            cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"" withCellType:type cellPosition:position];
            cell.textLabel.text = NSLocalizedString(@"Carrier",@"");
            if(carrier_){
               cell.detailTextLabel.text = NSLocalizedString(carrier_, @"");
            }
            UIImage *accessoryImage = [[TPDialerResourceManager sharedManager] getImageByName:@"setting_listitem_detail@2x.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
             CGRect frame = CGRectMake(TPScreenWidth() - accessoryImage.size.width - 16, (self.localTableView.rowHeight - accessoryImage.size.height ) / 2, accessoryImage.size.width, accessoryImage.size.height);
            button.frame = frame;
            [button setImage:accessoryImage forState:UIControlStateNormal];
            [button setImage:accessoryImage forState:UIControlStateHighlighted];
            button.backgroundColor= [UIColor clearColor];
            [cell addSubview:button];
            break;
        }
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    cell.detailTextLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row != 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_KEYBOARD_TEXTFIELD
                                                            object:nil
                                                          userInfo:nil];        
    }
    switch (row) {
        case 0: {
            SelectCountryViewController *countryController = [[SelectCountryViewController alloc] init];
            countryController.delegate = self;
            countryController.loadSimSettingData = YES;
            [self.navigationController pushViewController:countryController animated:YES];
            break;
        }
        case 1: {
            break;
        }
        case 2: {
            FeatureGuideSelectCarrierViewController *carrierViewController = [[FeatureGuideSelectCarrierViewController alloc] init];
            carrierViewController.selectRowBlock = ^(NSString *carrier){
                carrier_ = carrier;
                [self setSimInfoWithCountryCode:nil carrier:carrier];
            };
            [self.navigationController pushViewController:carrierViewController animated:YES];
            break;
        }
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionHeader = [[UIView alloc] init];
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

#pragma SettingCellDelegate
- (void)textDidEndEditing:(NSString *)text withKey:(NSString *)key
{
    NSString *areaNumber = [text digitNumber];
    if ([areaNumber length] > 6) {
        return;
    }
    
    if (![[settingModel residentAreaCode] isEqualToString:areaNumber]) {
        [settingModel setResidentAreaCode:areaNumber];
    }
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_KEYBOARD_TEXTFIELD
														object:nil
													  userInfo:nil];
}

#pragma mark RegisterProtocolDelegate
-(void)selectCountryWithCountryName:(NSString *)name countryCode:(NSString *)code
{
  [self setSimInfoWithCountryCode:code carrier:nil];
}

-(void)selectCountryWithCountryName:(NSString *)name countryCode:(NSString *)code carrier:(NSString *)carrier
{
    carrier_ = carrier;
    [self setSimInfoWithCountryCode:code carrier:carrier];
}

- (void)setSimInfoWithCountryCode:(NSString *)code carrier:(NSString *)carrier
{
    if ([carrier length] != 0) {
        [settingModel setCurrentChinaCarrier:carrier];
    } else {
        [settingModel setSimMncWithNonHeadingPlusCountryCode:code];
    }
    [self reloadData];
}

@end
