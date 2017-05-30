//
//  PhonePadKeyProtocol.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/25/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    T9KeyBoardType,
    QWERTYBoardType,
}DailerKeyBoardType;

@protocol PhonePadKeyProtocol
@optional
- (void)clickPhonePadKey:(NSString *)number_str;
- (void)deleteInputNumer;
- (void)deleteAllInputNumber;
- (void)clickKeyBoardChanged:(DailerKeyBoardType)keyboradType;
- (void)clickPaste;
- (void)onWillChangeGestureRecginzer:(NSString *)key;
- (void)beginTouchWithKeyCenter:(CGPoint )center;
@end
@protocol GesturePadKeyDelegate
@optional
-(BOOL)isGestureMode;
-(BOOL)preGesturePadState;
@end
@protocol PhonePadPressProtocol <NSObject>
@optional
- (void)setAnimationKeyValue:(id)key;
- (void)stopPressViewAnimation;
@end