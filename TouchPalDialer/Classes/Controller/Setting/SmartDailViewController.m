//
//  SmartDailViewController.m
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 CooTek. All rights reserved.
//

#import "SmartDailViewController.h"
#import "HeaderBar.h"
#import "CootekTableViewCell.h"
#import "TPHeaderButton.h"
#import "TouchPalDialerAppDelegate.h"
#import "LocalPhoneInfoViewController.h"
#import "ProfileModel.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "CootekNotifications.h"
#import "UITableView+TP.h"
#import "FunctionUtility.h"
#import "ExcludedListForSmartDialViewController.h"
#import "UserDefaultsManager.h"
#import "SmartDailerSettingModel.h"
#import "RuleModel.h"
#import "InitSmartSettingViewController.h"

#define CALL_BACK_SUFFIX @"Call Back"

typedef enum {
    SectionLocalInfo = 0,
    SectionSmartDailer = 1,
    SectionRoaming = 2,
    SectionSmartRules = 3,
    SectionExcludedMembers = 4,
}SmartDailerSectionType;

@interface SmartDailViewController (){
   RuleModel __strong *ruleBeingRemovedFromDisplay_;
}
- (void)RemoveRuleFromIPRuleArray;
- (void)moreSettingsForIPRulesWithRuleKey:(NSString *)key isOn:(BOOL)isOn;
@end

@implementation SmartDailViewController

@synthesize settingModel;
@synthesize dailerTableView;
@synthesize IPRuleArray;
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
    headerTitle.text = NSLocalizedString(@"Dialing assistant",@"");
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

    
    UITableView *tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight()-50) style:UITableViewStylePlain];
    tmpTableView.backgroundView = nil;
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    tmpTableView.sectionHeaderHeight = 20;
    tmpTableView.rowHeight = 60;
    tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tmpTableView setSkinStyleWithHost:self forStyle:@"defaultUITableView_style"]; 
    [self.view addSubview:tmpTableView];
    self.dailerTableView = tmpTableView;
    
    SmartDailerSettingModel *tmpSettingModel = [[SmartDailerSettingModel alloc] init];
    self.settingModel = tmpSettingModel;
    
    if ([UserDefaultsManager boolValueForKey:IS_SIM_CHANGED]) {
        NSString *msg = NSLocalizedString(@"TouchPal detects you changing the SIM card. Please reset the IP dialing information.", @"");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                              otherButtonTitles:NSLocalizedString(@"Ok",@""), nil];
        [alert show];
    }
    self.IPRuleArray = [settingModel smartDialProfileRulesBySim];
    [self RemoveRuleFromIPRuleArray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:N_CARRIER_CHANGED object:nil];
}

-(void)reloadTableView{
    self.IPRuleArray = [settingModel smartDialProfileRulesBySim];
    [self RemoveRuleFromIPRuleArray];
    [dailerTableView reloadData];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 1) {       
        [self loadInitView];
        [UserDefaultsManager setBoolValue:NO forKey:IS_SIM_CHANGED];
    }
}

- (void)loadInitView{
    if ([SmartDailerSettingModel isChinaSim]) {
        InitSmartSettingViewController *tmpSmartRuleViewController = [[InitSmartSettingViewController alloc] init];
        
        [self.navigationController pushViewController:tmpSmartRuleViewController animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *areaCode = settingModel.residentAreaCode;
    if (areaCode == nil || [areaCode length] == 0) {
        settingModel.smartDialAdviceEnabled = NO;
    }
    [dailerTableView reloadData];
}

- (void)gotoBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [indexPath section];
	int row = [indexPath row];
    RoundedCellBackgroundViewPosition position = [tableView cellPositionOfIndexPath:indexPath];
    CootekTableViewCell *cell = nil;

    if ((section == SectionSmartDailer && row < 2)||section == SectionSmartRules) {
        cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:nil
                                          withCellType:SwitchCellType
                                          cellPosition:position];
    }else if (section == SectionRoaming) {
        cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:nil
                                          withCellType:SwitchCellType
                                          cellPosition:position];
    } else if (section == SectionExcludedMembers ){
        
        cell = [[CootekTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                           reuseIdentifier:nil
                                              cellPosition:position];
    } else {
        
        cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:nil
                                         withCellType:Default_Cell
                                         cellPosition:position];
         }
    switch (section) {
        case SectionLocalInfo:
        {
            cell.textLabel.text = NSLocalizedString(@"My phone",@"");
            cell.detailTextLabel.text = NSLocalizedString(@"Input country and carrier",@"");
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            
            UIImage *accessoryImage = [[TPDialerResourceManager sharedManager] getImageByName:@"setting_listitem_detail@2x.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(TPScreenWidth() - accessoryImage.size.width - 16, (self.dailerTableView.rowHeight - accessoryImage.size.height ) / 2, accessoryImage.size.width, accessoryImage.size.height);
            button.frame = frame;
            [button setImage:accessoryImage forState:UIControlStateNormal];
            [button setImage:accessoryImage forState:UIControlStateHighlighted];
            button.backgroundColor= [UIColor clearColor];
            [cell addSubview:button];
            break;
        }
        case SectionSmartDailer:
        {
            SettingCellView *tmpCell = (SettingCellView *)cell;
            tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (row) {
                case 0:                    
                {
                    tmpCell.cellKey = @"suggestions";
                    tmpCell.textLabel.text = NSLocalizedString(@"Autodialing suggestions",@"");
                    tmpCell.textLabel.font = [UIFont systemFontOfSize:16];
                    tmpCell.detailTextLabel.text = NSLocalizedString(@"Show applied IP dialing rules and suggestions to assist dialing when roaming",@"");
                    tmpCell.delegate = self;
                    [tmpCell.rightSwitch setOn:(settingModel.smartDialAdviceEnabled && IPRuleArray.count >0)];
                    [tmpCell.rightSwitch setEnabled:IPRuleArray.count > 0];
                    break; 
                }
                case 1:                    
                {
                    tmpCell.cellKey = @"dial";
                    tmpCell.textLabel.text = NSLocalizedString(@"Auto apply suggestion",@"");
                    tmpCell.textLabel.font = [UIFont systemFontOfSize:16];
                    tmpCell.detailTextLabel.text = NSLocalizedString(@"Only one IP rule, direct call",@"");
                    tmpCell.delegate = self;
                    if(settingModel.smartDialAdviceEnabled && IPRuleArray.count >0)
                    {
                        [tmpCell.rightSwitch setOn:settingModel.autoDialEnabled];
                        tmpCell.rightSwitch.enabled = YES;
                    }
                    else
                    {
                        [tmpCell.rightSwitch setOn:false];
                        tmpCell.rightSwitch.enabled = NO;
                        tmpCell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
                        tmpCell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    }
                    break; 
                }
                default:
                    break;
            }
            break;  
        }
        case SectionRoaming:
        {
            SettingCellView *tmpCell = (SettingCellView *)cell;
            tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tmpCell.cellKey = @"the_roaming_cell";
            tmpCell.textLabel.text = NSLocalizedString(@"roaming_status_cell_title",@"");
            tmpCell.textLabel.font = [UIFont systemFontOfSize:16];
            tmpCell.delegate = self;
            [tmpCell.rightSwitch setOn:[settingModel isRoaming]];
            break;
        }
        case SectionSmartRules:
        {
            SettingCellView *tmpcell = (SettingCellView *)cell;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            RuleModel *rule = (RuleModel *)[IPRuleArray objectAtIndex:row];
            tmpcell.textLabel.text = NSLocalizedString(rule.name,"");
            tmpcell.detailTextLabel.text = NSLocalizedString(rule.description,"");
            tmpcell.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
            tmpcell.textLabel.font = [UIFont systemFontOfSize:16];
            tmpcell.delegate = self;
            tmpcell.cellKey = rule.key;
            if(!settingModel.smartDialAdviceEnabled){
                tmpcell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultTextGray_color"];
                tmpcell.userInteractionEnabled = NO;
            }else{
                tmpcell.textLabel.textColor = [UIColor colorWithRed:COLOR_IN_256(0x33) green:COLOR_IN_256(0x33) blue:COLOR_IN_256(0x33) alpha:1.0];
                tmpcell.userInteractionEnabled = YES;
            }
            [tmpcell.rightSwitch setOn:[UserDefaultsManager boolValueForKey:rule.key defaultValue:rule.isEnable]];
            if([rule.name hasSuffix:CALL_BACK_SUFFIX]){
              //the before users may set one of the two international call back to off state, in this case the other one should also be set to off
                [self moreSettingsForIPRulesWithRuleKey:rule.key
                                                   isOn:[UserDefaultsManager boolValueForKey:rule.key defaultValue:rule.isEnable]];
            }
            break;
        }
        case SectionExcludedMembers:
        {
            cell.textLabel.text = NSLocalizedString(@"Excluded contacts",@"");
            cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
            cell.detailTextLabel.text = @"";
            UIImage *accessoryImage = [[TPDialerResourceManager sharedManager] getImageByName:@"setting_listitem_detail@2x.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
             CGRect frame = CGRectMake(TPScreenWidth() - accessoryImage.size.width - 16, (self.dailerTableView.rowHeight - accessoryImage.size.height ) / 2, accessoryImage.size.width, accessoryImage.size.height);
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
    cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.textLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_MainText_color"];
    cell.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    cell.detailTextLabel.highlightedTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL isChinaSim = [SmartDailerSettingModel isChinaSim];
    BOOL isSmartDialEnabled = [[SmartDailerSettingModel settings] isSmartDialAdviceEnabled];
    
    switch (section) {
        case SectionLocalInfo:
            return 1;
        case SectionSmartDailer:
            return isChinaSim ? 2 : 0;
        case SectionRoaming:
            return isChinaSim && isSmartDialEnabled ? 1 : 0;
        case SectionSmartRules:
            return isChinaSim && isSmartDialEnabled && [IPRuleArray count] > 0 ? [IPRuleArray count] : 0;
        case SectionExcludedMembers:
            return isChinaSim && isSmartDialEnabled ? 1 : 0;
        default:
            return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 20)];
    sectionView.backgroundColor = [UIColor clearColor];
//    UILabel* sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 305, 30)];
//    sectionHeader.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"settings_section_header_text_color"];
//    sectionHeader.font = [UIFont systemFontOfSize:FONT_SETTINGS_TITLE];
//    sectionHeader.textAlignment = NSTextAlignmentLeft;
//    sectionHeader.backgroundColor = [UIColor clearColor];
//    
//    BOOL isChinaSim = [SmartDailerSettingModel isChinaSim];
//    BOOL isSmartDialEnabled = [[SmartDailerSettingModel settings] isSmartDialAdviceEnabled];
//    
//    switch (section) {
//        case SectionLocalInfo:
//        {
//            sectionHeader.text = NSLocalizedString(@"My phone", @"");
//            break;
//        }
//        case SectionSmartDailer:
//        {
//            sectionHeader.text = isChinaSim ? NSLocalizedString(@"Smart dial setting", @"") : @"";
//            break;
//        }
//        case SectionRoaming:
//        {
//            sectionHeader.text = isChinaSim && isSmartDialEnabled ? NSLocalizedString(@"Roaming status setting", @"") : @"";
//            break;
//        }
//        case SectionSmartRules:
//        {
//            sectionHeader.text = isChinaSim && isSmartDialEnabled && [IPRuleArray count] > 0 ? NSLocalizedString(@"IP dialing rules", @"") : @"";
//            break;
//        }
//        case SectionExcludedMembers:
//        {
//            sectionHeader.text = isChinaSim && isSmartDialEnabled ? NSLocalizedString(@"Manage excluded members", @"") : @"";
//            break;
//        }
//        default:
//            break;
//    } 
//    
//    [sectionView addSubview:sectionHeader];
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
    int section = [indexPath section];
    if (section == SectionLocalInfo) {
        LocalPhoneInfoViewController *tmpLocalInfoViewController = [[LocalPhoneInfoViewController alloc] init];
        [self.navigationController  pushViewController:tmpLocalInfoViewController animated:YES];
    }else if(section == SectionExcludedMembers){
        ExcludedListForSmartDialViewController *tmpExcludedViewController = [[ExcludedListForSmartDialViewController alloc] init];
        tmpExcludedViewController.headerTitle = NSLocalizedString(@"Excluded contacts", @"");
        [self.navigationController pushViewController:tmpExcludedViewController animated:YES];
    }
}

#pragma SettingCellDelegate
- (void)changeSwitch:(BOOL)is_on withKey:(NSString *)key{
    if ([key isEqualToString:@"the_roaming_cell"]) {
        [settingModel setRoaming:is_on];
        [dailerTableView reloadData];
    } else if ([key isEqualToString:@"suggestions"]) {
        if(is_on &&
           (settingModel.residentAreaCode == nil || [settingModel.residentAreaCode length] ==0)){
            [self loadInitView];
        }
        settingModel.smartDialAdviceEnabled = is_on;
        [dailerTableView reloadData];
    }else if([key isEqualToString:@"dial"])  {
        settingModel.autoDialEnabled = is_on;
    }else if([key length] > 0) {
        [UserDefaultsManager setObject:[NSNumber numberWithBool:is_on] forKey:key];
        [self moreSettingsForIPRulesWithRuleKey:key isOn:is_on];
    }  
}

-(void)RemoveRuleFromIPRuleArray{
    // remove one of the two international roaming call back rules
    NSMutableArray *ruleArray = [[NSMutableArray alloc] initWithArray:self.IPRuleArray];
    for(RuleModel *rule in ruleArray){
        if([rule.name hasSuffix:CALL_BACK_SUFFIX]){
            ruleBeingRemovedFromDisplay_ = rule;
            [ruleArray removeObject:rule];
            break;
        }
    }
    self.IPRuleArray = ruleArray;
}

- (void)moreSettingsForIPRulesWithRuleKey:(NSString *)key isOn:(BOOL)isOn{
    for(RuleModel *rule in self.IPRuleArray){
        if([rule.name hasSuffix:CALL_BACK_SUFFIX]
           && [key isEqualToString:rule.key]){
           [UserDefaultsManager setObject:[NSNumber numberWithBool:isOn] forKey:ruleBeingRemovedFromDisplay_.key];
            break;
        }
    }
}
- (void)dealloc{
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
@end
