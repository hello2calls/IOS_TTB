//
//  HangUpAdButton.m
//  TouchPalDialer
//
//  Created by wen on 16/4/28.
//
//

#import "HangUpAdButton.h"

@implementation HangUpAdButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(press) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return self;
}

-(void)press{
    if (self.pressBlock) {
        self.pressBlock();
    }
}
@end
