//
//  AlipayPopupView.h
//  TouchPalDialer
//
//  Created by Chen Lu on 8/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlipayPopupView : UIView

- (id)initWithTitle:(NSString *)title 
           message:(NSString *)message
       cancelButtonText:(NSString *)cancelButtonText
       actionButtonText:(NSString *)actionButtonText
   checkBoxText:(NSString*) checkBoxText
    actionBlock:(void (^) (BOOL checked))actionBlock
    cancelBlock:(void (^) (BOOL checked))cancelBlock;
@end
