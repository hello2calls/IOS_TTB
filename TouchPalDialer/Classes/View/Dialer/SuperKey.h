//
//  SuperKey.h
//  TouchPalDialer
//
//  Created by zhang Owen on 8/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhonePadKeyProtocol.h"
#import "UIView+WithSkin.h"
#import "PhonePadModel.h"

#define LETTER_COLOR @"letterColor"
#define LETTER_COLOR_HT @"letterColor_ht"

#define IMAGE_ON_KEY @"imageOnKey"
#define IMAGE_ON_KEY_HT @"imageOnKey_ht"

@interface SuperKey : UIView{
	NSTimer *m_timer;
	NSString *str_number;
	id<PhonePadKeyProtocol> __unsafe_unretained delegate;
	
	int number;
	BOOL clickable; //only a key can be clicked.
	BOOL being_click;
	BOOL have_done_longclick;
    BOOL is_sound;

	UIImage *img_bg;
	UIImage *img_bg_selected;
	UIImage *img_bg_normal;

    NSString *_keyStyle;

}

@property(nonatomic, retain) NSTimer *m_timer;
@property(nonatomic, retain) NSString *str_number;
@property(nonatomic, assign) id<PhonePadKeyProtocol> delegate;
@property(nonatomic, assign) id<GesturePadKeyDelegate> gestureDelegate;
@property(nonatomic, assign) id<PhonePadPressProtocol> pressDelegate;
@property(nonatomic, retain) UIImage *img_bg;
@property(nonatomic, retain) UIImage *img_bg_normal;
@property(nonatomic, retain) UIImage *img_bg_selected;
@property(nonatomic) BOOL is_sound;
@property(nonatomic, assign) BOOL isAnimation;
@property(nonatomic, assign) BOOL keyboardHasAnimation;
@property(nonatomic, assign) BOOL isA;
@property(nonatomic, assign) BOOL isL;
@property(nonatomic, assign) BOOL isMaxWidth;
@property(nonatomic, assign) float topAdjust;

- (void)doWhenPress;
- (void)beginTouchWithKeyCenter:(CGPoint)center;
- (void)doWhenLongPress;
- (void)doWhenSlide;
- (void)doWhenLeftSlide;

- (void)doWhenTokenBusy;
- (void)doWhenTokenIdle;
- (void)endClickKeyPad;
- (void)backNormalKeyPad;
- (id)initWithFrame:(CGRect)frame andKeyStyle:(NSString *)keyStyle;
- (BOOL)isGestureMode;
@end
