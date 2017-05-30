//
//  AntiharassmentViewController.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "CootekViewController.h"

@interface AntiharassmentViewController : CootekViewController


-(void)updateAntiharassVersionInDialerVC;


/**
 the proper view controller class name

 @return @"AntiharassmentViewController_iOS10" if iOS 10 antiharass feature is available
    else return the legacy @"AntiharassmentViewController" class name
 */
+ (NSString *) controllerClassName;

+ (BOOL) hasNewDBVersion;
@end
