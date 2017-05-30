//
//  SettingCell.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import <UIKit/UIKit.h>
#import "SettingItem.h"
#import "AvatarSettingItem.h"
#import "UnbindSettingItem.h"
#import "TPDialerResourceManager.h"
#import "IconSettingItem.h"
#import "CommonSettingItem.h"
#import "AboatUsLogoItem.h"

typedef NS_ENUM(NSInteger,SettingCellSeparateLineType){
    SettingCellSeparateLineTypeNormal,
    SettingCellSeparateLineTypeHeader,
    SettingCellSeparateLineTypeFooter,
    SettingCellSeparateLineTypeSingle
};
 
static CGFloat kSettingCellFrontPadding             = 20;
static CGFloat kSettingCellArrowPadding             = 16;
static CGFloat kSettingCellTailPadding              = 32;
static CGFloat kSettingCellHiddenArrowTailPadding   = 20;

@interface SettingCell : UITableViewCell

@property (nonatomic,assign) BOOL hiddenArrow;

@property (nonatomic,strong) SettingItem *settingItem;
@property (nonatomic,assign) SettingCellSeparateLineType separateLineType;
@property (nonatomic,assign) BOOL hiddenSeparateLine;
@property (nonatomic,weak) UILabel *checkMarkLabel;

+ (instancetype)cellWithTableView:(UITableView *)tableView settingItem:(SettingItem *)settingItem;

- (UIColor *)mainTextColor;

- (UIColor *)subTextColor;

@end
