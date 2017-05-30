//
//  CallStateDisplay.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import <Foundation/Foundation.h>
#import "CallViewController.h"

@interface CallStateDisplay : NSObject
- (id)initWithHolderView:(UIView *)view andDisplayArea:(CGRect)frame;

- (void)setNumber:(NSString *)number andCallMode:(CallMode)callMode;

- (void)showHangupState;

- (void)showTicker:(NSInteger)tick;

- (void)showSystemCallComing;

- (void)showHardTrying;

- (void)hideDisplay;

- (void)showDisplay;

-(void)showOperationInLine3;

-(void)changeColor;

@end