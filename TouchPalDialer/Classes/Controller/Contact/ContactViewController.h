//
//  ContactViewController.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllViewController.h"
#import "ClearView.h"
#import "TPHeaderButton.h"
#import "FilterContactResultListView.h"
#import "PushRightView.h"
#import "BaseTabBar.h"
#import "HeadTabBar.h"
#import "CooTekPopUpSheet.h"
#import "GroupOperationCommandBase.h"
#import "PullDownSheet.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum tag_ContactPageIndex {
    ContactPageIndexAll = 0,
    ContactPageIndexGroup,
    ContactPageIndexNone,
    ContactPageIndexTouchpaler,
} ContactPageIndex;


@interface ContactViewController : UIViewController  <RestoreViewLocation, BaseTabBarDelegate, PullDownSheetDelegate>
{
    ContactPageIndex current_page_index;
    TPUIButton *segment_touchpaler;
	TPUIButton *segment_all;
	TPUIButton *segment_group;
	
    TPHeaderButton* operation_button;
    //  TPHeaderButton* invite_button;
    
    AllViewController* all_controller;
    PushRightView *filterView;
    // CooTekPopUpSheet *popUpManagementOperation;
    OperationSheetType sheetType;
}

@property(nonatomic,retain) ExpandableListView *groupList;

@property(nonatomic,retain) TPHeaderButton *operation_button;
@property(nonatomic,retain) TPUIButton *segment_touchpaler;
@property(nonatomic,retain) TPUIButton *segment_all;
@property(nonatomic,retain) TPUIButton *segment_group;
@property(nonatomic, retain) PullDownSheet *pullDownSheet;
@property (nonatomic) TPUIButton *backButton;
@property (nonatomic) TPUIButton *editButton;
@property (nonatomic, retain) NSArray *menu;
@property (nonatomic, retain) NSArray *menuSmart;
@property (nonatomic, retain) NSArray *menuAll;
@property (nonatomic, retain) NSArray *menuGroup;
@property (nonatomic, retain) NSMutableArray *array;
//@property (nonatomic, retain) CooTekPopUpSheet *popUpManagementOperation;

@property(nonatomic,retain) AllViewController* all_controller;
@property(nonatomic,readonly) UILabel *titleBar;
- (void)exitEditingMode;
@end
NS_ASSUME_NONNULL_END