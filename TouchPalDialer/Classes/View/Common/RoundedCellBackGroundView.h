//
//  RoundedCellBackGroundView.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 9/7/12.
//
//

#import <UIKit/UIKit.h>
typedef enum  {
    RoundedCellBackgroundViewPositionTop,
    RoundedCellBackgroundViewPositionMiddle,
    RoundedCellBackgroundViewPositionBottom,
    RoundedCellBackgroundViewPositionSingle
} RoundedCellBackgroundViewPosition;

@interface RoundedCellBackGroundView : UIView

@property(nonatomic, retain) UIColor *borderColor, *fillColor;
@property(nonatomic) RoundedCellBackgroundViewPosition position;
@end
