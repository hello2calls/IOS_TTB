//
//  BaseTabBar.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseTabBar.h"
#import "TPUIButton.h"

@implementation BaseTabBar

@synthesize buttonArray;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count
{
    self = [self initWithFrame:frame buttonCount:count withWidthPadding:0];
    return self;
}
- (id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count withWidthPadding:(CGFloat)widthpadding
{
    self = [self initWithFrame:frame buttonCount:count withWidthPadding:0 fontSize:CELL_FONT_TITILE];
    return self;
}
- (id)initWithFrame:(CGRect)frame buttonCount:(NSInteger)count withWidthPadding:(CGFloat)widthpadding fontSize:(NSInteger)size
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.buttonArray = [NSMutableArray array];
        int width = (frame.size.width-widthpadding)/count;
        int leftpadding = widthpadding/(count-1);
        for (int i = 0; i<count; i++) {
            CGRect segmentFrame = CGRectMake(i*(width+leftpadding),0,width,frame.size.height);
            TPUIButton *tmpButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
            tmpButton.frame = segmentFrame;
            tmpButton.tag= i;
            tmpButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            tmpButton.titleLabel.font = [UIFont systemFontOfSize:size];
            [tmpButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:tmpButton];
            [buttonArray addObject:tmpButton];
        }
    }
    return self;
}
-(void)tabBarTitle:(NSArray *)titleList{
    for (int i = 0; i< [titleList count]; i++) {
        TPUIButton *tmpBtn = [buttonArray objectAtIndex:i];
        [tmpBtn setTitle:[titleList objectAtIndex:i] forState:UIControlStateNormal];
    }
}
-(BOOL)isEnableButtonAfterClick{
    return NO;
}
-(void)clickItem:(TPUIButton *)button{
    [self clickTabIndex:button.tag];
}
-(void)clickTabIndex:(NSInteger)index{
    for (int i = 0; i< [buttonArray count]; i++) {
        TPUIButton *tmpBtn = [buttonArray objectAtIndex:i];
        if (index == i) {
            tmpBtn.enabled = [self isEnableButtonAfterClick];
        }else {
            tmpBtn.enabled = YES;
        }
    }
    [delegate onClickAtIndexBar:index];
}

@end
