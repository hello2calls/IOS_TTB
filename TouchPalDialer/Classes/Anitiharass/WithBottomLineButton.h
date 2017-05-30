//
//  withBottomLineButton.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/15.
//
//

#import <UIKit/UIKit.h>

@interface WithBottomLineButton : UIButton
@property (nonatomic, assign) BOOL ifLast;
- (void)setFirstText:(NSString *)text;
- (void)setSecondText:(NSString *)text;
- (void)setSecondColor:(UIColor *)color;
@end
