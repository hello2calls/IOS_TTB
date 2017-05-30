//
//  RootScrollView.m
//  TouchPalDialer
//
//  Created by Scyuan on 14-7-2.
//
//

#import "RootScrollView.h"
#import "CootekNotifications.h"
#import "PhonePadModel.h"
#import "GestureModel.h"
#define POSITIONID (int)scrollView.contentOffset.x/TPScreenWidth()
@implementation RootScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.scrollEnabled = NO;
        //self.pagingEnabled = YES;
        self.userInteractionEnabled = YES;
        self.bounces = NO;
        self.contentSize = CGSizeMake(TPScreenWidth()*3,TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.contentOffset = CGPointMake(TPScreenWidth(), 0);
        if ([[GestureModel getShareInstance] isOpenSwitchGesture]) {
            self.delaysContentTouches = NO;
            self.canCancelContentTouches = YES;
        }else{
            self.delaysContentTouches = YES;
            self.canCancelContentTouches = NO;
        }
        userContentOffsetX = 0;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closePhonePadMove) name:N_GESTURE_SETTING_OPEN object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openPhonePadMove) name:N_GESTURE_SETTING_CLOSE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseMove) name:N_DIALER_INPUT_EMPTY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(holdMove) name:N_DIALER_INPUT_NOT_EMPTY object:nil];
        [self initWithViews];
        _nowStatus = 1;
        
    }
    return self;
}

- (void)initWithViews
{
    
    
}

- (void)closePhonePadMove
{
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = NO;
}
- (void)openPhonePadMove
{
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = YES;
}

- (void)holdMove
{
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = YES;
}

- (void)releaseMove
{
    if ([[GestureModel getShareInstance] isOpenSwitchGesture]) {
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = YES;
    }else{
        self.delaysContentTouches = YES;
        self.canCancelContentTouches = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    userContentOffsetX = scrollView.contentOffset.x;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_STARTING_SCROLLING object:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (_nowStatus!=POSITIONID) {
        [self adjustTopScrollViewButton:scrollView];
    }
    _nowStatus = POSITIONID;
    
    
}
- (void)adjustTopScrollViewButton:(UIScrollView *)scrollView
{
    
    [_rootTabBarView setButtonUnSelect];
    _rootTabBarView.scrollViewSelectedChannelID = POSITIONID;
    [_rootTabBarView setButtonSelect];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view{

    return YES;
    
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view{
	
    return YES;
    
}


@end
