//
//  YellowPageWebViewController.m
//  TouchPalDialer
//
//  Created by Simeng on 14-7-16.
//
//

#import "YellowPageWebViewController.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "DefaultSettingViewController.h"
#import "SettingsModelCreator.h"
#import "CootekNotifications.h"
#import "CallLogDataModel.h"
#import "CallLog.h"
#import "TPCallActionController.h"
#import "PersonalCenterController.h"
@implementation YellowPageWebViewController

@synthesize gobackBtn;
@synthesize reloadView;
@synthesize loadingView;
@synthesize imageView;
@synthesize wifiView;
@synthesize reloadLabel;
@synthesize reloadBtn;
@synthesize loadingDissy;
@synthesize loadingLabel;
@synthesize personalCenterButton;
@synthesize funcStr;

- (void)loadView
{
    [super loadView];
    gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];
    gobackBtn.hidden = YES;
    [gobackBtn release];
    self.web_view.hidden = YES;
    
    wait_indicator.hidden = YES;
    
    reloadView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    [self.view addSubview:reloadView];
    reloadView.hidden = YES;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (TPScreenHeight() > 500) ? 73 : 44.5, TPScreenWidth(), 176)];
    [reloadView addSubview:imageView];
    
    wifiView = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2 -20, (TPScreenHeight() > 500) ? 276.5 : 236.5, 39.5, 39.5)];
    [reloadView addSubview:wifiView];
    
    reloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (TPScreenHeight() > 500) ? 330.5 : 280, TPScreenWidth(), 25)];
    reloadLabel.backgroundColor = [UIColor clearColor];
    reloadLabel.text = NSLocalizedString(@"reset_net_prompt", @"");
    reloadLabel.textAlignment = NSTextAlignmentCenter;
    reloadLabel.font = [UIFont systemFontOfSize:12];
    [reloadView addSubview:reloadLabel];
    
    reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake((TPScreenWidth()/2 - 54.5), (TPScreenHeight() > 500) ? 368 : 317.5, 109, 35)];
    [reloadBtn addTarget:self action:@selector(loadURL) forControlEvents:UIControlEventTouchUpInside];
    reloadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [reloadBtn setTitle:NSLocalizedString(@"reload_yellow_page", @"") forState:UIControlStateNormal];
    reloadBtn.layer.cornerRadius = 5;
    reloadBtn.layer.masksToBounds = YES;
    [reloadView addSubview:reloadBtn];
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    [self.view addSubview:loadingView];
    loadingView.hidden = YES;
    
    loadingDissy = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2 - 16.5, (TPScreenHeight() > 500) ? 135 : 120, 33, 33)];
    [loadingView addSubview:loadingDissy];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (TPScreenHeight() > 500) ? 180 : 165, TPScreenWidth(), 25)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.text = NSLocalizedString(@"Loading...", @"");
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont systemFontOfSize:12];
    [loadingView addSubview:loadingLabel];
    
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    reloadView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    loadingView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    imageView.image = [manager getImageByName:@"yellow_page_help@2x.png"];
    wifiView.image = [manager getImageByName:@"yellow_page_wifi@2x.png"];
    reloadLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_reload_text_color"];
    [reloadBtn setBackgroundImage:[FunctionUtility imageWithColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"] withFrame:CGRectMake(0, 0, reloadBtn.frame.size.width, reloadBtn.frame.size.height)] forState:UIControlStateNormal];
    reloadBtn.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"];
    [reloadBtn setTitleColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_text_color"] forState:UIControlStateNormal];
    loadingDissy.image = [manager getImageByName:@"loading_circle@2x.png"];
    loadingLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_loading_text_color"];
    
    //setting button
//    settingBtn = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth()-45, 0, 45, 45)];
//    [settingBtn setSkinStyleWithHost:self forStyle:@"default_moreButton_style"];
//    [settingBtn addTarget:self action:@selector(superDialButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    settingBtn.selected = NO;
//	[self.view addSubview:settingBtn];
//
//    //pulldown sheet
//    PullDownSheet *sheet = [[PullDownSheet alloc] initWithContent:nil];
//    self.pullDownSheet = sheet;
//    [sheet release];
//
    EntranceIcon *tmpCenter = [[EntranceIcon alloc]initWithFrame:CGRectMake(TPScreenWidth() - 50, TPHeaderBarHeightDiff(), 50, 45)];
    [tmpCenter setSkinStyleWithHost:self forStyle:@""];
    tmpCenter.delegate = self;
    [self.view addSubview:tmpCenter];
    self.personalCenterButton = tmpCenter;
    [tmpCenter release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin) name:N_SKIN_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SHOW_ROOT_TAB_BAR object:nil userInfo:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [personalCenterButton refresh];
    [super viewWillAppear:animated];
    [self exitEditingMode];
    [self isAtIndex];
}

- (void)loadURL
{
    [super loadURL];
}

- (void)showPage
{
    self.web_view.hidden = NO;
    reloadView.hidden = YES;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
}

- (void)showReload
{
    self.web_view.hidden = YES;
    reloadView.hidden = NO;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SHOW_ROOT_TAB_BAR object:nil userInfo:nil];
}

- (void)showLoading
{
    self.web_view.hidden = YES;
    reloadView.hidden = YES;
    loadingView.hidden = NO;
    [self beginLoadingAnimation];
}

- (void)beginLoadingAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    [loadingDissy.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [gobackBtn release];
    [reloadView release];
    [loadingView release];
    [imageView release];
    [wifiView release];
    [reloadLabel release];
    [reloadBtn release];
    [loadingDissy release];
    [loadingLabel release];
    [super dealloc];
}

- (void)changeSkin{
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    reloadView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    loadingView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    imageView.image = [manager getImageByName:@"yellow_page_help@2x.png"];
    wifiView.image = [manager getImageByName:@"yellow_page_wifi@2x.png"];
    reloadLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_reload_text_color"];
    [reloadBtn setBackgroundImage:[FunctionUtility imageWithColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"] withFrame:CGRectMake(0, 0, reloadBtn.frame.size.width, reloadBtn.frame.size.height)] forState:UIControlStateNormal];
    reloadBtn.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"];
    [reloadBtn setTitleColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_text_color"] forState:UIControlStateNormal];
    loadingDissy.image = [manager getImageByName:@"loading_circle@2x.png"];
    loadingLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_loading_text_color"];
}

- (BOOL)isAtIndex
{
    NSString *url = [self.web_view.request.URL absoluteString];
    if (url == nil || [url isEqualToString: @""] || [url isEqualToString:@"http://search.cootekservice.com/page/index.html"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_SHOW_ROOT_TAB_BAR object:nil userInfo:nil];
        return YES;
    } else {
        if (!self.web_view.canGoBack) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_SHOW_ROOT_TAB_BAR object:nil userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_ROOT_TAB_BAR object:nil userInfo:nil];
        }
        return NO;
    }
}

#pragma UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSString *url = [self.web_view.request.URL absoluteString];
    if (url == nil || [url isEqualToString: @""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_SHOW_ROOT_TAB_BAR object:nil userInfo:nil];
        gobackBtn.hidden = [self isAtIndex];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_HIDE_ROOT_TAB_BAR object:nil userInfo:nil];
        gobackBtn.hidden = NO;
    }
    [self showLoading];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"tel"]) {
        NSString *phoneNumber = [url resourceSpecifier];
        CallLogDataModel *item = [[CallLogDataModel alloc]
                                  initWithPersonId:-1
                                  phoneNumber:phoneNumber
                                  loadExtraInfo:YES];
        [TPCallActionController logCallFromSource:@"YellowPage"];
        [[TPCallActionController controller] makeCall:item];
        [item release];
        return NO;
    }
    if ([scheme isEqualToString:@"http"]) {
        if ([[url resourceSpecifier] hasPrefix:@"//maps.apple.com"]) {
            return ![[UIApplication sharedApplication] openURL:url];
        }
    }
    if ([scheme isEqualToString:@"pic"]) {
        NSArray *ary1 = [[url resourceSpecifier] componentsSeparatedByString: @"url="];
        if ([ary1 count] == 2) {
            NSString *str = ary1[1];
            NSArray *ary2 = [str componentsSeparatedByString:@"&callback="];
            if ([ary2 count] == 2) {
                funcStr = [ary2[1] retain];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)ary2[0]]]];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                return NO;
            }
        }
    }
    return YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
    NSString *msg = nil;
    NSString *func = nil;
    if(error != NULL) {
        msg = NSLocalizedString(@"save_image_failed", @"保存失败");
        func = [NSString stringWithFormat:@"%@(false)", funcStr];
    } else {
        msg = NSLocalizedString(@"save_image_succeed", @"保存成功");
        func = [NSString stringWithFormat:@"%@(true)", funcStr];
    }
    [self.web_view stringByEvaluatingJavaScriptFromString:func];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.hasLoaded = NO;
    if (error.code != 999) {
        [self showReload];
    }
    gobackBtn.hidden = [self isAtIndex];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.hasLoaded = YES;
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (![theTitle isEqual: @""]) {
        self.headerTitle = theTitle;
    }
    gobackBtn.hidden = [self isAtIndex];
    [self showPage];
    if ([self isAtIndex]) {
        self.web_view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight()-TPHeaderBarHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    } else {
        self.web_view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPAppFrameHeight()-TPHeaderBarHeight()+TPHeaderBarHeightDiff());
    }
}

- (void)gobackBtnPressed
{
    if ([[self.web_view.request.URL absoluteString] isEqualToString:@"http://search.cootekservice.com/page/indexCity.html"] || !self.web_view.canGoBack) {
        self.url_string = @"http://search.cootekservice.com/page/index.html";
        self.hasLoaded = NO;
        [self loadURL];
    } else {
        [self.web_view stopLoading];
        [self.web_view goBack];
    }
}

- (void)exitEditingMode
{
    [self isAtIndex];
}

- (void) onEntranceClick {
    UIViewController *controller = [[PersonalCenterController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


@end
