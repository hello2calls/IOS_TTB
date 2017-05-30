//
//  GroupManagerViewController.h
//  TouchPalDialer
//
//  Created by Sendor on 11-8-29.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomEditingCell.h"
#import "TPHeaderButton.h"

@interface GroupManagerViewController : UITableViewController<CustomEditingCellProtocol> {
    UITableView *group_table_view;
    UIButton *cancel_but;
}

@property(nonatomic, retain) UITableView *group_table_view;
@property(nonatomic, retain) UIButton *cancel_but;
- (void)popUpToTop;
@end
