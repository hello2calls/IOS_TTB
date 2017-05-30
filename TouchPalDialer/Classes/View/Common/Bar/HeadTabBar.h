//
//  HeadTabBar.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabBar.h"

@interface HeadTabBar : BaseTabBar{
    BOOL expandableHeadTabBar;
    NSDictionary *operDic;
}
@property (nonatomic, assign)BOOL expandableHeadTabBar;
@property (nonatomic, assign)BOOL changeSkinHeadTabBar;
@property (nonatomic, assign)BOOL canChangeSkin;

-(void)clickTabIndex:(NSInteger)index;
@end
