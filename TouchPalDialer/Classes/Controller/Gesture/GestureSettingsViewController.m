//
//  GestureSettingsViewController.m
//  TouchPalDialer
//
//  Created by Admin on 6/5/13.
//
//


#import "GestureSettingsViewController.h"
#import "HeaderBar.h"
#import "CootekTableViewCell.h"
#import "CootekNotifications.h"
#import "GestureEditViewController.h"
#import "GesturePersonPickerViewController.h"
#import "GestureUtility.h"
#import "Person.h"
#import "PersonDBA.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "NSString+PhoneNumber.h"
#import "UIButton+DoneButton.h"
#import "GestureScrollView.h"
#import "GestureSinglePageView.h"
#import "GestureSinglePersonView.h"
#import "UserDefaultsManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIDevice+SystemVersion.h"

@interface GestureSettingsViewController (){
    BOOL isEditMode;
    GestureModel *gestureModel;
    UISwitch *_switch;
}

@property (nonatomic,weak) UIView *switchView;
@end

@implementation GestureSettingsViewController
@synthesize defaultType;
@synthesize gestureCustomList;
@synthesize editGestureButton;
@synthesize actionKey;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff()-TPHeightBetweenIP4AndIP5(), TPScreenWidth(), TPScreenHeight()-TPHeaderBarHeightDiff()+TPHeightBetweenIP4AndIP5())];
    [backGroundView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
    [self.view addSubview:backGroundView];
	// Do any additional setup after loading the view.
    //self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    // HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar] ;
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    
   
    // Label
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    [headerTitle setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.text = NSLocalizedString(@"Gesture dialing", @"");
	[headBar addSubview:headerTitle];
   
     
    // edit
    TPHeaderButton *tmpEdit = [[TPHeaderButton alloc] initWithFrame:CGRectMake(TPScreenWidth() - 55, 0, 50, 45)];
    [tmpEdit setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [tmpEdit addTarget:self action:@selector(editGestureSettings) forControlEvents:UIControlEventTouchUpInside];
    [tmpEdit setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    tmpEdit.titleLabel.font = [UIFont systemFontOfSize:16];
    tmpEdit.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    [headBar addSubview:tmpEdit];
    self.editGestureButton = tmpEdit;
    
    if(isVersionSix) {
        UIColor *tColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        headerTitle.textColor   = tColor;
        [self.editGestureButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"] forState:UIControlStateNormal];
        
        //BackButton
        tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:backBtn];

    } else {
    
        // BackButton
        TPHeaderButton *cancel_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [cancel_but setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [cancel_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:cancel_but];

    }

    
    
    [self.view addSubview:headBar];
    
    isEditMode = NO;
    gestureModel = [GestureModel getShareInstance];
    
    [self buildSwitchView];
    
    
//    //switch  
//    UILabel *switch_text = [[UILabel alloc] initWithFrame:CGRectMake(20, 54+TPHeaderBarHeightDiff(), 190, 30)];
//    switch_text.backgroundColor = [UIColor clearColor];
//    switch_text.adjustsFontSizeToFitWidth = YES;
//    switch_text.textColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"GestureEditViewController_addGestureButtonText_color" needCache:NO];
//    switch_text.text = NSLocalizedString(@"switch text", @"");
//    [switch_text setFont:[UIFont systemFontOfSize:FONT_SIZE_3]];
//    [self.view addSubview:switch_text];
//    
//    UIImageView *switch_line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 90+TPHeaderBarHeightDiff(), TPScreenWidth()-20, 1)];
//    switch_line.backgroundColor =[[TPDialerResourceManager sharedManager]
//                                   getResourceByStyle:@"GestureSettingSwitchLine_color" needCache:NO];
//    [self.view addSubview:switch_line];
//    
//    if ([UIDevice systemVersionLessThanMajor:7 minor:0])
//    {
//        _switch = [[UISwitch alloc] initWithFrame:CGRectMake(TPScreenWidth()-90, 52+TPHeaderBarHeightDiff(), 70, 20)];
//    } else {
//        _switch = [[UISwitch alloc] initWithFrame:CGRectMake(TPScreenWidth()-64, 52+TPHeaderBarHeightDiff(), 70, 20)];
//    }
//    [_switch setOn:gestureModel.isOpenSwitchGesture];
//    [_switch addTarget:self action:@selector(setSwitch:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_switch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noGesture)
                                                 name:N_GESTURE_NOGESTURE object:nil];

}

- (void)buildSwitchView{
    
    UIView *switchView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight() + 20, TPScreenWidth(), 60)];
        //switch
    UILabel *switch_text = [[UILabel alloc] init];
    switch_text.backgroundColor = [UIColor clearColor];
//    switch_text.adjustsFontSizeToFitWidth = YES;
    switch_text.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
    switch_text.text = NSLocalizedString(@"switch text", @"");
    [switch_text setFont:[UIFont systemFontOfSize:17]];
    [switch_text sizeToFit];
    switch_text.tp_x = 20;
    switch_text.tp_y = (60 - switch_text.tp_height) / 2;
    [switchView addSubview:switch_text];
    
    UIImageView *switch_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 1 / [UIScreen mainScreen].scale)];
    switch_line.backgroundColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
    [switchView addSubview:switch_line];
    
    UIImageView *switch_line_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, TPScreenWidth(), 1/ [UIScreen mainScreen].scale)];
    switch_line_bottom.backgroundColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
    [switchView addSubview:switch_line_bottom];

     _switch = [[UISwitch alloc] init];
    [_switch setOn:gestureModel.isOpenSwitchGesture];
    [_switch addTarget:self action:@selector(setSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    _switch.tp_x = TPScreenWidth() - _switch.tp_width - 20;
    _switch.tp_y = (60 - _switch.tp_height) / 2;
    [switchView addSubview:_switch];
    switchView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_color"];
    [self.view addSubview:switchView];
    self.switchView = switchView;
}

- (void)loadData
{
    self.gestureCustomList = [NSMutableArray arrayWithArray:[gestureModel.mGestureRecognier getGestureList]];
    
    if ([gestureCustomList count] == 0) {
        editGestureButton.hidden = YES;
        isEditMode = NO;
    }else {
        editGestureButton.hidden = !gestureModel.isOpenSwitchGesture;
    }
}

- (void) loadGrid
{
    NSInteger currentPage = 0;
    if (showArea) {
        currentPage = showArea.currentPage;
    }
    [showArea removeFromSuperview];
    showArea = [[GestureScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.switchView.frame), TPScreenWidth()*2, TPScreenHeight()-CGRectGetMaxY(self.switchView.frame))
                                                 isEdit:isEditMode
                                        WithCurrentPage:currentPage];
    showArea.hidden = !gestureModel.isOpenSwitchGesture;
    [self.view addSubview:showArea];
}

- (void)setSwitch:(UISwitch *)sender
{
    [self loadData];
    [gestureModel setIsOpenSwitchGesture:sender.on];
    editGestureButton.hidden = !sender.isOn|| ([gestureCustomList count] == 0);
    if (!sender.isOn && isEditMode)
    {
        isEditMode = NO;
        [editGestureButton setTitle:NSLocalizedString(@"Edit", @"")forState:UIControlStateNormal];
        [self updateLocalScrollViewDeleteButtonVisibility];
    }
    showArea.hidden = !sender.isOn;
    if (sender.isOn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_SETTING_CLOSE object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_SETTING_OPEN object:nil];
    }
}

- (void)noGesture
{
    isEditMode = NO;
    [editGestureButton setTitle:NSLocalizedString(@"Edit", @"")forState:UIControlStateNormal];
    editGestureButton.hidden = YES;
    [self loadGrid];
}

- (void)editGestureSettings
{
    if (!gestureModel.isOpenSwitchGesture) {
        isEditMode = NO;
        [editGestureButton setTitle:NSLocalizedString(@"Edit", @"")forState:UIControlStateNormal];
        editGestureButton.hidden = YES;
        return;
    }
    
    if ( [gestureCustomList count] == 0) {
        isEditMode = NO;
        [editGestureButton setTitle:NSLocalizedString(@"Edit", @"")forState:UIControlStateNormal];
        editGestureButton.hidden = YES;
        [self loadGrid];
        return;
    }
        
    isEditMode = !isEditMode;
    if (isEditMode == YES) {
        [editGestureButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    } else {
        [editGestureButton setTitle:NSLocalizedString(@"Edit", @"")forState:UIControlStateNormal];
    }
    [self updateLocalScrollViewDeleteButtonVisibility];
}

- (void)updateLocalScrollViewDeleteButtonVisibility
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[GestureScrollView class]]) {
            GestureScrollView *itemView = (GestureScrollView *)subView;
            [itemView setDeleteBtn: isEditMode];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}

- (void)gotoBack
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadData];
    [self loadGrid];
    cootek_log(@"viewWillAppear GestureSettingsViewController");
}

@end
