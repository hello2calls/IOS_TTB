//
//  AskLikeShareSecondViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/9.
//
//

#import "AskLikeShareSecondViewController.h"
#import "TPDialerResourceManager.h"
#import "TPHeaderButton.h"
#import "HeaderBar.h"
#import "AskLikeShareView.h"
#import "FunctionUtility.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"

@interface AskLikeShareSecondViewController ()

@end

@implementation AskLikeShareSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] ){
    
        UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth() - 40, 24)];
        [self.view addSubview:firstView];
        
        UILabel *iconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 24, firstView.frame.size.height)];
        iconLabel.text = @"S";
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
        iconLabel.backgroundColor = [UIColor clearColor];
        iconLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
        [firstView addSubview:iconLabel];
        
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(28, 0, firstView.frame.size.width-28, 24)];
        textLabel.text = @"更多分享方式";
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:17];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
        [firstView addSubview:textLabel];
        
        globalY += firstView.frame.size.height + 24;
        
        UIView *shareView = [[UIView alloc]initWithFrame:CGRectMake(25, globalY, TPScreenWidth() - 50, 82)];
        [self.view addSubview:shareView];
        
        
        CGFloat betweenWidth = (TPScreenWidth() - 290)/3;
        AskLikeShareView *wechatShareView = [[AskLikeShareView alloc]initWithFrame:CGRectMake(0, 0, 60, 82) andDictionary:@{@"share_icon":@"r",@"share_icon_color":@"tp_color_green_500",@"share_text":@"微信好友"}];
        [shareView addSubview:wechatShareView];
        wechatShareView.clickBlock = ^{
            NSString *url = [FunctionUtility generateWechatMessage:@"weixin020" andFrom:@"friends"];
            [FunctionUtility shareByWeixin:NSLocalizedString(@"voip_weixin_share_title", "") andDescription:NSLocalizedString(@"voip_weixin_share_description", "") andUrl:url andImageUrl:nil andFromWhere:@"ask_like_share_second" andResultCallback:nil];
            [DialerUsageRecord recordpath:PATH_RATE_NEW kvs:Pair(@"rate_share_wechat", @([[NSDate date] timeIntervalSince1970])),nil];
        };
        
        AskLikeShareView *timelineShareView = [[AskLikeShareView alloc]initWithFrame:CGRectMake(60+betweenWidth, 0, 60, 82) andDictionary:@{@"share_icon":@"p",@"share_icon_color":@"tp_color_light_blue_400",@"share_text":@"朋友圈"}];
        [shareView addSubview:timelineShareView];
        timelineShareView.clickBlock = ^{
            NSString *url = [FunctionUtility generateWechatMessage:@"timeline020" andFrom:@"timeline"];
            [FunctionUtility shareByWeixinTimeline:NSLocalizedString(@"voip_weixin_timeline_share", "") andDescription:nil andUrl:url andImageUrl:nil andFromWhere:@"ask_like_share_second" andResultCallback:nil];
            [DialerUsageRecord recordpath:PATH_RATE_NEW kvs:Pair(@"rate_share_timeline", @([[NSDate date] timeIntervalSince1970])),nil];
        };
        
        AskLikeShareView *qqShareView = [[AskLikeShareView alloc]initWithFrame:CGRectMake(120+2*betweenWidth, 0, 60, 82) andDictionary:@{@"share_icon":@"q",@"share_icon_color":@"tp_color_light_blue_500",@"share_text":@"QQ好友"}];
        [shareView addSubview:qqShareView];
        qqShareView.clickBlock = ^{
            NSString *url = [FunctionUtility generateWechatMessage:@"qq020" andFrom:@"qq"];
            [FunctionUtility shareByQQ:NSLocalizedString(@"voip_weixin_share_title", "") andDescription:NSLocalizedString(@"voip_weixin_share_description", "") andUrl:url andImageUrl:nil andFromWhere:@"ask_like_share_second" andResultCallback:nil];
            [DialerUsageRecord recordpath:PATH_RATE_NEW kvs:Pair(@"rate_share_qq", @([[NSDate date] timeIntervalSince1970])),nil];
        };
        
        AskLikeShareView *qzoneShareView = [[AskLikeShareView alloc]initWithFrame:CGRectMake(shareView.frame.size.width - 60, 0, 60, 82) andDictionary:@{@"share_icon":@"t",@"share_icon_color":@"tp_color_amber_500",@"share_text":@"QQ空间"}];
        [shareView addSubview:qzoneShareView];
        qzoneShareView.clickBlock = ^{
            NSString *url = [FunctionUtility generateWechatMessage:@"qzone020" andFrom:@"qzone"];
            [FunctionUtility shareByQQZone:NSLocalizedString(@"voip_weixin_timeline_share", "") andDescription:nil andUrl:url andImageUrl:nil andFromWhere:@"ask_like_share_second" andResultCallback:nil];
            [DialerUsageRecord recordpath:PATH_RATE_NEW kvs:Pair(@"rate_share_qzone", @([[NSDate date] timeIntervalSince1970])),nil];
        };
        
        globalY += shareView.frame.size.height + 36;
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth()-20, 0.5)];
        lineView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_150"];
        [self.view addSubview:lineView];
        
        globalY += lineView.frame.size.height + 36;
        
    }
    
    UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(20, globalY, TPScreenWidth() - 40, 24)];
    [self.view addSubview:secondView];
    
    UILabel *iconLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 24, secondView.frame.size.height)];
    iconLabel2.text = @"f";
    iconLabel2.textAlignment = NSTextAlignmentCenter;
    iconLabel2.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    iconLabel2.backgroundColor = [UIColor clearColor];
    iconLabel2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
    [secondView addSubview:iconLabel2];
    
    UILabel *textLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(28, 0, secondView.frame.size.width-28, 24)];
    textLabel2.text = @"给我们打分";
    textLabel2.textAlignment = NSTextAlignmentLeft;
    textLabel2.font = [UIFont systemFontOfSize:17];
    textLabel2.backgroundColor = [UIColor clearColor];
    textLabel2.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"];
    [secondView addSubview:textLabel2];
    
    globalY += secondView.frame.size.height + 24;
    
    UIButton *likeButton = [[UIButton alloc]initWithFrame:CGRectMake(40, globalY, TPScreenWidth()-80, 56)];
    [likeButton setTitle:@"喜欢我们，就给好评" forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    likeButton.layer.cornerRadius = 4.0f;
    likeButton.layer.masksToBounds = YES;
    likeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [likeButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_600"] withFrame:likeButton.bounds] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_orange_700"] withFrame:likeButton.bounds] forState:UIControlStateHighlighted];
    [likeButton addTarget:self action:@selector(likeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:likeButton];
    
    [DialerUsageRecord recordpath:PATH_RATE_NEW kvs:Pair(@"rate_page_enter", @([[NSDate date] timeIntervalSince1970])),nil];
    
}

#pragma mark - Action

- (void)gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)likeButtonClick
{
    [DialerUsageRecord recordpath:PATH_RATE_NEW kvs:Pair(@"rate_app_click", @([[NSDate date] timeIntervalSince1970])),nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TOUCHPAL_DIALER_APP_STORE_REVIEW_URL]];

}


@end
