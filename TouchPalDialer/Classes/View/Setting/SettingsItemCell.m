//
//  SettingsItemCell.m
//  TouchPalDialer
//
//  Created by Sendor on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingsItemCell.h"
#import "TPDialerResourceManager.h"

@implementation SettingsItemCell
@synthesize bool_value;
//@synthesize detail_view_controller_name; // 在controller里面保存
//@synthesize detail_view_controller_title;
@synthesize text_value;
@synthesize data_key;
@synthesize app_setting_model;

- (id)initWithType:(SettingsItemCellType)type reuseIdentifier:(NSString *)reuseIdentifier cellPosition:(RoundedCellBackgroundViewPosition)position
{
    return [self initWithType:type isHaveSubTitle:NO reuseIdentifier:reuseIdentifier cellPosition:position];
}

- (id)initWithType:(SettingsItemCellType)type isHaveSubTitle:(BOOL)isHaveSubTitle reuseIdentifier:(NSString *)reuseIdentifier cellPosition:(RoundedCellBackgroundViewPosition)position
{
    cell_type = type;
    if (isHaveSubTitle) {
        self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier cellPosition:position];
    } else {
        if (SettingsItemCellTypeString == type) {
            self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier cellPosition:position];
        } else {
            self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier cellPosition:position];
        }
    }
    if (self) {
        switch (type) {
            case SettingsItemCellTypeNone: {
                self.selectionStyle = UITableViewCellSelectionStyleBlue;
                self.accessoryType = UITableViewCellAccessoryNone;
                break;
            }
            case SettingsItemCellTypeDetail: {
                self.selectionStyle = UITableViewCellSelectionStyleBlue;
                UIImage *accessoryImage = [[TPDialerResourceManager sharedManager] getImageByName:@"setting_listitem_detail@2x.png"];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                CGRect frame = CGRectMake(0.0, 0.0, accessoryImage.size.width, accessoryImage.size.height);
                button.frame = frame;
                [button setImage:accessoryImage forState:UIControlStateNormal];
                [button setImage:accessoryImage forState:UIControlStateHighlighted];
                button.backgroundColor= [UIColor clearColor];
                self.accessoryView = button;
                break;
            }
            case SettingsItemCellTypeCheck:
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                self.accessoryType = UITableViewCellAccessoryCheckmark;
                break;
            case SettingsItemCellTypeSwitch: {
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                switch_view = [[UISwitch alloc] initWithFrame:CGRectZero];
                [switch_view addTarget:self action:@selector(onSwitchClick:) forControlEvents:UIControlEventValueChanged];
                self.accessoryView = switch_view;
                break;
            }
            case SettingsItemCellTypeText:
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case SettingsItemCellTypeString:
                self.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            default:
                cootek_log(@"Unknown style");
                break;
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBool_value:(BOOL)boolValue {
    if (SettingsItemCellTypeSwitch == cell_type) {
        switch_view.on = boolValue;
    } else if (SettingsItemCellTypeCheck == cell_type) {
        
    }
}

- (void)setText_value:(NSString *)textValue {
    if (SettingsItemCellTypeString == cell_type) {
        self.detailTextLabel.text = textValue;
    }
}

- (void)onSwitchClick:(UIControl*)sender{
    [app_setting_model setSettingValue:[NSNumber numberWithBool:switch_view.on] forKey:data_key];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    switch_view.userInteractionEnabled = userInteractionEnabled;
}

@end
