//
//  DialToneTips.m
//  TouchPalDialer
//
//  Created by wen on 15/10/26.
//
//

#import "DialToneTips.h"

@implementation DialToneTips

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame withSkinIcon:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat itemPadding = 10.0f;
        CGSize buttonSize = CGSizeMake(58.0f, 28.0f);
        CGFloat buttonMarginTop = 10.0f;
        CGFloat iconImageHeight = (image.size.height / image.size.width) * TPScreenWidth();
        CGFloat itemContainerHeight = iconImageHeight + buttonMarginTop * 2 + buttonSize.height;
        CGFloat itemContainerWidth = TPScreenWidth() -  itemPadding;
        CGSize itemContainerSize = CGSizeMake(itemContainerWidth, itemContainerHeight);
        CGFloat ver = 85;
        if ([[UIDevice currentDevice] systemVersion].floatValue <7) {
            ver = 65;
        }
        CGFloat hornMargin = 5.0f;
        CGSize hornSize = CGSizeMake(30.0f, 30.0f);
        UILabel *horn= [[UILabel alloc] initWithFrame:CGRectMake(
                                                         itemContainerSize.width - hornMargin - hornSize.width, iconImageHeight - hornMargin - hornSize.height+ver,
                                                         hornSize.width, hornSize.height)];
        horn.clipsToBounds = YES;
        horn.layer.cornerRadius = hornSize.width / 2;
        horn.backgroundColor = [TPDialerResourceManager getColorForStyle:@"skin_horn_bg_color"];
        horn.font = [UIFont fontWithName:@"iPhoneIcon3" size:20.0f];
        horn.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        horn.textAlignment = NSTextAlignmentCenter;
        horn.text = @"4";
        [self addSubview:horn];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[TPDialerResourceManager getImage:@"theme_tips_arrow_right@2x.png"]];
        imageView.frame = CGRectMake(CGRectGetMinX(horn.frame)-48, CGRectGetMinY(horn.frame)+15, 38, 32);
        [self addSubview:imageView];


        UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+5, TPScreenWidth(), 21)];
        lable1.text = @"带有这个图标的主题，";
        lable1.textAlignment = NSTextAlignmentCenter;
        lable1.backgroundColor = [UIColor clearColor];
        lable1.textColor = [UIColor whiteColor];
        lable1.font = [UIFont systemFontOfSize:15];
        [self addSubview:lable1];

        UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lable1.frame), TPScreenWidth(), 21)];
        lable2.text = @"拨号时会有惊喜拨号音哦~";
        lable2.textAlignment = NSTextAlignmentCenter;
        lable2.textColor = [UIColor whiteColor];
        lable2.backgroundColor = [UIColor clearColor];
        lable2.font = [UIFont systemFontOfSize:15];
        [self addSubview:lable2];

        UILabel *lable3 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lable2.frame), TPScreenWidth(), 21)];
        lable3.text = @"不要试试么？";
        lable3.backgroundColor = [UIColor clearColor];
        lable3.textAlignment = NSTextAlignmentCenter;
        lable3.textColor = [UIColor whiteColor];
        lable3.font = [UIFont systemFontOfSize:15];
        [self addSubview:lable3];


        UIButton *sureBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        sureBtn.frame = CGRectMake(TPScreenWidth()/2-120/2, CGRectGetMaxY(lable3.frame)+30, 120, 36);
        [sureBtn setTitle:@"我知道了" forState:(UIControlStateNormal)];
        sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sureBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_900"] forState:(UIControlStateHighlighted)];
        [sureBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:sureBtn.bounds] forState:(UIControlStateHighlighted)];
        sureBtn.backgroundColor = [UIColor clearColor];
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        sureBtn.layer.borderWidth = 1;
        sureBtn.layer.cornerRadius = 4;
        [sureBtn addTarget:self action:@selector(sureToCloseSelf) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:sureBtn];
        if ([[UIDevice currentDevice].systemVersion floatValue]<7) {
            self.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}


-(void)sureToCloseSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}


@end
