//
//  WebPageSettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "WebPageSettingItemModel.h"
#import "CommonWebViewController.h"

@implementation WebPageSettingItemModel

@synthesize url;

+(WebPageSettingItemModel*) itemWithTitle:(NSString*) title url:(NSString*) url {
    WebPageSettingItemModel* item = [[WebPageSettingItemModel alloc] init];
    item.title = title;
    item.url = url;
    item.isURLLocalized = YES;
  
    return item;
}

-(void) executeAction:(UIViewController *)vc {
    CommonWebViewController* webVC = [[CommonWebViewController alloc] init];
    if(self.isURLLocalized) {
        webVC.url_string = NSLocalizedString(self.url, @"");
    } else {
        webVC.url_string = self.url;
    }
    webVC.header_title = NSLocalizedString(self.title, @"");
    
    if(![vc isKindOfClass:[UINavigationController class]]) {
        vc = vc.parentViewController;
    }
    
    if([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nc = (UINavigationController*) vc;
        [nc pushViewController:webVC animated:YES];
    } else {
        cootek_log(@"Error: the input vc is not a navigation controller");
    }
    
}

@end
