//
//  DialerGuideAnimationView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import <UIKit/UIKit.h>

@protocol DialerGuideAnimationViewDelegate <NSObject>
- (void)onEscapeButtonPressed;
@end

@interface DialerGuideAnimationView : UIView
@property (nonatomic,assign) id<DialerGuideAnimationViewDelegate> delegate;
@end
