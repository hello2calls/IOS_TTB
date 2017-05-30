//
//  TPDContactCopyViewController.h
//  TouchPalDialer
//
//  Created by H L on 2016/10/11.
//
//


#import <UIKit/UIKit.h>
//#import "AllViewController.h"
#import "AllCopyViewController.h"
#import "ClearView.h"
#import "TPHeaderButton.h"
#import "FilterContactResultListView.h"
#import "PushRightView.h"
#import "BaseTabBar.h"
#import "HeadTabBar.h"
#import "CooTekPopUpSheet.h"
#import "GroupOperationCommandBase.h"
#import "PullDownSheet.h"
#import "ContactViewController.h"

@interface TPDContactCopyViewController : UIViewController  <RestoreViewLocation, BaseTabBarDelegate, PullDownSheetDelegate>
{
    ContactPageIndex current_page_index;
    TPUIButton *segment_touchpaler;
    TPUIButton *segment_all;
    TPUIButton *segment_group;
    
    TPHeaderButton* operation_button;
    //  TPHeaderButton* invite_button;
    
    AllCopyViewController* all_controller;
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

@property(nonatomic,retain) AllCopyViewController* all_controller;
@property(nonatomic,readonly) UILabel *titleBar;
- (void)exitEditingMode;
@end

