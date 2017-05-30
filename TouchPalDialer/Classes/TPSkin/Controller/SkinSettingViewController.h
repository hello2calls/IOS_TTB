//
//  SkinSettingViewController.h
//  TouchPalDialer
//
//  Created by Liangxiu on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadTabBar.h"
#import "HeaderBar.h"
#import "LocalSkinItemView.h"
#import "RemoteSkinItemView.h"
#import "RemoteSkinReloadView.h"

typedef enum {
    UNKNOWN_TAB_SKIN_INDEX = -1,
    LOCAL_TAB_SKIN_INDEX = 1,
    REMOTE_TAB_SKIN_INDEX = 0,
}TabSkinIndex;

@interface SkinSettingViewController : UIViewController <BaseTabBarDelegate, LocalSkinItemViewDelegate>

@property (nonatomic, assign)TabSkinIndex startPage;

@end
