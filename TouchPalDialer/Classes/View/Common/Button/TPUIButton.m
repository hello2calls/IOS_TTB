//
//  TPUIButton.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-10-23.
//
//

#import "TPUIButton.h"

@implementation TPUIButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame withString:(NSString *)icon_str {
	if (self = [self initWithFrame:frame]) {
        [self setTitle:icon_str forState:UIControlStateNormal];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4];
	}
	return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
