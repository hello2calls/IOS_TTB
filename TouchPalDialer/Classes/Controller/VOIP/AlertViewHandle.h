//
//  COAlertViewHandle.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/4.
//
//

#import <Foundation/Foundation.h>
#import "HangupViewModelGenerator.h"


@interface AlertViewHandle : NSObject

+( instancetype ) sharedSingleton;

- (void)showAlertErrorWithHangUpModel:(HangupModel *)hangUpModel;

@end
