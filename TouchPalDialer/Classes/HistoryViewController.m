//
//  HistoryViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/27.
//
//

#import "HistoryViewController.h"
#import "TPHttpRequest.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView
{
    [self.view setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"]];
    [self initHeader];
    NSString *url = @"http://121.52.250.39:30007/voip/ttbpay_history";
    [[TPHttpRequest sharedTPHttpRequest] post:url content:nil success:^(id respondObj) {
        
    } fail:^(id respondObj, NSError *error) {
        
    }];
    
}


-(void)initHeader
{
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    
    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = @"充值历史记录";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}

@end
