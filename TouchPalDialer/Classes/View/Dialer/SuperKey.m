//
//  SuperKey.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/5/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SuperKey.h"
#import "consts.h"
#import "PhonePadModel.h"
#import "CootekSystemService.h"
#import "FunctionUtility.h"
#import "PhonePadGestureView.h"
#import "CootekNotifications.h"
#import "GestureModel.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"

#define minX -107
#define minY -CELL_HEIGHT
#define maxX 107
#define maxY CELL_HEIGHT

#define DEFAULT_LENGTH 0

@interface SuperKey(){
    BOOL isGestureMode;
    BOOL preGestureMode;
}
@end

@implementation SuperKey
@synthesize delegate;
@synthesize gestureDelegate;
@synthesize pressDelegate;
@synthesize str_number;
@synthesize m_timer;
@synthesize img_bg;
@synthesize img_bg_selected;
@synthesize img_bg_normal;
@synthesize is_sound;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		clickable = YES;
		being_click = NO;
		have_done_longclick = NO;
        is_sound = YES;
        
		self.img_bg_normal = nil;
		self.img_bg = nil;
        self.img_bg_selected = nil;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenTokenBusy) name:N_CLICK_TOKEN_BUSY object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenTokenIdle) name:N_CLICK_TOKEN_IDLE object:nil];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame andKeyStyle:(NSString *)keyStyle{
     
     self = [self initWithFrame:frame];
     if (self) {        
     }
     return self;
}


- (void)doWhenPress {
	// for subclass.
	cootek_log(@"super key %d do press.", number);
}
- (void)beginTouchWithKeyCenter:(CGPoint)center{
    // for subclass.
}

- (void)doWhenLeftSlide {
	// only delete key has special action.
	[self doWhenSlide];
}

- (void)doWhenLongPress {
	// for subclass.
	cootek_log(@"super key %d do long press.", number);
	have_done_longclick = YES;
}

- (void)doWhenSlide {
	// for subclass.
	cootek_log(@"super key %d do slide.", number);
}

- (void)doWhenTokenBusy {
	clickable = NO;
}

- (void)doWhenTokenIdle {
	clickable = YES;
}
 
// Touchs control.
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    if (!clickable && !being_click) {
		return;
	}
    if ( pressDelegate != nil && _keyboardHasAnimation){
        [pressDelegate setAnimationKeyValue:self];
    }
    [super touchesBegan:touches withEvent:event];
    preGestureMode = [gestureDelegate preGesturePadState];
    isGestureMode = NO;
    if (preGestureMode) {
        return;
    }
	if (clickable) {
		being_click = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_CLICK_TOKEN_BUSY object:nil userInfo:nil];
	}
	self.img_bg = img_bg_selected;
    if (m_timer) {
        [m_timer invalidate];
    }
	self.m_timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(doWhenLongPress) userInfo:nil repeats:NO];
    [self setNeedsDisplay];
    [self beginTouchWithKeyCenter:self.center];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    if (!clickable && !being_click) {
	}else{
        isGestureMode = [gestureDelegate isGestureMode];
        if (isGestureMode) {
            if ( pressDelegate != nil && _keyboardHasAnimation){
                [pressDelegate stopPressViewAnimation];
            }
            [self backNormalKeyPad];
            [self setNeedsDisplay];
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((!clickable && !being_click)){return;}
    [super touchesCancelled:touches withEvent:event];
    [self backNormalKeyPad];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((!clickable && !being_click)){return;}
    [super touchesEnded:touches withEvent:event];
    [self endClickKeyPad];
}
- (void)endClickKeyPad{
     cootek_log(@"**********preGestureMode status= %d********currentstatus = %d",preGestureMode,isGestureMode);
    if (isGestureMode||(!isGestureMode&& preGestureMode)) {
        return;
    }
    if (m_timer != nil && [m_timer isValid]) {
        [m_timer invalidate];
        have_done_longclick = NO;
    }
    if (!have_done_longclick) {
        [self doWhenPress];
    }
    [self backNormalKeyPad];
	[self setNeedsDisplay];
}
- (void)backNormalKeyPad{
    self.img_bg = img_bg_normal;
	[[NSNotificationCenter defaultCenter] postNotificationName:N_CLICK_TOKEN_IDLE object:nil userInfo:nil];
	being_click = NO;
	have_done_longclick = NO;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code.
    if ( _keyboardHasAnimation ){
        return;
    }
    if (img_bg != nil) {
        CGFloat widthHeight = img_bg.size.width/img_bg.size.height;
        CGFloat rectWidth = rect.size.height * widthHeight;
        CGFloat leftAdjust = 0;
        if ( self.isA ){
            leftAdjust = 15;
        }
        if ( self.isMaxWidth ){
            rectWidth = rect.size.width;
        }
        [img_bg drawInRect:CGRectMake(rect.origin.x, rect.origin.y + 0.5, rect.size.width, rect.size.height)];
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SkinHandler removeRecursively:self];
}

- (BOOL)isGestureMode
{
    return isGestureMode;
}

@end
