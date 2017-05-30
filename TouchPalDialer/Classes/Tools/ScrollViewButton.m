//
//  ScrollViewButton.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/23.
//
//

#import "ScrollViewButton.h"
#import "FunctionUtility.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#define DELTA_DISTANCE 50

@interface ScrollViewButton(){
    BOOL _beginEnabled;
}

@end

@implementation ScrollViewButton

@synthesize highlightColor;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _beginEnabled = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enableBegin:) name:N_SCROLL_ENABLE object:nil];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_beginEnabled) {
        self.backgroundColor = highlightColor;
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.y < -DELTA_DISTANCE || point.y > self.frame.size.height + DELTA_DISTANCE) {
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.backgroundColor = highlightColor;
    }
    [super touchesMoved:touches withEvent:event];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self clearHighlightStateAnimate];
}

- (void)clearHighlightState {
    self.backgroundColor = [UIColor clearColor];
}

- (void)clearHighlightStateAnimate {
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [UIColor clearColor];
    }];
}

- (void)enableBegin:(NSNotification*)noti {
    BOOL result = [[[noti userInfo] objectForKey:KEY_SCROLL] boolValue];
    _beginEnabled = result;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
