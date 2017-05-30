//
//  DialerGuideAnimationStringView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import "DialerGuideAnimationStringView.h"
#import "TPDialerResourceManager.h"

@interface DialerGuideAnimationStringView(){
    UILabel *_animationLabel;
    NSMutableAttributedString *_attributedString;
}

@end

@implementation DialerGuideAnimationStringView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        UIColor *grayColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"];
        
        NSString *animationString = @"李（Li）四（Si）";
        _attributedString = [[NSMutableAttributedString alloc] initWithString:animationString];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, animationString.length)];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(1, 1)];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(4, 1)];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(6, 1)];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(9, 1)];
        [_attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Light" size:22] range:NSMakeRange(0, animationString.length)];
        
        _animationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _animationLabel.textAlignment = NSTextAlignmentCenter;
        _animationLabel.attributedText = _attributedString;
        if ([[UIDevice currentDevice] systemVersion].floatValue<7.0) {
            _animationLabel.backgroundColor = [UIColor clearColor];
        }
        [self addSubview:_animationLabel];
        
    }
    
    return self;
}

- (void)refreshStringView:(NSInteger)type{
    UIColor *blueColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    if ( type == 0 )
        [_attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(2, 1)];
    else if ( type == 1 ){
        [_attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(0, 1)];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(2, 2)];
    }else if ( type == 2 )
        [_attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(7, 1)];
    else if ( type == 3 ){
        [_attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(5, 1)];
        [_attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(7, 2)];
    }
    _animationLabel.attributedText = _attributedString;
}

@end
