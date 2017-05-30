//
//  CallKeyboard.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/21.
//
//

#import <UIKit/UIKit.h>

@protocol CallKeyboardDelegate
- (void)onKeyPressed:(NSString *)key;
@end

@interface CallKeyboard : UIView
- (id)initWithFrame:(CGRect)frame andDelegate:(id<CallKeyboardDelegate>)delegate;
@end
