//
//  PersonalCenterTableView.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/25.
//
//

#import <UIKit/UIKit.h>
#import "SettingItem.h"

@class SettingTableView;

@protocol SettingTableViewDelegate <NSObject>

@optional
- (void)settingTableView:(SettingTableView *)tableView didSelectSettingItem:(SettingItem *)settingItem;
@end

@interface SettingTableView : UIView
@property (nonatomic,strong) NSMutableArray *settingArr;
@property (nonatomic,weak) id<SettingTableViewDelegate> delegate;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIView *footerView;

@end
