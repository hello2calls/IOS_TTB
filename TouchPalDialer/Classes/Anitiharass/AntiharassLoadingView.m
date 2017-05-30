//
//  AntiharassLoadingView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/16.
//
//

#import "AntiharassLoadingView.h"
#import "CootekNotifications.h"

@interface AntiharassLoadingView(){
    UILabel *loadingLabel;
    UILabel *firstLabel;
    UILabel *secondLabel;
    UIImageView *rotationView;
    UILabel *noteLable;
    UILabel *noteLable2;
    UILabel *tapLable;
}

@end

@implementation AntiharassLoadingView
- (instancetype)init{
    self = [super init];
    if ( self ){
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-286)/2, 280, 286)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];

        CGFloat globalY = 30;

        firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 18)];
        firstLabel.text = @"更新骚扰号码库";
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.font = [UIFont boldSystemFontOfSize:17];
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [middleView addSubview:firstLabel];

        globalY += firstLabel.frame.size.height + 30;

        rotationView = [[UIImageView alloc]initWithFrame:CGRectMake((middleView.frame.size.width - 64)/2, globalY, 64 , 64)];
        rotationView.image = [TPDialerResourceManager getImage:@"antiharass_loading@2x.png"];
        [middleView addSubview:rotationView];


        loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake((middleView.frame.size.width - 64)/2, globalY, 64 , 64)];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        [middleView addSubview:loadingLabel];

        globalY += loadingLabel.frame.size.height + 30;

        secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 16)];
        secondLabel.text = @"正在检查更新";
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [middleView addSubview:secondLabel];

        globalY += secondLabel.frame.size.height + 20;


        UILabel *lineLable = [[UILabel alloc] initWithFrame:CGRectMake(0, globalY, middleView.frame.size.width, 0.5)];
        lineLable.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"];
        [middleView addSubview:lineLable];

        globalY += lineLable.frame.size.height + 20;

        noteLable = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 16)];
        noteLable.text = @"开启“骚扰识别”，可对陌生来电进行识别 ";
        noteLable.backgroundColor = [UIColor clearColor];
        noteLable.textAlignment = NSTextAlignmentCenter;
        noteLable.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        noteLable.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [middleView addSubview:noteLable];
        globalY += noteLable.frame.size.height + 8;


        noteLable2 = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 110-20 , 16)];
        noteLable2.text = @"如何识别陌生未接号码？";
        noteLable2.backgroundColor = [UIColor clearColor];
        noteLable2.textAlignment = NSTextAlignmentRight;
        noteLable2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        noteLable2.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        [middleView addSubview:noteLable2];


        NSString *str = @"点击查看秘籍";
        NSRange rangeBlue = [str rangeOfString:@"点击查看秘籍"];
        NSMutableAttributedString *tapString = [[NSMutableAttributedString alloc] initWithString:str];
        [tapString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range: rangeBlue];
         [tapString addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] range: rangeBlue];
        tapLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(noteLable2.frame), globalY, 90 , 16)];
        tapLable.attributedText = tapString;
        tapLable.backgroundColor = [UIColor clearColor];
        tapLable.textAlignment = NSTextAlignmentCenter;
        tapLable.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
        [middleView addSubview:tapLable];


        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(0, 0, 130, 50);
        [middleView addSubview:btn];
        btn.center = tapLable.center;
        [btn addTarget:self action:@selector(tapToTodayVC) forControlEvents:(UIControlEventTouchUpInside)];


        [self beginLoadingAnimation];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];

    }
    return self;
}

-(void)tapToTodayVC{
    if (self.delegate!=nil &&  [self.delegate respondsToSelector:@selector(clickTapButton)]) {
        [self.delegate clickTapButton];
    }
}

- (void)beginLoadingAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    [rotationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)restartAnimation{
    [rotationView.layer removeAllAnimations];
    [self beginLoadingAnimation];
}

- (instancetype)initWithStep:(AntiharassViewStep)step{
    self = [self init];
    if ( self ){
        if ( step == ANTIHARASS_VIEW_REMOVE_LOADING ){
            firstLabel.text = @"关闭骚扰识别";
            secondLabel.text = @"关闭中，请勿退出";
        }
    }
    return self;
}

- (void)refreshStep:(AntiharassModelStep)step{
    switch (step) {
        case ANTIHARASS_NEW_BUILD_BUILD_ADDRESSBOOK:{
            secondLabel.text = @"正在更新，请勿退出";

            NSString *numberText = @"0％";
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:numberText];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 1)];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(1, 1)];
            loadingLabel.attributedText = attrStr;
            break;
        }
        case ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK:{
            secondLabel.text = @"正在删除旧数据库";
        }
        default:
            break;
    }
}


- (void)refreshPercent:(NSInteger)percent{
    NSString *numberText = [NSString stringWithFormat:@"%d％",percent];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:numberText];

    NSRange range1 = [numberText rangeOfString:[NSString stringWithFormat:@"%d",percent]];
    NSRange range2 = [numberText rangeOfString:@"％"];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:range1];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:range2];
    loadingLabel.attributedText = attrStr;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
