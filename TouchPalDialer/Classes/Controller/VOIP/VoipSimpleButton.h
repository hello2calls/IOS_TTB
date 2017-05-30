//
//  CustomButton.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-11.
//
//

#import <UIKit/UIKit.h>

@interface VoipSimpleButton : UIView
@property (nonatomic, strong) NSString *fontIconText;
@property (nonatomic, strong) NSString *fontIconTextPressed;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign)float scaleRatio;
@property (nonatomic, copy) void(^pressBlock)(void);
@property (nonatomic, assign)BOOL persistPressed;
@property (nonatomic, strong) UIColor *bgHighlighColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *fontIconHighlightColor;
- (void)setPressed:(BOOL)pressed;
- (BOOL)isPressed;
@end
