//
//  FeatureGuideSelectCountryViewController.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 8/30/12.
//
//

#import "FeatureGuideSelectCarrierViewController.h"
#import "FeatureGuideSelectCarrierView.h"

@interface FeatureGuideSelectCarrierViewController()
- (void)gotoBack;
@end

@implementation FeatureGuideSelectCarrierViewController
@synthesize selectRowBlock = selectRowBlock_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerTitle = NSLocalizedString(@"Select SIM Carrier", @"");
    FeatureGuideSelectCarrierView *carrierListView = [[FeatureGuideSelectCarrierView alloc] initWithFrame:
                                                      CGRectMake(0,TPHeaderBarHeight(), TPScreenWidth(),TPHeightFit(435)) needAnimation:NO];
    carrierListView.selectRowBlock = ^(NSString *carrier){
        if(selectRowBlock_){
           selectRowBlock_(carrier);
        }
        [self gotoBack];
    };
    carrierListView.datas = [NSArray arrayWithObjects:@"China Mobile",@"China Unicom",@"China Telecom", nil];
    [self.view addSubview:carrierListView];
}

- (void)gotoBack {
	[self.navigationController popViewControllerAnimated:YES];
}
@end
