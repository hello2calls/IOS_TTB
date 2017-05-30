//
//  AlertWithTextInputView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 12/22/12.
//
//

#import "AlertWithTextInputView.h"
#import "DefaultUIAlertViewHandler.h"
#import "BCZeroEdgeTextView.h"
#import "NSString+PhoneNumber.h"
#import "TPDialerResourceManager.h"

@interface AlertWithTextInputViewHandler()
@property (nonatomic, copy) void(^okBlock)(NSString *);
@property (nonatomic, copy) void(^cancelBlock)(void);
@end

static AlertWithTextInputViewHandler *handler;

@implementation AlertWithTextInputViewHandler
@synthesize okBlock;
@synthesize cancelBlock;

+ (void) showAlertWithTextFieldViewWithTitle:(NSString *)title
                                     message:(NSString *)message
                             textInTextField:(NSString *)text
                                     oKTitle:(NSString *)oKTitle
                         okButtonActionBlock:(void(^)(NSString *))okActionBlock
                     cancelButtonActionBlock:(void(^)())cancelActionBlock
{
    handler = [[AlertWithTextInputViewHandler alloc] init];
    handler.okBlock = okActionBlock;
    handler.cancelBlock = cancelActionBlock;
    [handler showWithTitle:title message:message textInTextField:text oKTitle:oKTitle];
}

- (void)showWithTitle:(NSString *)title
              message:(NSString *)message
      textInTextField:(NSString *)text
              oKTitle:(NSString *)oKTitle
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                          otherButtonTitles:oKTitle,
                          nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *tmpTextView = [alert textFieldAtIndex:0];
    tmpTextView.font = [UIFont systemFontOfSize:16];
    tmpTextView.text = [text formatPhoneNumber];
    tmpTextView.keyboardType = UIKeyboardTypePhonePad;
    tmpTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
    tmpTextView.textAlignment = NSTextAlignmentCenter;
    [alert show];
    [tmpTextView becomeFirstResponder];

    UITextPosition *start = tmpTextView.beginningOfDocument;
    tmpTextView.selectedTextRange = [tmpTextView textRangeFromPosition:start toPosition:start];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textView = [alertView textFieldAtIndex:0];
    if(buttonIndex == 1){
        if(self.okBlock){
            NSString *text = textView.text;
            self.okBlock(text);
        }
    }
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
    
    alertView.delegate = nil;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{   
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
    
    alertView.delegate = nil;
}
@end
