//
//  CallingAnimateTextView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-19.
//
//

#import "CallingAnimateTextView.h"
#import "VoipConsts.h"
#import <QuartzCore/QuartzCore.h>
#define ANIM_DUR 1.5

@interface DisplayAttr : NSObject
@property (nonatomic, copy) void(^block)(void);
@property (nonatomic, assign) BOOL needHightLight;
@property (nonatomic, retain) id text;
@end

@implementation DisplayAttr

@end

@implementation CallingAnimateTextView {
    UILabel  *_mainLabel;
    UILabel  *_altLabel;
    UILabel  *_indicatorLabel;
    UILabel  *_showingLabel;
    UILabel  *_hidingLabel;
    float _mainH;
    BOOL _animateGoing;
    BOOL _noChange;
    CGRect _origFrame;
    NSMutableArray __strong *_displayArray;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        float scaleRatio = WIDTH_ADAPT;
        float mainH = frame.size.height;
        _mainH = 30;
        UIFont *font = [UIFont systemFontOfSize: 19*scaleRatio];
        UIColor *color = [UIColor colorWithRed:COLOR_IN_256(0x33) green:COLOR_IN_256(0x33) blue:COLOR_IN_256(0x33) alpha:1];
        UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - mainH)/2, frame.size.width, mainH)];
        mainLabel.textColor = color;
        mainLabel.font = font;
        mainLabel.backgroundColor = [UIColor clearColor];
        mainLabel.textAlignment = NSTextAlignmentCenter;
        mainLabel.numberOfLines = 3;
        [self addSubview:mainLabel];
        _mainLabel = mainLabel;
        _origFrame = mainLabel.frame;
        
        
        UILabel *altLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - mainH)/2, frame.size.width, mainH)];
        altLabel.textColor = color;
        altLabel.font = font;
        altLabel.backgroundColor = [UIColor clearColor];
        altLabel.textAlignment = NSTextAlignmentCenter;
        altLabel.numberOfLines = 3;
        [self addSubview:altLabel];
        _altLabel = altLabel;
        _altLabel.alpha = 0;
        
        UILabel *indicator = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height)/2 + 30*scaleRatio, frame.size.width, 20)];
        indicator.textColor = color;
        indicator.font = font;
        indicator.backgroundColor = [UIColor clearColor];
        indicator.textAlignment = NSTextAlignmentCenter;
        indicator.text = @"...";
        [self addSubview:indicator];
        _indicatorLabel = indicator;
        _displayArray = [NSMutableArray array];
    }
    return self;
}

- (void)setTextColor:(UIColor *)color {
    _mainLabel.textColor = color;
    _altLabel.textColor = color;
    _indicatorLabel.textColor = color;
}

- (void)setInitialText:(NSString *)text {
    if (_mainLabel.alpha == 0) {
        _altLabel.text = text;
    } else {
        _mainLabel.text = text;
    }
    _noChange = NO;
    _indicatorLabel.hidden = NO;
    [_displayArray removeAllObjects];
}

- (void)decideShowingAndHidingLabel {
    if (_mainLabel.alpha == 0) {
        _showingLabel = _mainLabel;
        _hidingLabel = _altLabel;
    } else {
        _showingLabel = _altLabel;
        _hidingLabel = _mainLabel;
    }
}

- (void)normalAnimate{
    _animateGoing = YES;
    CGRect origFrame = _hidingLabel.frame;
    [UIView animateWithDuration:ANIM_DUR
                          delay:0
                        options:UIViewAnimationCurveLinear animations:^{
                            _showingLabel.alpha = 1;
                            _hidingLabel.frame = CGRectMake(0, origFrame.origin.y - _mainH, origFrame.size.width, origFrame.size.height);
                            _hidingLabel.alpha = 0;
                        } completion:^(BOOL finished) {
                            _hidingLabel.frame = origFrame;
                            _hidingLabel.alpha = 0;
                            _showingLabel.alpha = 1;
                            _animateGoing = NO;
                            [self checkRemainingChanges];
                        }];
}

- (void)checkRemainingChanges {
    if ([_displayArray count] > 0 && !_noChange) {
        DisplayAttr *attr = (DisplayAttr *)_displayArray[0];
        if (attr.needHightLight) {
            if ([attr.text isKindOfClass:[NSString class]]) {
                [self highLightChangeText:attr.text changingBlock:attr.block];
            } else if ([attr.text isKindOfClass:[NSAttributedString class]]) {
                [self hightLightChaneAttrText:attr.text withChangingBlock:attr.block];
            }
        } else {
            if ([attr.text isKindOfClass:[NSString class]]) {
                [self chaneText:attr.text changingBlock:attr.block];
            } else if ([attr.text isKindOfClass:[NSAttributedString class]]) {
                [self changeAttrText:attr.text withChangingBlock:attr.block];
            }
        }
        [_displayArray removeObject:attr];
    }
}

- (void)hightLightChaneAttrText:(NSAttributedString *)text withChangingBlock:(void(^)(void))block{
    if (_noChange) {
        return;
    }
    if (_animateGoing) {
        [self addToDisplay:block withText:text needHightlight:YES];
        return;
    }
    if (block) {
        block();
    }
//    [self decideShowingAndHidingLabel];
    _showingLabel.attributedText = text;
    [self highLightAnimate];
}

- (void)changeAttrText:(NSAttributedString *)text withChangingBlock:(void (^)(void))block{
    if (_noChange) {
        return;
    }
    if (_animateGoing) {
        [self addToDisplay:nil withText:text needHightlight:NO];
        return;
    }
    [self decideShowingAndHidingLabel];
    _showingLabel.attributedText = text;
    [self normalAnimate];
}


- (void)chaneText:(NSString *)text changingBlock:(void(^)(void))block{
    if (_noChange) {
        return;
    }
    if (_animateGoing) {
        [self addToDisplay:block withText:text needHightlight:NO];
        return;
    }
    if (block) {
        block();
    }
    [self decideShowingAndHidingLabel];
    _showingLabel.text = text;
    [self normalAnimate];
}

- (void)highLightChangeText:(NSString *)text changingBlock:(void (^)(void))block{
    if (_noChange) {
        return;
    }
    if (_animateGoing) {
        [self addToDisplay:block withText:text needHightlight:YES];
        return;
    }
    if (block) {
        block();
    }
    [self decideShowingAndHidingLabel];
    _showingLabel.text = text;
    [self highLightAnimate];
}

- (void)addToDisplay:(id)block withText:(id)text needHightlight:(BOOL)hightlight{
    DisplayAttr *displayAttr = [[DisplayAttr alloc] init];
    displayAttr.block = block;
    displayAttr.needHightLight = hightlight;
    displayAttr.text = text;
    [_displayArray addObject:displayAttr];
}

- (void)highLightAnimate {
    _animateGoing = YES;
    CGRect origFrame = _hidingLabel.frame;
    [UIView animateWithDuration:ANIM_DUR/2
                          delay:0
                        options:UIViewAnimationCurveLinear animations:^{
                            _showingLabel.alpha = 1;
                            _showingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
                            _hidingLabel.frame = CGRectMake(0, origFrame.origin.y - _mainH, origFrame.size.width, origFrame.size.height);
                            _hidingLabel.alpha = 0;
                        } completion:^(BOOL finished) {
                            _hidingLabel.frame = origFrame;
                            _hidingLabel.alpha = 0;
                            _showingLabel.alpha = 1;
                            [UIView animateWithDuration:ANIM_DUR/2
                                                  delay:0
                                                options:UIViewAnimationCurveLinear animations:^{
                                                    _showingLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                                                } completion:^(BOOL finished) {
                                                    _animateGoing = NO;
                                                    [self checkRemainingChanges];
                                                }];
                        }];
}

- (void)forceChangeText:(id)text withDoneBlock:(void(^)(void))block{
    _noChange = YES;
    if (_animateGoing) {
        dispatch_after(ANIM_DUR, dispatch_get_main_queue(), ^{
            [self forceChangeText:text withDoneBlock:block];
        });
        return;
    }
    [_displayArray removeAllObjects];
    [UIView animateWithDuration:0.1 animations:^{
        _mainLabel.alpha = 1;
        _mainLabel.frame = _origFrame;
        _altLabel.alpha = 0;
        _altLabel.frame = _origFrame;
    } completion:^(BOOL finished) {
        if ([text isKindOfClass:[NSAttributedString class]]) {
            [_mainLabel setAttributedText:text];
        } else {
            _mainLabel.text = text;
        }
        if (block) {
            block();
        }
    }];
}

- (void)showIndicator {
    if (_noChange) {
        return;
    }
    _indicatorLabel.hidden = NO;
}

- (void)animateIndcator {
    if (_indicatorLabel.hidden) {
        return;
    }
    NSString *originalText = _indicatorLabel.text;
    if (originalText.length == 3) {
        originalText = @".";
    } else if (originalText.length == 2)  {
        originalText = @"...";
    } else if (originalText.length == 1) {
        originalText = @"..";
    }
    _indicatorLabel.text = originalText;
}

- (void)hideIndicator {
    _indicatorLabel.hidden = YES;
}

- (void)noChange {
    _noChange = YES;
}

@end
