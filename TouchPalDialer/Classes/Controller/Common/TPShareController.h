//
//  TPShareController.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-27.
//
//

#import <Foundation/Foundation.h>
#import "TPWebShareController.h"
#import "WXApi.h"


@interface TPShareController : NSObject<WXApiDelegate>
+ (TPShareController *)controller;
+ (void)registerWeiXinApp;

- (void)showShareActionSheet:(NSString *)title
                     message:(NSString *)message
              naviController:(UINavigationController *)controller;

- (void)showShareActionSheet:(NSString *)title
                     message:(NSString *)message
              naviController:(UINavigationController *)controller
                 actionBlock:(void(^)())executeBackAction;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)voipWechatSharePic:(UIImage *)image andIfTimeLine:(BOOL)ifTimeLine;

- (void)voipWechatShare:(NSString *)title
         andDescription:(NSString *)description
                 andUrl:(NSString *)url
               andImage:(UIImage *)image
          andIfTimeLine:(BOOL)ifTimeLine
               andBlock:(void(^)(void))block;

- (void)voipWechatShare:(NSString *)title
         andDescription:(NSString *)description
                 andUrl:(NSString *)url
          andIfTimeLine:(BOOL)ifTimeLine
               andBlock:(void(^)(void))block;

- (void)voipWechatShare:(NSString *)title
         andDescription:(NSString *)description
                 andUrl:(NSString *)url
               andImage:(UIImage *)image
          andIfTimeLine:(BOOL)ifTimeLine
         resultCallback:(ShareResultCallback)block;

- (void)voipWechatShareText:(NSString *)text
                   andImage:(UIImage *)image
                   andBlock:(void(^)(void))block;


- (void)setAfterSuccessNil;

- (void) sendPay:(NSString*) data callbackBlock:(void(^)(NSDictionary*))payBackAction;

@end
