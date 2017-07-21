//
//  FeedbackViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/7/21.
//
//

#import "FeedbackViewController.h"
#import "TPDialerResourceManager.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UILabel+ContentSize.h"
#import "ByTextField.h"
#import "ColorUtil.h"
#import "TPHttpRequest.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "TPChargeUtil.h"

@interface FeedbackViewController ()

@property (strong, nonatomic) ByTextField *emailTextField;

@property (strong, nonatomic) UITextView *contentTextView;

@property (strong, nonatomic) UIButton *commitBtn;

@end

@implementation FeedbackViewController

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
    titleLabel.text = NSLocalizedString(@"feed_back",@"");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}

-(void)initBody
{
    
    UILabel *emailTitleLabel = [[UILabel alloc]init];
    emailTitleLabel.text = NSLocalizedString(@"feed_back_email",@"");
    emailTitleLabel.font = [UIFont systemFontOfSize:16.0f];
    emailTitleLabel.textColor = [UIColor blackColor];
    emailTitleLabel.textAlignment = NSTextAlignmentCenter;
    emailTitleLabel.frame = CGRectMake(20, 20 +TPStatusBarHeight() + 45, emailTitleLabel.contentSize.width, 40);
    [self.view addSubview:emailTitleLabel];
    
    
    _emailTextField = [[ByTextField alloc]init];
    _emailTextField.placeholder = NSLocalizedString(@"feed_back_email_hint", @"");
    _emailTextField.font = [UIFont systemFontOfSize:16.0f];
    _emailTextField.textColor = [UIColor blackColor];
    _emailTextField.layer.borderWidth = 0.5;
    _emailTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];;
    _emailTextField.layer.masksToBounds = YES;
    _emailTextField.layer.cornerRadius = 4;
    _emailTextField.backgroundColor = [UIColor whiteColor];
    [_emailTextField setPadding:10 right:10 top:0 bottom:0];
    _emailTextField.frame = CGRectMake(20 + emailTitleLabel.contentSize.width, 20 +TPStatusBarHeight() + 45, TPScreenWidth()-emailTitleLabel.contentSize.width - 40, 40);
    [self.view addSubview:_emailTextField];

    _contentTextView = [[UITextView alloc]init];
    _contentTextView.font = [UIFont systemFontOfSize:16.0f];
    _contentTextView.textColor = [UIColor blackColor];
    _contentTextView.layer.borderWidth = 0.5;
    _contentTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];;
    _contentTextView.layer.masksToBounds = YES;
    _contentTextView.layer.cornerRadius = 4;
    _contentTextView.frame = CGRectMake(20 , 20 +TPStatusBarHeight() + 45 + 40 + 10, TPScreenWidth() - 40, 200);
    [self.view addSubview:_contentTextView];
    
    
    _commitBtn = [[UIButton alloc]init];
    _commitBtn.backgroundColor = [ColorUtil colorWithHexString:@"#3695ED"];
    _commitBtn.layer.masksToBounds = YES;
    _commitBtn.layer.cornerRadius = 8;
    [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    _commitBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _commitBtn.frame = CGRectMake(20,  20 +TPStatusBarHeight() + 45 + 40 + 10 + 220, TPScreenWidth()-40, 50);
    [_commitBtn addTarget:self action:@selector(doFeedback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commitBtn];
}


- (void) gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doFeedback{
    NSString *emailStr = _emailTextField.text;
    NSString *contentStr = _contentTextView.text;
    NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:nil];

    
    if(IS_NS_STRING_EMPTY(contentStr)){
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"feed_back_content_nil",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSString *url = @"http://search.oem.cootekservice.com/yellowpage_v3/collector_push";
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    dic[@"type"] = @"feedback";
    
    NSMutableDictionary *feedbackDic = [[NSMutableDictionary alloc]init];
    feedbackDic[@"message"] = contentStr;
    feedbackDic[@"email"] = emailStr;
    feedbackDic[@"phone"] = accountName;
    feedbackDic[@"buildnumber"] = @"1";
    feedbackDic[@"channelcode"] = IPHONE_CHANNEL_CODE;
    
    dic[@"json"] = [TPChargeUtil transformJson:feedbackDic];

    [[TPHttpRequest sharedTPHttpRequest]post:url content:[TPChargeUtil transformJson:dic] success:^(id respondObj) {
        NSData *data = respondObj;
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        long resultCode = [[resultDic objectForKey:@"result_code"] intValue];
        if(resultCode == 2000)
        {
            UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"feed_back_commit_success_title",@"") message:NSLocalizedString(@"feed_back_commit_success_content", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil, nil];
            [alertView show];
            _emailTextField.text = @"";
            _contentTextView.text = @"";
        }else{
            [self showErrorDialog];
        }
       
    } fail:^(id respondObj, NSError *error) {
        [self showErrorDialog];
        
    }];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_emailTextField resignFirstResponder];
    [_contentTextView resignFirstResponder];
}

-(void)showErrorDialog
{
    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"feed_back_commit_fail_title",@"") message:NSLocalizedString(@"feed_back_commit_fail_content",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil, nil];
    [alertView show];
}

@end
