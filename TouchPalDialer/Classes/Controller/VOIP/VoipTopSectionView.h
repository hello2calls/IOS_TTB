//
//  VoipTopSectionView.h
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import <UIKit/UIKit.h>
#import "VoipTopSectionHeaderBar.h"
#import "VoipTopSectionMiddleView.h"

@interface VoipTopSectionView : UIView
- (id) initWithFrame:(CGRect)frame andBgColor:(UIColor*)bgColor;
- (VoipTopSectionMiddleView*) getMiddleView;
@end
