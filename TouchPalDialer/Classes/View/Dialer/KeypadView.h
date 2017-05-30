//
//  KeypadView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperKey.h"
#import "PhonePadModel.h"

@interface KeypadView : UIView

@property(nonatomic,assign) id<PhonePadKeyProtocol> delegate;
- (id)initWithFrame:(CGRect)frame andKeyPadType:(DailerKeyBoardType)padType andDelegate:(id<PhonePadKeyProtocol>)_delegate;
@end
