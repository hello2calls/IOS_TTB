//
//  DialerGuideAnimationKeyAnimationView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/8/19.
//
//

#import <UIKit/UIKit.h>

@protocol DialerGuideAnimationKeyAnimationDelegate <NSObject>
- (void)showViewAnimation;
@end

@interface DialerGuideAnimationKeyAnimation : UIView
@property (nonatomic,assign) id<DialerGuideAnimationKeyAnimationDelegate> delegate;
- (void)startAnimation;
@end
