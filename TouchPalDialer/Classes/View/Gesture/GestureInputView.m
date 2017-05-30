//
//  GestureInputView.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GestureInputView.h"
#import "TPDialerResourceManager.h"
#import "NumberKey.h"
#define GESTURE_COLOR @"gestureColor"

@implementation GestureInputView

@synthesize stroke;
@synthesize currentPath;
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.currentPath = [UIBezierPath bezierPath];
        Strokie *tmpstrokie = [[Strokie alloc] init];
        self.stroke = tmpstrokie;
        _skinStyle_Dic=[[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"gesturePad_style"];
        _imageView = [[ImageViewUtility alloc] initImageViewUtilityWithFrame:self.bounds wityStyle:@"KeyPadBgViewT9_style"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [_imageView setSkinStyleWithHost:self forStyle:DRAW_RECT_STYLE];
        [self addSubview:_imageView];
        
        _pressView = [[UIView alloc] initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
        
        NSString *path_number = [[NSBundle mainBundle] pathForResource:@"NumberKeys" ofType:@"plist"];
        NSDictionary *numberkeys_dic = [NSDictionary dictionaryWithContentsOfFile:path_number];
        for (id key in numberkeys_dic) {
            NSDictionary *m_key_dic = [numberkeys_dic objectForKey:key];
            NumberKey *numkey = [[NumberKey alloc] initPhonePadKeyWithDictionary:m_key_dic keyPadFrame:frame];
            [numkey setSkinStyleWithHost:self forStyle:[m_key_dic objectForKey:@"key_style"]];
            [_pressView addSubview:numkey];
        }
        _pressView.userInteractionEnabled = NO;
        _pressView.hidden = YES;
        [self addSubview:_pressView];
        
        UIView *white_transparencyView = [[UIView alloc] initWithFrame:self.bounds];
        white_transparencyView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[_skinStyle_Dic objectForKey:BACK_GROUND_COLOR]];
        [self addSubview:white_transparencyView];
        _drawView = [[GestureDrawView alloc] initWithFrame:self.bounds];
        _drawView.delegate = self;
        [self addSubview:_drawView];
        strokeColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[_skinStyle_Dic objectForKey:GESTURE_COLOR]];
        self.backgroundColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[_skinStyle_Dic objectForKey:BACK_GROUND_COLOR]];
       
    }
    return self;
}
- (void)didFinishDrawView{
    self.stroke = _drawView.stroke;
    [delegate didFinishDraw];
}
- (void)beginDrawView{
    self.stroke = _drawView.stroke;
    [delegate beginDraw];
}


-(void)refreshGestureInputView{
    [_drawView refreshGestureInputView];
}
-(void)refreshDraw{
    [_drawView refreshDraw];
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[_skinStyle_Dic objectForKey:BACK_GROUND_COLOR]];
    [_drawView setNeedsDisplay];
}


@end
