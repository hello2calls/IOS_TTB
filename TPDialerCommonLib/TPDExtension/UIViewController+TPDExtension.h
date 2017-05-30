//
//  UIViewController+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/20.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (TPDExtension)
+ (UIViewController*)tpd_topViewController;

- (UIView*)tpd_makeItScrollBase;

- (UITableView*)tpd_tableViewOfController;

-(void)tpd_enableSlideReturn;
@end
