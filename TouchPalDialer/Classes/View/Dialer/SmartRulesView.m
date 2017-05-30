//
//  SmartRulesView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 11/7/12.
//
//

#import "SmartRulesView.h"
#import "HeaderBar.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "SettingCellView.h"
#import "RuleModel.h"
#import "SmartDailerSettingModel.h"
#import "FunctionUtility.h"
#import "TPItemButton.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"

@interface SmartRulesView() <SettingCellDelegate>{
    SmartDailerSettingModel __strong *settingModel_;
    RuleModel __strong *ruleBeingRemovedFromDisplay_;
}
@property (nonatomic,retain) NSArray *rules;
@end

@implementation SmartRulesView

@synthesize rules = rules_;
@synthesize doWhenPressDoneButtonBlock = doWhenPressDoneButtonBlock_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        int toTop =(TPScreenHeight() - 360)/2 - 20;
        int toLeft = 20;
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(toLeft, toTop, TPScreenWidth() - 40, 360)];
        bgView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"popup_bg_color"];
        [self addSubview:bgView];
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(toLeft, toTop, bgView.frame.size.width, 41)];
        headView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_dialog_title_bg@2x.png"];
        headView.backgroundColor = [UIColor clearColor];
        [self addSubview:headView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(toLeft + 5, toTop, bgView.frame.size.width - 10, 41)];
        titleLabel.text = NSLocalizedString(@"Start smart dialer", @"");
        titleLabel.font = [UIFont systemFontOfSize:CELL_FONT_LARGE];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"defaultCellMainText_color"];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        UILabel *instructLabel = [[UILabel alloc] initWithFrame:CGRectMake(toLeft + 10, toTop + 45, bgView.frame.size.width - 20, 50)];
        [instructLabel setSkinStyleWithHost:self forStyle:@"SmartRuleView_instructLabel_style"];
        instructLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        instructLabel.text = NSLocalizedString(@"The following IP dialing rules may suit for you, please make your choice:", @"");
        instructLabel.numberOfLines = 2;
        [self addSubview:instructLabel];
        
        UITableView *smartRuleTable = [[UITableView alloc] initWithFrame:CGRectMake(toLeft + 10, toTop + 95, bgView.frame.size.width - 20, 175)];
        smartRuleTable.backgroundColor = [UIColor clearColor];
        smartRuleTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        smartRuleTable.backgroundView = nil;
        smartRuleTable.rowHeight = 50;
        smartRuleTable.dataSource = self;
        smartRuleTable.delegate = self;
        [smartRuleTable flashScrollIndicators];
        [self addSubview:smartRuleTable];

        UIImageView *gradientView = [[UIImageView alloc] initWithFrame:CGRectMake(toLeft + 10, toTop + 225, bgView.frame.size.width - 20, 45)];
        gradientView.image = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_report_commit_bg_shadow@2x.png"];
        [self addSubview:gradientView];
        
        UILabel *reminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(toLeft + 10, toTop + 270, bgView.frame.size.width-20,50)];
        [reminderLabel setSkinStyleWithHost:self forStyle:@"SmartRuleView_reminderLabel_style"];
        reminderLabel.text =NSLocalizedString(@"Note:\n the IP rules you choose will pop up automatically every time before you make call",@"");
        reminderLabel.numberOfLines = 3;
        reminderLabel.font = [UIFont systemFontOfSize:CELL_FONT_SMALL];
        [self addSubview:reminderLabel];

        UIImage *buttonBackgroundNormal = [[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_left_normal@2x.png"];
        UIImage *buttonBackgroundHighlighted = [[TPDialerResourceManager sharedManager]
                                                getImageByName:@"common_popup_button_ht@2x.png"];
        UIButton *doneButton = [TPItemButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(toLeft, toTop + 320, 280, 40);
        [doneButton setTitle:NSLocalizedString(@"Done",@"") forState:UIControlStateNormal];
        [doneButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"common_popup_button_text_color"] forState:UIControlStateNormal];
        [doneButton setBackgroundImage:buttonBackgroundNormal forState:UIControlStateNormal];
        [doneButton setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
        [doneButton addTarget:self action:@selector(closeTips) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        //data
        settingModel_ = [[SmartDailerSettingModel alloc] init];
        [self prepareRuleArray];
    }
    return self;
}

- (UIImage *)gradientViewToBottomOfTable:(CGSize) size{
    UIColor *startColor =  [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"gradienViewToBottom_start_color"];
    UIColor *endColor =  [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"gradienViewToBottom_end_color"];
    UIImage *gradientImage = [FunctionUtility getGradientImageFromStartColor:startColor
                                                                endColor:endColor
                                                                 forSize:size];
    return gradientImage;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)dealloc{
    [SkinHandler removeRecursively:self];
}

-(void)closeTips{
    if(doWhenPressDoneButtonBlock_){
        doWhenPressDoneButtonBlock_();
    }
    [self removeFromSuperview];
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return rules_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   NSString *CellIdentifierTypeSwitch = @"CellIdentifierTypeChecked";
     SettingCellView *cell = (SettingCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierTypeSwitch];
    if (cell == nil) {
            cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:CellIdentifierTypeSwitch
                                              withCellType:CheckButtonTypeCell];
        cell.textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"SmartRuleView_smartRuleTabelCellText_color"];
        cell.detailTextLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"SmartRuleView_smartRuleTabelCellDetailText_color"];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName: @"common_report_commit_item@2x.png"]];
        
        UIView *selectedBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        selectedBackView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"defaultCellSelected_color"];
        cell.selectedBackgroundView = selectedBackView;
    }
    RuleModel *rule = (RuleModel *)[rules_ objectAtIndex:indexPath.row];
    [cell.textLabel setFrame:CGRectMake(0, cell.textLabel.frame.origin.y,
                                        cell.textLabel.frame.size.width, cell.textLabel.frame.size.height)];
    [cell.detailTextLabel setFrame:CGRectMake(0, cell.detailTextLabel.frame.origin.y,
                                        cell.detailTextLabel.frame.size.width, cell.detailTextLabel.frame.size.height)];
    cell.textLabel.text = NSLocalizedString(rule.name,"");
    cell.detailTextLabel.text = NSLocalizedString(rule.description,"");
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.delegate = self;
    cell.cellKey = rule.key;
    
    [cell setCheckedForCheckButtonTypeCell:[UserDefaultsManager boolValueForKey:rule.key defaultValue:rule.isEnable]];
    if([rule.name hasSuffix:@"Call Back"]){
        //the before users may set one of the two international call back to off state, in this case the other one should also be set to off
        [self moreSettingsForIPRulesWithRuleKey:rule.key
                                           isOn:[UserDefaultsManager boolValueForKey:rule.key defaultValue:rule.isEnable]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingCellView * cell = (SettingCellView *)[tableView cellForRowAtIndexPath:indexPath];
    [cell touchCheckButton];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)prepareRuleArray{
    // remove one of the two international roaming call back rules
    NSMutableArray *ruleArray = [[NSMutableArray alloc] initWithArray:[settingModel_ smartDialProfileRulesBySim]];
    for(RuleModel *rule in ruleArray){
        if([rule.name hasSuffix:@"Call Back"]){
            ruleBeingRemovedFromDisplay_ = rule;
            [ruleArray removeObject:rule];
            break;
        }
    }
    self.rules = ruleArray;
}

- (void)moreSettingsForIPRulesWithRuleKey:(NSString *)key isOn:(BOOL)isOn{
    for(RuleModel *rule in rules_){
        if([rule.name hasSuffix:@"Call Back"]
           && [key isEqualToString:rule.key]){
            [UserDefaultsManager setObject:[NSNumber numberWithBool:isOn] forKey:ruleBeingRemovedFromDisplay_.key];
            break;
        }
    }
}

#pragma SettingCellDelegate
- (void)touchCheckButton:(BOOL)checked withKey:(NSString *)cellKey{
    if([cellKey length] > 0) {
        [UserDefaultsManager setObject:[NSNumber numberWithBool:checked] forKey:cellKey];
        [self moreSettingsForIPRulesWithRuleKey:cellKey isOn:checked];
    }
}

@end
