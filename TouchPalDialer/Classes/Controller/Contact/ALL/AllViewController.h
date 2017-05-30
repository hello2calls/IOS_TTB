//
//  ContactViewController.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultViewController.h"
#import "ContactSearchModel.h"
#import "SectionIndexView.h"
#import "ClearView.h"
#import "ContactItemCell.h"
#import "TPHeaderButton.h"
#import "LongGestureOperationView.h"
#import "ExpandableListView.h"
#import "FilterContactResultListView.h"
#import "LeafNode.h"
#import "LongGestureController.h"
#import "TPUISearchBar.h"
#import "UIDialerSearchHintView.h"
#import "FavoriteNopersonHintView.h"
#import "ContactSpecialCell.h"
#import "TouchpalMembersManager.h"
#import "SelectSearchResultView.h"
#import "ContactEmptyGuideView.h"

/* macros from ContactItemCell.h
 #define CONTACT_CELL_HEIGHT (66)
 #define CONTACT_CELL_MARGIN_LEFT (66)
 #define CONTACT_CELL_PHOTO_DIAMETER (36)
*/

#define CONTACT_VIEW_CONTROLLER_ADD_BUTTON_TAG 12345

#define CONTACT_CELL_SECTION_HEADER_HEIGHT (20)
#define CONTACT_CELL_LEFT_GAP         ((CONTACT_CELL_MARGIN_LEFT - CONTACT_CELL_PHOTO_DIAMETER) / 2)

#define FAV_ITEM_LENGTH_GAP           ((TPScreenHeight()>=600)? 30: 20)
#define FAV_ICON_LENGTH               ((TPScreenHeight()>=600)? (TPScreenHeight()>700?69:64):68)

#define COOTEK_USER_ICON_MARGIN_RIGHT (10)

#define FAV_ROW_COUNT                 ((TPScreenHeight() >= 600) ? 5: 4)

#define FAV_ROW_MARGIN_TOP            (24)
#define FAV_ROW_MARGIN_BOTTOM         (24)

#define FAV_ICON_TEXT_GAP             (8)
#define FAV_ROW_MARGIN_RIGHT          (INDEX_SECTION_VIEW_WIDTH > CONTACT_CELL_LEFT_GAP ? INDEX_SECTION_VIEW_WIDTH : CONTACT_CELL_LEFT_GAP)
#define FAV_ICON_GAP                  ((TPScreenWidth() - CONTACT_CELL_LEFT_GAP - FAV_ROW_MARGIN_RIGHT - FAV_ROW_COUNT * FAV_ICON_LENGTH) / (FAV_ROW_COUNT - 1))
#define FAV_TEXT_HEIGHT               (16)
#define GAP_BETWEEN_FAV_ICON          (((TPScreenWidth()-CONTACT_CELL_LEFT_GAP-24)-FAV_ROW_COUNT*FAV_ICON_LENGTH)/(FAV_ROW_COUNT-1))

@interface DisplayRequirementsForFilter : NSObject {
}
@property(nonatomic, assign)NSArray *datas;
@property(nonatomic, assign)NSString *filterDescription;
@property(nonatomic, assign)BOOL needAZScrollist;
@property(nonatomic, assign)BOOL needDisplayNote;
@property(nonatomic, assign)BOOL needRefreshInFilterState;
@end


@protocol RestoreViewLocation
-(void)restoreViewLocation;
@end

@interface AllViewController : UIViewController <UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
ContactItemCellProtocol,
SearchResultViewDelegate,
SectionIndexDelegate,
DataContainersProtocol,
LongGestureStatusChangeDelegate,
SelectViewProtocalDelegate,
ContactSpecialCellDelegate,
TouchpalsChangeDelegate,
UIGestureRecognizerDelegate>
{
	UITableView *all_content_view;
	TPUISearchBar *m_searchbar;
    TPHeaderButton* add_member_button;
    TPUIButton* select_all_button;
	SearchResultViewController *search_result_controller;
    SelectSearchResultView *searchResultView;
    ContactSearchModel* search_engine;
	NSMutableDictionary *section_map;
    NSDictionary *contact_layout;
    CGRect search_result_frame;
	SectionIndexView *section_index_view;
	ClearView *clear_view;
    FavoriteNopersonHintView *hintViewGroup;
    FavoriteNopersonHintView *hintViewUngroup;
    
    NSMutableSet *cellMarkedArray;
    LongGestureOperationView *longGestureOperationView;
    BOOL old_phone_pad_state;
    NSString *tableViewName;
    NSString *CellIdentifier;
    TPHeaderButton *allButtonInFilterResultDisplayView;
    LeafNodeWithContactIds *leafNodeFromFilter;
    UILabel *filterDescriptionLabel;
//    LongGestureController *longGestureController_;
    BOOL needCheck;
    UIButton *AddMember;
}

@property(nonatomic, retain) UITableView *all_content_view;
@property(nonatomic, retain) UISearchBar *m_searchbar;
@property(nonatomic, retain) SearchResultViewController *search_result_controller;
@property(nonatomic, retain) ContactSearchModel* search_engine;
@property(nonatomic, retain) NSMutableDictionary *section_map;
@property(nonatomic, retain) SectionIndexView *section_index_view;
@property(nonatomic, retain) ClearView *clear_view;
@property(nonatomic, retain) FavoriteNopersonHintView *hintViewGroup;
@property(nonatomic, retain) FavoriteNopersonHintView *hintViewUngroup;
@property(nonatomic, retain) NSString *CellIdentifier;
@property(nonatomic, assign) BOOL loadDataFromFilter;
@property(nonatomic, assign) BOOL needCheck;
@property(nonatomic, retain) NSMutableDictionary *contactsFromFilter;
@property(nonatomic, retain) NSMutableArray *sectionKeysFromFilter;
@property(nonatomic, assign) id<RestoreViewLocation> restoreViewLocationDelegate;
@property(nonatomic, retain) UILabel *filterDescriptionLabel;
@property(nonatomic, retain) FilterContactResultListView *contactsDisplayViewWithNoAZScrollist;
@property(nonatomic, assign) CellDisplayType displayType;
@property(nonatomic, assign) UIViewController *parentViewController1;
@property(nonatomic, retain) NSArray *contactIDsFromFilter;
@property(nonatomic, retain) NSArray *favArray;
@property(nonatomic, retain) StringNumberPair *filterDisplayTitle;
@property(nonatomic, retain) LeafNodeWithContactIds *leafNodeFromFilter;
@property(nonatomic, retain) LongGestureController *longGestureController;
@property(nonatomic, retain) NSMutableArray  *personArray;
@property(nonatomic, retain) ContactEmptyGuideView *guideViewWhenNoContact;

- (void)refresh;
- (void)refreshView;
- (void)clearSectionIndexView;
- (void)changeAllmemberChecked:(BOOL)state;
- (BOOL)allChecked;
- (NSArray *)getAllCheckedPerson:(BOOL)needChecked;
- (BOOL)haveContacts;
- (BOOL)havePhoneNumbers;
- (void)scrollToDismissFavort;
+ (NSArray *)getNumberArrarFromBindsuccessListArray;
+ (void)asyncGetActivityFamilyInfo;
//- (Command[])getCommand;

@end
