//
//  HandlerWebViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/4/13.
//
//

#import "HandlerWebViewController.h"
#import "CootekWebHandler.h"
#import "UserDefaultsManager.h"

@interface HandlerWebViewController()<CootekWebHandlerDelegate>{
    CootekWebHandler *_webHandler;
}

@end

@implementation HandlerWebViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.useWkWebView = NO;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self registerHandlerEvent];
}

-(void)dealloc{
    _webHandler = nil;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [super webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_webHandler initPageData];
    [super webViewDidFinishLoad:webView];
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [_webHandler initPageData];
    [super webView:webView didFinishNavigation:navigation];
}

- (void)reload{
    [super reload];
    [self registerHandlerEvent];
}

- (void)reloadUrl:(NSString *)url{
    [super reloadUrl:url];
    [self registerHandlerEvent];
}

- (void)reloadFile:(NSString *)fileName;{
    [super reloadFile:fileName];
}

- (void)registerHandlerEvent{
    _webHandler = nil;
    _webHandler = [[CootekWebHandler alloc]initWithWebView:self.commonWebView.web_view andDelegate:self];
    _webHandler.webDelegate = self;
    [_webHandler registerHandler];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


@end
