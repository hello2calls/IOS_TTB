//
//  AntiharassFailedView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/17.
//
//

#import "AntiharassFailedView.h"

@implementation AntiharassFailedView

- (instancetype)init{
    self = [super init];
    if ( self ){
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-190)/2, 280, 190)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];
        
        CGFloat globalY = 30;
        
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 18)];
        firstLabel.text = @"更新出现错误";
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.font = [UIFont boldSystemFontOfSize:17];
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [middleView addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 30;
        
        UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 16)];
        secondLabel.text = @"更新过程中出现错误，请重新尝试";
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [middleView addSubview:secondLabel];
        
        globalY += secondLabel.frame.size.height + 30;
        
        UIButton *sureButton = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, 240, 46) withType:GRAY_LINE withFirstLineText:@"确定" withSecondLineText:nil];
        [sureButton addTarget:self action:@selector(onSureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:sureButton];
    }
    return self;
}

- (void)onSureButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_FAILED_VIEW_PRESS_TIME, @(1)), nil];
    [self.delegate clickCancelButton];
}

@end
