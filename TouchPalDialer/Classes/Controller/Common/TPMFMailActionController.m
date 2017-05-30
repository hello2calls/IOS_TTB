//
//  TPMFMailActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 11/11/12.
//
//

#import "TPMFMailActionController.h"

@interface TPMFMailActionController ()
@property (nonatomic,copy) void (^sent)(void);
@property (nonatomic,copy) void (^cancelled)(void);
@property (nonatomic,copy) void (^saved)(void);
@property (nonatomic,copy) void (^failed)(void);
@end

static TPMFMailActionController *instance;

@implementation TPMFMailActionController

@synthesize sent = sent_;
@synthesize cancelled = cancelled_;
@synthesize saved = saved_;
@synthesize failed = failed_;

+(void)initialize{
    instance = [[TPMFMailActionController alloc]init];
}

+(TPMFMailActionController *)controller
{
    return instance;
}

-(void) sendEmailToAddress:(NSString *)emailAddress
               withSubject:(NSString *)subject
               withMessage:(NSString *)message
               presentedBy:(UIViewController *)aViewController
{
    [self sendEmailToAddress:emailAddress
                 withSubject:subject
                 withMessage:message
                 presentedBy:aViewController
                        sent:nil
                   cancelled:nil
                       saved:nil
                      failed:nil];
}

-(void)sendEmailToAddress:(NSString *)emailAddress
              withSubject:(NSString *)subject
              withMessage:(NSString *)message
              presentedBy:(UIViewController *)aViewController
                     sent:(void (^)(void))sent
                cancelled:(void (^)(void))cancelled
                    saved:(void (^)(void))saved
                   failed:(void (^)(void))failed
{
    if ([emailAddress length] == 0) {
        emailAddress = nil;
    }
    NSArray *array;
    if (emailAddress) {
        array = [NSArray arrayWithObject:emailAddress];
    } else {
        array = [NSArray array];
    }
    
    [self sendEmailToAddresses:array
                   withSubject:subject
                   withMessage:message
                   presentedBy:aViewController
                          sent:sent
                     cancelled:cancelled
                         saved:saved
                        failed:failed];
}

-(void)sendEmailToAddresses:(NSArray *)emailAddresses
                withSubject:(NSString *)subject
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController
{
    [self sendEmailToAddresses:emailAddresses
                   withSubject:subject
                   withMessage:message
                   presentedBy:aViewController
                          sent:nil
                     cancelled:nil
                         saved:nil
                        failed:nil];
}

-(void)sendEmailToAddresses:(NSArray *)emailAddresses
                withSubject:(NSString *)subject
                withMessage:(NSString *)message
                presentedBy:(UIViewController *)aViewController
                       sent:(void (^)(void))sent
                  cancelled:(void (^)(void))cancelled
                      saved:(void (^)(void))saved
                     failed:(void (^)(void))failed
{
    self.sent = sent;
    self.cancelled = cancelled;
    self.saved = saved;
    self.failed = failed;
    
    if (![MFMailComposeViewController canSendMail]) {
        if (self.failed) {
            (self.failed)();
        }
        UIAlertView *isEmailalert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"set email account", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
        [isEmailalert show];
        return;
    }
    
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    [mailVC setSubject:subject];
    [mailVC setToRecipients:emailAddresses];
    [mailVC setMessageBody:message isHTML:NO];
    mailVC.mailComposeDelegate = self;
    [aViewController presentViewController:mailVC animated:YES completion:^(){}];
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error

{
	switch (result)
	{
        case MFMailComposeResultSent:
            if (self.sent) {
                (self.sent)();
            }
			break;
		case MFMailComposeResultCancelled:
            if (self.cancelled) {
                (self.cancelled)();
            }
			break;
		case MFMailComposeResultSaved:
            if (self.saved) {
                (self.saved)();
            }
			break;
		case MFMailComposeResultFailed:
            if (self.failed) {
                (self.failed)();
            }
			break;
		default:
			break;
	}
    [controller dismissViewControllerAnimated:YES completion:^(){}];
    controller.mailComposeDelegate = nil;
}



@end
