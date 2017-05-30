//
//  CallFunctionButtons.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    Calling = 1,
    BackCalling,
    Incoming,
    Connected,
    Test
} CallFunctionButtonsType;

@protocol CallFunctionButtonDelegate
- (void)onShareButtonPressed;
- (void)onHangupButtonPressed;
- (void)onBackCallButtonPressed;
- (void)onMuteButtonPressed;
- (void)onSpeakerButtonPressed;
- (void)onCloseButtonPressed;
- (void)onKeyButtonPressed;
- (void)onAccpetButtonPressed;
@end

@interface CallFunctionButtons : UIView
- (id)initWithHostView:(UIView *)hostView andDelegate:(id<CallFunctionButtonDelegate>)delegate;

- (void)setType:(CallFunctionButtonsType)type;

- (CGSize)size;

- (void)hideFirstLineFunctionButtons;

- (void)showFirstLineFunctionButtons;


@end
