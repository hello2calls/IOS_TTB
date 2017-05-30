//
//  InitSmartSettingViewController.h
//  TouchPalDialer
//
//  Created by Ailce on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingCellView.h"
@class SmartDailerSettingModel;

@interface InitSmartSettingViewController :  UIViewController<UITableViewDelegate,UITableViewDataSource,
SettingCellDelegate,UIScrollViewDelegate>{
    SmartDailerSettingModel *settingModel;
    UITableView *localTableView;
    UITextField *areaCodeField;
}
@property(nonatomic,retain) SmartDailerSettingModel *settingModel;
@property(nonatomic,retain) UITableView *localTableView;
@property(nonatomic,retain) UITextField* areaCodeField;
@end
