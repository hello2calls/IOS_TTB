//
//  HangupActionView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/11.
//
//

#import <UIKit/UIKit.h>
#import "HangupViewModelGenerator.h"
#import "HangUpAdButton.h"

@interface HangupActionView : UIView
@property (nonatomic,retain)UIButton *mainButton;
@property (nonatomic,retain)HangUpAdButton *closeButton;

//@property (nonatomic,weak) UIView *bubbleView;
//@property (nonatomic,strong) UIButton *actionMainButton;
- (id)initWithModel:(MainActionViewModel *)model;
- (instancetype)initForAdWebWithModel:(MainActionViewModel*)model frame:(CGRect)frame;
- (UIView *)getActionVieWithModel:(MainActionViewModel *)model frame:(CGRect)frame;

@end
