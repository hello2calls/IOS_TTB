//
//  CallKeyboardDisplay.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/22.
//
//

#import <Foundation/Foundation.h>
#import "CallKeyboard.h"

@interface CallKeyboardDisplay : NSObject <CallKeyboardDelegate>

- (id)initWithHolderView:(UIView *)view andDelegate:(id<CallKeyboardDelegate>)delegate;

- (void)showDisplay;

- (void)hideDisplay;
@end
