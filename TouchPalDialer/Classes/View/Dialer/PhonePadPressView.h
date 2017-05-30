//
//  PhonePadPressView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/3/16.
//
//

#import <UIKit/UIKit.h>
#import "PhonePadKeyProtocol.h"
#import "SuperKey.h"
#import "PhonePadKeyProtocol.h"


#define KEY_PAD_SHADOW_TOP_LENGTH (9)

@interface PhonePadPressView : UIView <PhonePadPressProtocol>
@property (nonatomic,retain) UIImage *img_bg_selected;
@property (nonatomic,retain) SuperKey *pressKey;
@property (nonatomic,assign) BOOL isT9;
@property(nonatomic, assign) id<GesturePadKeyDelegate> gestureDelegate;
@end
