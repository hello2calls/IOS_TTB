//
//  TPMFMessageActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/11/12.
//
//

#import "TPMFMessageActionController.h"
#import "FunctionUtility.h"
static TPMFMessageActionController *sController;
@interface TPMFMessageActionController ()
@property (nonatomic,copy) void (^sent)(void);
@property (nonatomic,copy) void (^cancelled)(void);
@property (nonatomic,copy) void (^failed)(void);
@end

@implementation TPMFMessageActionController

+(void)sendMessageToNumber:(NSString *)number
               withMessage:(NSString *)message
               presentedBy:(UIViewController *)aViewController
{
    [self sendMessageToNumber:number
                  withMessage:message
                  presentedBy:aViewController
                         sent:nil
                    cancelled:nil
                       failed:nil];
}

+(void)sendMessageToNumber:(NSString *)number
               withMessage:(NSString *)message
               presentedBy:(UIViewController *)aViewController
                      sent:(void (^)(void))sent
                 cancelled:(void (^)(void))cancelled
                    failed:(void (^)(void))failed
{
    if ([number length] == 0) {
        number = nil;
    }
    
    NSArray *array;
    if (number) {
        if ([number rangeOfString:@","].length > 0) {
            array = [number componentsSeparatedByString:@","];
        } else {
            array = [NSArray arrayWithObject:number];
        }
    } else {
        array = [NSArray array];
    }
    
    [self sendMessageToNumbers:array
                   withMessage:message
                   presentedBy:aViewController
                          sent:sent
                     cancelled:cancelled
                        failed:failed];
}

+(void)sendMessageToNumbers:(NSArray *)numbers
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController
{
    [self sendMessageToNumbers:numbers
                   withMessage:message
                   presentedBy:aViewController
                          sent:nil
                     cancelled:nil
                        failed:nil];
}

+(void)sendMessageToNumbers:(NSArray *)numbers
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController
                       sent:(void (^)(void))sent
                  cancelled:(void (^)(void))cancelled
                     failed:(void (^)(void))failed
{
    sController = [[TPMFMessageActionController alloc] init];
    sController.sent = sent;
    sController.cancelled = cancelled;
    sController.failed = failed;
    
    if (![MFMessageComposeViewController canSendText]) {
        if (sController.failed) {
            (sController.failed)();
        }
        return;
    }
    
    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
    [messageVC setBody:message];
    [messageVC setRecipients:numbers];
    messageVC.messageComposeDelegate = sController;
    [aViewController presentViewController:messageVC animated:YES completion:^(){}];
}

+(void)sendMessagePopSelectVC:(UIViewController *)selectVC
                ToNumbers:(NSArray *)numbers
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController
                       sent:(void (^)(void))sent
                  cancelled:(void (^)(void))cancelled
                     failed:(void (^)(void))failed
{
    sController = [[TPMFMessageActionController alloc] init];
    sController.sent = sent;
    sController.cancelled = cancelled;
    sController.failed = failed;
    
    if (![MFMessageComposeViewController canSendText]) {
        if (sController.failed) {
            (sController.failed)();
        }
        return;
    }
    
    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
    [messageVC setBody:message];
    [messageVC setRecipients:numbers];
    messageVC.messageComposeDelegate = sController;
    
    [aViewController presentViewController:messageVC animated:YES completion:^{
         [FunctionUtility removeFromStackViewController:selectVC];
    }];
   

}

#pragma mark MFMessageComposeViewControllerDelegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller
				didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultSent:
            if (self.sent) {
                (self.sent)();
            }
            break;
        case MessageComposeResultCancelled:
            if (self.cancelled) {
                (self.cancelled)();
            }
            break;
        case MessageComposeResultFailed:
            if (self.failed) {
                (self.failed)();
            }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^(){}];
    controller.messageComposeDelegate = nil;
    sController = nil;
}

@end
