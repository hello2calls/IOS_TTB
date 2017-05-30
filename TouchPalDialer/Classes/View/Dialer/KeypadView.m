//
//  KeypadView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "KeypadView.h"
#import "ImageViewUtility.h"
#import "FunctionUtility.h"
#import "PhonePadGestureView.h"
#import "SpecialKey.h"
#import "NumberKey.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"
#import "PhonePadPressView.h"
#import <QuartzCore/QuartzCore.h>
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"


@implementation KeypadView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame andKeyPadType:(DailerKeyBoardType)padType andDelegate:(id<PhonePadKeyProtocol>)_delegate
{
    self = [super initWithFrame:frame];
    if (self) {
         self.delegate = _delegate;
         //load keys
        switch (padType) {
            case T9KeyBoardType:
            {
                ImageViewUtility *padBgView = [[ImageViewUtility alloc] initImageViewUtilityWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) wityStyle:@"KeyPadBgViewT9_style"];
                
                [padBgView setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
                PhonePadGestureView *phonepad = [[PhonePadGestureView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                [phonepad setSkinStyleWithHost:self forStyle:@"gesturePad_style"];
                
                phonepad.delegate = self.delegate;
                [padBgView addSubview:phonepad];
                [self addSubview:padBgView];
                
                PhonePadPressView *pressView = [[PhonePadPressView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                [pressView setSkinStyleWithHost:self forStyle:@"pressPad_style"];
                pressView.isT9 = YES;
                pressView.gestureDelegate = phonepad;
                [phonepad addSubview:pressView];
                
                NSString *path_number = [[NSBundle mainBundle] pathForResource:@"NumberKeys" ofType:@"plist"];
                NSDictionary *numberkeys_dic = [NSDictionary dictionaryWithContentsOfFile:path_number];
                for (id key in numberkeys_dic) {
                    NSDictionary *m_key_dic = [numberkeys_dic objectForKey:key];
                    NumberKey *numkey = [[NumberKey alloc] initPhonePadKeyWithDictionary:m_key_dic keyPadFrame:frame];
                    [numkey setSkinStyleWithHost:self forStyle:[m_key_dic objectForKey:@"key_style"]];
                    numkey.gestureDelegate = phonepad;
                    numkey.delegate = self.delegate;
                    numkey.pressDelegate = pressView;
                    [pressView addSubview:numkey];
                }
                break;
            }
            case QWERTYBoardType:
            {
                ImageViewUtility *padBgView = [[ImageViewUtility alloc] initImageViewUtilityWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) wityStyle:@"KeyPadBgViewQwerty_style"];
                
                [padBgView setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
                
                PhonePadGestureView *phonepad = [[PhonePadGestureView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                [phonepad setSkinStyleWithHost:self forStyle:@"gesturePad_style"];
                
                phonepad.delegate = self.delegate;
                [padBgView addSubview:phonepad];
                [self addSubview:padBgView];
                
                PhonePadPressView *pressView = [[PhonePadPressView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
                [pressView setSkinStyleWithHost:self forStyle:@"pressPad_style"];
                pressView.gestureDelegate = phonepad;
                [phonepad addSubview:pressView];
                
                NSArray *keys = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0", 
                                 @"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",
                                 @"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",
                                 @"*" ,@"Z",@"X",@"C",@"V",@"B",@"N",@"M",@"#",nil];
                int the_first_key_of_second_row = 10;
                int the_first_key_of_third_row = 20;
                int the_first_key_of_fourth_row = 29;
                int the_last_key_of_third_row = 28;
                
                CGFloat p_x = 0;
                CGFloat p_y = 0;
                CGFloat normalKey_width = frame.size.width / 10.0;
                CGFloat normalKey_height = frame.size.height / 4.0;
                
                NSString *keyStyle;
                CGFloat topAdjust = 0;
                NSInteger totalKeySize = keys.count;
                for(int i=0; i < totalKeySize; i++)
                {
                    keyStyle = @"qwertyNormalKey_style";
                    if(i<the_first_key_of_second_row){
                        p_x = i * normalKey_width;
                        topAdjust = 15;
                        
                    }else if(i>=the_first_key_of_second_row && i<the_first_key_of_third_row){
                        p_x = (i-10) * normalKey_width;
                        p_y = normalKey_height;
                        topAdjust = 5;
                        
                    }else if(i>=the_first_key_of_third_row && i<the_first_key_of_fourth_row){
                        p_x = frame.size.width / 20 + (i - 20) * normalKey_width;
                        p_y=  normalKey_height * 2;
                        topAdjust = -5;
                        
                    }else if(i>=the_first_key_of_fourth_row){
                        p_x = frame.size.width / 20 + (i-29) * normalKey_width;
                        p_y= normalKey_height * 3;
                    }
                    
                    CGRect keyFrame = CGRectMake(p_x, p_y, normalKey_width, normalKey_height);
                    
                    if(i==the_first_key_of_third_row) {
                        keyFrame = CGRectMake(p_x-15, p_y, normalKey_width+15, normalKey_height);
                    }
                    
                    if(i==the_last_key_of_third_row) {
                        keyFrame = CGRectMake(p_x, p_y, normalKey_width+15, normalKey_height);
                    }
                    
                    if(i==the_first_key_of_fourth_row){
                        keyFrame = CGRectMake(0, p_y, frame.size.width / 20.0 * 3, normalKey_height);
                    }
                    
                    if(i==keys.count-1){
                        keyFrame = CGRectMake(p_x, p_y, frame.size.width / 20.0 * 3, normalKey_height);
                    }
                    SpecialKey *key = [[SpecialKey alloc] initSpecialKeyWithFame:keyFrame andKeyString:[keys objectAtIndex:i] andKeyToneNumber:i%9+1 andKeyStyle:keyStyle];
                    key.topAdjust = 0;
                    [key setSkinStyleWithHost:self forStyle:keyStyle];
                    key.gestureDelegate = phonepad;
                    key.delegate = self.delegate;
                    key.pressDelegate = pressView;
                    key.hidden = NO;
                    [pressView addSubview:key];
                }
                break;
            }
            default:
                break;
        }
    }
    return self;
}
- (void)dealloc{
    [SkinHandler removeRecursively:self];
}
@end
