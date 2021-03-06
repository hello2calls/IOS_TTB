//
//  PersonalViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/24.
//
//

#import "PersonalCenterViewController.h"
#import "HeaderBar.h"
#import "ColorUtil.h"
#import "UILabel+ContentSize.h"
#import "FreeCallLoginController.h"
#import "ChargeViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommonWebViewController.h"
#import "UserDefaultsManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "IntroduceViewController.h"
#import "YellowPageWebViewController.h"
#import "CTUrl.h"
#import "SeattleFeatureExecutor.h"
#import "HistoryViewController.h"
#import "HandlerWebViewController.h"
#import "MBProgressHUD+MJ.h"
#import "UIScrollView+MJRefresh.h"
#import "FeedbackViewController.h"
#import "MJRefreshNormalHeader.h"
#import "NoahManager.h"


@interface PersonalCenterViewController ()

@property(nonatomic, retain) HeaderBar *headerView;

@property(nonatomic, strong) UIView *topView;

@property(strong, nonatomic) UIButton *chargeBtn;

@property(strong, nonatomic) UIButton *historyBtn;

@property(strong, nonatomic) UIButton *questionBtn;

@property(strong, nonatomic) UIButton *feedbackBtn;

@property(strong, nonatomic) UIButton *loginBtn;

@property(strong, nonatomic) UILabel *minutesTitleLabel;

@property(strong, nonatomic) UILabel *minutesLabel;

@property(strong, nonatomic) UILabel *noLoginLabel;

@property(strong, nonatomic) UILabel *numberLabel;

@property(strong, nonatomic) MJRefreshStateHeader *header;

@property (strong, nonatomic)UIScrollView *scrollView;
@end

@implementation PersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView
{
    [self initHeader];
    [self initBody];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginInfo) name:@"loginAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"getAccount" object:nil];
    [[NoahManager sharedPSInstance] registerDevice:[UserDefaultsManager stringForKey:APPLE_PUSH_TOKEN]];

}


-(void)viewWillAppear:(BOOL)animated{

    [SeattleFeatureExecutor queryVOIPAccountInfo];
}



//用户信息更新通知
-(void)updateUserInfo : (NSNotification *)notification
{
    NSString *balance = notification.object;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _minutesLabel.text = balance;
        });
    });

}

//登录更新通知
-(void)updateLoginInfo
{
    [_loginBtn setTitle:NSLocalizedString(@"personal_center_logout_text",@"") forState:UIControlStateNormal];
    _minutesTitleLabel.hidden = NO;
    _minutesLabel.hidden = NO;
    _noLoginLabel.hidden = YES;
    NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];
    _numberLabel.text = accountName;
}

-(void)initHeader
{
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    self.headerView = headerBar;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-180)/2, TPHeaderBarHeightDiff(), 180, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = NSLocalizedString(@"personal_center_title",@"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:titleLabel];
}


-(void)initBody
{

    _header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(doRefresh)];
    [_header setTitle:NSLocalizedString(@"refresh_normal", @"") forState:MJRefreshStateIdle];
    [_header setTitle:NSLocalizedString(@"refresh_pull", @"") forState:MJRefreshStatePulling];
    [_header setTitle:NSLocalizedString(@"refresh_pulling", @"") forState:MJRefreshStateRefreshing];
    _header.lastUpdatedTimeLabel.hidden = YES;
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.frame = CGRectMake(0, 45 + TPHeaderBarHeightDiff(), TPScreenWidth(), TPScreenHeight() - (45 + TPHeaderBarHeightDiff()));
    _scrollView.contentSize = CGSizeMake(TPScreenWidth(), TPScreenHeight());
    [_scrollView setMj_header:_header];
    [self.view addSubview:_scrollView];
    [self initTopView :_scrollView];
    
    
    _chargeBtn = [[UIButton alloc]init];
    _chargeBtn.frame = CGRectMake(0,_topView.tp_y + _topView.tp_height + 10, TPScreenWidth(), 60);
    _chargeBtn.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_chargeBtn];
    [self createItemButton:NSLocalizedString(@"personal_center_item_charge",@"") image:[UIImage imageNamed:@"ic_charge"] root:_chargeBtn];
    
    _historyBtn = [[UIButton alloc]init];
    _historyBtn.frame = CGRectMake(0,_chargeBtn.tp_y + _chargeBtn.tp_height + 10, TPScreenWidth(), 60);
    _historyBtn.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_historyBtn];
    [self createItemButton:NSLocalizedString(@"personal_center_item_charge_history",@"") image:[UIImage imageNamed:@"ic_history"] root:_historyBtn];
    
    
    _questionBtn = [[UIButton alloc]init];
    _questionBtn.frame = CGRectMake(0,_historyBtn.tp_y + _historyBtn.tp_height + 10, TPScreenWidth(), 60);
    _questionBtn.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_questionBtn];
    [self createItemButton:NSLocalizedString(@"personal_center_item_charge_rate",@"")  image:[UIImage imageNamed:@"ic_question"] root:_questionBtn];
    
    
    _feedbackBtn = [[UIButton alloc]init];
    _feedbackBtn.frame = CGRectMake(0,_questionBtn.tp_y + _questionBtn.tp_height + 10, TPScreenWidth(), 60);
    _feedbackBtn.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_feedbackBtn];
    [self createItemButton:NSLocalizedString(@"feed_back",@"")   image:[UIImage imageNamed:@"ic_feedback"] root:_feedbackBtn];
    
    _loginBtn = [[UIButton alloc]init];
    _loginBtn.frame = CGRectMake(0,_feedbackBtn.tp_y + _feedbackBtn.tp_height + 10, TPScreenWidth(), 60);
    _loginBtn.backgroundColor = [UIColor whiteColor];
    
    if([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]){
        [_loginBtn setTitle:NSLocalizedString(@"personal_center_logout_text",@"") forState:UIControlStateNormal];
        _minutesTitleLabel.hidden = NO;
        _minutesLabel.hidden = NO;
        _noLoginLabel.hidden = YES;
    }else{
        [_loginBtn setTitle:NSLocalizedString(@"personal_center_login_text",@"") forState:UIControlStateNormal];
        _minutesTitleLabel.hidden = YES;
        _minutesLabel.hidden = YES;
        _noLoginLabel.hidden = NO;
    }
    [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_scrollView addSubview:_loginBtn];
    
    
    [_chargeBtn addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_historyBtn addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_questionBtn addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_feedbackBtn addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn addTarget:self action:@selector(OnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)initTopView : (UIScrollView *)scrollView
{
    _topView = [[UIView alloc]init];
    _topView.frame = CGRectMake(0, 0, TPScreenWidth(), 200);
    _topView.backgroundColor = [ColorUtil colorWithHexString:@"#3695ED"];
    [scrollView addSubview:_topView];
    
    [self createCircleView:140 backgroudColor: [ColorUtil colorWithHexString:@"#58aeff" alpha:103.0f/255.0f] view:_topView];
    [self createCircleView:120 backgroudColor: [ColorUtil colorWithHexString:@"#88c6ff" alpha:1.0f] view:_topView];
    
    _minutesTitleLabel = [[UILabel alloc]init];
    _minutesTitleLabel.text = NSLocalizedString(@"personal_center_munites_left_lable",@"");
    _minutesTitleLabel.font = [UIFont systemFontOfSize:13.0f];
    _minutesTitleLabel.textColor = [UIColor whiteColor];
    _minutesTitleLabel.frame = CGRectMake((TPScreenWidth() - _minutesTitleLabel.contentSize.width ) /2, 80 - _minutesTitleLabel.contentSize.height  - 10, _minutesTitleLabel.contentSize.width, _minutesTitleLabel.contentSize.height);
    [_topView addSubview:_minutesTitleLabel];
    
    
    _minutesLabel = [[UILabel alloc]init];
    _minutesLabel.font = [UIFont systemFontOfSize:20.0f];
    _minutesLabel.textColor = [UIColor whiteColor];
    _minutesLabel.textAlignment = NSTextAlignmentCenter;
    _minutesLabel.text = [NSString stringWithFormat:@"%d",[UserDefaultsManager intValueForKey:@"voip_account_balance"]];
    _minutesLabel.frame = CGRectMake(0, 80 , TPScreenWidth(), 30);
    [_topView addSubview:_minutesLabel];
    
    
    _noLoginLabel = [[UILabel alloc]init];
    _noLoginLabel.font = [UIFont systemFontOfSize:20.0f];
    _noLoginLabel.textColor = [UIColor whiteColor];
    _noLoginLabel.textAlignment = NSTextAlignmentCenter;
    _noLoginLabel.text = NSLocalizedString(@"personal_center_need_login",@"");
    _noLoginLabel.hidden = YES;
    _noLoginLabel.frame = CGRectMake(0, (160 - _noLoginLabel.contentSize.height)/2 , TPScreenWidth(), _noLoginLabel.contentSize.height);
    [_topView addSubview:_noLoginLabel];
    
    
    _numberLabel = [[UILabel alloc]init];
    _numberLabel.font = [UIFont systemFontOfSize:18.0f];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    if([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]){
        NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];
        _numberLabel.text = accountName;
    }else{
        _numberLabel.text = @"";
    }
    _numberLabel.frame = CGRectMake(0, 160, TPScreenWidth(), _numberLabel.contentSize.height);
    [_topView addSubview:_numberLabel];



}


-(void)createCircleView : (int)width backgroudColor : (UIColor *)color view : (UIView *)topView
{
    UIView *outCircleView = [[UIView alloc]init];
    outCircleView.frame = CGRectMake((TPScreenWidth() - width)/2,  (160-width)/2, width, width);
    outCircleView.layer.cornerRadius = width/2;
    outCircleView.layer.masksToBounds = YES;
    outCircleView.backgroundColor = color;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(OnClick:)];
    [outCircleView addGestureRecognizer:recognizer];
    [topView addSubview:outCircleView];
}


-(void)createItemButton : (NSString *)title image : (UIImage *)image root : (UIButton *)button
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = image;
    imageView.frame = CGRectMake(20, 15, 30, 30);
    [button addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]init];
    label.text = title;
    label.textColor = [UIColor blackColor];
    label.frame = CGRectMake(60, (60 -label.contentSize.height)/2, label.contentSize.width, label.contentSize.height);
    [button addSubview:label];
    
    UIImageView *arrowImageView = [[UIImageView alloc]init];
    arrowImageView.image = [UIImage imageNamed:@"ic_arrow"];
    arrowImageView.frame = CGRectMake(TPScreenWidth()-50, 20, 20, 20);
    [button addSubview:arrowImageView];
    
}



-(void)OnClick : (id)sender
{
    UIButton *button = sender;
    if(![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]){
         [LoginController checkLoginWithDelegate:[FreeCallLoginController withOrigin:@"personal_center_head"] ];
        
        return;
    }

    if(button == _chargeBtn){
        [TouchPalDialerAppDelegate pushViewController:[[ChargeViewController alloc]init] animated:YES];
        
    }else if(button == _historyBtn){
        [TouchPalDialerAppDelegate pushViewController:[[HistoryViewController alloc]init] animated:YES];
        
    }else if(button == _questionBtn){
        [TouchPalDialerAppDelegate pushViewController:[[IntroduceViewController alloc]init] animated:YES];
        
    }else if(button == _loginBtn){
        [self doLogin];
    }
    else if(button == _feedbackBtn){
      [TouchPalDialerAppDelegate pushViewController:[[FeedbackViewController alloc]init] animated:YES];
    }
}

-(void)doLogin{
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"personal_center_logout_hint", @"") message:nil cancelTitle:NSLocalizedString(@"personal_center_logout_cancel", @"") okTitle:NSLocalizedString(@"personal_center_logout_confirm", @"") okButtonActionBlock:^ {
        [LoginController removeLoginDefaultKeys];
        [_loginBtn setTitle:NSLocalizedString(@"personal_center_login_text",@"") forState:UIControlStateNormal];
        _numberLabel.text = @"";
        _noLoginLabel.hidden = NO;
        _minutesLabel.hidden = YES;
        _minutesTitleLabel.hidden = YES;
    } cancelActionBlock:^{
        
    }];
}


-(void)doRefresh{
    if([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]){
        [SeattleFeatureExecutor queryVOIPAccountInfo];
    }
    [_header endRefreshing];
}


@end
