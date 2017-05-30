//
//  NewFeatureGuideManager.m
//  TouchPalDialer
//
//  Created by ALEX on 16/9/12.
//
//

#import "NewFeatureGuideManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommonWebViewController.h"
#import "SeattleFeatureExecutor.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"
#import "AntiharassmentViewController_iOS10.h"
#import "CommonTipsWithBolckView.h"
#import "DialerUsageRecord.h"
#define NEWFEATUREGUIDEURL @"http://touchlife.cootekservice.com/page_v3/ios_update.html?os_version=%@&token=%@&app_version=%@"

@interface NewFeatureGuideManager ()

@property (nonatomic,weak) UIView *bgView;
@end

@implementation NewFeatureGuideManager

+ (instancetype)sharedManager {
    
    static NewFeatureGuideManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

// data point
- (void)checkNewFeatureGuide {

    if ([self checkUserdefault]) {
        [DialerUsageRecord recordpath:PATH_ANTIHARASS_MASK_SHOW kvs:Pair(PATH_ANTIHARASS_MASK_SHOW, @1), nil];
        UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [[UIApplication sharedApplication].keyWindow addSubview:bgView];
        self.bgView = bgView;
        UIImage *image = nil;
        if ([UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION defaultValue:NO]) {
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"antiharass_guide_switchOn@2x.png"];
                [UserDefaultsManager setIntValue:2 forKey:ANTIHARASS_GUIDE_SWITCH_ON];
        } else {
            image = [[TPDialerResourceManager sharedManager] getImageByName:@"antiharass_guide_switchOff@2x.png"];
            [UserDefaultsManager setIntValue:2 forKey:ANTIHARASS_GUIDE_SWITCH_OFF];
        }
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tp_width = [UIScreen mainScreen].bounds.size.width;
        imageView.tp_height = image.size.height;
        imageView.center = bgView.center;
        imageView.image = image;
        imageView.userInteractionEnabled = YES;
        [bgView addSubview:imageView];

        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, imageView.tp_width, imageView.tp_height - 100)];
        [imageView addSubview:button];
        
        [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        
        
    } else {

        cootek_log(@"%d",[UserDefaultsManager boolValueForKey:SHOULD_SHOW_ANTIALERT_SWIITCH_OFF defaultValue:NO]);
        if ([FunctionUtility is64bitAndIOS10] && [UserDefaultsManager boolValueForKey:SHOULD_SHOW_ANTIALERT_SWIITCH_OFF defaultValue:NO] ){
            [UserDefaultsManager setBoolValue:NO forKey:SHOULD_SHOW_ANTIALERT_SWIITCH_OFF];
            if (![UserDefaultsManager boolValueForKey:CALL_DIRECTORY_EXTENSION_AUTHORIZATION defaultValue:NO]) {
                __weak NewFeatureGuideManager *wkseff = self;

                [CommonTipsWithBolckView showTipsWithTitle:@"升级后，防骚扰功能需要重新开启。" leftString:@"我知道了" rightString:@"去开启" rightBlock:^{
                    [wkseff buttonClick];
                } leftBlock:nil checkString:nil ifCheckSure:NO lableStringArg:nil];
            }
        }
    }
}



- (BOOL)checkUserdefault {
    if ([FunctionUtility is64bit]) {
        if ([UIDevice currentDevice].systemVersion.floatValue>=10) {
                if ([UserDefaultsManager intValueForKey:ANTIHARASS_GUIDE_SWITCH_ON defaultValue:0]==2 || [UserDefaultsManager intValueForKey:ANTIHARASS_GUIDE_SWITCH_OFF defaultValue:0]==2) {
                    return NO;
                }
            [UserDefaultsManager setBoolValue:NO forKey:SHOULD_SHOW_ANTIALERT_SWIITCH_OFF];
            return YES;
        } else {
            if ([UserDefaultsManager intValueForKey:ANTIHARASS_GUIDE_INAPP]<2) {
                [UserDefaultsManager setIntValue:1 forKey:ANTIHARASS_GUIDE_INAPP];
                return NO;
            }
        }
    }
    return NO;
}

- (void)buttonClick {

    [self.bgView removeFromSuperview];
    [[TouchPalDialerAppDelegate naviController] pushViewController:nil animated:YES];
    AntiharassmentViewController_iOS10 *controller = [[AntiharassmentViewController_iOS10 alloc] init];
    controller.notCheckDBVersion = YES;
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS_MASK_CLICK kvs:Pair(PATH_ANTIHARASS_MASK_CLICK, @1), nil];
}


@end
