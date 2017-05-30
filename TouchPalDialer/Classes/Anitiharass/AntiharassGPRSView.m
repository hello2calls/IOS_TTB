//
//  AntiharassGPRSView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/17.
//
//

#import "AntiharassGPRSView.h"

@implementation AntiharassGPRSView

- (instancetype)init{
    self = [super init];
    if ( self ){
        UIView *middleView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-280)/2, (TPScreenHeight()-214)/2, 280, 214)];
        middleView.backgroundColor = [UIColor whiteColor];
        middleView.layer.masksToBounds = YES;
        middleView.layer.cornerRadius = 4.0f;
        [self addSubview:middleView];
        
        CGFloat globalY = 30;
        
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 18)];
        firstLabel.text = @"触宝提示";
        firstLabel.backgroundColor = [UIColor clearColor];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.font = [UIFont boldSystemFontOfSize:17];
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [middleView addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 30;
        
        NSString *labelString = @"要使用数据流量更新数据包吗？\n(约35K)";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelString];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:4];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelString length])];
        
        UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, middleView.frame.size.width - 40 , 40)];
        secondLabel.attributedText = attributedString;
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        secondLabel.numberOfLines = 2;
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        [middleView addSubview:secondLabel];
        
        globalY += secondLabel.frame.size.height + 30;
        
        TPButton *cancelButton = [[TPButton alloc]initWithFrame:CGRectMake(20, globalY, 110, 46) withType:GRAY_LINE withFirstLineText:@"取消" withSecondLineText:nil];
        [cancelButton addTarget:self action:@selector(onCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:cancelButton];
        
        UIButton *sureButton = [[TPButton alloc]initWithFrame:CGRectMake(150, globalY, 110, 46) withType:BLUE_LINE withFirstLineText:@"继续" withSecondLineText:nil];
        [sureButton addTarget:self action:@selector(onSureButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:sureButton];
    }
    return self;
}

- (void)onCancelButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GPRS_VIEW_PRESS_CANCEL, @(1)), nil];
    [self.delegate clickCancelButton];
}

- (void)onSureButtonPressed{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GPRS_VIEW_PRESS_OK, @(1)), nil];
    [self.delegate clickSureButton];
}

@end
