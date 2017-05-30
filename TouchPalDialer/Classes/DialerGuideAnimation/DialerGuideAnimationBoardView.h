//
//  DialerGuideAnimationBoardView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/8/19.
//
//

#import <UIKit/UIKit.h>

@protocol DialerGuideAnimationBoardViewDelegate <NSObject>
- (void)onAnimationStop;
@end

@interface DialerGuideAnimationBoardView : UIView
@property (nonatomic,assign) id<DialerGuideAnimationBoardViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSString *)title andTag:(NSInteger)tag;
- (void) startAnimation;
@end
