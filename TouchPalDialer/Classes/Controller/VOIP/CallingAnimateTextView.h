//
//  CallingAnimateTextView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-19.
//
//

#import <UIKit/UIKit.h>

@interface CallingAnimateTextView : UIView
- (id)initWithFrame:(CGRect)frame;
- (void)setInitialText:(NSString *)text;
- (void)chaneText:(NSString *)text changingBlock:(void(^)(void))block;
- (void)hideIndicator;
- (void)showIndicator;
- (void)animateIndcator;
- (void)noChange;
- (void)forceChangeText:(id)text withDoneBlock:(void(^)(void))block;
- (void)highLightChangeText:(NSString *)text changingBlock:(void(^)(void))block;
- (void)hightLightChaneAttrText:(NSAttributedString *)text withChangingBlock:(void(^)(void))block;
- (void)changeAttrText:(NSAttributedString *)text withChangingBlock:(void(^)(void))block;
- (void)setTextColor:(UIColor *)color;
@end
