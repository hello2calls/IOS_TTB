//
//  DefaultUIAlertViewHandler.m
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DefaultUIAlertViewHandler.h"
@interface DefaultUIAlertViewHandler () {
    NSString* _title;
    NSString* _message;
    NSString* _cancelTitle;
    NSString* _okTitle;
    NSTimeInterval _dismissIn;
    void (^_actionBlock)(void);
     void (^_cancelBlock)(void);
}

-(DefaultUIAlertViewHandler*) initWithTitle:(NSString*)title
                                    message:(NSString*)message
                                cancelTitle:(NSString*)cancelTitle
                                    okTitle:(NSString*)okTitle
                                actionBlock:(void (^)(void))actionBlock
                                cancelBlock:(void (^)(void))cancelBlock
                                  dismissIn:(NSTimeInterval)seconds;
-(void) show;
@end


@implementation DefaultUIAlertViewHandler

-(DefaultUIAlertViewHandler*) initWithTitle:(NSString*)title
                                    message:(NSString*)message
                                cancelTitle:(NSString*)cancelTitle
                                    okTitle:(NSString*)okTitle
                                actionBlock:(void (^)(void))actionBlock
                                cancelBlock:(void (^)(void))cancelBlock
                                  dismissIn:(NSTimeInterval)seconds;
{
    self = [super  init];
    if(self != nil) {
        _title = [title copy];
        _message = [message copy];
        _cancelTitle = [cancelTitle copy];
        _okTitle = [okTitle copy];
        _actionBlock = [actionBlock copy];
        _cancelBlock = [cancelBlock copy];
        _dismissIn = seconds;
    }
    return self;
}

-(void) show {
    UIAlertView *alert;
    NSString *okTitle = _okTitle ? _okTitle : NSLocalizedString(@"Ok", @"");
    
    if (_actionBlock) {
        if (_cancelTitle == nil) {
            alert = [[UIAlertView alloc]
                     initWithTitle:_title
                     message:_message
                     delegate:[self retain]
                     cancelButtonTitle:nil
                     otherButtonTitles:okTitle,
                     nil];
        } else {
            NSString *cancelTitle = _cancelTitle ? _cancelTitle :NSLocalizedString(@"Cancel",@"");
            alert = [[UIAlertView alloc]
                     initWithTitle:_title
                     message:_message
                     delegate:[self retain]
                     cancelButtonTitle:cancelTitle
                     otherButtonTitles:okTitle,
                     nil];
        }
    } else {
        alert = [[UIAlertView alloc]
                 initWithTitle:_title
                 message:_message
                 delegate:[self retain]
                 cancelButtonTitle:okTitle
                 otherButtonTitles:nil,
                 nil];
    }
    alert.autoresizesSubviews = YES;
    alert.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [alert show];
    
    if (_dismissIn > 0) {
        [self performSelector:@selector(dismissAutomatically:) withObject:alert afterDelay:_dismissIn];
    }
    [alert release];
}

- (void) dismissAutomatically:(id)object
{
    UIAlertView *alertView = object;
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
                    cancelTitle:(NSString*)cancelTitle
                        okTitle:(NSString*)okTitle
            okButtonActionBlock:(void (^)(void))actionBlock
              cancelActionBlock:(void (^)(void))cancelBlock
{
    [self showAlertViewWithTitle:title
                         message:message
                     cancelTitle:cancelTitle
                         okTitle:okTitle
             okButtonActionBlock:actionBlock
               cancelActionBlock:cancelBlock
                       dismissIn:-1];
    
}
+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
                    cancelTitle:(NSString*)cancelTitle
                        okTitle:(NSString*)okTitle
            okButtonActionBlock:(void (^)(void))actionBlock
              cancelActionBlock:(void (^)(void))cancelBlock
                      dismissIn:(NSTimeInterval)seconds
{
    DefaultUIAlertViewHandler* handler = [[DefaultUIAlertViewHandler alloc] initWithTitle:title
                                                                                  message:message
                                                                              cancelTitle:cancelTitle
                                                                                  okTitle:okTitle
                                                                              actionBlock:actionBlock
                                                                              cancelBlock:cancelBlock
                                                                                dismissIn:seconds];
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler show];
    });
      [handler release];
}

+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
                    cancelTitle:(NSString*)cancelTitle
                        okTitle:(NSString*)okTitle
            okButtonActionBlock:(void (^)(void))actionBlock
{
    [self showAlertViewWithTitle:title
                         message:message
                     cancelTitle:cancelTitle
                         okTitle:okTitle
             okButtonActionBlock:actionBlock
               cancelActionBlock:nil];
    
}

+ (void) showAlertViewWithTitle:(NSString*)title
                        message:(NSString*)message
            okButtonActionBlock:(void (^)(void))actionBlock
              cancelActionBlock:(void (^)(void))cancelBlock
{
    [self showAlertViewWithTitle:title message:message
                     cancelTitle:NSLocalizedString(@"Cancel",@"")
                         okTitle:nil
             okButtonActionBlock:actionBlock
               cancelActionBlock:cancelBlock];
}

+ (void) showAlertViewWithTitle:(NSString*)title message:(NSString*)message okButtonActionBlock:(void (^)(void))actionBlock {
    [self showAlertViewWithTitle:title message:message
                     cancelTitle:NSLocalizedString(@"Cancel",@"")
                         okTitle:nil
             okButtonActionBlock:actionBlock
               cancelActionBlock:nil];
}

+ (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message onlyOkButtonActionBlock:(void (^)(void))actionBlock {
    [self showAlertViewWithTitle:title message:message
                     cancelTitle:nil
                         okTitle:nil
             okButtonActionBlock:actionBlock
               cancelActionBlock:nil];
}

+ (void) showAlertViewWithTitle:(NSString *)title
                        message:(NSString *)message
                        okTitle:(NSString*)okTitle
        onlyOkButtonActionBlock:(void (^)(void))actionBlock {
    [self showAlertViewWithTitle:title message:message
                     cancelTitle:nil
                         okTitle:okTitle
             okButtonActionBlock:actionBlock
               cancelActionBlock:nil];
}

+ (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message{
    [self showAlertViewWithTitle:title message:message okButtonActionBlock:nil];
}

+ (void) showAlertViewWithTitle:(NSString *)title message:(NSString *)message dismissIn:(NSTimeInterval)seconds{
    [self showAlertViewWithTitle:title
                         message:message
                     cancelTitle:nil
                         okTitle:nil
             okButtonActionBlock:nil
               cancelActionBlock:nil
                       dismissIn:seconds];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == [alertView numberOfButtons] - 1) && _actionBlock && buttonIndex != [alertView cancelButtonIndex]) {
        _actionBlock();
    }
    
    if ((buttonIndex == [alertView cancelButtonIndex]) && _cancelBlock) {
        _cancelBlock();
    }
    
    alertView.delegate = nil;
    [self release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == [alertView cancelButtonIndex]) && _cancelBlock && [[[UIDevice currentDevice]systemVersion]floatValue] >6.0) {
        _cancelBlock();
    }
    
    alertView.delegate = nil;
    [self release];
}

//- (void)didPresentAlertView:(UIAlertView *)alertView
//{
//    [UIView beginAnimations:@"" context:nil];
//    [UIView setAnimationDuration:0.1];
//    alertView.transform = CGAffineTransformMakeRotation(M_PI_2);
//    [UIView commitAnimations];
//}

- (void)dealloc {
    [_title release];
    [_message release];
    [_cancelTitle release];
    [_okTitle release];
    [_actionBlock release];
    [_cancelBlock release];
    [super dealloc];
}

@end
