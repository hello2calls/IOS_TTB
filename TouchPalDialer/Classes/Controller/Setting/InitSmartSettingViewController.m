//
//  InitSmartSettingViewController.m
//  TouchPalDialer
//
//  Created by Ailce on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InitSmartSettingViewController.h"
#import "LocalPhoneInfoViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "CootekTableViewCell.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "SmartDailerSettingModel.h"
#import "PhoneNumber.h"
#import "UIButton+DoneButton.h"

@implementation InitSmartSettingViewController{
    TPHeaderButton *finishButton_;
}

@synthesize settingModel;
@synthesize localTableView;
@synthesize areaCodeField;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SmartDailerSettingModel *tmpSettingModel = [[SmartDailerSettingModel alloc] init];
    self.settingModel = tmpSettingModel;
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff()-TPHeightBetweenIP4AndIP5(), TPScreenWidth(), TPScreenHeight()-TPHeaderBarHeightDiff()+TPHeightBetweenIP4AndIP5())];
    [backGroundView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    
    [self.view addSubview:backGroundView];
    
    //HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar] ;
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headBar];
    
    //BackButton
    TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initWithFrame:CGRectMake(0, 0,50, 45)];
    [cancel_but setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [cancel_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:cancel_but];
    
    //FinishButton
    finishButton_ = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth() - 50, 0, 50, 45) ];
    [finishButton_ setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [finishButton_ setTitle:NSLocalizedString(@"Done",@"") forState:UIControlStateNormal];
    finishButton_.hidden = !(settingModel.residentAreaCode != nil && [settingModel.residentAreaCode length] != 0);
    [finishButton_ addTarget:self action:@selector(gotoSave) forControlEvents:UIControlEventTouchUpInside];
    [headBar addSubview:finishButton_];
    
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    headerTitle.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"InitSmartSettingViewController_headerTitle_color"];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.text = NSLocalizedString(@"Dialing assistant",@"");
    [headBar addSubview:headerTitle];
    
    NSString *text = NSLocalizedString(@"init_smart_setting_note", @"");
    UIFont *font = [UIFont systemFontOfSize:FONT_SETTINGS_DESCRIPTION];
    
    //    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    //    CGFloat height = [text boundingRectWithSize:CGSizeMake(TPScreenWidth() - 10 * 2, CGFLOAT_MAX)
    //                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    //                                         attributes:tdic
    //                                            context:nil].size.height;
    
    
    CGFloat height = [text sizeWithFont:font constrainedToSize:CGSizeMake(TPScreenWidth() - 10 * 2, CGFLOAT_MAX)].height;
    
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(10, 50 + TPHeaderBarHeightDiff(), TPScreenWidth() - 10 * 2, height + 16)];
    content.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"settings_section_header_text_color"];
    content.font = font;
    content.textAlignment = NSTextAlignmentLeft;
    content.backgroundColor = [UIColor clearColor];
    content.numberOfLines = 0;
    content.lineBreakMode = NSLineBreakByWordWrapping;
    content.text = text;
    [self.view addSubview:content];
    
    CGFloat tableViewTopMargin = content.frame.origin.y + content.frame.size.height;
    
    UITableView *tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewTopMargin, TPScreenWidth(), TPAppFrameHeight()-tableViewTopMargin)
                                                             style:UITableViewStyleGrouped];
    tmpTableView.backgroundView = nil;
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    tmpTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tmpTableView];
    self.localTableView = tmpTableView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [localTableView reloadData];
}

-(void)viewDidUnload {
    [super viewDidUnload];
    finishButton_ = nil;
}

- (void)gotoBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoSave{
    if([areaCodeField.text length] > 0 && [areaCodeField.text length] <=6){
        [settingModel setResidentAreaCode: areaCodeField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc{
    [SkinHandler removeRecursively:self];
}

#pragma UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    SettingCellType type = Default_Cell;
    if (row == 1) {
        type = TextFieldTypeCell;
    }
    RoundedCellBackgroundViewPosition position = [tableView cellPositionOfIndexPath:indexPath];
    SettingCellView *cell;
    cell = [[SettingCellView alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"" withCellType:type cellPosition:position];
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
    switch (row) {
        case 0:
        {
            cell.textLabel.text = NSLocalizedString(@"Country or region",@"");
            cell.detailTextLabel.text = [[PhoneNumber sharedInstance] getAreaCountryInfo];//NSLocalizedString(@"CN(+86)",@"");
            break;
        }
        case 1:
        {
            SettingCellView *settingCell = (SettingCellView *)cell;
            settingCell.textLabel.text = NSLocalizedString(@"Area code",@"");
            settingCell.rightTextField.text =[settingModel residentAreaCode]; //NSLocalizedString(@"021",@"");
            settingCell.rightTextField.placeholder =  NSLocalizedString(@"/",@"");
            [settingCell.rightTextField setValue:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"]
                                      forKeyPath:@"_placeholderLabel.textColor"];
            self.areaCodeField = settingCell.rightTextField;
            settingCell.delegate = self;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([SmartDailerSettingModel isChinaSim]) {
        return 2;
    }else{
        return 3;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60;
}
#pragma SettingCellDelegate
- (void)textChanged:(NSString *)text withKey:(NSString *)key{
    BOOL hidden = (text == nil || [text length] == 0);
    finishButton_.hidden = hidden;
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_KEYBOARD_TEXTFIELD
                                                        object:nil
                                                      userInfo:nil];
} 

@end
