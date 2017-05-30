//
//  TPMFMailActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/11/12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface TPMFMailActionController : NSObject<MFMailComposeViewControllerDelegate>

// convenience method
+(TPMFMailActionController *) controller;

-(void) sendEmailToAddress:(NSString *)emailAddress
               withSubject:(NSString *)subject
               withMessage:(NSString *)message
               presentedBy:(UIViewController *)aViewController;

-(void) sendEmailToAddress:(NSString *)emailAddress
               withSubject:(NSString *)subject
               withMessage:(NSString *)message
               presentedBy:(UIViewController *)aViewController
                      sent:(void(^)(void))sent
                 cancelled:(void(^)(void))cancelled
                     saved:(void(^)(void))saved
                    failed:(void(^)(void))failed;

-(void) sendEmailToAddresses:(NSArray *)emailAddresses
                 withSubject:(NSString *)subject
                 withMessage:(NSString *)message
                 presentedBy:(UIViewController *)aViewController;

-(void) sendEmailToAddresses:(NSArray *)emailAddresses
                 withSubject:(NSString *)subject
                 withMessage:(NSString *)message
                 presentedBy:(UIViewController *)aViewController
                        sent:(void(^)(void))sent
                   cancelled:(void(^)(void))cancelled
                       saved:(void(^)(void))saved
                      failed:(void(^)(void))failed;

@end
