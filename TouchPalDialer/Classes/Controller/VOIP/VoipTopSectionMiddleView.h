//
//  VoipTopSectionMiddleView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import <UIKit/UIKit.h>
#define VOIP_BREATHING_OUTTER_CIRCLE_RADIUS 230
@interface VoipTopSectionMiddleView : UIView

@property(nonatomic, assign)UIView *outter;
@property(nonatomic, assign)UIView *middle;
@property(nonatomic, assign)UIView *inner;
@property(nonatomic, assign)UIImageView *innerImageView;


- (id) initWithFrame:(CGRect)frame;
- (void)beginBreathing;
- (void)stopBreathing;
- (void)setInnerCircleImage:(UIImage *)image;
@property(nonatomic, assign)UIColor *circleColor;
@end
