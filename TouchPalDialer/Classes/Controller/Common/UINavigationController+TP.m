//
//  UINavigationController+TP.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/5/12.
//
//

#import "UINavigationController+TP.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@implementation UINavigationController (TP)

- (void)configureHeaderSkin
{
    // title background
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    [manager makeSureStatusBarChanged];
    CGSize size = CGSizeMake(TPScreenWidth(), TPHeaderBarHeight());
    UIImage *bgImage = [FunctionUtility imageWithResize:[manager getImageByName:@"common_header_bg@2x.png"] scaledToSize:size];
    if (!bgImage) {
        return;
    }
    
    [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    // title color
    UIColor *textColor = [TPDialerResourceManager getColorForStyle:@"configuredNavbarHeader_color"];
    
    //NSDictionary *titleAttrDict = @{NSForegroundColorAttributeName:textColor};
    
    NSDictionary *titleAttrDict = [NSDictionary dictionaryWithObject:textColor forKey:UITextAttributeTextColor];

    self.navigationBar.titleTextAttributes = titleAttrDict;
}

@end
