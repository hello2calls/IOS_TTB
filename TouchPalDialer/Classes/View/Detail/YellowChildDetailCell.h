//
//  YellowChildDetailCell.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseYellowCell.h"

@interface YellowBranchDetailCell : BaseYellowCell{
    UIImageView *iconView_; 
}
- (void)setContributeMode:(BOOL)isContibute;
@end

@interface YellowBranchAddressDetailCell : YellowBranchDetailCell{
    UIImageView *distanceIconView;
    UILabel *distanceLabel;
}
@end