//
//  CallProceedingDisplay.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import <Foundation/Foundation.h>
#import "CallViewController.h"
#import "CallAvatarView.h"

#define STATUS_INFO_BOX_WIDTH (254)
#define STATUS_INFO_BOX_HEIGHT (140)
#define STATUS_INFO_BOX_HEIGHT_SMALL (90)

@interface CallProceedingDisplay : NSObject

@property (nonatomic, assign)NSInteger originalMinute;
@property (nonatomic, assign)BOOL isBackCall;
@property (nonatomic, strong)NSString *promotion;
@property (nonatomic, assign)BOOL hiddenProceeding;
@property (nonatomic, assign)UserType userType;


- (id)initWithHostView:(UIView *)view andDisplayArea:(CGRect)frame callMode:(CallMode)callMode otherPhoneNumberArr:(NSArray *)otherPhoneNumberArr;

- (void)proceedingWithCallMode:(CallMode)callMode;

- (void)stop;

- (void)showQueryTouchPal;

- (void)showQueryResultIsPalOrNot:(BOOL)isPal isActive:(BOOL)isActive callType:(NSInteger)callType;

- (void)showBackCallDecided;

- (void)showFreeCallShouldHighlight:(BOOL)highLight;

- (void)showRemainingMinutes:(int)remaining;

- (void)showPalNotDecide;

- (void)showErrorInfo:(NSString *)info;

- (void)showRinging;

- (void)showCallFeeRemindWithRemainingMin:(int)remaining;

- (void)checkExchangeDisplayPromotionWithRemainingMinu:(int)remainning;

- (void)animateIndicator;

- (void)showBackCall;

- (void)hideDisplay;

- (void)hideDisplayAnimations:(void (^)())animations completion:(void (^)(BOOL finished))complete;

- (void)showDisplay;

- (void)ifShowFreeCallPrivilegaMessage;

- (void)stopMovingArrow;
- (void)setStatus:(NSString *)statusString;
- (void)setInfo:(NSString *)info;
- (void)showTicker:(NSInteger)ticker;
- (void)showCalling;
- (void)setInfoWhenBackcall;
+ (NSString *)translateTickerToTime:(NSInteger) ticker;

@end
