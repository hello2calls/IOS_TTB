//
//  SearchResultViewController.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/29/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultModel.h"
#import "LongGestureController.h"
#import "LongGestureOperationView.h"


@protocol SearchResultViewDelegate

- (void)resignKeyboard;
- (void)research;
@optional
- (void)saveSearchText;

@end


@interface SearchResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, LongGestureStatusChangeDelegate,UIGestureRecognizerDelegate>{
	UITableView *m_tableview;
	SearchResultModel *result_arr;
	
	id<SearchResultViewDelegate> __unsafe_unretained delegate;
     
     NSMutableIndexSet *cellMarkedArray;
     UILongPressGestureRecognizer *longPressReger;
//     LongGestureOperationView *longGestureOperationView;
     BOOL old_phone_pad_state;
     NSString *tableViewName;
     NSString *CellIdentifier;
}

@property(nonatomic, retain) UITableView *m_tableview;
@property(nonatomic, retain) SearchResultModel *result_arr;
@property(nonatomic, assign) id<SearchResultViewDelegate> delegate;
@property(nonatomic, retain) NSString *CellIdentifier;
@property(nonatomic, retain) LongGestureController *longGestureController;

- (void)refreshMyResult:(SearchResultModel *)result;
- (void)refreshView;
- (void)registerPersonDataChangeNotification;
- (void)unregisterPersonDataChangeNotification;
@end
