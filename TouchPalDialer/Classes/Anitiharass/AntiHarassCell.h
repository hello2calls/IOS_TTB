//
//  AntiHarassCell.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "SettingCell.h"
#import "AntiNormalItem.h"

@interface AntiHarassCell : UITableViewCell

@property (nonatomic,assign) SettingCellSeparateLineType separateLineType;

@property (nonatomic,strong) AntiNormalItem *item;

+ (instancetype)cellWithTableView:(UITableView *)tableView settingItem:(AntiNormalItem *)settingItem;

@end
