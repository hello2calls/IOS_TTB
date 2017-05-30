//
//  DialerGuideAnimationKeyboardView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import <UIKit/UIKit.h>

@protocol DialerGuideAnimationKeyboardViewDelegate <NSObject>
- (void)onStartAnimation:(NSInteger)time;
- (void)onAnimationOver;
@end

@interface DialerGuideAnimationKeyboardView : UIView
@property (nonatomic,assign) id<DialerGuideAnimationKeyboardViewDelegate> delegate;
- (void)startAnimation;
@end
