//
//  SpecialKey.m
//  TouchPalDialer
//
//  Created by zhang Owen on 8/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SpecialKey.h"
#import "consts.h"
#import "CootekSystemService.h"
#import "TouchPalDialerAppDelegate.h"
#import "CootekNotifications.h"
#import "TPDialerResourceManager.h"
#import "PhonePadModel.h"
#import "FunctionUtility.h"
#import "TouchPalVersionInfo.h"
@implementation SpecialKey{
    NSString *subStr;
}
@synthesize textColor;
@synthesize textColor_ht;
@synthesize imageOnKey_ht;
@synthesize imageOnKey;
@synthesize minorTextColor;

//for qwertyKey initiation
- (id) initSpecialKeyWithFame:(CGRect)frame andKeyString:(NSString *)keyString andKeyToneNumber:(int)tone_number andKeyStyle:(NSString *)keyStyle{
	
	if (self = [self initWithFrame:frame andKeyStyle:keyStyle]) {
		self.str_number = keyString;
        subStr = @"";
        if([keyString isEqualToString:@"*"]){
            subStr = @"9键";
            self.isMaxWidth = YES;
        }else if([keyString isEqualToString:@"#"]){
            subStr = @"粘贴";
            self.isMaxWidth = YES;
        }else if ([str_number isEqualToString:@"A"]){
            self.isA = YES;
        }else if ([str_number isEqualToString:@"L"]){
            self.isL = YES;
        }
        toneNumber = tone_number;
	}
	return self;
}

- (void)doWhenPress
{
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
	if (appSettingsModel.dial_tone) {
            [CootekSystemService playCustomKeySound:toneNumber]; //按键声音
        }
    [super doWhenPress];
    [delegate clickPhonePadKey:str_number];
}

- (void)doWhenLongPress{
    [super doWhenLongPress];
    if ([subStr isEqualToString:@"9键"]){
        [delegate clickKeyBoardChanged:T9KeyBoardType];
    }else if([subStr isEqualToString:@"粘贴"]){
        [delegate clickPaste];
    }
}

- (id)selfSkinChange:(NSString *)style{
    NSDictionary *propertyDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:style];
 
    self.img_bg_selected = [[TPDialerResourceManager sharedManager] getCachedImageByName:[propertyDic objectForKey:BACK_GROUND_IMAGE_HT]];
    
    if([propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]){
        self.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:TEXT_COLOR_FOR_STYLE]];
        self.textColor_ht = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:HT_TEXT_COLOR_FOR_STYLE]];
    }
    NSString *imageOnkeyString = [propertyDic objectForKey:IMAGE_ON_KEY];
    if(imageOnkeyString){
        self.imageOnKey = [[TPDialerResourceManager sharedManager] getImageByName:imageOnkeyString];
        self.imageOnKey_ht = [[TPDialerResourceManager sharedManager] getImageByName:[propertyDic objectForKey:IMAGE_ON_KEY_HT]];
    }
    self.minorTextColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[propertyDic objectForKey:@"minorTextColor"]];
    self.keyboardHasAnimation = [[[TPDialerResourceManager sharedManager]getResourceNameByStyle:@"keyboardHasAnimation"]boolValue];
    [self setNeedsDisplay];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if([str_number isEqualToString:@"A"]){
        rect = CGRectMake(rect.origin.x+15, rect.origin.y, rect.size.width-15, rect.size.height);
    }
    if([str_number isEqualToString:@"L"]){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width-15, rect.size.height);
    }
	[super drawRect:rect];
    // Drawing code.
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSString *fontStr = @"Helvetica-Light";
    if (!being_click) {
        if(textColor!=nil){
            CGContextSetFillColorWithColor(context,[textColor CGColor]);
        }
    }else{
        if(textColor_ht!=nil)   
        {
            CGContextSetFillColorWithColor(context,[textColor_ht CGColor]);
        }
    }
    if ( self.isAnimation ){
        CGContextSetFillColorWithColor(context,[self.textColor_ht CGColor]);
    }

    int font_size = FONT_SIZE_1;
    int top_cap = (self.frame.size.height-font_size)/2;
    int left_cap = 0;
    int frame_width = rect.size.width;
    if([str_number isEqualToString:@"A"]){
        left_cap = 15;
    }
    if ([str_number isEqualToString:@"*"]) {
        font_size = 40;
        top_cap = self.frame.size.height/2 - 22;
    }
    if ( [str_number isEqualToString:@"#"]) {
        font_size = FONT_SIZE_2_5;
        top_cap = self.frame.size.height/2 - font_size;
    }
    if ( ([str_number integerValue] >0 && [str_number integerValue]<=9 ) || [str_number isEqualToString:@"0"]){
        font_size = FONT_SIZE_0_5;
    }
    
    float top = top_cap + self.topAdjust;
    
    if ( !self.keyboardHasAnimation ){
        top = top_cap;
    }
    
    
    [str_number drawInRect:CGRectMake(left_cap, top, frame_width, rect.size.height)
                  withFont:[UIFont fontWithName:fontStr size:font_size]
             lineBreakMode:NSLineBreakByClipping
                 alignment:NSTextAlignmentCenter];
    if ( subStr != nil && [subStr length] > 0 ){
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (!being_click) {
            if ( minorTextColor!= nil ){
                CGContextSetFillColorWithColor(context,minorTextColor.CGColor);
            }
        }else{
            if(textColor_ht!=nil)
            {
                CGContextSetFillColorWithColor(context,[textColor_ht CGColor]);
            }
        }
        if ( self.isAnimation ){
            CGContextSetFillColorWithColor(context,[self.textColor_ht CGColor]);
        }
        float topCap = self.frame.size.height/2;
        
        float top = topCap + self.topAdjust;
        
        if ( !self.keyboardHasAnimation ){
            top = topCap;
        }

        [subStr drawInRect:CGRectMake(self.frame.size.width/4,top, self.frame.size.width/2, FONT_SIZE_5_5)
                  withFont:[UIFont fontWithName:@"Helvetica-Light" size:FONT_SIZE_5_5]
             lineBreakMode:NSLineBreakByClipping
                 alignment:NSTextAlignmentCenter];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
