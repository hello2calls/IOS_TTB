//
//  GoDetailSettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "GoDetailSettingItemModel.h"
#import "SettingsModelCreator.h"
#import "DefaultSettingViewController.h"
#import "UMFeedbackFAQController.h"
#import "GestureSettingsViewController.h"
#import "SmartDailViewController.h"
#import "FunctionUtility.h"

@implementation GoDetailSettingItemModel

@synthesize settingPageType;

+(GoDetailSettingItemModel*) itemWithTitle:(NSString*) title subTitle:(NSString*)subTitle withHintType:(int)type withHintCount:(NSInteger)count PageType:(SettingPageType) pageType {
    GoDetailSettingItemModel* item = [[GoDetailSettingItemModel alloc] init];
    item.title = title;
    item.subtitle = subTitle;
    item.settingPageType = pageType;
    item.hintType = type;
    item.hintCount = count;
    
    return item;
}

+(GoDetailSettingItemModel*) itemWithTitle:(NSString*) title subTitle:(NSString*)subTitle PageType:(SettingPageType) pageType {
    return [GoDetailSettingItemModel itemWithTitle:title subTitle:subTitle withHintType:Type_none withHintCount:0 PageType:pageType];
}

+(GoDetailSettingItemModel*) itemWithTitle:(NSString*) title PageType:(SettingPageType) pageType {
    return [GoDetailSettingItemModel itemWithTitle:title subTitle:nil PageType:pageType];
}

-(void) executeAction:(UIViewController *)vc {
    SettingPageModel* page = [[SettingsCreator creator] modelForPage:self.settingPageType];
    if (page.pageType == SETTING_PAGE_GESTURE) {
        if ( [FunctionUtility judgeContactAccessFail] )
            return;
        GestureSettingsViewController *gesController = [[GestureSettingsViewController alloc] init];
        if (gesController == nil) {
            return;
        }
        [vc.navigationController pushViewController:gesController animated:YES];
    } else if (page.pageType == SETTING_PAGE_SMART_DIAL){
         SmartDailViewController *sdController = [[SmartDailViewController alloc] init];
        [vc.navigationController pushViewController:sdController animated:YES];
    } else if (page.pageType == SETTING_PAGE_FEEDBACK) {
        UMFeedbackFAQController *feedback = [[UMFeedbackFAQController alloc]init];
        [vc.navigationController pushViewController:feedback animated:YES];
    } else {
        DefaultSettingViewController* controller = [DefaultSettingViewController controllerWithPageModel:page];
        if(![vc isKindOfClass:[UINavigationController class]]) {
            vc = vc.parentViewController;
        }
    
        if([vc isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nc = (UINavigationController*) vc;
            [nc pushViewController:controller animated:YES];
        } else {
            cootek_log(@"Error: the input vc is not a navigation controller");
        }
    }
}
@end
