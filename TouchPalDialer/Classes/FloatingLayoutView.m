//
//  FloatingButtonView.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/1/19.
//
//

#import <Foundation/Foundation.h>
#import "FloatingLayoutView.h"
#import "VerticallyAlignedLabel.h"
#import "TPUIButton.h"
#import "TouchPalVersionInfo.h"
#import "TPDialerResourceManager.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "UIImage+Extra.h"
#import "FLoatingMenuView.h"
#import "CTUrl.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"

#define OFF_SET_MAX 30l
#define MARGIN_TOP 50l
#define COMMEN_HEIGHT 50
#define MENUS_WIDTH 180
#define BUTTON_MARGIN_LEFT 8
#define BUTTON_MARGIN_RIGHT 10
#define BUTTON_MARGIN_BETWEEN 2

@interface FloatingLayoutView()
{
    UIImageView *rightImgView;
    FLoatingMenuView *menusView;
    TPUIButton *exitButton;
    TPUIButton *sendToDeskButton;
    BOOL isMenusHidden;
    CTUrl *ctUrl;
    BOOL showSendToDeskTop;
    CGPoint startPoint;
    BOOL isMoving;
    CGRect startFrame;
    NSTimer* hideViewTimer;
    BOOL isHide;
    CGRect hideBeforeRect;
    UIInterfaceOrientation currentOrientation;
}

@property (nonatomic, strong) NSValue *touchPointValue;
@end


@implementation FloatingLayoutView

- (id) initWithCTUrl: (CTUrl*)ctLink
{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    isMenusHidden = YES;
    ctUrl = ctLink;
    showSendToDeskTop = ctUrl.sendToDeskTop && ctUrl.serviceId && ctUrl.shortCutTitle && ctUrl.shortCutIcon;
    menusView = [[FLoatingMenuView alloc] init];
    menusView.autoresizingMask = UIViewAutoresizingNone;
    menusView.backgroundColor = [UIColor clearColor];
    [self addSubview:menusView];
    rightImgView = [[UIImageView alloc] init];
    rightImgView.backgroundColor = [UIColor clearColor];
    rightImgView.autoresizingMask = UIViewAutoresizingNone;
    exitButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
    sendToDeskButton = [TPUIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:sendToDeskButton];
    [self addSubview:exitButton];
    [self addSubview:rightImgView];
    [exitButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    [sendToDeskButton addTarget:self action:@selector(openSafari:) forControlEvents:UIControlEventTouchUpInside];
    isMoving = NO;
    [self drawView];
    [self hidBtnViewWithDelay];
    return self;
}


- (void)drawView
{
    UIImage *image;
    image = [[TPDialerResourceManager sharedManager] getImageByName:@"show_menus@2x.png"];
    rightImgView.frame = CGRectMake(self.frame.origin.x, TPScreenHeight() / 2, COMMEN_HEIGHT, COMMEN_HEIGHT);
    rightImgView.userInteractionEnabled = YES;

    [rightImgView setContentMode:UIViewContentModeScaleToFill];
    [rightImgView setImage:image];

    image = [[TPDialerResourceManager sharedManager] getImageByName:@"close_game@2x.png"];

    CGSize imgSize = CGSizeMake(image.size.width * 2 / 3, image.size.height * 2 / 3);
    [exitButton setImage:[image imageByScalingProportionallyToSize:imgSize] forState:UIControlStateNormal];

    [exitButton setTitle:@"退出游戏" forState:UIControlStateNormal];
    [exitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [exitButton setTitle:@"退出游戏" forState:UIControlStateHighlighted];
    [exitButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    exitButton.titleLabel.font = [UIFont systemFontOfSize:10];
    
    UIImage *sendToDeskImg;
    sendToDeskImg = [[TPDialerResourceManager sharedManager]getImageByName:@"desktop_shortcut@2x.png"];
    CGSize desImgSize = CGSizeMake((sendToDeskImg.size.width * 2 / 3), sendToDeskImg.size.height * 2 / 3);
    
    [sendToDeskButton setImage:[sendToDeskImg imageByScalingProportionallyToSize:desImgSize] forState:UIControlStateNormal];
    [sendToDeskButton setTitle:@"发送到桌面" forState:UIControlStateNormal];
    [sendToDeskButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendToDeskButton setTitle:@"发送到桌面" forState:UIControlStateHighlighted];
    [sendToDeskButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    sendToDeskButton.titleLabel.font = [UIFont systemFontOfSize:10];
    
    [self setButtonEdgeInset];
}
- (void) resetCoordinate
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation != orientation) {
        [self hidBtnViewWithDelay];
        isHide = NO;
        rightImgView.alpha = 1.0f;
        rightImgView.frame = CGRectMake(self.frame.origin.x, TPScreenHeight() / 2, COMMEN_HEIGHT, COMMEN_HEIGHT);
        hideBeforeRect = rightImgView.frame;
        startFrame = rightImgView.frame;
        [self setNeedsDisplay];
        currentOrientation = orientation;
    }

}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    UIImage *rightImg;
    if (isMenusHidden) {
        rightImg = [[TPDialerResourceManager sharedManager] getImageByName:@"show_menus@2x.png"];
    } else {
        rightImg = [[TPDialerResourceManager sharedManager] getImageByName:@"hide_menus@2x.png"];
    }
    [rightImgView setImage:rightImg];

    menusView.isPressed = self.pressed;

    if ([self isOnLeftScreen]) {
        menusView.frame = CGRectMake(rightImgView.frame.origin.x, rightImgView.frame.origin.y, MENUS_WIDTH, COMMEN_HEIGHT);
        if (showSendToDeskTop) {
            sendToDeskButton.frame = CGRectMake(rightImgView.frame.origin.x + rightImgView.frame.size.width + BUTTON_MARGIN_LEFT, rightImgView.frame.origin.y, (menusView.bounds.size.width - rightImgView.frame.size.width - BUTTON_MARGIN_LEFT - BUTTON_MARGIN_RIGHT - BUTTON_MARGIN_BETWEEN) / 2, COMMEN_HEIGHT);
            exitButton.frame = CGRectMake(rightImgView.frame.origin.x + rightImgView.frame.size.width + BUTTON_MARGIN_LEFT + sendToDeskButton.frame.size.width + BUTTON_MARGIN_BETWEEN, rightImgView.frame.origin.y, (menusView.bounds.size.width - rightImgView.frame.size.width - BUTTON_MARGIN_LEFT - BUTTON_MARGIN_RIGHT - BUTTON_MARGIN_BETWEEN) / 2, COMMEN_HEIGHT);
        } else {
            exitButton.frame = CGRectMake(rightImgView.frame.origin.x + rightImgView.frame.size.width + BUTTON_MARGIN_LEFT, rightImgView.frame.origin.y, menusView.bounds.size.width - rightImgView.frame.size.width - BUTTON_MARGIN_LEFT - BUTTON_MARGIN_RIGHT, COMMEN_HEIGHT);
        }
    } else {
        menusView.frame = CGRectMake(rightImgView.frame.origin.x - MENUS_WIDTH + rightImgView.frame.size.width, rightImgView.frame.origin.y, MENUS_WIDTH, COMMEN_HEIGHT);
        if (showSendToDeskTop) {
            sendToDeskButton.frame = CGRectMake(rightImgView.frame.origin.x  - MENUS_WIDTH + BUTTON_MARGIN_RIGHT + rightImgView.frame.size.width, rightImgView.frame.origin.y, (menusView.bounds.size.width - rightImgView.frame.size.width - BUTTON_MARGIN_LEFT - BUTTON_MARGIN_RIGHT - BUTTON_MARGIN_BETWEEN) / 2, COMMEN_HEIGHT);
            exitButton.frame = CGRectMake(rightImgView.frame.origin.x + rightImgView.frame.size.width - MENUS_WIDTH + BUTTON_MARGIN_RIGHT + sendToDeskButton.frame.size.width + BUTTON_MARGIN_BETWEEN, rightImgView.frame.origin.y, (menusView.bounds.size.width - rightImgView.frame.size.width - BUTTON_MARGIN_LEFT - BUTTON_MARGIN_RIGHT - BUTTON_MARGIN_BETWEEN) / 2, COMMEN_HEIGHT);
        } else {
            exitButton.frame = CGRectMake(rightImgView.frame.origin.x  - MENUS_WIDTH + BUTTON_MARGIN_RIGHT + rightImgView.frame.size.width, rightImgView.frame.origin.y, menusView.bounds.size.width - rightImgView.frame.size.width - BUTTON_MARGIN_LEFT - BUTTON_MARGIN_RIGHT, COMMEN_HEIGHT);
        }
    }

    menusView.hidden = isMenusHidden;
    exitButton.hidden = isMenusHidden;
    sendToDeskButton.hidden = isMenusHidden&&showSendToDeskTop;

    exitButton.backgroundColor = [UIColor clearColor];
    sendToDeskButton.backgroundColor = [UIColor clearColor];
    [self setButtonEdgeInset];

    [menusView setNeedsDisplay];

}

- (void) setButtonEdgeInset
{
    [exitButton setTitleEdgeInsets:UIEdgeInsetsMake(exitButton.imageView.bounds.size.height, -exitButton.imageView.bounds.size.width, 0, 0)];
    [exitButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, exitButton.titleLabel.bounds.size.height, -exitButton.titleLabel.bounds.size.width)];
    [sendToDeskButton setTitleEdgeInsets:UIEdgeInsetsMake(sendToDeskButton.imageView.bounds.size.height, -sendToDeskButton.imageView.bounds.size.width, 0, 0)];
    [sendToDeskButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, sendToDeskButton.titleLabel.bounds.size.height, -sendToDeskButton.titleLabel.bounds.size.width)];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    // We only support single touches, so anyObject retrieves just that touch from touches.
    UITouch *touch = [touches anyObject];

    startPoint = [touch locationInView:self];

    // Only move the placard view if the touch was in the placard view.
    if ([touch view] != rightImgView) {
        return;
    }
    rightImgView.frame = hideBeforeRect;
    rightImgView.alpha = 1.0;
    if (isHide) {
        if ([self isOnLeftScreen]) {
            rightImgView.frame = CGRectMake(0, rightImgView.frame.origin.y, rightImgView.frame.size.width, rightImgView.frame.size.height);
        } else {
            rightImgView.frame = CGRectMake(TPScreenWidth() - rightImgView.frame.size.width, rightImgView.frame.origin.y, rightImgView.frame.size.width, rightImgView.frame.size.height);
        }
        isHide = NO;
    }
    startFrame = rightImgView.frame;
    [self cancelHidBtnView];
    isMoving = NO;
    // Animate the first touch.
//    CGPoint touchPoint = [touch locationInView:self];
//    [self animateFirstTouchAtPoint:touchPoint];

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];

    // If the touch was in the placardView, move the placardView to its location.
    if ([touch view] == rightImgView) {
        CGPoint location = [touch locationInView:self];
        CGPoint point = [touch locationInView:self];
        CGRect rect = CGRectMake(startPoint.x - CLICK_CANCELED_OFFSET, startPoint.y - CLICK_CANCELED_OFFSET,  2 * CLICK_CANCELED_OFFSET, 2 * CLICK_CANCELED_OFFSET);
        if (!CGRectContainsPoint(rect,point)) {//actual move

            if ((long)location.y < MARGIN_TOP) {
                rightImgView.center = CGPointMake(location.x, MARGIN_TOP);
            } else if ((long)location.y > (long)(self.frame.size.height - MARGIN_TOP)) {
                rightImgView.center = CGPointMake(location.x, self.frame.size.height - MARGIN_TOP);
            } else {
                rightImgView.center = location;
            }
            isMoving = YES;
            [self hideOrShowMenus:YES];
            UIImage* img = [[TPDialerResourceManager sharedManager] getImageByName:@"show_menus@2x.png"];
            [rightImgView setImage:img];
            self.backgroundColor = [UIColor clearColor];
            return;
        }
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];

    // If the touch was in the placardView, bounce it back to the center.
    if ([touch view] == rightImgView) {
        /*
         Disable user interaction so subsequent touches don't interfere with animation until the placard has returned to the center. Interaction is reenabled in animationDidStop:finished:.
         */
//        self.userInteractionEnabled = NO;
        if (isMoving) {
            [self animatePlacardViewToBoundary];
        } else {
            [self menusAnimate];
        }
        [self hidBtnViewWithDelay];
        return;
    }
}

- (BOOL) isOnLeftScreen
{
    return rightImgView.center.x < self.frame.size.width / 2;
}

- (void) hidBtnViewWithDelay {
    hideBeforeRect = rightImgView.frame;
    if (!isHide && isMenusHidden) {
        hideViewTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hidBtnView:) userInfo:nil repeats:NO];
        isHide = YES;
    }
}

- (void)hidBtnView:(id)sender {
    if (isMenusHidden && hideViewTimer) {
        rightImgView.alpha = 0.6;
        hideViewTimer = nil;
        [UIView animateWithDuration:0.3 animations:^{
            if ([self isOnLeftScreen]) {
                rightImgView.center = CGPointMake(0, rightImgView.center.y);
            } else {
                rightImgView.center = CGPointMake(self.frame.size.width, rightImgView.center.y);
            }
        } completion:^(BOOL finished) {

        }];
    }
}

- (void) cancelHidBtnView {
    if (hideViewTimer) {
        [hideViewTimer invalidate];
        hideViewTimer = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    /*
     To impose as little impact on the device as possible, simply set the placard view's center and transformation to the original values.
     */
    UITouch *touch = [touches anyObject];
    if ([touch view] == rightImgView) {
        [self menusAnimate];
    }
    rightImgView.transform = CGAffineTransformIdentity;
    [self hidBtnViewWithDelay];
}

- (void)menusAnimate
{
    if (isMenusHidden) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        //show animate

        CGRect rect = menusView.frame;
        CGRect btnRect = exitButton.frame;
        CGRect sendBtnRect = sendToDeskButton.frame;
        if ([self isOnLeftScreen]) {
            menusView.frame = CGRectMake(rect.origin.x + rightImgView.frame.size.width / 2, rect.origin.y, 0, rect.size.height);
            if (showSendToDeskTop) {
                sendToDeskButton.frame = CGRectMake(-60 , sendBtnRect.origin.y, 0, sendBtnRect.size.height);
                exitButton.frame = CGRectMake(-60 , btnRect.origin.y, 0, btnRect.size.height);
            } else {
                exitButton.frame = CGRectMake(-60 , btnRect.origin.y, 0, btnRect.size.height);
            }
        } else {
            menusView.frame = CGRectMake(rect.origin.x + rect.size.width - rightImgView.frame.size.width / 2, rect.origin.y, 0, rect.size.height);
            if (showSendToDeskTop) {
                sendToDeskButton.frame = CGRectMake(rect.origin.x + rect.size.width - rightImgView.frame.size.width / 2, btnRect.origin.y, 0, btnRect.size.height);
            } else {
                exitButton.frame = CGRectMake(rect.origin.x + rect.size.width - rightImgView.frame.size.width / 2, btnRect.origin.y, 0, btnRect.size.height);
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            menusView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
            exitButton.frame = CGRectMake(btnRect.origin.x, btnRect.origin.y, btnRect.size.width, btnRect.size.height);
            sendToDeskButton.frame = CGRectMake(sendBtnRect.origin.x, sendBtnRect.origin.y, sendBtnRect.size.width, sendBtnRect.size.height);
        } completion:^(BOOL finished) {
        }];
        [self hideOrShowMenus : !isMenusHidden];
    } else {
        self.backgroundColor = [UIColor clearColor];
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionPush;
        if ([self isOnLeftScreen]) {
            animation.subtype = kCATransitionFromRight;
        } else {
            animation.subtype = kCATransitionFromLeft;
        }

        animation.duration = 0.3;
        [menusView.layer addAnimation:animation forKey:nil];
        [exitButton.layer addAnimation:animation forKey:nil];
        [sendToDeskButton.layer addAnimation:animation forKey:nil];
        
        [self hideOrShowMenus : !isMenusHidden];
    }

    rightImgView.frame = startFrame;
    [self setNeedsDisplay];
}


- (void) hideOrShowMenus:(BOOL) isHidden
{
    isMenusHidden = isHidden;
    menusView.hidden = isMenusHidden;
    exitButton.hidden = isMenusHidden;
    sendToDeskButton.hidden = isMenusHidden&&showSendToDeskTop;
}

/*
 First of two possible implementations of animateFirstTouchAtPoint: illustrating different behaviors.
 To choose the second, replace '1' with '0' below.
 */

#define GROW_FACTOR 1.2f
#define SHRINK_FACTOR 1.1f

#if 1

/**
 "Pulse" the placard view by scaling up then down, then move the placard to under the finger.
 */
- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
    /*
     This illustrates using UIView's built-in animation.  We want, though, to animate the same property (transform) twice -- first to scale up, then to shrink.  You can't animate the same property more than once using the built-in animation -- the last one wins.  So we'll set a delegate action to be invoked after the first animation has finished.  It will complete the sequence.

     The touch point is passed in an NSValue object as the context to beginAnimations:. To make sure the object survives until the delegate method, pass the reference as retained.
     */

#define GROW_ANIMATION_DURATION_SECONDS 0.05
    _touchPointValue = [NSValue valueWithCGPoint:touchPoint];
    [UIView beginAnimations:nil context:(__bridge_retained void *)self.touchPointValue];
    [UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
    CGAffineTransform transform = CGAffineTransformMakeScale(GROW_FACTOR, GROW_FACTOR);
    rightImgView.transform = transform;
    [UIView commitAnimations];
}


- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

#define MOVE_ANIMATION_DURATION_SECONDS 0.0f

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
    rightImgView.transform = CGAffineTransformMakeScale(SHRINK_FACTOR, SHRINK_FACTOR);
    /*
     Move the placardView to under the touch.
     We passed the location wrapped in an NSValue as the context. Get the point from the value, and transfer ownership to ARC to balance the bridge retain in touchesBegan:withEvent:.
     */
    NSValue *touchPointValue = (__bridge_transfer NSValue *)context;
    rightImgView.center = [touchPointValue CGPointValue];
    [UIView commitAnimations];
}

#else

/*
 Alternate behavior.
 The preceding implementation grows the placard in place then moves it to the new location and shrinks it at the same time.  An alternative is to move the placard for the total duration of the grow and shrink operations; this gives a smoother effect.

 */


/**
 Create two separate animations. The first animation is for the grow and partial shrink. The grow animation is performed in a block. The method uses a completion block that itself includes an animation block to perform the shrink. The second animation lasts for the total duration of the grow and shrink animations and contains a block responsible for performing the move.
 */

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {

#define GROW_ANIMATION_DURATION_SECONDS 0.05
#define SHRINK_ANIMATION_DURATION_SECONDS 0.05

    [UIView animateWithDuration:GROW_ANIMATION_DURATION_SECONDS animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(GROW_FACTOR, GROW_FACTOR);
        self.placardView.transform = transform;
    }
                     completion:^(BOOL finished){

                         [UIView animateWithDuration:(NSTimeInterval)SHRINK_ANIMATION_DURATION_SECONDS animations:^{
                             self.placardView.transform = CGAffineTransformMakeScale(SHRINK_FACTOR, SHRINK_FACTOR);
                         }];

                     }];

    [UIView animateWithDuration:(NSTimeInterval)GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS animations:^{
        self.placardView.center = touchPoint;
    }];

}


/*

 Equivalent implementation using delegate-based method.

 - (void)animateFirstTouchAtPointOld:(CGPoint)touchPoint {

 #define GROW_ANIMATION_DURATION_SECONDS 0.15
 #define SHRINK_ANIMATION_DURATION_SECONDS 0.15

 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
 [UIView setAnimationDelegate:self];
 [UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
 CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
 self.placardView.transform = transform;
 [UIView commitAnimations];

 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS];
 self.placardView.center = touchPoint;
 [UIView commitAnimations];
 }


 - (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

 [UIView beginAnimations:nil context:NULL];
 [UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
 self.placardView.transform = CGAffineTransformMakeScale(1.1, 1.1);
 [UIView commitAnimations];
 }
 */


#endif


/**
 Bounce the placard back to the boundary.
 */
- (void)animatePlacardViewToBoundary {

    UIView *placardView = rightImgView;
    CALayer *welcomeLayer = placardView.layer;

    // Create a keyframe animation to follow a path back to the center.
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    bounceAnimation.removedOnCompletion = NO;

    CGFloat animationDuration = 1.5f;


    // Create the path for the bounces.
    UIBezierPath *bouncePath = [[UIBezierPath alloc] init];

    CGFloat originX = placardView.frame.size.width / 2;
    if (![self isOnLeftScreen]) {
        originX = self.frame.size.width - placardView.frame.size.width / 2;
    }
    CGPoint centerPoint = CGPointMake(originX, placardView.center.y);
    CGFloat midX = centerPoint.x;
    CGFloat midY = centerPoint.y;
    CGFloat originalOffsetX = placardView.center.x - midX;
    CGFloat originalOffsetY = placardView.center.y - midY;
    CGFloat offsetDivider = 4.0f;

    BOOL stopBouncing = NO;

    // Start the path at the placard's current location.
    [bouncePath moveToPoint:CGPointMake(placardView.center.x, placardView.center.y)];
    [bouncePath addLineToPoint:CGPointMake(midX, midY)];

    // Add to the bounce path in decreasing excursions from the center.
    while (stopBouncing != YES) {

        CGPoint excursion = CGPointMake(midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
        [bouncePath addLineToPoint:excursion];
        [bouncePath addLineToPoint:centerPoint];

        offsetDivider += 20;
        animationDuration = 1/offsetDivider * 10;
        if ((fabs(originalOffsetX/offsetDivider) < 6) && (fabs(originalOffsetY/offsetDivider) < 6)) {
            stopBouncing = YES;
        }
    }

    bounceAnimation.path = [bouncePath CGPath];
    bounceAnimation.duration = animationDuration;

    // Create a basic animation to restore the size of the placard.
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.duration = animationDuration;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];


    // Create an animation group to combine the keyframe and basic animations.
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];

    // Set self as the delegate to allow for a callback to reenable user interaction.
    theGroup.delegate = self;
    theGroup.duration = animationDuration;
    theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    theGroup.animations = @[bounceAnimation, transformAnimation];


    // Add the animation group to the layer.
    [welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];

    // Set the placard view's center and transformation to the original values in preparation for the end of the animation.
    placardView.center = centerPoint;
    placardView.transform = CGAffineTransformIdentity;
}

/**
 Animation delegate method called when the animation's finished: restore the transform and reenable user interaction.
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {

    rightImgView.transform = CGAffineTransformIdentity;
    self.userInteractionEnabled = YES;
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([rightImgView pointInside:[self convertPoint:point toView:rightImgView] withEvent:event] || (![menusView isHidden] && [exitButton pointInside:[self convertPoint:point toView:exitButton] withEvent:event]) || (![menusView isHidden] && showSendToDeskTop && [sendToDeskButton pointInside:[self convertPoint:point toView:sendToDeskButton] withEvent:event]))
        return YES;

    if ([menusView pointInside:[self convertPoint:point toView:menusView] withEvent:event]) {
        isHide = NO;
        return NO;
    }
    self.backgroundColor = [UIColor clearColor];

    if (!isMenusHidden) {
        [self menusAnimate];
    }
    [self hideOrShowMenus:YES];
    [self hidBtnViewWithDelay];
    return NO;
}

-(void)exit:(id)sender
{
    if (self.gameDelegate) {
        [self.gameDelegate exitGame];
    }
}

- (void)openSafari:(id)sender
{
//  get short_cut info from cturl
    if (showSendToDeskTop) {
        [UserDefaultsManager setObject:(NSMutableDictionary*)[ctUrl jsonFromCTUrl] forKey:[@"shortcut" stringByAppendingString:ctUrl.serviceId]];
        NSString *urlStr;
        if (USE_DEBUG_SERVER) {
            urlStr = [NSString stringWithFormat:@"%@%@service_id=%@&title=%@&icon=%@", YP_DEBUG_SERVER, SHORTCUT_PAGE_PATH, ctUrl.serviceId, ctUrl.shortCutTitle, ctUrl.shortCutIcon];
        } else {
            urlStr = [NSString stringWithFormat:@"%@%@service_id=%@&title=%@&icon=%@", SEARCH_SITE, SHORTCUT_PAGE_PATH, ctUrl.serviceId, ctUrl.shortCutTitle, ctUrl.shortCutIcon];
        }
        NSString *encodeUrl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodeUrl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_SEND_TO_DESK_TOP_CLICK kvs:Pair(@"send_to_desk_top", @"selected"), Pair(@"shortcut_url", ctUrl.url), nil];
    }
}

@end
