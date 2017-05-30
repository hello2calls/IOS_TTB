//
//  FlowWaterWaveView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/29.
//
//

#import <UIKit/UIKit.h>

@interface FlowWaterWaveView : UIView
@property (nonatomic,assign) float currentLinePointY;
- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)bgColor andY:(NSInteger)y andA:(float)aPos andB:(float)bPos;
- (void)addTimer;
- (void)removeTimer;
@end
