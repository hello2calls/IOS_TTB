//
//  PhonePadPressView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/16.
//
//

#import "PhonePadPressView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@interface PhonePadPressView(){
    BOOL isPress;
    BOOL isAnimation;
    BOOL clickAble;
    float posX;
    float posY;
    
    CGRect _initFrame;
    NSTimer *timer;
    
    int animationNumber;
    float alphaA;
    float alphaB;
    float alphaC;
    
    float _radius;
    
    BOOL preGestureMode;
    BOOL keyboardHasAnimation;
    CAGradientLayer *_topShadowLayer;
}

@end

@implementation PhonePadPressView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if ( self ){
        self.backgroundColor = [UIColor clearColor];
        clickAble = YES;
        isPress = NO;
        isAnimation = NO;
        posX = 0;
        posY = 0;
        _initFrame = frame;
        _radius = 0;
        preGestureMode = NO;
        keyboardHasAnimation = NO;
        [self setTopShadowView:frame];
    }
    
    return self;
}

- (void)stopAnimation{
    if ( timer != nil && [timer isValid]){
        [timer invalidate];
        timer = nil;
        isAnimation = NO;
    }
    if ( self.pressKey!= nil ){
        self.pressKey.isAnimation = NO;
        [self.pressKey setNeedsDisplay];
        self.pressKey = nil;
    }
}

- (void)doAnimation{
    animationNumber += 1;
    if ( animationNumber >= 20 ){
        [self stopAnimation];
    }
    float value = fabsf((float)sin(M_PI/20*animationNumber));
    
    alphaA = 0.2*value;
    alphaB = 0.3*value;
    
    if ( animationNumber <= 10 )
        alphaC = 0.8 + 0.2*value;
    
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!keyboardHasAnimation){
        [super touchesBegan:touches withEvent:event];
        return;
    }
    if ( !clickAble && !isPress )
        return;
    clickAble = NO;
    isPress = YES;
    _radius = 0;
    [self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
    if ( ![_gestureDelegate preGesturePadState] ){
        [self setAnimationPro];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!keyboardHasAnimation){
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    if ( !clickAble && !isPress )
        return;
    [self finishPress];
    [self setNeedsDisplay];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!keyboardHasAnimation){
        [super touchesMoved:touches withEvent:event];
        return;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!keyboardHasAnimation){
        [super touchesEnded:touches withEvent:event];
        return;
    }
    if ( !clickAble && !isPress )
        return;
    [self finishPress];
    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}


- (void)finishPress{
    isPress = NO;
    clickAble = YES;
}

- (void)setAnimationPro{
    isAnimation = YES;
    animationNumber = 0;
    alphaA = 0;
    alphaB = 0;
    alphaC = 0;
    if ( self.pressKey == nil )
        return;
    CGRect oldFrame = self.pressKey.frame;
    posX = oldFrame.origin.x + oldFrame.size.width/2;
    posY = oldFrame.origin.y + oldFrame.size.height/2;
    if (_isT9){
        _radius = 60;
        posY -= 1;
    }else{
        _radius = 55;
        posY += 1;
        if ( self.pressKey.isA )
            posX += 7.5;
        if ( self.pressKey.isL )
            posX -= 7.5;
    }
}
- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
    self.img_bg_selected = [[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE_HT]];
    keyboardHasAnimation = [[[TPDialerResourceManager sharedManager]getResourceNameByStyle:@"keyboardHasAnimation"]boolValue];
    
    NSString *startColorStyle = [propertyDic objectForKey:@"keyPadTopShadow_start_color"];
    NSString *endColorStyle = [propertyDic objectForKey:@"keyPadTopShadow_end_color"];
    if (startColorStyle != nil  && endColorStyle != nil) {
        UIColor *startColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:startColorStyle];
        UIColor *endColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:endColorStyle];
        _topShadowLayer.colors = [[NSArray alloc] initWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    }
    
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

- (void)drawRect:(CGRect)rect{
    if ( !isAnimation && !isPress && !keyboardHasAnimation)
        return;
    float radius1 = _radius;
    float radius2 = radius1*5/6;
    float radius3 = radius1*3/4*alphaC;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect frameRect;
    if ( _radius > 0 ){
        if ( isAnimation ){
            frameRect = CGRectMake(posX-radius1/2, posY-radius1/2, radius1, radius1);
            CGContextSetLineWidth(context, 0);
            CGContextAddEllipseInRect(context, frameRect);
            CGContextClip(context);
            CGContextSetAlpha(context,alphaA);
            CGContextDrawImage(context, frameRect, [_img_bg_selected CGImage]);
            CGContextStrokePath(context);
            
            frameRect = CGRectMake(posX-radius2/2, posY-radius2/2, radius2, radius2);
            CGContextSetLineWidth(context, 0);
            CGContextAddEllipseInRect(context, frameRect);
            CGContextClip(context);
            CGContextSetAlpha(context,alphaB);
            CGContextDrawImage(context, frameRect, [_img_bg_selected CGImage]);
            CGContextStrokePath(context);
            
            frameRect = CGRectMake(posX-radius3/2, posY-radius3/2, radius3, radius3);
            CGContextSetLineWidth(context, 0);
            CGContextAddEllipseInRect(context, frameRect);
            CGContextClip(context);
            CGContextSetAlpha(context,1);
            CGContextDrawImage(context, frameRect, [_img_bg_selected CGImage]);
            CGContextStrokePath(context);

        }else if ( isPress ){
            frameRect = CGRectMake(posX-radius3/2, posY-radius3/2, radius3, radius3);
            CGContextSetLineWidth(context, 0);
            CGContextAddEllipseInRect(context, frameRect);
            CGContextClip(context);
            CGContextSetAlpha(context,1);
            CGContextDrawImage(context, frameRect, [_img_bg_selected CGImage]);
            CGContextStrokePath(context);
        }
    }
    [super drawRect:rect];
    
}

#pragma mark views
- (void) setTopShadowView:(CGRect)frame {
    CGRect topShadowFrame = CGRectMake(frame.origin.x, frame.origin.y - KEY_PAD_SHADOW_TOP_LENGTH, frame.size.width, KEY_PAD_SHADOW_TOP_LENGTH);
    UIView *topShadowView = [[UIView alloc] initWithFrame:topShadowFrame];
    topShadowView.backgroundColor = [UIColor clearColor];
    topShadowView.clipsToBounds = YES;
    
    _topShadowLayer = [CAGradientLayer layer];
    _topShadowLayer.frame = topShadowView.bounds;
    [topShadowView.layer insertSublayer:_topShadowLayer atIndex:0];
    
    [self addSubview:topShadowView];
}

#pragma mark PhonePadPressProtocol

- (void)setAnimationKeyValue:(id)key{
    [self stopAnimation];
    if ( ![key isKindOfClass:[SuperKey class]] ){
        return;
    }
    SuperKey *pressKey = (SuperKey *)key;
    self.pressKey = pressKey;
    self.pressKey.isAnimation = YES;
}


- (void)stopPressViewAnimation{
    [self finishPress];
    [self stopAnimation];
    [self setNeedsDisplay];
}

@end
