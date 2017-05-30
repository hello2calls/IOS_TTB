//
//  NumberKey.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "NumberKey.h"
#import "consts.h"
#import "CootekSystemService.h"
#import "TouchPalDialerAppDelegate.h"
#import "CootekNotifications.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "TouchPalVersionInfo.h"
@implementation NumberKey{
    int specialSize;
}
@synthesize letter;
@synthesize m_info_dic;

@synthesize textColor;
@synthesize textColor_ht;
@synthesize minorTextColor = minorTextColor_;
- (id)initPhonePadKeyWithDictionary:(NSDictionary *)info_dic keyPadFrame:(CGRect)padFrame{
	self.m_info_dic = info_dic;
    
    int padNumber = [[info_dic objectForKey:@"number"]intValue];
    
    CGFloat keyWidth = padFrame.size.width / 3.0;
    CGFloat keyHeight = padFrame.size.height / 4.0;
    
	CGFloat keyX = keyWidth * (int)((padNumber-1) % 3);
    CGFloat keyY = keyHeight * (int)((padNumber-1) / 3);
    
    specialSize = 0;
    if (0 == padNumber) {
        keyX = keyWidth;
        keyY = keyHeight * 3;
        
    }else if ( 10 == padNumber ){
        keyX = 0;
        keyY = keyHeight * 3;
        specialSize = 40;
        
    }else if ( 11 == padNumber ){
        keyX = keyWidth * 2;
        keyY = keyHeight * 3;
        specialSize = 20;
    }
    
    NSString *keyStyle = [info_dic objectForKey:@"key_style"];
     
	CGRect frame_key = CGRectMake(keyX, keyY, keyWidth, keyHeight);
	
	if (self = [self initWithFrame:frame_key andKeyStyle:keyStyle]) {
		number = [[info_dic objectForKey:@"number"] intValue];
		self.str_number = [NSString stringWithFormat:@"%d", number];
		self.letter = [info_dic objectForKey:@"letter_eng"];
        if ( number == 10 ){
            self.str_number = @"*";
        }else if ( number == 11 ){
            self.str_number = @"#";
        }
        if ( number > 0 && number <= 3){
            self.topAdjust = self.frame.size.height*7/8 - 39;
        }else if ( number >3 && number <= 6){
            self.topAdjust = (self.frame.size.height*2-78)/3 - self.frame.size.height/8;
        }else if ( number >6 && number <= 9){
            self.topAdjust = (self.frame.size.height-39)/3 - self.frame.size.height/8;
        }else{
            self.topAdjust = -self.frame.size.height/8;
        }
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:N_PHONE_PAD_LANGUAGE_CHANGED object:nil];
	}
	return self;
}

- (void)beginTouchWithKeyCenter:(CGPoint)center{
    [delegate beginTouchWithKeyCenter:center];
}
- (void)doWhenPress {
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
	if (appSettingsModel.dial_tone) {
		[CootekSystemService playCustomKeySound:number]; //按键声音
        }
    
	[super doWhenPress];
	[self setNeedsDisplay];
	[delegate clickPhonePadKey:str_number];
}

- (void)doWhenLongPress {
	if (![super isGestureMode]) {
        [super doWhenLongPress];
        if ([str_number isEqualToString:@"0"]) {
            [delegate clickPhonePadKey:@"+"];
        }else if ([str_number isEqualToString:@"*"]){
            [delegate clickKeyBoardChanged:QWERTYBoardType];
        }else if([str_number isEqualToString:@"#"]){
            [delegate clickPaste];
        }
    }
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
     self.img_bg_selected = [[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE_HT]];
   
    if([propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]){
        self.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]];
        self.textColor_ht = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]];
    }
    self.minorTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"minorTextColor"]];
    self.keyboardHasAnimation = [[[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"keyboardHasAnimation"] boolValue];
    [self setNeedsDisplay];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
- (void)refresh {
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
    if (!being_click){
        CGContextSetFillColorWithColor(context,[self.textColor CGColor]);
    } else {
        CGContextSetFillColorWithColor(context,[self.textColor_ht CGColor]);
    }
    if ( self.isAnimation ){
        CGContextSetFillColorWithColor(context,[self.textColor_ht CGColor]);
    }
    float top = self.frame.size.height*1/8;// + self.topAdjust;
    float fontSize = FONT_SIZE_0_KEY;
    if ( specialSize != 0 ){
        fontSize = specialSize;
    }
    if ( !self.keyboardHasAnimation ){
        top = self.frame.size.height*1/8;
    }
	[str_number drawInRect:CGRectMake(self.frame.size.width/4, top, self.frame.size.width/2, fontSize)
				  withFont:[UIFont fontWithName:@"Helvetica-Light" size:fontSize]
			 lineBreakMode:NSLineBreakByClipping
				 alignment:NSTextAlignmentCenter];
    if (!being_click){
        CGContextSetFillColorWithColor(context,[minorTextColor_ CGColor]);
    }
    if ( self.isAnimation ){
        CGContextSetFillColorWithColor(context,[self.textColor_ht CGColor]);
    }
	if (letter != nil && ![letter isEqualToString:@""]) {
        CGFloat letterSize = FONT_SIZE_7;
        CGFloat letterTop = top + 28;
        if (TPScreenHeight() >= 600) {
            letterSize = FONT_SIZE_5_5;
            letterTop = top + 27;
        }
        if ([letter isEqualToString:@"+"]) {
            letterSize += 4;
            letterTop -= 2;
        }
        [letter drawInRect:CGRectMake(self.frame.size.width/4, letterTop, self.frame.size.width/2, letterSize)
                  withFont:[UIFont fontWithName:@"Helvetica-Light" size:letterSize]
             lineBreakMode:NSLineBreakByClipping
                 alignment:NSTextAlignmentCenter];
	}
}

- (void)dealloc {
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
