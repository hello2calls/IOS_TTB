//
//  HeadbarNotiView.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/9/7.
//
//

#import "HeadbarNotiView.h"
#import "TPDialerResourceManager.h"

@implementation HeadbarNotiView

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5_5];
        titleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"status_bar_title_color"];
        [self addSubview:titleLabel];
        
        self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"status_bar_background_color"];
    }
    return self;
}

@end
