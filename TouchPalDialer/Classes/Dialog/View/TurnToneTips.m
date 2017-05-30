//
//  TurnToneTips.m
//  TouchPalDialer
//
//  Created by wen on 15/10/26.
//
//

#import "TurnToneTips.h"
#import "DialerUsageRecord.h"
#define w 280
#define h 184
@implementation TurnToneTips

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame titleString:(NSString *)titleString leftString:(NSString *)leftString rightString:(NSString *)rightString sureBlock:(btnBlock)sureBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.sureBlock = sureBlock;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-h/2, w, h)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 4;



        UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
        lable1.font = [UIFont systemFontOfSize:17];
        CGSize size = [titleString sizeWithFont:lable1.font constrainedToSize:CGSizeMake(lable1.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
        lable1.text = titleString;
        lable1.numberOfLines = 0;
        lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [lable1 setFrame:CGRectMake(20, 30, size.width, size.height)];
        lable1.textAlignment = NSTextAlignmentCenter;
        [view addSubview:lable1];

        UIButton *leftBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        leftBtn.frame = CGRectMake(20,h-66,(w-3*20)/2,46);

        [leftBtn setTitle:leftString forState:(UIControlStateNormal)];
        [leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] forState:(UIControlStateNormal)];
        [leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:leftBtn.bounds] forState:(UIControlStateHighlighted)];
        [leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"] withFrame:leftBtn.bounds] forState:(UIControlStateHighlighted)];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        leftBtn.backgroundColor = [UIColor clearColor];
        leftBtn.layer.masksToBounds = YES;
        leftBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
        leftBtn.layer.borderWidth = 1;
        leftBtn.layer.cornerRadius = 4;
        [leftBtn addTarget:self action:@selector(removeSelf) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:leftBtn];

        UIButton *rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        rightBtn.frame = CGRectMake(CGRectGetMaxX(leftBtn.frame)+20,h-66,(w-3*20)/2,46);
        [rightBtn setTitle:rightString forState:(UIControlStateNormal)];
        [rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:(UIControlStateNormal)];
        [rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] withFrame:rightBtn.bounds] forState:(UIControlStateHighlighted)];
        [rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:rightBtn.bounds] forState:(UIControlStateNormal)];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        rightBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;
        rightBtn.layer.masksToBounds = YES;
        rightBtn.layer.borderWidth = 1;
        rightBtn.layer.cornerRadius = 4;
        [rightBtn addTarget:self action:@selector(sureToBlock) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:rightBtn];
        [self addSubview:view];

    }
    return self;
}



-(void)removeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_APP, @(3)), nil];
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_UPDATE_FROM_TODAYWIDGET defaultValue:NO]) {
        [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_TODAY, @(3)), nil];

    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
        [UserDefaultsManager setBoolValue:NO forKey:@"ALERDYSHOWTIPS"];
    }];
}

-(void)sureToBlock{
    if (self.sureBlock) {
        self.sureBlock();
    }
    [self removeSelf];
}


@end
