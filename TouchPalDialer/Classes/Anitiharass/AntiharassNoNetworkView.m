//
//  AntiharassNoNetworkView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/17.
//
//

#import "AntiharassNoNetworkView.h"
#import "UserDefaultKeys.h"
@implementation AntiharassNoNetworkView

- (instancetype)init{
    self = [super init];
    if ( self ){
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-300)/2, 280, 290)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];
        
        CGFloat globalY = 30;
        
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 18)];
        firstLabel.text = @"更新失败";
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.font = [UIFont boldSystemFontOfSize:17];
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [middleView addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 30;
        
        UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 90)];
        iconLabel.text = @"F";
        iconLabel.backgroundColor = [UIColor clearColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:72];
        iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_300"];
        [middleView addSubview:iconLabel];
        
        globalY += iconLabel.frame.size.height + 10;
        
        UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 16)];
        secondLabel.text = @"大人，好像没有联网哦";
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [middleView addSubview:secondLabel];
        
        globalY += secondLabel.frame.size.height + 30;
        
        TPButton *cancelButton = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, 110, 46) withType:GRAY_LINE withFirstLineText:@"取消" withSecondLineText:nil];
        [cancelButton addTarget:self action:@selector(onCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:cancelButton];
        
        UIButton *sureButton = [[TPButton alloc]initWithFrame:CGRectMake(150, globalY, 110, 46) withType:BLUE_LINE withFirstLineText:@"设置" withSecondLineText:nil];
        [sureButton addTarget:self action:@selector(onSureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:sureButton];
    }
    return self;
}

- (void)onCancelButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NO_NETWORK_PRESS_CANCEL, @(1)), nil];
    [self.delegate clickCancelButton];
}

- (void)onSureButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_NO_NETWORK_PRESS_OK, @(1)), nil];
    [self.delegate clickSureButton];
}


@end
