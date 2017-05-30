//
//  DialerViewController.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhonePadKeyProtocol.h"
#import "PhonePadModel.h"
#import "PhoneNumberInputView.h"
#import "TPHeaderButton.h"
#import "DialerSearchResultViewController.h"
#import "HeaderBar.h"
#import "UIDialerSearchHintView.h"
#import "CallLogTitleView.h"
#import "KeypadView.h"
#import "CalllogFilterBar.h"
#import "PushRightView.h"
#import "ExpandableListView.h"
#import "HighlightTip.h"
#import "LongGestureController.h"
#import "CooTekPopUpSheet.h"
#import "CallAndDeleteBar.h"

@class RootScrollViewController;
#define TIPS_VIEW_TAG    200
#define INVITATION_CODE_BELTA  @"Touchpal20151217"
#define ORIGINAL_INVITATION_CODE_BELTA  @"295056384351364720151217"
#define V536_INVITATION_CODE_BELTA  @"295056384325364731536"


#define TAG_RING_VIWE (301)
#define TAG_POINT_VIWE (302)


//29505638435136471217
#define INVITATION_URL_STRING  @"http://oss.aliyuncs.com/cootek-dialer-download/dialer/free-call/international/oversea_main/index.html"
#define INTERNATIONAL_CALL_OK @"您已成功开通此功能"
@interface DialerViewController : UIViewController <UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UIScrollViewDelegate,
                                                    PhonePadKeyProtocol,
                                                    PhoneNumberInputViewDelegate,
                                                    UIAlertViewDelegate,
                                                    DialerSearchResultViewControllerDelegate,
                                                    CalllogTitleClickDelegate,
                                                    BaseTabBarDelegate,
                                                    UIActionSheetDelegate,
                                                    LongGestureStatusChangeDelegate>
{
	PhonePadModel *shared_phonepadmodel;
	// views for assemble the dialer.
	PhoneNumberInputView *phone_number_label;
    CallLogTitleView *header_title;
	
	TPHeaderButton *clearall_button;
	
	UITableView *contactlist_view;
	UIView *phonepad_view;
	
	DialerSearchResultViewController *search_result_viewcontroller;

	HeaderBar *headerView;
    UIDialerSearchHintView *hintView;
    BOOL haveLeavedFeatureGuide_;
    BOOL haveParsedCallLogWithSmartEye_;
    NSString *tableViewName;
    NSString *currentCellName;
    HighlightTip* tipForSuperDial_;

}
@property(nonatomic, retain) PhonePadModel *shared_phonepadmodel;
@property(nonatomic, retain) PhoneNumberInputView *phone_number_label;
@property(nonatomic, retain) CallLogTitleView *header_title;
@property(nonatomic, retain) TPHeaderButton *clearall_button;
@property(nonatomic, retain) UITableView *contactlist_view;
@property(nonatomic, retain) UIView *phonepad_view;
@property(nonatomic, retain) UIView *callLogType_view;
@property(nonatomic, retain) HeaderBar *headerView;
@property(nonatomic, retain) UIDialerSearchHintView *hintView;
@property(nonatomic, retain) DialerSearchResultViewController *search_result_viewcontroller;
@property(nonatomic, assign) RootScrollViewController* parent;
@property(nonatomic, retain) NSString* tableViewName;
@property(nonatomic, copy)   NSString *keyName;
@property(nonatomic, copy)   NSString *currentCellName;
@property(nonatomic, retain) LongGestureController *longGestureController;
@property(nonatomic, retain) CallAndDeleteBar *callDeleteBar;

- (void)phonepad_show;
- (void)phonepad_hide;

- (void)doWhenInputEmpty;
- (void)doWhenInput;
- (void)loadPhonePad:(DailerKeyBoardType)keyPadType;
- (void)editCallLog;
- (void)onClickFilter:(CalllogFilterType)type;
- (void)exitEditingMode;
- (void)willHiddenKeyBoard;
- (void)restoreKeyBoard;
+(void)showGuidePopView;
@end
