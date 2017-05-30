//
//  BreathingView.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/13.
//
//

#import <UIKit/UIKit.h>

@interface BreathingView : UIView

- (instancetype)initWithFrame:(CGRect)frame withOutCircleRadius:(NSInteger)outRadius withMiddleCircleRadius:(NSInteger)middleRadius withInnerRadius:(NSInteger)innerRadius withAllColor:(UIColor*)color;
- (void)startBreath;
- (void)stopBreath;

@end
