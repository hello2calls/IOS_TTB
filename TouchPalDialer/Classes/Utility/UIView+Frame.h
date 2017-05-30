//
//  UIView+Frame.h
//  ItcastWeibo
//
//  Created by yz on 14/11/5.
//  Copyright (c) 2014年 iThinker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

@property (nonatomic, assign, setter=setTPWidth:) CGFloat tp_width;
@property (nonatomic, assign, setter=setTPHeight:) CGFloat tp_height;
@property (nonatomic, assign, setter=setTPX:) CGFloat tp_x;
@property (nonatomic, assign, setter=setTPY:) CGFloat tp_y;

@property (nonatomic, assign, setter=setTPSize:) CGSize tp_size;

@end
