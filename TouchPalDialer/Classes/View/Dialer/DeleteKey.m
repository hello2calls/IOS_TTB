//
//  DeleteKey.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "DeleteKey.h"
#import "consts.h"
#import "CootekNotifications.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "CootekSystemService.h"
#import "TouchPalVersionInfo.h"
@interface DeleteKey () {
    UILabel *textLabel_;
    CGPoint begin_point;
    CGPoint end_point;
}

@property (nonatomic, retain) UIColor* textNormalColor;
@property (nonatomic, retain) UIColor* textDisableColor;
@property (nonatomic, retain) UIColor* textHighlightedColor;

@end

@implementation DeleteKey

@synthesize textNormalColor;
@synthesize textDisableColor;
@synthesize textHighlightedColor;
@synthesize disableImage;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        textLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, frame.size.width, frame.size.height-29)];
        [textLabel_ setTextAlignment:NSTextAlignmentCenter];
        [textLabel_ setFont:[UIFont systemFontOfSize:12]];
        [textLabel_ setText:NSLocalizedString(@"Delete", @"")];
        [textLabel_ setBackgroundColor:[UIColor clearColor]];
        [self addSubview:textLabel_];
    }
    return self;
}
- (void)doWhenPress {
	[super doWhenPress];
	[delegate deleteInputNumer];
    if ([AppSettingsModel appSettings].dial_tone){
            [CootekSystemService playCustomKeySound:101];
        }
}

- (void)doWhenLeftSlide {
    [super doWhenLeftSlide];
	[delegate deleteAllInputNumber];
}

- (void)doWhenLongPress {
	[super doWhenLongPress];
	[delegate deleteAllInputNumber];
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (!clickable && !being_click) {
		return;
	}
	if (clickable) {
		being_click = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:N_CLICK_TOKEN_BUSY object:nil userInfo:nil];
		begin_point = [[touches anyObject] locationInView:self];
	}
	self.img_bg = img_bg_selected;
    // set label color to highlighted
    textLabel_.textColor = textHighlightedColor;
    self.m_timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(doWhenLongPress) userInfo:nil repeats:NO];
    [self setNeedsDisplay]; 
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!clickable && !being_click){return;}
    end_point = [[touches anyObject] locationInView:self];
    // set label color to normal
    textLabel_.textColor = textNormalColor;
    self.img_bg = img_bg_normal;
    [self endClickKeyPad];
}
- (void)willDrawDeleteKey:(BOOL)isEnable{
    self.userInteractionEnabled = isEnable;
    if (isEnable) {
        textLabel_.textColor = textNormalColor;
        self.img_bg = img_bg_normal;
    }else{
        textLabel_.textColor = textDisableColor;
        self.img_bg = disableImage;
    }
    [self setNeedsDisplay];
}
- (void)backNormalKeyPad{
    if ( self.userInteractionEnabled) {
        textLabel_.textColor = textNormalColor;
        self.img_bg = img_bg_normal;
    }else{
        textLabel_.textColor = textDisableColor;
        self.img_bg = disableImage;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:N_CLICK_TOKEN_IDLE object:nil userInfo:nil];
	being_click = NO;
	have_done_longclick = NO;
}
- (void)endClickKeyPad{
    if (m_timer != nil && [m_timer isValid]) {
        [m_timer invalidate];
        have_done_longclick = NO;
    }
    if (!have_done_longclick) {
        if ((begin_point.x - end_point.x) > 65) {
            [self doWhenLeftSlide];
        } else {
            [self doWhenPress];
        }
    }
    [self backNormalKeyPad];
	[self setNeedsDisplay];
}

- (id)selfSkinChange:(NSString *)style{
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    NSDictionary *propertyDic = [manager getPropertyDicByStyle:style];
    self.img_bg_normal = [manager getCachedImageByName:[propertyDic objectForKey:IMAGE_FOR_NORMAL_STATE]];
    self.img_bg_selected = [manager getCachedImageByName:[propertyDic objectForKey:IMAGE_FOR_HIGHLIGHTED_STATE]];
    self.disableImage = [manager getCachedImageByName:[propertyDic objectForKey:IMAGE_FOR_DISABLED_STATE]];
    self.img_bg = img_bg_normal;
    
//    self.textNormalColor = [manager getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]];
//    self.textHighlightedColor = [manager getUIColorFromNumberString:[propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]];
//    self.textDisableColor = [manager getUIColorFromNumberString:[propertyDic objectForKey:@"textColor_disable"]];
//    textLabel_.textColor = self.textNormalColor;
    textLabel_.hidden = YES;
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    [self setNeedsDisplay];
    return toTop;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code.
    float scale = [FunctionUtility imageScale];
    float width = img_bg.size.width/scale;
    float height = img_bg.size.height/scale;
    if (img_bg != nil) {
        [img_bg drawInRect:CGRectMake((rect.size.width-width)/2, (rect.size.height-height)/2,width,height)];
    }
}
@end
