//
//  UITableView+TP.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UITableView+TP.h"
#import "UIView+WithSkin.h"
#import "BaseCommonCell.h"
#import "RoundedCellBackGroundView.h"
@implementation UITableView (TPCreateCell)

-(id)createTableViewCell:(NSString *)cellName withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andSkinStyle:(NSString *)skinStyle  forHost:(id)host{
    id cell = [self dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [self newTableViewCell:cellName withStyle:style reuseIdentifier:reuseIdentifier];
         if(skinStyle){
            [cell setSkinStyleWithHost:host forStyle:skinStyle];
         }
    }
    return cell;
}
-(id)newTableViewCell:(NSString *)cellName withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    return [[NSClassFromString(cellName) alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
}
-(RoundedCellBackgroundViewPosition)cellPositionOfIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    int total = [self numberOfRowsInSection:[indexPath section]];
    if (row == 0) {
        if(total == 1) {
            return RoundedCellBackgroundViewPositionSingle;
        } else {
            return RoundedCellBackgroundViewPositionTop;
        }
    } else {
        if ((total - row) == 1) {
            return RoundedCellBackgroundViewPositionBottom;
        } else {
            return RoundedCellBackgroundViewPositionMiddle;
        }
    }
}

- (void)setExtraCellLineHidden{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:view];
}
@end
