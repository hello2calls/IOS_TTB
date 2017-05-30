//
//  NoahWebView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/2/2.
//
//

#import "CommonWebView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "NoahManager.h"
#import "UIDataManager.h"
#import "WKWebView+FLWKWebView.h"
#import "UIWebView+FLUIWebView.h"

@interface CommonWebView(){
    UIView *loadingView;
    UIView *reloadView;
    UIImageView *loadingDissy;
    UIImageView *imageView;
    UIImageView *wifiView;
    UILabel *reloadLabel;
    UIButton *reloadBtn;
    
    BOOL ifNoah;
    BOOL hasErrorPageReload;
}

@end

@implementation CommonWebView

@synthesize url_string;
@synthesize web_view;

- (instancetype)initWithFrame:(CGRect)frame andIfNoah:(BOOL)boolIfNoah andUsingWkWebview:(BOOL)boolUsingWkWebview{
    self = [self initWithFrame:frame];
    
    if (self){
        ifNoah = boolIfNoah;
        if (boolUsingWkWebview) {
            if (NSClassFromString(@"WKWebView")) {
                web_view = [[WKWebView alloc] initWithFrame:self.bounds];
            } else {
                web_view = [[UIWebView alloc] initWithFrame: self.bounds];
                ((UIWebView *)web_view).scalesPageToFit = YES;
            }
            web_view.backgroundColor = [UIColor whiteColor];
            [self addSubview:web_view];
        } else {
            web_view = [[UIWebView alloc] initWithFrame: self.bounds];
            ((UIWebView *)web_view).scalesPageToFit = YES;
            web_view.backgroundColor = [UIColor whiteColor];
            [self addSubview:web_view];
        }
    }
    
    return self;
}

- (instancetype)initWithADFrame:(CGRect)frame andIfNoah:(BOOL)boolIfNoah{
    self = [self initWithADFrame:frame];
    if (self){
        ifNoah = boolIfNoah;
        web_view = [[UIWebView alloc] initWithFrame: self.bounds];
        ((UIWebView *)web_view).scalesPageToFit = YES;
        web_view.backgroundColor = [UIColor clearColor];
        web_view.opaque = NO;
        for (UIView *view in web_view.subviews) {
            for (UIView *aview in view.subviews) {
                aview.backgroundColor = [UIColor clearColor];
            }
        }
        
        
        [self addSubview:web_view];
    }
    return self;
}


- (instancetype)initWithADFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:loadingView];
        loadingView.hidden = YES;
        
        loadingDissy = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2 - 16.5, frame.size.height/2 - 40, 33, 33)];
        loadingDissy.image = [[TPDialerResourceManager sharedManager] getImageByName:@"loading_circle@2x.png"];
        [loadingView addSubview:loadingDissy];
        
        reloadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:reloadView];
        reloadView.hidden = YES;

        wifiView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2 -20, frame.size.height/2 - 40, 39.5, 39.5)];
        wifiView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"yellow_page_wifi@2x.png"];
        [reloadView addSubview:wifiView];
        
        reloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2 + 10, frame.size.width, 25)];
        reloadLabel.backgroundColor = [UIColor clearColor];
        reloadLabel.text = NSLocalizedString(@"reset_net_prompt", @"");
        reloadLabel.textAlignment = NSTextAlignmentCenter;
        reloadLabel.font = [UIFont systemFontOfSize:12];
        [reloadView addSubview:reloadLabel];
        
        reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2 - 54.5), frame.size.height/2 + 40 ,109, 35)];
        [reloadBtn addTarget:self action:@selector(loadURL) forControlEvents:UIControlEventTouchUpInside];
        reloadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [reloadBtn setTitle:NSLocalizedString(@"reload_yellow_page", @"") forState:UIControlStateNormal];
        reloadBtn.layer.cornerRadius = 5;
        reloadBtn.layer.masksToBounds = YES;
        [reloadView addSubview:reloadBtn];
        [reloadBtn setBackgroundImage:[FunctionUtility imageWithColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"] withFrame:CGRectMake(0, 0, reloadBtn.frame.size.width, reloadBtn.frame.size.height)] forState:UIControlStateNormal];
        reloadBtn.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"];
        [reloadBtn setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"yellow_page_reload_btn_text_color"] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)loadURL
{
    [[UIDataManager instance] addUserAgent];
    self.needLoad = YES;
    if ( ifNoah )
        [[NoahManager sharedPSInstance] webPageOpenedWithUrl:url_string];
    if (url_string) {
        if (!self.hasLoaded) {
            NSURL* url = [NSURL URLWithString:url_string];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            [web_view loadRequest:request];
        }
    }
//    [self loadExamplePage:web_view];
}

- (void)reload{
    self.needLoad = YES;
    self.hasLoaded = NO;
    [web_view reload];
}

- (void)testLoadUrl{
    [self loadExamplePage];
}

- (void)reloadURL
{
    self.needLoad = YES;
    self.hasLoaded = NO;
    if ( ifNoah )
        [[NoahManager sharedPSInstance] webPageOpenedWithUrl:url_string];
    if (url_string) {
        if (!self.hasLoaded) {
            NSURL* url = [NSURL URLWithString:url_string];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
            [web_view loadRequest:request];
        }
    }
}

- (void)loadFile:(NSString *)fileName{
    NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
    NSString *filePath  = [resourcePath stringByAppendingPathComponent:fileName];
    NSString *htmlstring =[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [web_view loadHTMLString:htmlstring  baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
}

- (void)loadExamplePage{
    NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
    NSString *filePath  = [resourcePath stringByAppendingPathComponent:@"task.html"];
    NSString *htmlstring =[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [web_view loadHTMLString:htmlstring  baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
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

- (void)showLoading
{
    web_view.hidden = YES;
    reloadView.hidden = YES;
    loadingView.hidden = NO;
    [self beginLoadingAnimation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)showPage
{
    web_view.hidden = NO;
    reloadView.hidden = YES;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)showReload
{
    web_view.hidden = YES;
    reloadView.hidden = NO;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
    if (hasErrorPageReload) {
        reloadLabel.frame = CGRectMake(reloadLabel.frame.origin.x, reloadLabel.frame.origin.y + 39.5, reloadLabel.frame.size.width, reloadLabel.frame.size.height);
        reloadBtn.frame = CGRectMake(reloadBtn.frame.origin.x, reloadBtn.frame.origin.y + 39.5, reloadBtn.frame.size.width, reloadBtn.frame.size.height);
        reloadLabel.text = NSLocalizedString(@"reset_net_prompt", @"");
        wifiView.hidden = NO;
        hasErrorPageReload = NO;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)showReloadWithText:(NSString*)text {
    web_view.hidden = YES;
    reloadView.hidden = NO;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
    reloadLabel.text = text;
    if (!hasErrorPageReload) {
        reloadLabel.frame = CGRectMake(reloadLabel.frame.origin.x, reloadLabel.frame.origin.y - 39.5, reloadLabel.frame.size.width, reloadLabel.frame.size.height);
        reloadBtn.frame = CGRectMake(reloadBtn.frame.origin.x, reloadBtn.frame.origin.y - 39.5, reloadBtn.frame.size.width, reloadBtn.frame.size.height);
        wifiView.hidden = YES;
        hasErrorPageReload = YES;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)restartAnimation{
    if (loadingView.hidden)
        return;
    [loadingDissy.layer removeAllAnimations];
    [self beginLoadingAnimation];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
