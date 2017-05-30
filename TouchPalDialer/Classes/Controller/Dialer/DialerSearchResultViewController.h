//
//  DialerSearchResultViewController.h
//  TouchPalDialer
//
//  Created by zhang Owen on 11/10/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhonePadModel.h"
#import "LongGestureOperationView.h"
#import "LongGestureController.h"
#import "BaseContactCell.h"
#import "AllViewController.h"
#import "CallLogCell.h"


typedef NS_ENUM(NSUInteger, ADDEXTERCELLTYPE) {
    None,
    ChangeToNmberPad,
    ChangeToQWERTYPad,
    PasteClipBoard,
};

typedef NS_ENUM(NSUInteger, CELLTYPE) {
    SPECIALKEY_ACTION_CELL_COUNT,
    CELL_SEND_MESSAGE,
    CELL_CREATE_NEW_CONTACT,
    CELL_ADD_TO_EXISTING_CONTACT
};

@protocol DialerSearchResultViewControllerDelegate <NSObject>
- (void)specailKey:(ADDEXTERCELLTYPE)type;
- (void)sendMessage;
- (void)addContact;
- (void)addToExistingContact;
@end

@interface DialerSearchResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, LongGestureStatusChangeDelegate,UIGestureRecognizerDelegate>{
	PhonePadModel *shared_phonepadmodel;
	UITableView *result_tableview;
    
    id<DialerSearchResultViewControllerDelegate> __unsafe_unretained delegate;

    NSMutableIndexSet *cellMarkedArray;
    UILongPressGestureRecognizer *longPressReger;
//    LongGestureOperationView *longGestureOperationView;
  
    NSString *tableViewName;
    NSString *CellIdentifier;
    NSString *currentCellName;
    BOOL old_phone_pad_state;
}

@property(nonatomic, retain) NSString *CellIdentifier;
@property(nonatomic, retain) PhonePadModel *shared_phonepadmodel;
@property(nonatomic, retain) UITableView *result_tableview;
@property(nonatomic, retain) NSString* tableViewName;
@property(nonatomic, copy) NSString *currentCellName;
@property(nonatomic, assign) id<DialerSearchResultViewControllerDelegate> delegate;
@property(nonatomic, retain) LongGestureController *longGestureController;
@property(nonatomic, retain) BaseContactCell *longModeCell;
@end
