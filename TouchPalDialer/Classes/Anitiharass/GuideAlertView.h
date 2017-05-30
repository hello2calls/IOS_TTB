//
//  GuideAlertView.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/30.
//
//

#import <UIKit/UIKit.h>

@interface GuideAlertView : UIView

- (nullable instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message guideImage:(nullable UIImage *)image;

- (void)show;
@end
