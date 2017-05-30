//
//  CalllogFilterBar.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabBar.h"
#import "UIView+WithSkin.h"

@interface CalllogFilterBar : BaseTabBar <SelfSkinChangeProtocol>{
     NSArray __strong *_imageList;
}
-(void)barStyle:(NSArray *)imageList;
@end
