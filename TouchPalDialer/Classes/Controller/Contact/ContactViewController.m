//
//  ContactViewController.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "ContactViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "consts.h"
#import "CootekNotifications.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "FunctionUtility.h"
#import "UIView+WithSkin.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "ExpandableListView.h"
#import "SmartGroupNode.h"
#import "HeadTabBar.h"
#import "TPABPersonActionController.h"
#import "GroupOperationCommandCreator.h"
#import "PullDownSheet.h"
#import "CommonSettingViewController.h"
#import "SettingsModelCreator.h"
#import "PersonalCenterController.h"
#import "DialerUsageRecord.h"
#import "NoahManager.h"
#import "NotificationAlertManger.h"
#import "ContactNoPermissionView.h"
#import "UserDefaultsManager.h"
#import "ContactCacheDataManager.h"
#import "RootScrollViewController.h"
#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"

#define SMART_GROUP_NODE (0)

@implementation ContactViewController {
    BOOL _afterFirstLoad;
    UIView *_indicatorHolderView;
    UIImageView *_indicatorView;
    TPHeaderButton *tmpOperationMember;
    TPHeaderButton *filterButton;
    CABasicAnimation *_rotationAnimation;
}

@synthesize groupList;
@synthesize operation_button;
@synthesize segment_touchpaler;
@synthesize segment_all;
@synthesize segment_group;
@synthesize all_controller;
@synthesize titleBar = titleBar_;
@synthesize menu;
@synthesize menuGroup;
@synthesize menuSmart;
@synthesize menuAll;
@synthesize editButton;
@synthesize backButton;

+(instancetype  )getContactCenterVC{
    if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]==nil) {
        return nil;
    }
    UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    [navigationController popToRootViewControllerAnimated:YES];
    RootScrollViewController *root = [[TouchPalDialerAppDelegate naviController].viewControllers objectAtIndex:0];
    [root selectTabIndex:0];
    UIViewController *contactController =[root.viewControllers[0] objectForKey:@"viewController"];
    return (ContactViewController *)contactController;
}

- (void)loadView {
    current_page_index = ContactPageIndexNone;
    
    // rootView
	UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff())];
    self.view = rootView;
    [rootView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];
//	rootView.backgroundColor = [UIColor clearColor];
    
	/// HeaderBar
	HeaderBar *header = [[HeaderBar alloc] initHeaderBar];
    [header setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
	[self.view addSubview:header];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = NSLocalizedString(@"Contact",@"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleBar_ = titleLabel;
    [header addSubview:titleLabel];

    tmpOperationMember = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-50, 0, 45, 45)];
    tmpOperationMember.ifHighlight = YES;
    [tmpOperationMember setSkinStyleWithHost:self forStyle:@""];
    tmpOperationMember.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    [tmpOperationMember setTitle:@"g" forState:UIControlStateNormal];
    tmpOperationMember.selected = NO;
    [tmpOperationMember addTarget:self action:@selector(onClickOperateButton) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:tmpOperationMember];
    self.operation_button  = tmpOperationMember;

    PullDownSheet *sheet = [[PullDownSheet alloc] initWithContent:nil];
    sheet.delegate = self;
    self.pullDownSheet = sheet;

    self.all_controller = nil;
    //   self.circle_controller = nil;
    [self onClickAtIndexBar:ContactPageIndexAll];
    
    //for smart filter
    self.all_controller.restoreViewLocationDelegate = self;
    //set tab key-value for expandable list
    
    ExpandableListView* expandableList = [[ExpandableListView alloc] initWithFrame:CGRectMake(0, 20 - TPHeaderBarHeightDiff(), LEFT_DRAWER_WIDTH, TPAppFrameHeight() + TPHeaderBarHeightDiff())];
    expandableList.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    expandableList.cellCreator = [[InnerCellContentViewCreator alloc] init];
    expandableList.dataContainer = self.all_controller;
    NSArray *tmpNodeSet = [[NSArray alloc] initWithObjects:[SmartGroupNode smartGroupNodeWithDelegate:expandableList], nil];
    NSArray *tmpNodeKey = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Smart group", @""), nil];
    [expandableList setNodeSet:tmpNodeSet keySet:tmpNodeKey];
    expandableList.rootNode = tmpNodeSet[SMART_GROUP_NODE];

    groupList = expandableList;
    
    filterButton = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, -TPHeaderBarHeightDiff(),45, 45)];
    filterButton.ifHighlight = YES;
    [filterButton setSkinStyleWithHost:self forStyle:@""];
    filterButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:24];
    [filterButton setTitle:@"a" forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(onClickContactsFilter) forControlEvents:UIControlEventTouchUpInside];
    
    UINavigationController *navController =
    ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
    
    UIViewController *rootVC = navController.viewControllers[0];
    
    filterView = [[PushRightView alloc] initWithButton:filterButton
                                           movableView:rootVC.view
                                             belowView:expandableList
                                        remainingWidth:TPScreenWidth() - LEFT_DRAWER_WIDTH];
    filterView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    //edit button
    CGSize buttonSize = CGSizeMake(50, 45);
    CGRect buttonFrame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    editButton = [[TPHeaderButton alloc] initWithFrame:buttonFrame];
    [editButton addTarget:self action:@selector(onClickEditButton) forControlEvents:UIControlEventTouchUpInside];
    
    [editButton setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    [editButton setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    UIColor *htColor =[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
    [editButton setTitleColor:htColor forState:UIControlStateHighlighted];
    
    backButton = [[TPUIButton alloc] initWithFrame:editButton.frame];
    [backButton applySkinWithStyle:@"default_backButton_style"];
    [backButton setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [backButton addTarget:self action:@selector(onClickEditButton) forControlEvents:UIControlEventTouchUpInside];
    backButton.hidden = YES;
    
    UIView *buttonHolder = [[UIView alloc] initWithFrame:editButton.frame];
    editButton.frame = buttonFrame;
    backButton.frame = buttonFrame;
    
    // view tree of buttonHolder
//    [FunctionUtility setBorderForView:editButton colorStyle:@"tp_color_green_500"];
//    [FunctionUtility setBorderForView:backButton colorStyle:@"tp_color_red_500"];
//    [FunctionUtility setBorderForView:buttonHolder colorStyle:@"tp_color_blue_500"];
    
    [buttonHolder addSubview:backButton];
    [buttonHolder addSubview:editButton];

    // view tree: header
    [header addSubview:buttonHolder];
    
    groupList.filterView = filterView;
    
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] ){
        current_page_index = ContactPageIndexAll;
        
        ContactNoPermissionView *permissionView = [[ContactNoPermissionView alloc]initWithFrame:CGRectMake(0, 45+TPHeaderBarHeightDiff(), TPScreenWidth(), TPScreenHeight()-65-TAB_BAR_HEIGHT)];
        [permissionView setSkinStyleWithHost:self forStyle:@""];
        [self.view addSubview:permissionView];
    }
    
    [self setUpdatingContactsIndicatorHidden:YES];
    
}
-(NSMutableArray *)array{
    if (_array == nil) {
        self.array = [NSMutableArray arrayWithCapacity:0];
    }
    return self.array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
    
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return;
    
    UIView *gestureView = [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeight(), 10, TPScreenHeight()-TAB_BAR_HEIGHT)];
    [self.view addSubview:gestureView];
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMoveHandler:)];
    [gestureView addGestureRecognizer:panGes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNoahToast) name:N_NOAH_LOAD_CONFIG_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiBecomeActive) name:N_APPLICATION_BECOME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactReload:) name:N_CONTACT_TRANSFER_CONTACTS_RELOADED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactReload:) name:N_CONTACT_TRANSFER_CONTACTS_RELOADING object:nil];
}

#pragma mark Noah
- (void)onNotiBecomeActive{
    [self getNoahToast];
    [self checkToShowLoadingView];
}

- (void)getNoahToast{
    if (![NoahManager isReady]) {
        cootek_log(@"Dialer trying to get toast but not noah not ready");
        return;
    }
    cootek_log(@"Contact page is going to get noah toast");
}

- (void)onClickContactsFilter{
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    if ([all_controller.longGestureController inLongGestureMode]) {
        [all_controller.longGestureController exitLongGestureMode];
    }
    if ([all_controller.contactsDisplayViewWithNoAZScrollist.longGestureController inLongGestureMode]) {
        [all_controller.contactsDisplayViewWithNoAZScrollist.longGestureController exitLongGestureMode];
    }
    [filterView moveToRight];
    if (groupList.loadDataCount == 0) {
        [groupList.tableView reloadData];
    }
}

- (void) onClickEditButton {
    if (self.all_controller.leafNodeFromFilter != nil) {
        [self onClickContactsFilter];
    } else {
        [[GroupOperationCommandCreator commandForType:CommandTypeDeleteContact withData:nil] onClickedWithPageNode:self.all_controller.leafNodeFromFilter withPersonArray:all_controller.personArray];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	cootek_log(@"==TAB== Contact view will appear.");
    [all_controller clearSectionIndexView];
    [all_controller refreshView];
    [self exitEditingMode];
    [self checkToShowLoadingView];
    [super viewWillAppear:animated];
}

- (void) checkToShowLoadingView {
    if (!_indicatorHolderView.hidden) {
        [_indicatorView.layer removeAllAnimations];
        [_indicatorView.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];
    }
}

- (void) onContactReload:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = noti.name;
        if ([name isEqualToString:N_CONTACT_TRANSFER_CONTACTS_RELOADED]) {
            [self setUpdatingContactsIndicatorHidden:YES];
        } else if ([name isEqualToString:N_CONTACT_TRANSFER_CONTACTS_RELOADING]) {
            [self setUpdatingContactsIndicatorHidden:NO];
        }
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
    cootek_log(@"Received memory warning in ContactViewController.");
}

- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark click button action.
- (void)onClickAddButton {
    if ([all_controller.longGestureController inLongGestureMode]) {
        [all_controller.longGestureController exitLongGestureMode];
    }
    if ([all_controller.search_result_controller.longGestureController inLongGestureMode]) {
        [all_controller.search_result_controller.longGestureController exitLongGestureMode];
    }
    if ([all_controller.contactsDisplayViewWithNoAZScrollist.longGestureController inLongGestureMode]) {
        [all_controller.contactsDisplayViewWithNoAZScrollist.longGestureController exitLongGestureMode];
    }
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [[TPABPersonActionController controller] addNewPersonPresentedBy:aViewController];
}

- (void)onClickOperateButton {
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    if ([all_controller.longGestureController inLongGestureMode]) {
        [all_controller.longGestureController exitLongGestureMode];
    }
    if ([all_controller.search_result_controller.longGestureController inLongGestureMode]) {
        [all_controller.search_result_controller.longGestureController exitLongGestureMode];
    }
    if ([all_controller.contactsDisplayViewWithNoAZScrollist.longGestureController inLongGestureMode]) {
        [all_controller.contactsDisplayViewWithNoAZScrollist.longGestureController exitLongGestureMode];
    }
    self.operation_button.selected = YES;
    [all_controller.m_searchbar resignFirstResponder];
    if (all_controller.leafNodeFromFilter == nil) {
        sheetType = OperationSheetTypeAddContacts;
        
    } else if ([all_controller.leafNodeFromFilter isKindOfClass:[GroupNode class]]){
        if (all_controller.leafNodeFromFilter.nodeDescription == NSLocalizedString(@"Ungrouped", @"Ungrouped")) {
            sheetType = OperationSheetTypeSmartGroup;
        } else {
            sheetType = OperationSheetTypeMyGroup;
        }
    } else {
        sheetType = OperationSheetTypeSmartGroup;
    }
    
    [self.pullDownSheet clearAllBtns];
    for(NSString *title in [GroupOperationCommandCreator getCommandList:sheetType withContacts:[all_controller haveContacts] withPhones:[all_controller havePhoneNumbers]]){
        [self.pullDownSheet addContentTitle:title ifNeedToast:NO andKey:nil];
    }
    
    [self.view addSubview:self.pullDownSheet];
}

- (void)exitEditingMode
{
    [self removePullDownSheet];
}

- (void)doClickOnPullDownSheet:(int)index
{

    NSArray *title =[GroupOperationCommandCreator getCommandList:sheetType withContacts:[all_controller haveContacts] withPhones:[all_controller havePhoneNumbers]];
    if (index < title.count) {
        [GroupOperationCommandCreator executeCommandWithTitle:title[index] AndCurrentNode:self.all_controller.leafNodeFromFilter withPersonArray:all_controller.personArray];
    }
    if (index == title.count) {
        CommonSettingViewController *vc = [[CommonSettingViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (void)removePullDownSheet
{
    self.operation_button.selected = NO;
    [self.pullDownSheet removeFromSuperview];
}

- (void)onClickAtIndexBar:(NSInteger)index{
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return;
    //!isForce &&
    if ( current_page_index == index) {
        return;
    }
    current_page_index = index;
    switch (current_page_index) {
        case ContactPageIndexAll:
            
            filterView.hidden = NO;
            cootek_log(@"ContactPageIndexAll");
            segment_touchpaler.enabled = YES;
            segment_all.enabled = NO;
            segment_group.enabled = YES;
            
            if (!all_controller) {
                AllViewController *tmpAllViewController= [[AllViewController alloc] init];
                [self.view addSubview:tmpAllViewController.view];
                self.all_controller = tmpAllViewController;
                all_controller.parentViewController1 = self;
            }
            all_controller.view.hidden = NO;
            [all_controller refreshView];
            break;
        case ContactPageIndexGroup:
            filterView.hidden = NO;
            [all_controller.m_searchbar resignFirstResponder];
            cootek_log(@"ContactPageIndexGroup");
            segment_touchpaler.enabled = YES;
            segment_all.enabled = YES;
            segment_group.enabled = NO;
            
            all_controller.view.hidden = YES;
            break;
        default:
            cootek_log(@"unknown pageType in ContactViewController->switchPage");
            break;
    }
}

-(void)restoreViewLocation{
    [filterView restoreViewLocation];
}

-(void)bringFilterViewToFront{
    [self.view bringSubviewToFront:filterView];
}

- (void)panMoveHandler:(UIPanGestureRecognizer *)gesture{
    
    CGPoint point = [gesture translationInView:self.view];
    if (point.x >= 0 && point.x <= 10 && point.y >= -5 && point.y<= 5 ) {
        [self onClickContactsFilter];
    }
}

- (void) setUpdatingContactsIndicatorHidden:(BOOL)toHide {
    if (!_indicatorHolderView) {
        CGRect holderFrame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPScreenHeight()- TPHeaderBarHeight());
        // container
        _indicatorHolderView = [[UIView alloc] initWithFrame:holderFrame];
        _indicatorHolderView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"defaultCellBackground_color"];
        
        // loading label
        UILabel *loadingLabel = [[UILabel alloc]
                initWithTitle:NSLocalizedString(@"contact_transfer_view_loading", @"正在更新，请稍后") fontSize:13];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.font = [UIFont systemFontOfSize:12];
        loadingLabel.textColor = [TPDialerResourceManager getColorForStyle:@"defaultCellDetailText_color"];
        
        // loading image view
        CGSize indicatorSize = CGSizeMake(33, 33);
        
        CGFloat gY = (TPScreenHeight() - loadingLabel.frame.size.height - indicatorSize.height) / 2;
        gY -= TPHeaderBarHeight();
        UIImage *loadingImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"loading_circle@2x.png"];
        _indicatorView = [[UIImageView alloc] initWithImage:loadingImage];
        _indicatorView.frame = CGRectMake(
                                          (TPScreenWidth() - indicatorSize.width)/2,
                                          gY,
                                          indicatorSize.width,
                                          indicatorSize.height);
        _indicatorView.contentMode = UIViewContentModeScaleAspectFit;
        
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        _rotationAnimation.duration = 1;
        _rotationAnimation.repeatCount = HUGE_VALF;
        gY += _indicatorView.frame.size.height;
        
        gY += 10;
        CGSize labelSize = loadingLabel.frame.size;
        loadingLabel.frame = CGRectMake((TPScreenWidth() - labelSize.width) / 2, gY,
                                        labelSize.width, labelSize.height);
        cootek_log(@"loadingLabel, size: %@", NSStringFromCGRect(loadingLabel.frame));
        // view tree setup
        [_indicatorHolderView addSubview:_indicatorView];
        [_indicatorHolderView addSubview:loadingLabel];
        
        // skinify
        [[TPDialerResourceManager sharedManager] addSkinHandlerForView:_indicatorHolderView];
        
        // add to self.view
        [self.view addSubview:_indicatorHolderView];
    }
    
    if (toHide) {
        // hide the loading view
        all_controller.view.hidden = NO;
        tmpOperationMember.hidden = NO;
        filterButton.hidden = NO;
        if (_indicatorView) {
            [_indicatorView.layer removeAllAnimations];
        }
        if (_indicatorHolderView) {
            _indicatorHolderView.hidden = YES;
        }
    } else {
        // show the loading view
        all_controller.view.hidden = YES;
        tmpOperationMember.hidden = YES;
        filterButton.hidden = YES;
        if (_indicatorHolderView) {
            _indicatorHolderView.hidden = NO;
        }
        if (_indicatorView) {
            [_indicatorView.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];
        }
    }
}


@end
