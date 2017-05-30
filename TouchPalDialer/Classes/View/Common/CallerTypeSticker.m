//
//  CallerTypeSticker.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-15.
//
//

#import "CallerTypeSticker.h"
#import "TPDialerResourceManager.h"

@implementation CallerTypeSticker

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _typeImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultText_color"];
        _typeLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_typeImageView];
        [self addSubview:_typeLabel];
        
        _dotLabel = [[UILabel alloc] initWithFrame:CGRectMake(-6, 0, 8, frame.size.height)];
        _dotLabel.text = @"·";
        _dotLabel.hidden = YES;
        _dotLabel.backgroundColor = [UIColor clearColor];
        _dotLabel.font = [UIFont systemFontOfSize:FONT_SIZE_0_5];
        [_typeLabel addSubview:_dotLabel];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
