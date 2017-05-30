//
//  FlowExtractViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/30.
//
//

#import "FlowExtractViewController.h"
#import "VoipTopSectionHeaderBar.h"
#import "TPDialerResourceManager.h"

@interface FlowExtractViewController()<VoipTopSectionHeaderBarProtocol>{
    VoipTopSectionHeaderBar *_headBar;
}

@end

@implementation FlowExtractViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    _headBar = [[VoipTopSectionHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , 45+TPHeaderBarHeightDiff())];
    _headBar.delegate = self;
    _headBar.headerTitle.text = @"提取流量";
    _headBar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_top_view_green_bg_color"];
    [self.view addSubview:_headBar];
    
    UIButton *getFlowButton = [[UIButton alloc]initWithFrame:CGRectMake((TPScreenWidth() - 100)/2,_headBar.frame.size.height + 100, 100, 50)];
    [getFlowButton setTitle:@"提取流量" forState:UIControlStateNormal];
    [getFlowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getFlowButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:getFlowButton];
    [getFlowButton addTarget:self action:@selector(getFlow) forControlEvents:UIControlEventTouchDragInside];
    
    [_headBar setButtonText:@"J"];

}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
