//
//  UMFeedbackFAQController.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/3/16.
//  updated by siyi.xie in 2015-12
//
#import "UMFeedbackFAQController.h"
#import "CootekWebHandler.h"
#import "CommonWebView.h"
#import "TPDialerResourceManager.h"
#import "UIView+WithSkin.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "UMFeedbackController.h"
#import "PhonePadModel.h"
#import "CallLogDataModel.h"
#import "SeattleFeatureExecutor.h"
#import "HangupCommercialManager.h"

@interface UMFeedbackFAQController()<CommonHeaderBarProtocol> {
}

@end

@implementation UMFeedbackFAQController {
    NSString *_currentUrlString;
}

- (void)viewDidLoad {
    cootek_log(@"umeng, self.view: %@", NSStringFromCGRect(self.view.frame));
    [UMFeedbackFAQController setLatestVoipCall];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma override UIWebView delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [super webViewDidFinishLoad:webView];
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [super webView:webView didFinishNavigation:navigation];
}

+ (void) setLatestVoipCall {
    NSArray *callLogs = [PhonePadModel getSharedPhonePadModel].calllog_list.searchResults;
    int count = [callLogs count];
    BOOL hasVoipCall = NO;
    for (NSInteger index = 0; index < count; index++) {
        CallLogDataModel *log = (CallLogDataModel *)[callLogs objectAtIndex:index];
        // get the latest voip call log
        if (log.ifVoip) {
            NSDictionary *voipCall = @{
                @"number": log.number,
                @"timestamp": @(log.callTime),
            };
            NSData *callData = [NSJSONSerialization dataWithJSONObject:voipCall options:kNilOptions error:nil];
            NSString *callInfo = [[NSString alloc] initWithData:callData encoding:NSUTF8StringEncoding];
            cootek_log(@"UMFeedbackController, feedback_last_voip_call, callInfo: %@", callInfo);
            [UserDefaultsManager setObject:callInfo forKey:FEEDBACK_LAST_VOIP_CALL];
            hasVoipCall = YES;
            break;
        }
    }
    if (!hasVoipCall) {
        [UserDefaultsManager setObject:@"" forKey:FEEDBACK_LAST_VOIP_CALL];
    }
}

- (void) exit {
    self.headerBar.delegate = self;
}

- (void) leftButtonAction {
    if ([_currentUrlString rangeOfString:@"faq.html"].location == NSNotFound) {
        // not faq.html page, jump to the faq.html
        if ([_currentUrlString rangeOfString:@"?fb_feedback=true"].location == NSNotFound) {
            // jump to the faq.html
            UMFeedbackFAQController *faqController = [[UMFeedbackFAQController alloc] init];
            faqController.url_string = FAQ_URL;
            faqController.header_title = NSLocalizedString(@"umeng_feedback_title", @"");
            [self.navigationController pushViewController:faqController animated:NO];
            [FunctionUtility removeFromStackViewController:self];
            
        } else {
            // exit this controller
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        // it is faq.html page, just pop this controller
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    _currentUrlString = request.URL.absoluteString;
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end
