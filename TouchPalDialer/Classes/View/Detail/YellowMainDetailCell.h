//
//  YellowMainDetailCell.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseYellowCell.h"
#import "TPUIButton.h"

@protocol YellowMainDetailCellDelegate <NSObject>

-(void)onWillGoDetail:(id)detailCell;
-(void)reportShopWithCell:(id)reportCell;

@end

@interface YellowMainDetailCell : BaseYellowCell{
    void (^_goDetailBlock_)();
    TPUIButton *reportButton_;
}
@property(nonatomic,assign) id<YellowMainDetailCellDelegate>delegate;

-(void)setContributeMode:(BOOL)isContibute;
@end

@interface YellowMainMoreDetailCell : YellowMainDetailCell{
    UILabel *distanceLabel;
}
@end
