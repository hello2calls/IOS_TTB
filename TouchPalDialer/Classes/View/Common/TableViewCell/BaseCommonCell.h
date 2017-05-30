//
//  BaseDialerCell.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"
#import "FaceSticker.h"
#import "HighLightLabel.h"
#import "CallLogDataModel.h"
#import "UIView+WithSkin.h"
#import "LongGestureController.h"

@interface BaseCommonCell : CootekTableViewCell <SelfSkinChangeProtocol,LongGestureCellDelegate>
@property(nonatomic, retain) id currentData;
- (void)accessoryButtonClicked:(id)sender; 
- (void)goToDetail;
- (void)setDataToCell;
- (void)refreshWithEditingState:(BOOL)isediting;
- (BOOL)isShowNumberAttr;
- (id)selfSkinChange:(NSString *)style;
@end
