//
//  DiscoverAnimationButton.h
//  TouchPalDialer
//
//  Created by lin tang on 16/11/10.
//
//

#import "YPUIView.h"
#import "VerticallyAlignedLabel.h"
#import "DiscoverCircleAnimation.h"

@interface DiscoverAnimationButton : YPUIView
@property(strong)UIImageView* pointView;
@property(strong)UIImageView* arrowView;
@property(strong)UIImageView* title;

- (void) show;
@end
