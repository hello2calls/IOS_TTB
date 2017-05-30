//
//  UIView+Frame.m
//  ItcastWeibo
//
//  Created by yz on 14/11/5.
//  Copyright (c) 2014年 iThinker. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat)tp_width
{
    return self.frame.size.width;
}
- (void)setTPWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)tp_height
{
    return self.frame.size.height;
}
- (void)setTPHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)tp_x
{
    return self.frame.origin.x;
}

- (void)setTPX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;

}

- (CGFloat)tp_y
{
    return self.frame.origin.y;
}
- (void)setTPY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;

}


- (CGSize)tp_size
{
    return self.frame.size;
}
- (void)setTPSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

    

@end
