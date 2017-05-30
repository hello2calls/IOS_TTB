//
//  ShowList&MoveRight.m
//  TableViewMultiSelect
//
//  Created by Liangxiu on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PushRightView.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"

@interface PushRightView (){
    UIButton *actionControl_;

    UIControl *coverView_;
    UIView *movableView_;
    UIView *belowView_;
    CGFloat moveStep_;
    
    BOOL isStatusBarNeedChange;

    CGRect originalMovableViewFrame_;
    CGRect originalBelowViewFrame_;
}
@end

@implementation PushRightView

-(id)initWithButton:(UIButton *)actionButton
        movableView:(UIView *)movableView
          belowView:(UIView *)belowView
     remainingWidth:(CGFloat)remainingWidth
{
      self = [super initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(),actionButton.frame.size.width, actionButton.frame.size.height)];

    if (self){
        movableView_ = movableView;
        belowView_ = belowView;
        actionControl_ = actionButton;
        [self addSubview:actionControl_];
        originalMovableViewFrame_ = movableView_.frame;
        originalBelowViewFrame_ = belowView_.frame;
        moveStep_ = originalMovableViewFrame_.size.width - remainingWidth;
        belowView_.frame = CGRectMake(-moveStep_, originalBelowViewFrame_.origin.y, originalBelowViewFrame_.size.width, originalBelowViewFrame_.size.height);
        belowView_.hidden = YES;
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:belowView_];
        
        coverView_ = [[UIControl alloc] initWithFrame:CGRectMake(TPScreenWidth()-remainingWidth, 0, remainingWidth, TPScreenHeight())];
        coverView_.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.4];
        [coverView_ addTarget:self action:@selector(restoreViewLocation) forControlEvents:UIControlEventTouchDown];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(restoreViewLocationWithoutAnimation)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(restoreViewLocationWithoutAnimation)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)moveToRight
{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ONCLICK_FILTER_BEGINS object:nil];
    [FunctionUtility updateStatusBarStyle];
    
    belowView_.hidden = NO;
    originalBelowViewFrame_.origin.y = TPStatusBarHeight() - TPHeaderBarHeightDiff();
    originalBelowViewFrame_.size.height = TPAppFrameHeight() + TPHeaderBarHeightDiff();
    [UIView animateWithDuration:0.2
                     animations:^{
                         movableView_.frame = CGRectMake(moveStep_, movableView_.frame.origin.y,
                                                         movableView_.frame.size.width, movableView_.frame.size.height);
                         belowView_.frame = originalBelowViewFrame_;
                     }
                     completion:^(BOOL finished){
                         if ( !belowView_.hidden )
                             [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:coverView_];
                         cootek_log(@"belowview: %@", [belowView_ description]);
                     }];
}

- (void)restoreViewLocation
{
    [FunctionUtility updateStatusBarStyle];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_RESTORE_FILTER_ENDS object:nil];
    [coverView_ removeFromSuperview];
    originalBelowViewFrame_.origin.y = TPStatusBarHeight() - TPHeaderBarHeightDiff();
    originalBelowViewFrame_.size.height = TPAppFrameHeight() + TPHeaderBarHeightDiff();
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self viewRestoreFrame];
                     }
                     completion:^(BOOL finished){
                         belowView_.hidden = YES;
                     }];
}

- (void)restoreViewLocationWithoutAnimation
{
    if (isStatusBarNeedChange) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_RESTORE_FILTER_ENDS object:nil];
    [coverView_ removeFromSuperview];
    originalBelowViewFrame_.origin.y = TPStatusBarHeight() - TPHeaderBarHeightDiff();
    originalBelowViewFrame_.size.height = TPAppFrameHeight() + TPHeaderBarHeightDiff();
    [self viewRestoreFrame];
    belowView_.hidden = YES;
}

- (void)viewRestoreFrame
{
    movableView_.frame = CGRectMake(0, movableView_.frame.origin.y,
                                    movableView_.frame.size.width, movableView_.frame.size.height);
    belowView_.frame = CGRectMake(-moveStep_, originalBelowViewFrame_.origin.y,
                                  originalBelowViewFrame_.size.width, originalBelowViewFrame_.size.height);
}

- (void)dealloc
{
    [belowView_ removeFromSuperview];
    [coverView_ removeFromSuperview];
}
@end
