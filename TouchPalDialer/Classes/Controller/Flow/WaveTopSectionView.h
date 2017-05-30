//
//  FlowTopSectionView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/1/28.
//
//

#import <UIKit/UIKit.h>

#define VOIP_UNIT 0
#define FLOW_UNIT 1

@interface WaveTopSectionView : UIView
- (id) initWithFrame:(CGRect)frame andBgColor:(UIColor*)bgColor andIfWave:(BOOL)ifWave andUnitType:(NSInteger)unitType;
- (UIView*) getMiddleView;
- (void) startWave:(NSInteger)currentValue;
- (void) setTitle:(NSString*)title;
- (void) setDescription:(NSString*)description;
- (void) setMaxValue:(NSInteger)maxValue;
- (void) adjustWave:(NSInteger)currentValue;
@end
