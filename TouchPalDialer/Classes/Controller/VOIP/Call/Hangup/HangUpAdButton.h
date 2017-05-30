//
//  HangUpAdButton.h
//  TouchPalDialer
//
//  Created by wen on 16/4/28.
//
//

#import "VoipSimpleButton.h"

@interface HangUpAdButton : UIButton

@property (nonatomic, copy) void(^pressBlock)(void);
@end
