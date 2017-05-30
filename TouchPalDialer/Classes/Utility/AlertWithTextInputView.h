//
//  AlertWithTextInputView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 12/22/12.
//
//

#import <Foundation/Foundation.h>

@interface AlertWithTextInputViewHandler : NSObject<UIAlertViewDelegate>
+ (void) showAlertWithTextFieldViewWithTitle:(NSString *)title
                                     message:(NSString *)message
                             textInTextField:(NSString *)text
                                     oKTitle:(NSString *)oKTitle
                         okButtonActionBlock:(void(^)(NSString *))okActionBlock
                     cancelButtonActionBlock:(void(^)())cancelActionBlock;
@end
