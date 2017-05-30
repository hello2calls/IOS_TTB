//
//  RootScrollView.h
//  TouchPalDialer
//
//  Created by Scyuan on 14-7-2.
//
//

#import <UIKit/UIKit.h>
#import "RootTabBar.h"

@class RootTabBar;
@interface RootScrollView : UIScrollView<UIScrollViewDelegate>
{
    CGFloat userContentOffsetX;
}
@property (nonatomic, assign) RootTabBar *rootTabBarView;
@property (nonatomic, assign) NSInteger nowStatus;
@end