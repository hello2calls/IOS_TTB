//
//  RootScrollViewController.m
//  TouchPalDialer
//
//  Created by Scyuan on 14-7-2.
//
//

#import "RootScrollViewController.h"
#import "RootScrollView.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerViewController.h"
#import "ContactViewController.h"
#import "FavorViewController.h"
#import "RootTabBar.h"
#import "UserDefaultKeys.h"
#import "FeatureGuideTipsController.h"
#import "TPDialerResourceManager.h"
#import "UIDevice+SystemVersion.h"
#import "SkinHandler.h"
#import "AdvancedCalllog.h"
#import "CallAndDeleteBar.h"
#import "GestureUnRecognizerBar.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"
#import "WebSearchConstants.h"
#import "CallViewController.h"
#import "UpdateService.h"
#import "YellowPageMainTabController.h"
#import "TaskBonusManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "CheckboxAlertViewHandler.h"
#import "TouchPalDialerLaunch.h"
#import "EdurlManager.h"
#import "TPAdControlRequestParams.h"
#import "PersonalCenterViewController.h"

@interface RootScrollViewController ()<UIGestureRecognizerDelegate>{
	NSUInteger selectedIndex_;
    UIView* blockTabSelectionView_;
}
@property (nonatomic, retain) UIViewController *currentViewController;
-(void)onInitialDataCompleted;
@end


@implementation RootScrollViewController
@synthesize tabBar = tabBar_;
@synthesize viewControllers = viewControllers_;

- (void)viewDidLoad
{
    cootek_log(@"begin RootScrollViewController viewDidLoad***********");
	[super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    selectedIndex_ = 1;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
	DialerViewController *dialerViewController = [[DialerViewController alloc] init];
    dialerViewController.parent = self;
	ContactViewController *contactViewController = [[ContactViewController alloc] init];
    
    contactViewController.view.frame = CGRectMake(0, 0,TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    PersonalCenterViewController *yellowPageViewController = [[PersonalCenterViewController alloc] init];

    yellowPageViewController.view.frame = CGRectMake(TPScreenWidth()*2, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
	NSArray *tmpViewControllers = [[NSArray alloc] initWithObjects:
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"contactViewController_tabBar_style",@"style",
                                    NSLocalizedString(@"Contact_", @""),@"text_for_tab",
                                    contactViewController, @"viewController",
                                    [NSNumber numberWithInt:1], @"weight",
                                    nil],
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"dialerViewController_tabBar_style",@"style",
                                    NSLocalizedString(@"Dialpad_", @""),@"text_for_tab",
                                    dialerViewController, @"viewController",
                                    [NSNumber numberWithInt:1], @"weight",
                                    nil],
                                   [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"favorViewController_tabBar_style",@"style",
                                    NSLocalizedString(@"YellowPage_", @""),@"text_for_tab",
                                    yellowPageViewController, @"viewController",
                                    [NSNumber numberWithInt:1], @"weight",
                                    nil],nil];
    self.viewControllers = tmpViewControllers;
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
    
    UIBarButtonItem *tmpBackBar = [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target: nil
                                                                  action: nil];
	self.navigationItem.backBarButtonItem = tmpBackBar;
    
    RootTabBar *rootBar = [[RootTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-TAB_BAR_HEIGHT,
                                                                       self.view.frame.size.width, TAB_BAR_HEIGHT)];
    //rootBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    rootBar.delegate = self;
    rootBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [rootBar loadItemWithCount:viewControllers_.count];
    [rootBar setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
    
    self.tabBar = rootBar;
    [tabBar_ setBackgroundColor:[UIColor whiteColor]];
    
    blockTabSelectionView_ = [[UIView alloc] initWithFrame:tabBar_.frame];
    blockTabSelectionView_.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:tabBar_];
    [self.view addSubview:blockTabSelectionView_];
    
    self.rootView = [[RootScrollView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff())];
    _rootView.rootTabBarView = rootBar;
    rootBar.rootScrollView = _rootView;
    [self.view addSubview:_rootView];
    [self.tabBar firstSelectButtonAtIndex:1];
    [self loadViewControllerFromIndex:1];
    
    cootek_log(@"end RootTabViewController viewDidLoad***********");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRootTabBar) name:N_SHOW_ROOT_TAB_BAR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideRootTabBar) name:N_HIDE_ROOT_TAB_BAR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadOtherPage) name:N_CALL_LOG_LIST_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backRootAndToast) name:@"interCallBackRoot" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScroll) name:N_DIALER_INPUT_EMPTY object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScroll) name:N_DIALER_INPUT_NOT_EMPTY object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScroll) name:N_KEYBOARD_NOT_USED object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScroll) name:N_KEYBOARD_USED object:nil];
    [[TouchPalDialerLaunch getInstance] registerForStatusBarChange:tabBar_];
    [[TouchPalDialerLaunch getInstance] registerForStatusBarChange:blockTabSelectionView_];
    [[TouchPalDialerLaunch getInstance] registerForStatusBarChange:self.dialViewController.callDeleteBar];
    [[TouchPalDialerLaunch getInstance] registerForStatusBarChange:_rootView];
}

- (void)loadOtherPage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadViewControllerFromIndex:2];
        [self loadContactView];
    });
}

- (void)loadViewControllerFromIndex:(NSInteger)index {
    NSDictionary* data = [self.viewControllers objectAtIndex:index];
    UIViewController* viewController = [data objectForKey:@"viewController"];
    [_rootView addSubview:viewController.view];
    [self addChildViewController:viewController];
}

- (void)showRootTabBar
{
    if (self.tabBar.hidden) {
        self.tabBar.hidden = NO;
    }
    if (selectedIndex_ == 2) {
        _rootView.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
        //[self enableScroll];
        PersonalCenterViewController *tmpYellowPage = [[viewControllers_ objectAtIndex:2] objectForKey:@"viewController"];
        tmpYellowPage.view.frame = CGRectMake(TPScreenWidth()*2, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    }
}

- (void)hideRootTabBar
{
    if (selectedIndex_ == 2) {
        self.tabBar.hidden = YES;
        _rootView.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()+TPHeaderBarHeightDiff());
        //[self disableScroll];
        PersonalCenterViewController *tmpYellowPage = [[viewControllers_ objectAtIndex:2] objectForKey:@"viewController"];
        tmpYellowPage.view.frame = CGRectMake(TPScreenWidth()*2, 0, TPScreenWidth(), TPAppFrameHeight()+TPHeaderBarHeightDiff());
//        tmpYellowPage.web_view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight()-TPHeaderBarHeight()+TPHeaderBarHeightDiff());
    }
}

//- (void)enableScroll {
//    if (self.tabBar.hidden) {
//        return;
//    }
//    _rootView.scrollEnabled = YES;
//}
//
//- (void)disableScroll {
//    _rootView.scrollEnabled = NO;
//}

-(void) loadContactView {
    BOOL isDataReady = [TouchPalDialerLaunch getInstance].isDataInitialized;
    if (isDataReady) {
        [self onInitialDataCompleted];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onInitialDataCompleted)
                                                     name:N_INITIAL_DATA_COMPLETED
                                                   object:nil];
    }
}

-(void) onInitialDataCompleted
{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(onInitialDataCompleted) withObject:nil waitUntilDone:YES];
        return;
    }
    [blockTabSelectionView_ removeFromSuperview];
    blockTabSelectionView_ = nil;
    NSDictionary* data = [self.viewControllers objectAtIndex:0];
    UIViewController* viewController = [data objectForKey:@"viewController"];
    [_rootView addSubview:viewController.view];
    [self addChildViewController:viewController];
}

- (void) selectTabIndex:(NSInteger)index{
    [self.tabBar selectTabAtIndex:index];
}

- (NSInteger)getCurrentTabIndex {
    return _rootView.contentOffset.x / TPScreenWidth();
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [tabBar_ rootViewAppear];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [tabBar_ rootViewDisappear];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [[TPDialerResourceManager sharedManager]makeSureStatusBarChanged];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    if ([self getSelectedControllerIndex] == 1 && [UserDefaultsManager stringForKey:APP_TASK_BONUS defaultValue:@""].length > 0) {
        NSString *bonus = [UserDefaultsManager stringForKey:APP_TASK_BONUS] ;
        NSInteger type = [UserDefaultsManager intValueForKey:APP_TASK_BONUS_ALERT_ID defaultValue:0];
        
        if ( type == 0 )
            [DefaultUIAlertViewHandler showAlertViewWithTitle:bonus message:nil dismissIn:5];
        else if ( type == 1 )
            [CheckboxAlertViewHandler showAlertTitle:bonus andKey:TASK_BONUS_DAILY_ALERT];
        else if ( type == 2 ){
            UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
            [uiWindow makeToast:bonus duration:2.0f position:CSToastPositionUpKeyboard];
        }
        
        [UserDefaultsManager setObject:@"" forKey:APP_TASK_BONUS];
        [UserDefaultsManager setIntValue:0 forKey:APP_TASK_BONUS_ALERT_ID];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.navigationController.viewControllers.count == 1) {//关闭主界面的右滑动{
        return NO;
    } else {
        return YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    blockTabSelectionView_ = nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.contactViewController = nil;
    self.dialViewController = nil;
    self.filterViewController = nil;
    self.currentViewController = nil;
}

#pragma mark RootTabBarDelegate

- (NSDictionary *)attrForTabAtIndex:(NSUInteger)index
{
    return [viewControllers_ objectAtIndex:index];
}

- (int)getSelectedControllerIndex
{
	return selectedIndex_;
}

- (void)customTabBar:(RootTabBar*)customTabBar clickedButtonAtIndex:(NSUInteger)buttonIndex
{
    if(selectedIndex_ == buttonIndex)
        return;
    if (selectedIndex_ == 2 && buttonIndex != 2) {
        [[EdurlManager instance] removeAllNewsRecordWithCloseType:SWITCH_TAB];
    }
    selectedIndex_ = buttonIndex;
    if(buttonIndex != 1){
        //when changed to another view, the dialerViewController in editting state should quit
        DialerViewController * tmpDialer = [[viewControllers_ objectAtIndex:1] objectForKey:@"viewController"];
        [tmpDialer onClickFilter:AllCallLogFilter];
        [tmpDialer exitEditingMode];
        [self.dialViewController.longGestureController exitLongGestureModeWhenScrollView];
        [self.dialViewController.search_result_viewcontroller.longGestureController exitLongGestureModeWhenScrollView];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_HIDE_UNREGN_BAR object:nil userInfo:nil];
    }
    if(buttonIndex != 0){
        //when changed to another view, the dialerViewController in editting state should quit
        ContactViewController * tmpDialer = [[viewControllers_ objectAtIndex:0] objectForKey:@"viewController"];
        [tmpDialer exitEditingMode];
        [self.contactViewController.longGestureController exitLongGestureModeWhenScrollView];
        [self.contactViewController.search_result_controller.longGestureController exitLongGestureModeWhenScrollView];
        [self.filterViewController.longGestureController exitLongGestureModeWhenScrollView];
    }
    if(selectedIndex_ == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_SELECTED_YELLOWPAGE object:nil userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_UNSELECTED_YELLOWPAGE object:nil userInfo:nil];
    }
}

- (void)removeCurrentTabViewController
{
    if (self.currentViewController == nil) {
        return;
    }
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
    self.currentViewController = nil;
}

- (void)insertTabViewController:(UIViewController *)childController
{
    if (childController == nil) {
        return;
    }
    [self addChildViewController:childController];
    [self.view insertSubview:childController.view belowSubview:tabBar_];
    [childController didMoveToParentViewController:self];
    self.currentViewController = childController;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.navigationController.viewControllers.count == 1)//关闭主界面的右滑返回
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(void)backRootAndToast{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBar selectTabAtIndex:1];
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow makeToast:INTERNATIONAL_CALL_OK duration:1.5f position:CSToastPositionBottom];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if ([[UIDevice currentDevice].systemVersion intValue] >= 7) {
        tabBar_.frame = CGRectMake(0, TPAppFrameHeight()-TAB_BAR_HEIGHT + TPHeaderBarHeightDiff(), TPScreenWidth(), TAB_BAR_HEIGHT);
    } else {
        if (![[UIApplication sharedApplication] isStatusBarHidden]) {
            tabBar_.frame = CGRectMake(0, TPAppFrameHeight()-TAB_BAR_HEIGHT, TPScreenWidth(), TAB_BAR_HEIGHT);
        } else {
            tabBar_.frame = CGRectMake(0, TPAppFrameHeight()-TAB_BAR_HEIGHT - 20, TPScreenWidth(), TAB_BAR_HEIGHT);
            self.rootView.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT + TPHeaderBarHeightDiff() - 20);
            return;
        }
    }
    self.rootView.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT + TPHeaderBarHeightDiff());
    
}
@end
