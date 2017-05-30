//
//  TPMFMessageActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/11/12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface TPMFMessageActionController : NSObject<MFMessageComposeViewControllerDelegate>

// convenience method

+(void) sendMessageToNumber:(NSString *)number
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController;

+(void) sendMessageToNumber:(NSString *)number
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController
                       sent:(void(^)(void))sent
                  cancelled:(void(^)(void))cancelled
                     failed:(void(^)(void))failed;

+(void) sendMessageToNumbers:(NSArray *)numbers
                 withMessage:(NSString *)message
                 presentedBy:(UIViewController *)aViewController;

+(void) sendMessageToNumbers:(NSArray *)numbers
                 withMessage:(NSString *)message
                 presentedBy:(UIViewController *)aViewController
                        sent:(void(^)(void))sent
                   cancelled:(void(^)(void))cancelled
                      failed:(void(^)(void))failed;
+(void)sendMessagePopSelectVC:(UIViewController *)selectVC
                    ToNumbers:(NSArray *)numbers
                  withMessage:(NSString *)message
                  presentedBy:(UIViewController *)aViewController
                         sent:(void (^)(void))sent
                    cancelled:(void (^)(void))cancelled
                       failed:(void (^)(void))failed;
@end
