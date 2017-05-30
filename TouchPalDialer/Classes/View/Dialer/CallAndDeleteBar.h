//
//  CallAndDeleteBar.h
//  TouchPalDialer
//
//  Created by zhang Owen on 10/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhonePadKeyProtocol.h"
#import "UIView+WithSkin.h"
#import "CallKey.h"
#import "DeleteKey.h"

@interface CallAndDeleteBar : UIView <PhonePadKeyProtocol,SelfSkinChangeProtocol> {
	id<PhonePadKeyProtocol> __unsafe_unretained m_delegate;
     UIImageView *backgroundImageView;
     CallKey *key_call;
     DeleteKey *key_del;
     UIButton *key_pad;
     
}

@property(nonatomic, assign) id<PhonePadKeyProtocol> m_delegate;
- (id)initCallAndDeleteBarWithFrame:(CGRect)frame;
@end
