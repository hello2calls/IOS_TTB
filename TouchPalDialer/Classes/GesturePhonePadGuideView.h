//
//  GesturePhonePadGuideView.h
//  TouchPalDialer
//
//  Created by wen on 15/12/14.
//
//

#import <UIKit/UIKit.h>
#import "UILayoutUtility.h"
#import "DialogUtil.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "KeypadView.h"
@interface GesturePhonePadGuideView : UIView

@property (nonatomic , retain)UIImageView *animationView;
@property (nonatomic , retain)KeypadView *T9_phonePad;
@end
