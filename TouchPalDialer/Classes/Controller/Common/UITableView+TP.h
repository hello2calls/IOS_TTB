//
//  UITableView+TP.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"

@interface UITableView (TPCreateCell)

- (id)createTableViewCell:(NSString *)cellName withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andSkinStyle:(NSString *)skinStyle forHost:(id)host;
- (id)newTableViewCell:(NSString *)cellName withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (RoundedCellBackgroundViewPosition)cellPositionOfIndexPath:(NSIndexPath *)indexPath;
- (void)setExtraCellLineHidden;
@end
