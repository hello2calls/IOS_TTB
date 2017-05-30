//
//  BaseRowView.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-9.
//
//
#import "BaseRowView.h"

@implementation BaseRowView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    UIView* view = [self createViewItemWithFrame:frame];
    [self addSubview:view];
    
    [self drawView];
    return self;
}

- (void) drawView
{
    cootek_log(@"****** draw view");
}

- (void) updateData:(SectionGroup *)item
{
    self.itemData = item;
}

- (UIView *) createViewItemWithFrame:(CGRect)frame
{
    return nil;
}

@end