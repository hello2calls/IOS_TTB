//
//  SettingViewController.h
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CootekViewController.h"
#import "AppSettingsModel.h"

@interface SettingViewController : CootekViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray* __strong cell_titles;
    AppSettingsModel* __strong app_settings_model;
    UITableView* __strong table_view;
}

@property(nonatomic, retain, readonly) AppSettingsModel* app_settings_model;

- (void)gotoBack;
- (void)initializeCellTitles;
- (id)initWithSettingsModel:(AppSettingsModel*)settingsModel;
@end
