//
//  TPPageController.h
//  TouchPalDialer
//
//  Created by Admin on 8/5/13.
//
//

#import <Foundation/Foundation.h>
#import "UIView+WithSkin.h"
@interface TPPageController : UIPageControl <SelfSkinChangeProtocol>
{
    UIImage* __strong activeImage;
    UIImage* __strong inactiveImage;
}
@end

