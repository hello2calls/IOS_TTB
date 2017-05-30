//
//  withBottomLineButton.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/15.
//
//

#import "WithBottomLineButton.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@interface WithBottomLineButton(){
    UILabel *_firstLabel;
    UILabel *_secondLabel;
    
    UIView *_bottomLine;
}

@end

@implementation WithBottomLineButton
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        self.backgroundColor = [UIColor clearColor];
        
        [self setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:self.bounds] forState:UIControlStateHighlighted];
        
        _firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 9, 200, 18)];
        _firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        _firstLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16];
        _firstLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_firstLabel];
        
        _secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 33, 200, 14)];
        _secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        _secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        _secondLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_secondLabel];
        
        UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 33, 19, 18, 18)];
        iconLabel.text = @"n";
        iconLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:18];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
        iconLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:iconLabel];
        
        
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(15, self.frame.size.height-1, self.frame.size.width, 0.5)];
        _bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [self addSubview:_bottomLine];
        
    }
    
    return self;
}

- (void)setFirstText:(NSString *)text{
    _firstLabel.text = text;
    [self layoutSubviews];
}

- (void)setSecondText:(NSString *)text{
    _secondLabel.text = text;
    [self layoutSubviews];
}

- (void)setSecondColor:(UIColor *)color{
    _secondLabel.textColor = [color copy];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if ( _secondLabel.text.length == 0 ){
        CGRect oldFrame = _firstLabel.frame;
        _firstLabel.frame = CGRectMake(oldFrame.origin.x, 19, oldFrame.size.width, oldFrame.size.height);
    }else{
        CGRect oldFrame = _firstLabel.frame;
        _firstLabel.frame = CGRectMake(oldFrame.origin.x, 9, oldFrame.size.width, oldFrame.size.height);
    }
    if ( _ifLast ){
        _bottomLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 0.5);
    }

}
@end
