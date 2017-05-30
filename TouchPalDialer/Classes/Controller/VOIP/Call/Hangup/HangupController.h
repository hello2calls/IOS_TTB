//
//  HangupController.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/9.
//
//

#import <UIKit/UIKit.h>
#import "HangupViewModelGenerator.h"

@interface HangupController : UIViewController <UINavigationControllerDelegate>

- (id)initWithHanupModel:(HangupModel *)model;

- (id)initWithCallNumber:(NSString *)callNumber
               startTime:(double)startTime
                 callDur:(double)callDur
               isP2PCall:(BOOL)isP2p
                    uuid:(NSString *)uuid;
@end
