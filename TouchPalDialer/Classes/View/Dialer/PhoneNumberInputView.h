//
//  PhoneNumberInputView.h
//  TouchPalDialer
//
//  Created by zhang Owen on 9/29/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WithSkin.h"

@class PhoneNumberInputView;

@protocol PhoneNumberInputViewDelegate <NSObject>
- (void)pasteClickedInView:(PhoneNumberInputView *)view;
@end

@interface PhoneNumberInputView : UIView <SelfSkinChangeProtocol> {
	 NSString __strong *inputStr;
     UIColor __strong *textColor;
}
@property(nonatomic,retain) UIColor *textColor;
@property(nonatomic,retain) NSString *inputStr;
@property(nonatomic,retain) UIColor *attrTextColor;
@property(nonatomic,retain) UILabel *numLabel;
@property(nonatomic,assign) BOOL isYellowPage;
@property(nonatomic,assign) id<PhoneNumberInputViewDelegate> delegate;
@end
