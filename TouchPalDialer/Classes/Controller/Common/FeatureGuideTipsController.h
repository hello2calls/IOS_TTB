//
//  FeatureGuideTips.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDefaultKeys.h"
#import "RegisterProtocol.h"
#import "TPItemButton.h"
#import "TPPageController.h"

@interface FeatureGuideTipsController : UIViewController <UIScrollViewDelegate,RegisterProtocolDelegate>{
    BOOL isOnClick;
    UIScrollView *scrollView;
    int currentPage;
    TPPageController *pageController;
}
- (void)loadScrollViewItem;
@end
