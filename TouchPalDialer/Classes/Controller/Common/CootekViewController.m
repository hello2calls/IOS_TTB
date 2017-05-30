//
//  CootekViewController.m
//  TouchPalDialer
//
//  Created by Sendor on 12-3-29.
//  Refactored by Chen Lu
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CootekViewController.h"
#import "TPHeaderButton.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "YellowPageMainQueue.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UserDefaultsManager.h"
#import "TPDialerResourceManager.h"

@interface CootekViewController(){
    NSString* __strong headerTitle_;
}

@end

@implementation CootekViewController
@synthesize headerBar = headerBar_;
@synthesize backButton = backButton_;
@synthesize headerTitleLabel = titleLabel_;
- (id)init
{
    self = [super init];
    if (self) {
        headerTitle_ = NSLocalizedString(@"Now loading", @"");
    }
    return self;
}

-(NSString *)headerTitle
{
    return headerTitle_;
}

-(NSString*) controllerId {
    return headerTitle_;
}

-(void)setHeaderTitle:(NSString *)headerTitle
{
    headerTitle_ = headerTitle;
    titleLabel_.text = headerTitle_;
}

- (void)loadView
{
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()+TPHeaderBarHeightDiff())];
    self.view = rootView;
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff()-TPHeightBetweenIP4AndIP5(), TPScreenWidth(), TPScreenHeight()-TPHeaderBarHeightDiff()+TPHeightBetweenIP4AndIP5())];
    backGroundView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"CootekViewController_background_color"];
    backGroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView = backGroundView;
    [self.view addSubview:_backgroundView];
   
	//Header Bar
    HeaderBar* tmpHeaderBar = [[HeaderBar alloc] initHeaderBar] ;
    headerBar_.frame = CGRectMake(0, TPHeaderBarHeightDiff(), TPScreenWidth(), 45);
//    tmpHeaderBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    tmpHeaderBar.autoresizesSubviews = YES;
    
    headerBar_ = tmpHeaderBar;
    [self.view addSubview:tmpHeaderBar];
    if (self.headerBackgroundImage) {
        headerBar_.bgView.image = self.headerBackgroundImage;
    }
    
    // Title Label
    titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(90, TPHeaderBarHeightDiff(), TPScreenWidth() - 180, 45)];
   
    titleLabel_.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    titleLabel_.textAlignment = NSTextAlignmentCenter;
    titleLabel_.backgroundColor = [UIColor clearColor];
    titleLabel_.text = headerTitle_;
    titleLabel_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[headerBar_ addSubview:titleLabel_];
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if(isVersionSix) {
    // back button
    UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
    TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
    backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
    [backBtn setTitle:@"0" forState:UIControlStateNormal];
    [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
    [backBtn setTitleColor:tColor forState:UIControlStateNormal];
    backBtn.autoresizingMask = UIViewAutoresizingNone;
    [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [headerBar_ addSubview:backBtn];
    backButton_ = backBtn;
    }
    else {
        //Back Button
        TPHeaderButton *tmpBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        cootek_log(@"wallet, %@", NSStringFromCGRect(tmpBtn.titleLabel.frame));
        tmpBtn.autoresizingMask = UIViewAutoresizingNone;
        [tmpBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headerBar_ addSubview:tmpBtn];
        backButton_ = tmpBtn;
    }
    
    if (!self.skinDisabled) {
        [self setSkin];
    } else {
        // no skin
        [self.backButton setTitle:@"0" forState:UIControlStateNormal];
        UILabel *backLabel = self.backButton.titleLabel;
        backLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backLabel adjustSizeByFillContent];
        
        if (self.headerTextColor) {
            self.headerTitleLabel.textColor = self.headerTextColor;
            
            [self.backButton setTitleColor:self.headerTextColor forState:UIControlStateNormal];
            [self.backButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"] forState:UIControlStateHighlighted];
        }
    }
}

- (void) resetHeaderFrame
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ((orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) && [[UIApplication sharedApplication] isStatusBarHidden])
    {
        titleLabel_.frame = CGRectMake(90, 0, TPScreenWidth() - 180, 45);
        backButton_.frame = CGRectMake(0, 0, 50, 45);
    } else {
        titleLabel_.frame = CGRectMake(90, TPHeaderBarHeightDiff(), TPScreenWidth() - 180, 45);
        backButton_.frame = CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45);
    }
    
}

- (UIView *)getBackGroundView {
    return _backgroundView;
}

-(void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)gotoBack
{
    [[TouchPalDialerAppDelegate naviController]popViewControllerAnimated:YES];
}

- (void)setSkin{
    
    [headerBar_     setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [titleLabel_    setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];

    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        titleLabel_.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
        [backButton_ setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"] forState:UIControlStateNormal ] ;

    } else {
        [backButton_    setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    }
}

- (void) showInNavigationController:(UINavigationController*) navController {
    UIViewController* visibleController = navController.visibleViewController;
    if([visibleController isKindOfClass:[CootekViewController class]]) {
        if([((CootekViewController*)visibleController).controllerId isEqualToString:self.controllerId]) {
            // already the top controller
            return;
        }
    }
    
    //NOTE: might cause problems in the future, if later we change to use different navigation controllers instead of
    // tpappdelegate's active navigationcontroller. 
    if(visibleController.navigationController != navController) {
        [navController dismissViewControllerAnimated:NO completion:^(){}];
    }
    
    for(id c in navController.viewControllers) {
        if([c isKindOfClass:[CootekViewController class]]) {
            CootekViewController* vc = (CootekViewController*) c;
            if(vc.controllerId != nil && [vc.controllerId isEqualToString:self.controllerId]) {
                [navController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    
    [navController pushViewController:self animated:YES];
}

- (void)dealloc
{
    [SkinHandler removeRecursively:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    cootek_log(@"viewDidLoad: %@",self.class);
}

@end
