//
//  LocalPhoneInfoViewController.h
//  TouchPalDialer
//
//  Created by Ailce on 12-2-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingCellView.h"
#import "RegisterProtocol.h"

@class SmartDailerSettingModel;

@interface LocalPhoneInfoViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,
                                                            SettingCellDelegate,UIScrollViewDelegate,
                                                             RegisterProtocolDelegate>{
    SmartDailerSettingModel __strong *settingModel;
    UITableView __strong *localTableView;
    NSString __strong *carrier_;
}
@property(nonatomic,retain) SmartDailerSettingModel *settingModel;
@property(nonatomic,retain) UITableView *localTableView;
@end
