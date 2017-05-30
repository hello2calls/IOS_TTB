//
//  TPWebShareController.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/3.
//
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

#define CONTACT_DETAIL (@"ContactDetail")
#define CONTACT_FRIEND (@"ContactFriend")
#define PERSONAL_CENTER (@"PersonalCenter")
#define HANG_UP (@"HangUp")

typedef NS_ENUM(NSInteger,ShareResult){
    ShareSuccess = 0,
    ShareFail = 1,
    ShareCancel = 2,
};

typedef void (^ShareResultCallback)(ShareResult ret, NSString *source, NSString *error);

@interface TPWebShareController : NSObject
+ (TPWebShareController *)controller;
- (void)handleJSCallWithParam:(id)param responseCallback:(WVJBResponseCallback)responseCallback;
@end
