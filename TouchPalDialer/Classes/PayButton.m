//
//  PayButton.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/6/22.
//
//

#import "PayButton.h"
#import "ColorUtil.h"

@implementation PayButton

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self == [super initWithFrame:frame])
    {
        [self initView];
    }
    return self;
}


-(void)initView
{
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}


-(void)setButtonSelect : (Boolean)select
{
    if(select){
       self.layer.borderColor = [[ColorUtil colorWithHexString:@"#3695ED"] CGColor];
       [self setTitleColor:[ColorUtil colorWithHexString:@"#3695ED"] forState:UIControlStateNormal];
    }
    else{
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

@end
