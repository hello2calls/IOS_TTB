//
//  TPCallActionController.h
//  TouchPalDialer
//
//  Created by Chen Lu on 12/5/12.
//
//

#import <Foundation/Foundation.h>
#import "CallLogDataModel.h"
#import "CootekPopUpSheet.h"

@interface TPCallActionController : NSObject<CooTekPopUpSheetDelegate>

+(TPCallActionController *) controller;

- (void)makeCall:(CallLogDataModel *)phone appear:(void(^)())willAppearPopupSheet disappear:(void(^)())willDisappearPopupSheet;
- (void)makeCall:(CallLogDataModel *)phone;
- (void)makeGestureCall:(CallLogDataModel *)phone;
- (void)makeCallWithNumber:(NSString *)number;
- (void)makeCallWithNumber:(NSString *)number fromOutside:(BOOL)outside;
+ (void)logCallFromSource:(NSString*) source;
+ (void)onVoipCallHangupWithCallDur:(int)duration isDirectCall:(BOOL)isDirectCall;
- (NSInteger)getCallNumberTypeCustion:(NSString*) phoneNumber;
- (void)checkTestVoipCall:(CallLogDataModel *)phone;
- (void)makeCallAfterVoipChoice:(CallLogDataModel *)phone
                  isGestureCall:(BOOL)isGestureCall;

@end
