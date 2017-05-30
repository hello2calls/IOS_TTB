//
//  SettingsItemCell.h
//  TouchPalDialer
//
//  Created by Sendor on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekTableViewCell.h"
#import "AppSettingsModel.h"

typedef enum {
    SettingsItemCellTypeNone,
    SettingsItemCellTypeDetail,
    SettingsItemCellTypeSwitch,
    SettingsItemCellTypeCheck,
    SettingsItemCellTypeText,
    SettingsItemCellTypeString
} SettingsItemCellType;

@interface SettingsItemCell : CootekTableViewCell {
    SettingsItemCellType cell_type;
    UISwitch* switch_view;
}

@property(nonatomic, assign) BOOL bool_value;
@property(nonatomic, retain) NSString* text_value;
@property(nonatomic, retain) NSString* data_key;
@property(nonatomic, retain) AppSettingsModel* app_setting_model;

- (id)initWithType:(SettingsItemCellType)type reuseIdentifier:(NSString *)reuseIdentifier cellPosition:(RoundedCellBackgroundViewPosition)position;
- (id)initWithType:(SettingsItemCellType)type isHaveSubTitle:(BOOL)isHaveSubTitle reuseIdentifier:(NSString *)reuseIdentifier cellPosition:(RoundedCellBackgroundViewPosition)position;

//- (void)enableUserInteraction:(BOOL)enable;
@end
