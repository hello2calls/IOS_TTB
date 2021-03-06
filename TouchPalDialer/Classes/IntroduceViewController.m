
//
//  IntroduceViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/27.
//
//

#import "IntroduceViewController.h"
#import "TPDialerResourceManager.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UILabel+ContentSize.h"
#import "TouchPalDialerAppDelegate.h"

@interface IntroduceViewController ()

@property(nonatomic, retain) HeaderBar *headerView;


@end

@implementation IntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}


-(void)initView
{
    [self.view setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"]];
    [self initHeader];
    [self initBody];
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
    titleLabel.text = NSLocalizedString(@"personal_center_item_charge_rate", @"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}

-(void)initBody
{
    
    UITextView *textView = [[UITextView alloc]init];
    textView.text =[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"personal_center_rate_introduce", @""),NSLocalizedString(@"personal_center_rate_introduce2", @"")];
    textView.font = [UIFont systemFontOfSize:18.0f];
    textView.editable = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.frame = CGRectMake(20,TPHeaderBarHeightDiff() + 45 , TPScreenWidth() - 40, 300);
    [self.view addSubview:textView];
}



-(void)gobackBtnPressed
{
    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
}


@end
