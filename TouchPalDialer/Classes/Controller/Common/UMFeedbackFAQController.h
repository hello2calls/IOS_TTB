//
//  UMFeedbackFAQController.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/3/16.
//
//

#import <UIKit/UIKit.h>
#import "HandlerWebViewController.h"

#ifdef DEBUG
    #define FAQ_URL @"http://oss.aliyuncs.com/cootek-dialer-download/iphone/web/faq/faq.html"
#else
    #define FAQ_URL @"http://dialer-cdn.cootekservice.com/iphone/web/faq/faq.html"
#endif

@interface UMFeedbackFAQController : HandlerWebViewController
+ (void) setLatestVoipCall;
@end
