//
//  CommonTipsWithBolckView.m
//  TouchPalDialer
//
//  Created by wen on 15/11/30.
//
//
#define w 300
#define h 300
#import "CommonTipsWithBolckView.h"

@implementation CommonTipsWithBolckView

-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        self.titleLable = nil;
        self.lable1 = nil;
        self.lable2 = nil;
        self.lable3 = nil;
        self.lable4 = nil;
        self.lable5 = nil;
        self.checkImageLable = nil;
        self.userDefaultString = nil;
        self.rightBlock = nil;
        self.leftBlock = nil;
        self.ifCheckSure = NO;
    }
    return self;
}

- (instancetype)initWithtitleString:(NSString *)titleString lable1String:(NSString *)lable1String  lable1textAlignment:(NSTextAlignment)textAlignment1 lable2String:(NSString *)lable2String lable2textAlignment:(NSTextAlignment)textAlignment2 leftString:(NSString *)leftString  rightString:(NSString *)rightString rightBlock:(btnBlock)rightBlock leftBlock:(btnBlock)leftBlock{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        self.rightBlock = rightBlock;
        self.leftBlock = leftBlock;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-h/2, w, h)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 4;
        CGFloat buttonY = 30;

        if (titleString!=nil) {
            UILabel *lable0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
            lable0.font = [UIFont boldSystemFontOfSize:17];
            CGSize size = [titleString sizeWithFont:lable0.font constrainedToSize:CGSizeMake(lable0.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            lable0.text = titleString;
            lable0.textAlignment = NSTextAlignmentCenter;
            lable0.numberOfLines = 0;
            lable0.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
            [lable0 setFrame:CGRectMake(20, 30,  w-20*2, size.height)];
            lable0.center = CGPointMake(w/2, lable0.center.y);
            buttonY = (CGRectGetMaxY(lable0.frame)+30);
            self.titleLable = lable0;
            [view addSubview:lable0];
        }

        if (lable1String!=nil) {
            UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
            lable1.font = [UIFont systemFontOfSize:15];
            CGSize size = [lable1String sizeWithFont:lable1.font constrainedToSize:CGSizeMake(lable1.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            lable1.text = lable1String;
            lable1.textAlignment = textAlignment1;
            lable1.numberOfLines = 0;
            lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
            if(textAlignment1 !=NSTextAlignmentCenter){
            [lable1 setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLable.frame)+30, size.width, size.height)];
            }else{
            [lable1 setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLable.frame)+30,  w-20*2,size.height)];
            }
            buttonY = (CGRectGetMaxY(lable1.frame)+30);
            self.lable1 = lable1;
            [view addSubview:lable1];
        }

        if (lable2String!=nil) {
            UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
            lable2.font = [UIFont systemFontOfSize:15];
            CGSize size = [lable2String sizeWithFont:lable2.font constrainedToSize:CGSizeMake(lable2.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            lable2.text = lable2String;
            lable2.numberOfLines = 0;
            lable2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
            lable2.textAlignment = textAlignment2;
            if (textAlignment2 != NSTextAlignmentCenter) {
                [lable2 setFrame:CGRectMake(20, CGRectGetMaxY(self.lable1.frame)+15, size.width, size.height)];
            }
            else{
                [lable2 setFrame:CGRectMake(20, CGRectGetMaxY(self.lable1.frame)+15, w-20*2, size.height)];
            }
            self.lable2 = lable2;
            [view addSubview:lable2];
            buttonY = (CGRectGetMaxY(lable2.frame)+30);
        }
        if (leftString != nil) {
            _leftBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            _leftBtn.frame = CGRectMake(20,buttonY,(w-3*20)/2,46);

            [_leftBtn setTitle:leftString forState:(UIControlStateNormal)];
            [_leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] forState:(UIControlStateNormal)];
            [_leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
            [_leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:_leftBtn.bounds] forState:(UIControlStateHighlighted)];
            [_leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"] withFrame:_leftBtn.bounds] forState:(UIControlStateHighlighted)];
            _leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            _leftBtn.backgroundColor = [UIColor clearColor];
            _leftBtn.layer.masksToBounds = YES;
            _leftBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
            _leftBtn.layer.borderWidth = 0.5;
            _leftBtn.layer.cornerRadius = 4;
            [_leftBtn addTarget:self action:@selector(closeToBlock) forControlEvents:(UIControlEventTouchUpInside)];
            [view addSubview:_leftBtn];

        }

        if (rightString != nil) {
        _rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            if (leftString==nil) {
                 _rightBtn.frame = CGRectMake(20,buttonY,w-2*20,46);
            }else{
                _rightBtn.frame = CGRectMake(w/2+10,buttonY,(w-3*20)/2,46);

            }
        [_rightBtn setTitle:rightString forState:(UIControlStateNormal)];
        [_rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:(UIControlStateNormal)];
        [_rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [_rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] withFrame:_rightBtn.bounds] forState:(UIControlStateHighlighted)];
        [_rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:_rightBtn.bounds] forState:(UIControlStateNormal)];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        _rightBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;
        _rightBtn.layer.masksToBounds = YES;
        _rightBtn.layer.borderWidth = 0.5;
        _rightBtn.layer.cornerRadius = 4;
        [_rightBtn addTarget:self action:@selector(sureToBlock) forControlEvents:(UIControlEventTouchUpInside)];

        [view addSubview:_rightBtn];
            buttonY += 66;
        [self addSubview:view];
        }
        view.frame = CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-buttonY/2, w, buttonY);
    }
    return self;
}


+(void)showTipsWithTitle:(NSString *)titleString leftString:(NSString *)leftString rightString:(NSString *)rightString rightBlock:(btnBlock)rightBlock leftBlock:(btnBlock)leftBlock checkString:(NSString *)checkString ifCheckSure:(BOOL)ifCheckSure lableStringArg:(NSString *)firstString, ...{
    CommonTipsWithBolckView *tip =[[CommonTipsWithBolckView alloc]init];
    tip.rightBlock =rightBlock;
    tip.leftBlock =leftBlock;
    tip.ifCheckSure = ifCheckSure;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-h/2, w, h)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 4;
    CGFloat buttonY = 30;
    if (titleString!=nil) {
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
        titleLable.font = [UIFont boldSystemFontOfSize:17];
        CGSize size = [titleString sizeWithFont:titleLable.font constrainedToSize:CGSizeMake(titleLable.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
        titleLable.text = titleString;
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.numberOfLines = 0;
        titleLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [titleLable setFrame:CGRectMake(20, 30,  w-20*2, size.height)];
        titleLable.center = CGPointMake(w/2, titleLable.center.y);
        buttonY = (CGRectGetMaxY(titleLable.frame)+30);
        tip.titleLable = titleLable;
        [view addSubview:tip.titleLable];
    }

    va_list args;
    va_start(args, firstString); // scan for arguments after firstObject.

    NSUInteger lableCount = 0 ;
    UILabel *lable = tip.titleLable;
    if (checkString.length>0) {
        tip.userDefaultString = [NSMutableString string];
    }
    for (NSString *str = firstString; str != nil; str = va_arg(args,NSString*)) {
        lableCount++;
        if (lableCount >5) {
            break;
        }
        if(str.length>0){
            [tip.userDefaultString appendString:str];
            switch (lableCount) {
                case 1:{
                    tip.lable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
                    tip.lable1.font = [UIFont systemFontOfSize:15];
                    CGSize size = [str sizeWithFont:tip.lable1.font constrainedToSize:CGSizeMake(tip.lable1.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
                    tip.lable1.text = str;
                    tip.lable1.textAlignment = 0;
                    tip.lable1.numberOfLines = 0;
                    tip.lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                    [tip.lable1 setFrame:CGRectMake(20, CGRectGetMaxY(lable.frame)+30, size.width, size.height)];
                    buttonY = (CGRectGetMaxY(tip.lable1.frame)+30);
                    lable = tip.lable1 ;
                    [view addSubview:tip.lable1];
                    }break;

                case 2:{
                    tip.lable2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
                    tip.lable2.font = [UIFont systemFontOfSize:15];
                    CGSize size = [str sizeWithFont:tip.lable2.font constrainedToSize:CGSizeMake(tip.lable2.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
                    tip.lable2.text = str;
                    tip.lable2.textAlignment = 0;
                    tip.lable2.numberOfLines = 0;
                    tip.lable2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                    [tip.lable2 setFrame:CGRectMake(20, CGRectGetMaxY(lable.frame)+15, size.width, size.height)];
                    buttonY = (CGRectGetMaxY(tip.lable2.frame)+15);
                    lable = tip.lable2 ;
                    [view addSubview:tip.lable2];
                }break;

                case 3:{
                    tip.lable3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
                    tip.lable3.font = [UIFont systemFontOfSize:15];
                    CGSize size = [str sizeWithFont: tip.lable3.font constrainedToSize:CGSizeMake( tip.lable3.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
                    tip.lable3.text = str;
                    tip.lable3.textAlignment = 0;
                    tip.lable3.numberOfLines = 0;
                    tip.lable3.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                    [tip.lable3 setFrame:CGRectMake(20, CGRectGetMaxY(lable.frame)+15, size.width, size.height)];
                    buttonY = (CGRectGetMaxY(tip.lable3.frame)+15);
                    lable = tip.lable3 ;
                    [view addSubview:tip.lable3];
                }break;

                case 4:{
                    tip.lable4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
                    tip.lable4.font = [UIFont systemFontOfSize:15];
                    CGSize size = [str sizeWithFont:tip.lable4.font constrainedToSize:CGSizeMake(tip.lable4.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
                    tip.lable4.text = str;
                    tip.lable4.textAlignment = 0;
                    tip.lable4.numberOfLines = 0;
                    tip.lable4.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                    [tip.lable4 setFrame:CGRectMake(20, CGRectGetMaxY(lable.frame)+15, size.width, size.height)];
                    buttonY = (CGRectGetMaxY(tip.lable4.frame)+15);
                    lable = tip.lable4;
                    [view addSubview:tip.lable4];
                }break;

                case 5:{
                    tip.lable5 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
                    tip.lable5.font = [UIFont systemFontOfSize:15];
                    CGSize size = [str sizeWithFont:tip.lable5.font constrainedToSize:CGSizeMake(tip.lable5.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
                    tip.lable5.text = str;
                    tip.lable5.textAlignment = 0;
                    tip.lable5.numberOfLines = 0;
                    tip.lable5.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
                    [tip.lable5 setFrame:CGRectMake(20, CGRectGetMaxY(lable.frame)+15, size.width, size.height)];
                    buttonY = (CGRectGetMaxY(tip.lable5.frame)+15);
                    lable = tip.lable5;
                    [view addSubview:tip.lable5];
                }break;

                default:
                    break;
            }
        }
    }

    va_end(args);

    if (tip.userDefaultString.length>0 && [UserDefaultsManager boolValueForKey:tip.userDefaultString defaultValue:NO]) {
        return;
    }
    if (checkString.length>0) {
        UIView *checkView = [[UIView alloc] initWithFrame:CGRectMake(0, buttonY+5, w, 18)];
        checkView.backgroundColor = [UIColor clearColor];

        UILabel *checkLable = [[UILabel alloc] init];
        checkLable.userInteractionEnabled = YES;
        checkLable.font = [UIFont systemFontOfSize:13];
        CGSize size = [checkString sizeWithFont:lable.font constrainedToSize:CGSizeMake(lable.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
        checkLable.text = checkString;
        checkLable.frame = CGRectMake((w-size.width+6+18)/2, 0, size.width, checkView.bounds.size.height);
        checkLable.backgroundColor = [UIColor clearColor];
        checkLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        [checkView addSubview:checkLable];

        tip.checkImageLable  = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(checkLable.frame)-6-18, 0, 18, checkView.bounds.size.height)];
        tip.checkImageLable.font = [UIFont fontWithName:@"iPhoneIcon2" size:18];
        tip.checkImageLable.text = @"q";
        tip.checkImageLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        [checkView addSubview:tip.checkImageLable];
         tip.checkImageLable.userInteractionEnabled = YES;
         buttonY = (CGRectGetMaxY(checkView.frame)+30);
        [checkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:tip action:@selector(tapToChangeColor)]];
        [view addSubview:checkView];
        if (tip.ifCheckSure) {
            [tip tapToChangeColor];
        }


    }

    if (leftString != nil) {
        tip.leftBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        tip.leftBtn.frame = CGRectMake(20,buttonY,(w-3*20)/2,46);

        [tip.leftBtn setTitle:leftString forState:(UIControlStateNormal)];
        [tip.leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] forState:(UIControlStateNormal)];
        [tip.leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [tip.leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:tip.leftBtn.bounds] forState:(UIControlStateHighlighted)];
        [tip.leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"] withFrame:tip.leftBtn.bounds] forState:(UIControlStateHighlighted)];
        tip.leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        tip.leftBtn.backgroundColor = [UIColor clearColor];
        tip.leftBtn.layer.masksToBounds = YES;
        tip.leftBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
        tip.leftBtn.layer.borderWidth = 0.5;
        tip.leftBtn.layer.cornerRadius = 4;
        [tip.leftBtn addTarget:tip action:@selector(closeToBlock) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:tip.leftBtn];

    }

    if (rightString != nil) {
        tip.rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        if (leftString==nil) {
            tip.rightBtn.frame = CGRectMake(20,buttonY,w-2*20,46);
        }else{
            tip.rightBtn.frame = CGRectMake(w/2+10,buttonY,(w-3*20)/2,46);
        }
        [tip.rightBtn setTitle:rightString forState:(UIControlStateNormal)];
        [tip.rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:(UIControlStateNormal)];
        [tip.rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
        [tip.rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] withFrame:tip.rightBtn.bounds] forState:(UIControlStateHighlighted)];
        [tip.rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:tip.rightBtn.bounds] forState:(UIControlStateNormal)];
        tip.rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        tip.rightBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;

        tip.rightBtn.layer.masksToBounds = YES;
        tip.rightBtn.layer.borderWidth = 0.5;
        tip.rightBtn.layer.cornerRadius = 4;
        [tip.rightBtn addTarget:tip action:@selector(sureToBlock) forControlEvents:(UIControlEventTouchUpInside)];
        [view addSubview:tip.rightBtn];
        buttonY += 66;
        [tip addSubview:view];
    }
    view.frame = CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-buttonY/2, w, buttonY);

    [DialogUtil showDialogWithContentView:tip inRootView:nil];

}

-(void)tapToChangeColor{
    self.ifCheckSure = !self.ifCheckSure;
    if (!self.ifCheckSure) {
        self.checkImageLable.text = @"q";
        self.checkImageLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
    }else{
        self.checkImageLable.text = @"x";
        self.checkImageLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_400"];
    }

}

- (instancetype)initWithGreyButtonWithtitleString:(NSString *)titleString lable1String:(NSString *)lable1String  lable1textAlignment:(NSTextAlignment)textAlignment1 lable2String:(NSString *)lable2String lable2textAlignment:(NSTextAlignment)textAlignment2 leftString:(NSString *)leftString  rightString:(NSString *)rightString rightBlock:(btnBlock)rightBlock leftBlock:(btnBlock)leftBlock{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        self.rightBlock = rightBlock;
        self.leftBlock = leftBlock;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-h/2, w, h)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 4;
        CGFloat buttonY = 30;


        if (titleString!=nil) {
            UILabel *lable0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
            lable0.font = [UIFont boldSystemFontOfSize:17];
            CGSize size = [titleString sizeWithFont:lable0.font constrainedToSize:CGSizeMake(lable0.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            lable0.text = titleString;
            lable0.textAlignment = NSTextAlignmentCenter;
            lable0.numberOfLines = 0;
            lable0.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
            [lable0 setFrame:CGRectMake(20, 30,  w-20*2, size.height)];
            lable0.center = CGPointMake(w/2, lable0.center.y);
            buttonY = (CGRectGetMaxY(lable0.frame)+30);
            self.titleLable = lable0;
            [view addSubview:lable0];
        }

        if (lable1String!=nil) {
            UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
            lable1.font = [UIFont systemFontOfSize:15];
            CGSize size = [lable1String sizeWithFont:lable1.font constrainedToSize:CGSizeMake(lable1.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            lable1.text = lable1String;
            lable1.textAlignment = textAlignment1;
            lable1.numberOfLines = 0;
            lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
            if(textAlignment1 !=NSTextAlignmentCenter){
                [lable1 setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLable.frame)+30, size.width, size.height)];
            }else{
                [lable1 setFrame:CGRectMake(20, CGRectGetMaxY(self.titleLable.frame)+30,  w-20*2,size.height)];
            }
            buttonY = (CGRectGetMaxY(lable1.frame)+30);
            self.lable1 = lable1;
            [view addSubview:lable1];
        }

        if (lable2String!=nil) {
            UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, w-20*2, 24*2)];
            lable2.font = [UIFont systemFontOfSize:15];
            CGSize size = [lable2String sizeWithFont:lable2.font constrainedToSize:CGSizeMake(lable2.bounds.size.width, 2000) lineBreakMode:NSLineBreakByTruncatingTail];
            lable2.text = lable2String;
            lable2.numberOfLines = 0;
            lable2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
            lable2.textAlignment = textAlignment2;
            if (textAlignment2 != NSTextAlignmentCenter) {
                [lable2 setFrame:CGRectMake(20, CGRectGetMaxY(self.lable1.frame)+15, size.width, size.height)];
            }
            else{
                [lable2 setFrame:CGRectMake(20, CGRectGetMaxY(self.lable1.frame)+15, w-20*2, size.height)];
            }
            self.lable2 = lable2;
            [view addSubview:lable2];
            buttonY = (CGRectGetMaxY(lable2.frame)+30);
        }
        if (leftString != nil) {
            _leftBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            _leftBtn.frame = CGRectMake(20,buttonY,(w-3*20)/2,46);

            [_leftBtn setTitle:leftString forState:(UIControlStateNormal)];
            [_leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] forState:(UIControlStateNormal)];
            [_leftBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
            [_leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:_leftBtn.bounds] forState:(UIControlStateHighlighted)];
            [_leftBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"] withFrame:_leftBtn.bounds] forState:(UIControlStateHighlighted)];
            _leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            _leftBtn.backgroundColor = [UIColor clearColor];
            _leftBtn.layer.masksToBounds = YES;
            _leftBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
            _leftBtn.layer.borderWidth = 0.5;
            _leftBtn.layer.cornerRadius = 4;
            [_leftBtn addTarget:self action:@selector(closeToBlock) forControlEvents:(UIControlEventTouchUpInside)];
            [view addSubview:_leftBtn];

        }

        if (rightString != nil) {
            _rightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            if (leftString==nil) {
                _rightBtn.frame = CGRectMake(20,buttonY,w-2*20,46);
            }else{
                _rightBtn.frame = CGRectMake(w/2+10,buttonY,(w-3*20)/2,46);

            }
            [_rightBtn setTitle:rightString forState:(UIControlStateNormal)];
            [_rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] forState:(UIControlStateNormal)];
            [_rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateHighlighted)];
            [_rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:_rightBtn.bounds] forState:(UIControlStateHighlighted)];
            [_rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"] withFrame:_rightBtn.bounds] forState:(UIControlStateHighlighted)];
            _rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            _rightBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
            _rightBtn.layer.masksToBounds = YES;
            _rightBtn.layer.borderWidth = 0.5;
            _rightBtn.layer.cornerRadius = 4;
            [_rightBtn addTarget:self action:@selector(sureToBlock) forControlEvents:(UIControlEventTouchUpInside)];
            [view addSubview:_rightBtn];
            buttonY += 66;
            [self addSubview:view];
        }
        view.frame = CGRectMake(TPScreenWidth()/2-w/2, TPScreenHeight()/2-buttonY/2, w, buttonY);
    }
    return self;
}


-(void)closeToBlock{
    if (self.leftBlock) {
        self.leftBlock();
    }
    [self commonFunc];
}

-(void)removeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}

-(void)sureToBlock{
    if (self.rightBlock) {
        self.rightBlock();
    }
    [self commonFunc];
}

-(void)commonFunc{
    [self removeSelf];
    if (self.checkImageLable&&self.userDefaultString.length>0) {
        [UserDefaultsManager setBoolValue:self.ifCheckSure forKey:self.userDefaultString];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
