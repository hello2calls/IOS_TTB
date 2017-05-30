//
//  JBCallLogCell.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseCommonCell.h"
#import "UIView+WithSkin.h"
#import "WithEyeViewForBaseContactCell.h"
#import "TPUIButton.h"

@interface JBCallLogCell : WithEyeViewForBaseContactCell {
    TPUIButton *detailButton;
    TPUIButton *typeButton;
    UILabel *dateLabel; 
    UILabel *timeLabel;
    UIColor *nameColor;
   
}
@property(nonatomic,retain)UIColor *nameColor;
@property (nonatomic, retain)TPUIButton *detailButton2;
- (UIImage *)getNormalCallImage:(CallLogType)type;
- (UIImage *)getHightlightCallImage:(CallLogType)type;
@end
