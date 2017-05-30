//
//  AntiharassChooseCityViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/17.
//
//

#import "AntiharassChooseCityViewController.h"
#import "TPDialerResourceManager.h"
#import "AntiharassUtil.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"
#import "AntiharassManager.h"
#import "DialerUsageRecord.h"

@implementation AntiharassChooseCityViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];

    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45+TPHeaderBarHeightDiff())];
    headerView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    [self.view addSubview:headerView];

    // Label
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_2];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.text = @"选择常住城市";
    headerTitle.textColor = [UIColor whiteColor];
    [headerView addSubview:headerTitle];

    // BackButton
    UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(),50, 45)];
    cancelBut.backgroundColor = [UIColor clearColor];
    cancelBut.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
    [cancelBut setTitle:@"0" forState:UIControlStateNormal];
    [cancelBut addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:cancelBut];

    CGFloat globalY = TPScreenHeight() -  40 - 24;

    NSString *labelString = @"触宝通过云端大数据技术\n根据您的「常住地」智能生成骚扰电话号码库";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:4];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelString length])];

    UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, globalY, TPScreenWidth() - 30  , 40)];
    secondLabel.attributedText = attributedString;
    secondLabel.backgroundColor = [UIColor clearColor];
    secondLabel.textAlignment = NSTextAlignmentCenter;
    secondLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13];
    secondLabel.numberOfLines = 3;
    secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
    [self.view addSubview:secondLabel];

    globalY += secondLabel.frame.size.height + 15;

    UIView *chooseView = [[UIView alloc]initWithFrame:CGRectMake(0,headerView.frame.size.height + 20, TPScreenWidth(), 184)];
    chooseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:chooseView];

    for ( int i = 0 ; i < 5 ; i ++ ){
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, i*46, chooseView.frame.size.width, 0.5)];
        lineView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [chooseView addSubview:lineView];
    }

    for ( int i = 0 ; i < 4 ; i ++ ){
        UIView *middleLine1 = [[UIView alloc]initWithFrame:CGRectMake(TPScreenWidth()/3, 15.5 + i*46, 0.5, 15)];
        middleLine1.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [chooseView addSubview:middleLine1];

        UIView *middleLine2 = [[UIView alloc]initWithFrame:CGRectMake(TPScreenWidth()/3*2, 15.5 + i*46, 0.5, 15)];
        middleLine2.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_150"];
        [chooseView addSubview:middleLine2];
    }

    NSInteger type = [UserDefaultsManager intValueForKey:ANTIHARASS_TYPE];

    for ( int i = 0 ; i < 12 ; i ++ ){
        CGFloat originX = i % 3 *TPScreenWidth()/3;
        CGFloat originY = i / 3 *46;

        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(originX, originY, TPScreenWidth()/3, 46)];
        [button setTitle:[AntiharassUtil getStringName:i+1] forState:UIControlStateNormal];
        [button setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"] forState:UIControlStateNormal];
        [button setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:button.bounds] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
        button.tag = i + 1;
        [button addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:button];

        if ( i == type - 1 ){
            UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(button.frame.size.width/2 + (button.titleLabel.text.length)*7.5+2, 14, 18, 18)];
            iconLabel.text = @"x";
            iconLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:16];
            iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.layer.masksToBounds = YES;
            iconLabel.layer.cornerRadius = iconLabel.frame.size.width/2;
            iconLabel.backgroundColor = [UIColor clearColor];
            [button addSubview:iconLabel];

        }
    }

    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSE_CITY_PAGE_SHOW_TIME, @(1)), nil];
    if ( _ifFirstChoose ){
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSE_CITY_PAGE_FIRST_USED_SHOW_TIME, @(1)), nil];
    }
}

- (void) gotoBack {
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSE_CITY_PAGE_PRESS_BACK, @(1)), nil];
    if ( _ifFirstChoose ){
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSE_CITY_PAGE_FIRST_USED_PRESS_BACK, @(1)), nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonPressed:(UIButton *)button{
    [UserDefaultsManager setIntValue:button.tag forKey:ANTIHARASS_TYPE];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSE_CITY_PAGE_CHOOSE_CITY, @(1)), nil];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSED_CITY, [AntiharassUtil getStringName:[UserDefaultsManager intValueForKey:ANTIHARASS_TYPE]]), nil];
    if ( _ifFirstChoose ){
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_CHOOSE_CITY_PAGE_FIRST_USED_CHOOSE_CITY, @(1)), nil];
        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_CITY_CHOOSED];
        [[AntiharassManager instance] openAntiharass];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
