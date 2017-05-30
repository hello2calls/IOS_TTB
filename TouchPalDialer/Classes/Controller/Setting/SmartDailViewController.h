//
//  SmartDailViewController.h
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingCellView.h"
@class SmartDailerSettingModel;

@interface SmartDailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SettingCellDelegate,UIAlertViewDelegate>{
      SmartDailerSettingModel *settingModel;
      UITableView *dailerTableView;
      NSArray *IPRuleArray;
}
@property(nonatomic,retain) NSArray *IPRuleArray;
@property(nonatomic,retain) SmartDailerSettingModel *settingModel;
@property(nonatomic,retain) UITableView *dailerTableView;

- (void)loadInitView;
@end
