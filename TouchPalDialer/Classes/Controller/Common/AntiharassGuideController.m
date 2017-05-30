//
//  AntiHarassGuideController.m
//  TouchPalDialer
//
//  Created by siyi on 15/10/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AntiHarassGuideController.h"

#import "consts.h"
#import "UsageConst.h"
#import "DialerUsageRecord.h"
#import "UILayoutUtility.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "PredefCountriesUtil.h"
#import "TouchPalVersionInfo.h"
#import "SmartDailerSettingModel.h"

#import "TouchPalDialerAppDelegate.h"
#import "DefaultUIAlertViewHandler.h"
#import "CommonWebViewController.h"
#import "CootekNotifications.h"

#import "AntiharassmentViewController.h"

@implementation AntiharassGuideController {
    UIView *_pageContainer;
}

- (void) viewDidLoad {
    cootek_log(@"AntiHarassGuideController,%@, viewDidLoad",[self class]);
    [super viewDidLoad];
    CGFloat screenWidth = TPScreenWidth();
    CGFloat screenHeight = TPScreenHeight();
    
    // for iphone4 and iphone 4s
    CGFloat bottomMargin = 0.03f * screenHeight;
    CGFloat mainImageMargin = 0.04f * screenHeight;
    
    // for iphone 5 and higher
    if (isIPhone5Resolution()) {
        cootek_log(@"is iphone 5");
        bottomMargin = 0.05f * screenHeight;
        mainImageMargin = 0.06f * screenHeight;
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    // set page background color
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_lime_50"];
    
    // layouting from down to up
    // skip button
    UIFont *font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
    NSString *skipText = @"跳过>>";
    CGSize skipStringDimen = [skipText sizeWithFont:font];
    CGSize skipTextButtonDimen = CGSizeMake(skipStringDimen.width + 12 * 2, screenHeight * 0.05f);
    UIButton *skipTextButton = [[UIButton alloc] initWithFrame:CGRectMake((TPScreenWidth() - skipTextButtonDimen.width) / 2,
                                                TPScreenHeight() - (skipTextButtonDimen.height + bottomMargin),
                                            skipTextButtonDimen.width, skipTextButtonDimen.height)];
    skipTextButton.titleLabel.font = font;
    [skipTextButton setTitle:skipText forState:UIControlStateNormal];
    [skipTextButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"] forState:UIControlStateNormal];
    [skipTextButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_200"] forState:UIControlStateHighlighted];
    [skipTextButton setBackgroundColor:[UIColor clearColor]];
    skipTextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // start-use button
    CGSize startUseButtonDimen = CGSizeMake(screenWidth * 0.7f, screenHeight * 0.1f);
    UIButton *startUseButton =[[UIButton alloc] init];
    startUseButton.frame = CGRectMake((TPScreenWidth() - startUseButtonDimen.width) / 2,
                        skipTextButton.frame.origin.y - (0.02f * screenHeight + startUseButtonDimen.height),
                        startUseButtonDimen.width, startUseButtonDimen.height);
    
    startUseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [startUseButton setTitle:@"立即体验" forState:UIControlStateNormal];
    [startUseButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:UIControlStateNormal];
    startUseButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    [startUseButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"] withFrame:startUseButton.bounds] forState:UIControlStateNormal];
    [startUseButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_700"] withFrame:startUseButton.bounds] forState:UIControlStateHighlighted];
    startUseButton.layer.cornerRadius = 4;
    startUseButton.clipsToBounds = YES;
    
    //title image and main image
    UIImage *mainImage = [TPDialerResourceManager getImage:@"antiharass_guide_main@2x.png"];
    UIImage *titleImage = [TPDialerResourceManager getImage:@"antiharass_guide_title@2x.png"];
    
    // for iphone 4 and lower
    CGSize mainImageViewDimen = CGSizeMake(0.54f * screenWidth, 0.54f * screenHeight);
    CGSize titleImageViewDimen = CGSizeMake(0.54f * screenWidth, 0.11f * screenHeight);
    
    // for iphone 5 and higher
    if (isIPhone5Resolution()) {
        mainImageViewDimen = CGSizeMake(0.46f * screenWidth, 0.46f * screenHeight);
        titleImageViewDimen = CGSizeMake(0.46f * screenWidth, 0.1f * screenHeight);
    }
    
    
    UIImageView *mainImageView = [[UIImageView alloc] initWithImage:mainImage];
    mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    mainImageView.frame = CGRectMake((TPScreenWidth() - mainImageViewDimen.width) / 2,
                                     startUseButton.frame.origin.y - (mainImageViewDimen.height + mainImageMargin),
                                     mainImageViewDimen.width, mainImageViewDimen.height);

    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    titleImageView.frame = CGRectMake((TPScreenWidth() - titleImageViewDimen.width) / 2,
                                      mainImageView.frame.origin.y - (titleImageViewDimen.height + mainImageMargin),
                                      titleImageViewDimen.width, titleImageViewDimen.height);
    cootek_log(@"origin.y of skip:%f, use:%f, main:%f, title:%f",
               skipTextButton.frame.origin.y, startUseButton.frame.origin.y,
               mainImageView.frame.origin.y, titleImageView.frame.origin.y);
    //ui, layout and positioning
    [self.view addSubview:titleImageView];
    [self.view addSubview:mainImageView];
    [self.view addSubview:startUseButton];
    [self.view addSubview:skipTextButton];
    
    //set click-action targets
    [startUseButton addTarget:self action:@selector(goToAntiharassPage)
          forControlEvents:UIControlEventTouchUpInside];
    [skipTextButton addTarget:self action:@selector(goToMainView) forControlEvents:UIControlEventTouchUpInside];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated ];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(VIEW_APPEARED, @(1)), nil];
}

- (void) goToAntiharassPage {
    [UserDefaultsManager setBoolValue:NO forKey:SHOULD_SHOW_ANTIHARASS_GUIDE];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_CLICKED, @(1)), nil];
    UIViewController *antiHarassController = [[AntiharassmentViewController alloc] init];
    [[self navigationController] pushViewController:antiHarassController animated:YES];
    [self removeFromParentViewController];
}

- (void) goToMainView{
    [UserDefaultsManager setBoolValue:NO forKey:SHOULD_SHOW_ANTIHARASS_GUIDE];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_SKIPPED, @(1)), nil];
    [self.navigationController popViewControllerAnimated:YES];
    [self removeFromParentViewController];
}


@end