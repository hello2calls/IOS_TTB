//
//  ChargeViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/26.
//
//

#import "ChargeViewController.h"
#import "CommonWebView.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "SeattleFeatureExecutor.h"
#import "IndexConstant.h"
#import "ColorUtil.h"
#import "UserDefaultsManager.h"
#import "UILabel+ContentSize.h"
#import "PayButton.h"

@interface ChargeViewController ()

@property (strong, nonatomic) UIView *topView;

@property (strong, nonatomic) UILabel *phoneNumLabel;

@property (strong, nonatomic) PayButton *button100;

@property (strong, nonatomic) PayButton *button150;

@property (strong, nonatomic) PayButton *button500;

@property (strong, nonatomic) PayButton *button1100;

@property (strong, nonatomic) UIButton *chargeBtn;


@end

@implementation ChargeViewController{
    int select;
}

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
    titleLabel.text = @"通话时长充值";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}


-(void)initBody
{
    _topView = [[UIView alloc]init];
    _topView.frame = CGRectMake(0, 45 + TPHeaderBarHeightDiff(), TPScreenWidth(), 120);
    _topView.backgroundColor = [ColorUtil colorWithHexString:@"#3695ED"];
    [self.view addSubview:_topView];
    
    UIView *phoneView = [[UIView alloc]init];
    int width = TPScreenWidth() - 40;
    phoneView.frame = CGRectMake(20, 30, width, 60);
    phoneView.layer.masksToBounds = YES;
    phoneView.layer.cornerRadius = 8;
    phoneView.backgroundColor = [UIColor whiteColor];
    [_topView addSubview:phoneView];
    
    _phoneNumLabel = [[UILabel alloc]init];
    _phoneNumLabel.textColor = [UIColor blackColor];
    _phoneNumLabel.font = [UIFont systemFontOfSize:18.0f];
    if([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]){
        NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];
        _phoneNumLabel.text = accountName;
    }else{
        _phoneNumLabel.text = @"未登录";
    }
    _phoneNumLabel.textAlignment = NSTextAlignmentCenter;
    _phoneNumLabel.frame = phoneView.frame;
    [_topView addSubview:_phoneNumLabel];
    
    
    UIImage *image = [UIImage imageNamed:@"ic_phone"];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = image;
    imageView.frame = CGRectMake(40, 40, 40, 40);
    [_topView addSubview:imageView];
    
    int payButtonWidth =( TPScreenWidth() - 60 ) /2;
    _button100 = [[PayButton alloc]initWithFrame:CGRectMake(20, 45 + TPHeaderBarHeightDiff()+120 + 20, payButtonWidth, 50)];
    [_button100 setTitle:@"100 min/ ¥ 8" forState:UIControlStateNormal];
    [_button100 addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_button100 setButtonSelect:YES];
    select = 0;
    [self.view addSubview:_button100];
    
    _button150 = [[PayButton alloc]initWithFrame:CGRectMake(40 + payButtonWidth, 45 + TPHeaderBarHeightDiff()+120 + 20, payButtonWidth, 50)];
    [_button150 setTitle:@"150 min/ ¥ 12" forState:UIControlStateNormal];
    [_button150 addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button150];
    
    _button500 = [[PayButton alloc]initWithFrame:CGRectMake(20, 45 + TPHeaderBarHeightDiff()+120 + 90, payButtonWidth, 50)];
    [_button500 setTitle:@"500 min/ ¥ 40" forState:UIControlStateNormal];
    [_button500 addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button500];
    
    _button1100 = [[PayButton alloc]initWithFrame:CGRectMake(40 + payButtonWidth, 45 + TPHeaderBarHeightDiff()+120 + 90, payButtonWidth, 50)];
    [_button1100 setTitle:@"1100 min/ ¥ 88" forState:UIControlStateNormal];
    [_button1100 addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button1100];
    
    
    int chargeBtnWidth = TPScreenWidth()/2;
    _chargeBtn = [[UIButton alloc]init];
    _chargeBtn.backgroundColor = [ColorUtil colorWithHexString:@"#3695ED"];
    _chargeBtn.layer.masksToBounds = YES;
    _chargeBtn.layer.cornerRadius = 8;
    [_chargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_chargeBtn setTitle:@"立即充值" forState:UIControlStateNormal];
    _chargeBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _chargeBtn.frame = CGRectMake(TPScreenWidth()/4,  45 + TPHeaderBarHeightDiff()+120 + 170, chargeBtnWidth, 40);
    [_chargeBtn addTarget:self action:@selector(charge) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chargeBtn];
}


-(void)OnClick : (id)sender
{
    [_button100 setButtonSelect:NO];
    [_button150 setButtonSelect:NO];
    [_button500 setButtonSelect:NO];
    [_button1100 setButtonSelect:NO];
    PayButton *button  = sender;
    if(button == _button100){
        select = 0;
    }
    else if(button == _button150){
        select = 1;
    }
    else if(button == _button500){
        select = 2;
    }
    else if(button == _button1100){
        select = 3;
    }
    [button setButtonSelect:YES];
    
}

-(void)charge
{
    switch (select) {
        case 0:
            [self doChage:100];
            break;
        case 1:
            [self doChage:150];
            break;
        case 2:
            [self doChage:500];
            break;
        case 3:
            [self doChage:1100];
            break;
        default:
            break;
    }
}

-(void)doChage : (int)minutes
{
    NSLog([NSString stringWithFormat:@"%d",minutes]);
}

-(void)gobackBtnPressed
{
    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
}


@end
