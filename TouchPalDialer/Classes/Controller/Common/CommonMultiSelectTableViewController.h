//
//  CommonMultiSelectTableViewController.h
//  TouchPalDialer
//
//  Created by Sendor on 11-9-21.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonDataCell.h"
#import "CommonMultiSelectTableView.h"    


@interface CommonMultiSelectTableViewController : UITableViewController

@property(nonatomic) NSArray* data_list;
@property(nonatomic) id<CommonMultiSelectProtocol> delegate;

//if animateOut is YES, that you can't present another viewController immediately after dismiss this controller 
- (id)initWithStyle:(UITableViewStyle)style data:(NSArray*)dataList delegate:(id<CommonMultiSelectProtocol>)delegate title:(NSString *)title needAnimateOut:(BOOL)animateOut;

@end
