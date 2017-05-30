//
//  JoinInterCallTipView.m
//  TouchPalDialer
//
//  Created by wen on 16/2/29.
//
//

#import "JoinInterCallTipView.h"
#define bgWihteW (TPScreenWidth()-2*20)
@implementation JoinInterCallTipView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *bgWhiteView = [[UIView alloc] initWithFrame:CGRectMake(20, (TPScreenHeight()-bgWihteW*800/560.0)/2, bgWihteW, bgWihteW*800/560.0)];
        bgWhiteView.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        bgWhiteView.layer.masksToBounds = YES;
        bgWhiteView.layer.cornerRadius = 4;
        
        [self addSubview:bgWhiteView];
        
        
        UIButton *cancelButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        cancelButton.frame =CGRectMake(CGRectGetMaxX(bgWhiteView.frame)-40, CGRectGetMinY(bgWhiteView.frame), 40, 40);
        cancelButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:20];
        [cancelButton setTitle:@"F" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"] forState:(UIControlStateNormal)];
        [cancelButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"]] forState:(UIControlStateHighlighted)];
        [cancelButton addTarget:self action:@selector(tapToCancel) forControlEvents:
         (UIControlEventTouchUpInside)];
        

        [self addSubview:cancelButton];
        
        
        
        UIView *bgTopCyanView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgWhiteView.bounds.size.width, 100)];
        bgTopCyanView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_cyan_600"];
        [bgWhiteView addSubview:bgTopCyanView];
        
        UIImage *okImage = [TPDialerResourceManager getImage:@"join_intercall_ok@2x.png"];
        UIImageView *okImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, okImage.size.width, okImage.size.height)];
        okImageView.center =  CGPointMake(TPScreenWidth()/2, bgWhiteView.frame.origin.y+okImage.size.height/2-15);
        okImageView.image = okImage;
        [self addSubview:okImageView];
        
        UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, bgTopCyanView.bounds.size.height-37, bgWihteW, 17)];
        lable1.backgroundColor = [UIColor clearColor];
        lable1.text = @"您已成功开通此功能！";
        lable1.font = [UIFont boldSystemFontOfSize:17];
        lable1.textAlignment = NSTextAlignmentCenter;
        lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
        [bgTopCyanView addSubview:lable1];
        
        UILabel *tipTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgTopCyanView.frame)+30, bgWihteW, 17)];
        tipTitle.textAlignment = NSTextAlignmentCenter;
        tipTitle.text = @"小提示";
        tipTitle.font = [UIFont boldSystemFontOfSize:17];
        tipTitle.backgroundColor = [UIColor clearColor];
        tipTitle.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [bgWhiteView addSubview:tipTitle];
        
        UILabel *tip1 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tipTitle.frame)+20, bgWihteW-20*2,15)];
        tip1.text = @"1.免费国际长途暂时支持有限个数国家，后期会陆续开放更多";
        tip1.font = [UIFont systemFontOfSize:15];
        tip1.numberOfLines = 0;
        tip1.backgroundColor = [UIColor clearColor];
        tip1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        CGSize size = [tip1.text sizeWithFont:tip1.font constrainedToSize:CGSizeMake(tip1.bounds.size.width, 10000)];
        CGRect  oldFrame = tip1.frame;
        oldFrame.size.height = size.height;
        tip1.frame =oldFrame;
        [bgWhiteView addSubview:tip1];
        
        UILabel *tip2 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tip1.frame)+15, bgWihteW-20*2, 15)];
        tip2.text = @"2.拨打国际长途记得要加拨国家码（例如：中国为0086或+86）";
        tip2.font = [UIFont systemFontOfSize:15];
        tip2.numberOfLines = 0;
        tip2.backgroundColor = [UIColor clearColor];
        tip2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        size = [tip2.text sizeWithFont:tip2.font constrainedToSize:CGSizeMake(tip2.bounds.size.width, 10000)];
        oldFrame = tip2.frame;
        oldFrame.size.height = size.height;
        tip2.frame =oldFrame;
        [bgWhiteView addSubview:tip2];
        
        UILabel *tip3 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(tip2.frame)+15, bgWihteW-20*2, 15)];
        tip3.text = @"3.免费国际长途消耗的分钟数较多，要多多参加活动获取分钟数哦";
        tip3.font = [UIFont systemFontOfSize:15];
        tip3.numberOfLines = 0;
        tip3.backgroundColor = [UIColor clearColor];
        tip3.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        size = [tip3.text sizeWithFont:tip3.font constrainedToSize:CGSizeMake(tip3.bounds.size.width, 10000)];
        oldFrame = tip3.frame;
        oldFrame.size.height = size.height;
        tip3.frame =oldFrame;
        [bgWhiteView addSubview:tip3];
        
        
        UIButton *tapButton =[UIButton buttonWithType:(UIButtonTypeCustom)];
        tapButton.layer.cornerRadius = 4;
        tapButton.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_cyan_600"];
        [tapButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_cyan_800"]] forState:(UIControlStateHighlighted)];
        [tapButton setTitle:@"试打一下吧~" forState:(UIControlStateNormal)];
        tapButton.frame = CGRectMake(20, CGRectGetMaxY(tip3.frame)+20, bgWihteW-20*2, 46);
        [bgWhiteView addSubview:tapButton];
        [tapButton addTarget:self action:@selector(tapToRootView) forControlEvents:(UIControlEventTouchUpInside)];
        
        CGRect oldBgWhiteFrame =  bgWhiteView.frame;
        oldBgWhiteFrame.size.height = CGRectGetMaxY(tapButton.frame)+20;
        bgWhiteView.frame = oldBgWhiteFrame;
        bgWhiteView.center = CGPointMake(TPScreenWidth()/2, TPScreenHeight()/2);
        okImageView.center =  CGPointMake(TPScreenWidth()/2, bgWhiteView.frame.origin.y+okImage.size.height/2-15);
        cancelButton.frame =CGRectMake(CGRectGetMaxX(bgWhiteView.frame)-40, CGRectGetMinY(bgWhiteView.frame), 40, 40);
    }
    return self;
}

-(void)tapToCancel{
    UINavigationController *navigationController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    UIViewController *editVoipController;
    for(UIViewController *vc in navigationController.viewControllers) {
        if ([vc isKindOfClass:[EditVoipViewController class]]) {
            editVoipController = (EditVoipViewController *)vc;
            break;
        }
    }
    if (editVoipController) {
        // found, to use it
        [navigationController popViewControllerAnimated:YES];
    } else {
        editVoipController = [[EditVoipViewController alloc] init];
        [navigationController popViewControllerAnimated:NO];
        [navigationController pushViewController:editVoipController animated:YES];
    }
    [self removeSelf];
}


-(void)tapToRootView{
    [self removeSelf];
    [FunctionUtility popToRootViewWithIndex:1];
}


-(void)removeSelf{
    [[NSNotificationCenter defaultCenter]postNotificationName:DIALOG_DISMISS object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}


@end