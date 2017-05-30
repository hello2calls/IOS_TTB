//
//  PreShareViewController.h
//  TouchPalDialer
//
//  Created by junhzhan on 8/21/15.
//
//

#import <Foundation/Foundation.h>
#import "ShareData.h"
#import "PreShareView.h"

@interface PreShareFactory : NSObject

+ (PreShareView *)showPreShareView:(ShareData*)shareData inParent:(UIView*)container;

@end
