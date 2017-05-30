//
//  FlowExchangeView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/2/12.
//
//

#import "FlowExchangeView.h"
#import "CootekWebHandler.h"
#import "CommonWebView.h"
#import "TPDialerResourceManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"

@interface FlowExchangeView()
{
    CommonWebView *noahWebView;
    CootekWebHandler *noahHandler;
    
    NSString __strong *_url;
    UIActivityIndicatorView *_indicator;
}

@end

@implementation FlowExchangeView

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url delegate:(UIViewController<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> *)webViewDelegate{
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        _url = url;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        noahWebView = [[CommonWebView alloc]initWithFrame:CGRectMake(TPScreenWidth()*0.1, TPScreenHeight()*0.35-100, TPScreenWidth()*0.8, TPScreenHeight()*0.3+200) andIfNoah:NO andUsingWkWebview:NO];
        [noahWebView.web_view setDelegateViews:self];
        
        noahWebView.url_string = _url;
        noahWebView.layer.masksToBounds = YES;
        noahWebView.layer.cornerRadius = 3.0f;
        [self addSubview:noahWebView];
        
        [noahWebView loadURL];
        
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(noahWebView.frame.size.width - 40 , 0, 40, 40)];
        [cancelButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
        [noahWebView addSubview:cancelButton];
        
        UIImageView *cancelImage = [[UIImageView alloc]initWithFrame:CGRectMake(12.5, 12.5, 15, 15)];
        cancelImage.image = [TPDialerResourceManager getImage:@"contact_search_close@2x.png"];
        [cancelButton addSubview:cancelImage];
        
        noahHandler = [[CootekWebHandler alloc]initWithWebView:noahWebView.web_view andDelegate:webViewDelegate];
        [noahHandler registerHandler];
    }
    
    return self;
    
}


-(void)removeView{
    NSRange urlRange = [_url rangeOfString:@"all_get="];
    NSString *ifAllGet = @"";
    if ( urlRange.length != 0 )
        ifAllGet = [_url substringWithRange:NSMakeRange(urlRange.location + urlRange.length, 1)];
    if ( [ifAllGet isEqualToString:@"1"] ){
        [DialerUsageRecord recordpath:EV_FLOW_EXCHANGE_VIEW_ALL_FINISH_X_PRESS kvs:Pair(@"count", @(1)), nil];
    }
    
    [self removeFromSuperview];
}

-(void)unableToInteract{
    noahWebView.web_view.userInteractionEnabled = NO;
    _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, noahWebView.frame.size.width/2, noahWebView.frame.size.width/2)];
    [_indicator setCenter:CGPointMake(noahWebView.frame.size.width/2, noahWebView.frame.size.height/2)];
    [_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.hidesWhenStopped = YES;
    [_indicator startAnimating];
    [noahWebView addSubview:_indicator];
}

-(void)enableToInteract{
    [_indicator stopAnimating];
    noahWebView.web_view.userInteractionEnabled = YES;
}


@end
