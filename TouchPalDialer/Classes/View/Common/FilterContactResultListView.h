//
//  ContactContainersForExpandableCellView.h
//  TouchPalDialer
//
//  Created by Liangxiu on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandableListView.h"
#import "LongGestureOperationView.h"
#import "LongGestureController.h"
@interface FilterContactResultListView : UIView <DataContainersProtocol,UITableViewDelegate, UITableViewDataSource, LongGestureStatusChangeDelegate,UIGestureRecognizerDelegate>{
	UITableView *m_tableview;
    CGRect view_frame;
    NSMutableIndexSet *cellMarkedArray;
    UILongPressGestureRecognizer *longPressReger;
    BOOL old_phone_pad_state;
    NSString *tableViewName;
    NSString *CellIdentifier;
    UILabel *titleLabel;
}

@property(nonatomic, retain) UITableView *m_tableview;
@property(nonatomic, retain) NSString *CellIdentifier;
@property(nonatomic, retain) NSMutableArray *datas;
@property(nonatomic, readonly)  UILabel *titleLabel;
@property(nonatomic, retain) LongGestureController *longGestureController;

- (void)reloadTable;
@end
