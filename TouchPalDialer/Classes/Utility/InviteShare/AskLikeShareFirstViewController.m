//
//  AskLikeShareFirstViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/9.
//
//

#import "AskLikeShareFirstViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "AskLikeShareSecondViewController.h"
#import "AskLikeCellView.h"
#import "DialerUsageRecord.h"

@interface AskLikeShareFirstViewController ()<AskLikeCellViewDelegate>{
    NSMutableArray *_array;
}

@end

@implementation AskLikeShareFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _array = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    
    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    titleLabel.text = @"感谢您的支持";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
    
    CGFloat globalY = TPHeaderBarHeightDiff()+ 45 +36;
    
    UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth() - 40, 24)];
    [self.view addSubview:firstView];
    
    UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 24, firstView.frame.size.height)];
    iconLabel.text = @"T";
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:24];
    iconLabel.backgroundColor = [UIColor clearColor];
    iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
    [firstView addSubview:iconLabel];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(28, 0, firstView.frame.size.width-28, 24)];
    textLabel.text = @"推荐给更多朋友";
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.font = [UIFont systemFontOfSize:17];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
    [firstView addSubview:textLabel];
    
    globalY += firstView.frame.size.height + 24;
    
    UIView *contactView = [[UIView alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth()-40, 56*_resultArray.count)];
    contactView.backgroundColor = [UIColor whiteColor];
    contactView.layer.cornerRadius = 4.0f;
    contactView.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
    contactView.layer.borderWidth = 0.5f;
    [self.view addSubview:contactView];
    [self addContactView:contactView];
    
    globalY += contactView.frame.size.height + 24;
    
    UILabel *contactLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth()-40, 14)];
    contactLabel.text = @"推荐给常用联系人，享无限畅打";
    contactLabel.textAlignment = NSTextAlignmentCenter;
    contactLabel.font = [UIFont systemFontOfSize:13];
    contactLabel.backgroundColor = [UIColor clearColor];
    contactLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
    [self.view addSubview:contactLabel];
    
    globalY += contactLabel.frame.size.height + 12;
    
    UIButton *smsButton = [[UIButton alloc]initWithFrame:CGRectMake(40, globalY, TPScreenWidth()-80, 56)];
    [smsButton setTitle:@"一键短信邀请" forState:UIControlStateNormal];
    [smsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    smsButton.layer.cornerRadius = 4.0f;
    smsButton.layer.masksToBounds = YES;
    smsButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [smsButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"] withFrame:smsButton.bounds] forState:UIControlStateNormal];
    [smsButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_700"] withFrame:smsButton.bounds] forState:UIControlStateHighlighted];
    [smsButton addTarget:self action:@selector(smsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:smsButton];
    
    
    NSMutableAttributedString *strNormal = [[NSMutableAttributedString alloc] initWithString:@"跳过此步"];
    [strNormal addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range: NSMakeRange(0, strNormal.length)];
    [strNormal addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_600"] range:NSMakeRange(0, strNormal.length)];
    
    NSMutableAttributedString *strHighlight = [[NSMutableAttributedString alloc] initWithString:@"跳过此步"];
    [strHighlight addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range: NSMakeRange(0, strHighlight.length)];
    [strHighlight addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_800"] range:NSMakeRange(0, strHighlight.length)];
    
    
    CGFloat adjustHeight = TPScreenHeight() < 500 ? 16:0;
    UIButton *skipButton = [[UIButton alloc]initWithFrame:CGRectMake((TPScreenWidth()-100)/2, TPScreenHeight() - (76-TPHeaderBarHeightDiff()) + adjustHeight, 100, 20)];
    [skipButton setBackgroundColor:[UIColor clearColor]];
    [skipButton setAttributedTitle:strNormal forState:UIControlStateNormal];
    [skipButton setAttributedTitle:strHighlight forState:UIControlStateHighlighted];
    skipButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    [DialerUsageRecord recordpath:@"path_voip" kvs:Pair(@"rate_share_enter", @([[NSDate date] timeIntervalSince1970])),nil];
}

- (void)addContactView:(UIView *)contactView{
    for ( NSInteger i =0 ; i < _resultArray.count ; i ++ ){
        AskLikeCellView *view = [[AskLikeCellView alloc]initWithFrame:CGRectMake(0,i*contactView.frame.size.height/_resultArray.count, contactView.frame.size.width, contactView.frame.size.height/_resultArray.count) andDictionary:_resultArray[i]];
        view.delegate = self;
        [contactView addSubview:view];
        
        if ( i <= _resultArray.count - 1){
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, view.frame.size.height-0.5, contactView.frame.size.width-10, 0.5)];
            lineView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
            [view addSubview:lineView];
        }
        
        [_array addObject:_resultArray[i][@"number"]];
    }
}

#pragma mark - Action

- (void)gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)smsButtonClick{
    [DialerUsageRecord recordpath:@"path_voip" kvs:Pair(@"rate_share_click", @([[NSDate date] timeIntervalSince1970])),nil];
    NSString *smsUrl = [FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"];

    [FunctionUtility shareSMS:smsUrl andNeedDefault:YES andMessage:NSLocalizedString(@"voip_sms_share_message", "") andNumber:[_array componentsJoinedByString:@","] andFromWhere:@"ask_like"];
    
    AskLikeShareSecondViewController *vc = [[AskLikeShareSecondViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)skipButtonClick{
    [DialerUsageRecord recordpath:@"path_voip" kvs:Pair(@"rate_share_skip", @([[NSDate date] timeIntervalSince1970])),nil];
    AskLikeShareSecondViewController *vc = [[AskLikeShareSecondViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AskLikeCellViewDelegate

- (void)onButtonClick:(NSString *)phone isSelect:(BOOL)isSelect{
    if ( isSelect )
        [_array addObject:phone];
    else
        [_array removeObject:phone];
}

@end
