//
//  AnimateVerticalTextView
//
//
//  Created by frank.tang on 16/8/23.
//

#import <UIKit/UIKit.h>
#import "YPUIView.h"

@class AnimateVerticalTextView;

@protocol AnimateVerticalTextViewDelegate <NSObject>
- (void)gyChangeTextView:(AnimateVerticalTextView *)textView didTapedAtIndex:(NSInteger)index;
- (void)animationDone;
@end

@interface AnimateVerticalTextView : YPUIView
@property (nonatomic, assign) id<AnimateVerticalTextViewDelegate> delegate;

- (void)animation;
- (void)stop;
- (void)start;

@end
