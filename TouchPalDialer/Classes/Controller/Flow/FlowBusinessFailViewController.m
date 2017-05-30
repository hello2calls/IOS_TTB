//
//  FlowBusinessFailViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/28.
//
//

#import "FlowBusinessFailViewController.h"
#import "VoipScrollView.h"
#import "VoipTopSectionHeaderBar.h"
#import "WaveTopSectionView.h"
#import "TPDialerResourceManager.h"

@interface FlowBusinessFailViewController()<VoipTopSectionHeaderBarProtocol>{
    VoipScrollView *_frontView;
    
    VoipTopSectionHeaderBar *_headBar;
}

@end


@implementation FlowBusinessFailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.headerTitle = NSLocalizedString(@"免费电话", @"");
    //self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getResourceByStyle:@"defaultBackground_color"];
    self.view.backgroundColor = [UIColor whiteColor];
    _headBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , 45+TPHeaderBarHeightDiff())];
    _headBar.delegate = self;
    _headBar.headerTitle.text = @"流量钱包";
    _headBar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"flow_topSection_bg_color"];
    [self.view addSubview:_headBar];
    //iphone 6plus 可以放在一个屏幕中
    
    //scrollview调整位置
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _frontView = [[VoipScrollView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    [self.view addSubview:_frontView];

    UIImage *image = [TPDialerResourceManager getImage:@"flow_business_fail@2x.png"];
    float heightWidth = image.size.height / image.size.width;
    
    float globalY = 100;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((TPScreenWidth()-200)/2, globalY, 200, 200 * heightWidth)];
    imageView.image = image;
    [_frontView addSubview:imageView];
    
    int totalHeight = 548;
    if (totalHeight > TPScreenHeight()){
        _frontView.scrollEnabled = YES;
        _frontView.bounces = NO;
        _frontView.showsHorizontalScrollIndicator = NO;
        _frontView.showsVerticalScrollIndicator = NO;
        [_frontView setContentSize:CGSizeMake(TPScreenWidth() , totalHeight)];
    }else{
        [_frontView setContentSize:CGSizeMake(TPScreenWidth() , TPScreenHeight())];
    }
    
    globalY += imageView.frame.size.height + 30;
    
    UILabel *failLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), FONT_SIZE_1_5)];
    failLabel1.text = @"对不起～";
    failLabel1.font = [UIFont systemFontOfSize:FONT_SIZE_1_5];
    failLabel1.textColor = [TPDialerResourceManager getColorForStyle:@"flow_business_label1_color"];
    failLabel1.textAlignment = NSTextAlignmentCenter;
    [_frontView addSubview:failLabel1];

    globalY += failLabel1.frame.size.height + 20;
    
    UILabel *failLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), FONT_SIZE_1_5)];
    failLabel2.text = @"您的手机号无法参加此活动";
    failLabel2.font = [UIFont systemFontOfSize:FONT_SIZE_1_5];
    failLabel2.textColor = [TPDialerResourceManager getColorForStyle:@"flow_business_label1_color"];
    failLabel2.textAlignment = NSTextAlignmentCenter;
    [_frontView addSubview:failLabel2];

    globalY += failLabel2.frame.size.height + 42;
    
    NSString *labelStr = @"很抱歉，此次活动仅面向个人用户开放，\n我们检测到您的手机号可能是商用电话，\n故无法参加此活动，尽请谅解。";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:10];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelStr length])];
    
    UILabel *failLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, TPScreenWidth(), 60)];
    failLabel3.attributedText = attributedString;
    failLabel3.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
    failLabel3.textColor = [TPDialerResourceManager getColorForStyle:@"flow_business_label2_color"];
    failLabel3.textAlignment = NSTextAlignmentCenter;
    failLabel3.numberOfLines = 3;
    [_frontView addSubview:failLabel3];

    [self.view bringSubviewToFront:_headBar];
    
}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
