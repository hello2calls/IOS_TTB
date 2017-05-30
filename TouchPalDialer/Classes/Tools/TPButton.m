//
//  TPButton.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/14.
//
//

#import "TPButton.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UIView+WithSkin.h"
#import "TPButtonColorManager.h"

@interface TPButton() {
    UIView *_layer;
    UILabel *_title;
    UILabel *_subtitle;
    
    ButtonType buttonType;
    
    TPButtonColorManager *_buttonColorManager;
}

@end

@implementation TPButton

- (instancetype)initWithFrame:(CGRect)frame withType:(ButtonType)type withFirstLineText:(NSString *)firstText withSecondLineText:(NSString *)secondText {
    self = [super initWithFrame:frame];
    if (self) {
        [self setSkinStyleWithHost:self forStyle:@""];
        buttonType = type;
        _buttonColorManager = [[TPButtonColorManager alloc]initWithType:buttonType];
        BOOL doubleLine = secondText && secondText.length > 0;
        
        _layer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _layer.layer.cornerRadius = 4;
        _layer.layer.masksToBounds = YES;
        _layer.userInteractionEnabled = NO;
        _layer.layer.borderWidth = 0.5;
        
        if (doubleLine) {
            _title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 2 + 8)];
            _title.text = firstText;
            _title.backgroundColor = [UIColor clearColor];
            _title.textAlignment = NSTextAlignmentCenter;
            _title.font = [UIFont systemFontOfSize:FONT_SIZE_3];
            
            _subtitle = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height / 2 - 8, frame.size.width, frame.size.height / 2 + 8)];
            _subtitle.text = secondText;
            _subtitle.backgroundColor = [UIColor clearColor];
            _subtitle.textAlignment = NSTextAlignmentCenter;
            _subtitle.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
            _subtitle.userInteractionEnabled = NO;
        } else {
            _title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            _title.text = firstText;
            _title.backgroundColor = [UIColor clearColor];
            _title.textAlignment = NSTextAlignmentCenter;
            _title.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        }
        _title.userInteractionEnabled = NO;
        
        [self setSkin];
        [self addSubview:_layer];
        [self addSubview:_title];
        if (_subtitle) {
            [self addSubview:_subtitle];
        }
    }
    return self;
}

- (void) setSkin {
    if ([self isEnabled]) {
        _layer.layer.borderColor = _buttonColorManager.layerNormalColor.CGColor;
        _layer.backgroundColor = _buttonColorManager.bodyNormalColor;
        _title.textColor = _buttonColorManager.titleNormalColor;
        if (_subtitle) {
            _subtitle.textColor = _buttonColorManager.subtitleNormalColor;
        }
    } else {
        _layer.layer.borderColor = _buttonColorManager.layerDisabledColor.CGColor;
        _layer.backgroundColor = _buttonColorManager.bodyDisabledColor;
        _title.textColor = _buttonColorManager.titleDisabledColor;
        if (_subtitle) {
            _subtitle.textColor = _buttonColorManager.subtitleDisableColor;
        }
    }
    
}

- (void)setFirstLineText:(NSString *)title {
    _title.text = title;
}

- (void)setSecondLineText:(NSString *)text {
    if (_subtitle) {
        _subtitle.text = text;
    }
}

- (id)selfSkinChange:(NSString *)style{
    [self setSkin];
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([self isEnabled]) {
        _layer.layer.borderColor = _buttonColorManager.layerHightlightColor.CGColor;
        _layer.backgroundColor = _buttonColorManager.bodyHightlightColor;
        _title.textColor = _buttonColorManager.titleHightlightColor;
        if (_subtitle) {
            _subtitle.textColor = _buttonColorManager.subtitleHightlightColor;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setSkin];
}

@end
