 //
//  SelectView.h
//  TouchPalDialer
//
//  Created by Alice on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectViewProtocal.h"
#import "SelectSearchResultView.h"
#import "ContactSearchModel.h"
#import "SectionIndexView.h"
#import "ClearView.h"
#import "TPUIButton.h"
#import "TPUISearchBar.h"
#import "TPHeaderButton.h"


typedef enum {
    SelectViewNormal,
    SelectViewGroupCommandAll,
    SelectViewGroupCommandGroup,
} SelectViewType;


@interface SelectView : UIView <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UIScrollViewDelegate ,SelectViewProtocalDelegate, SectionIndexDelegate> {
	NSInteger select_count;
	NSArray *person_list;
	NSArray *keys_arr;
	NSDictionary *contact_dic;
	NSMutableDictionary *person_check_list;
	NSMutableDictionary *section_map;
    SelectViewType viewType;
    NSString *commandName;
	
	id <SelectViewProtocalDelegate> __unsafe_unretained select_view_delegate;
	
	TPUISearchBar *search_bar;
	UILabel *middle_digit;
    TPUIButton *operationButton;
	UITableView *content_view;
	SelectSearchResultView *search_result_view;
	ContactSearchModel *search_engine;
	
	NSMutableArray *tmp_mutablearr;
	
	SectionIndexView *section_index_view;
	ClearView *clear_view;
    
    TPHeaderButton *selectAllButton;

}
@property(nonatomic,assign) NSInteger select_count;
@property(nonatomic,retain) NSArray *person_list;
@property(nonatomic,retain) NSArray *keys_arr;
@property(nonatomic,retain) NSDictionary *contact_dic;
@property(nonatomic,retain) NSMutableDictionary *person_check_list;
@property(nonatomic,retain) NSMutableDictionary *section_map;
@property(nonatomic,retain) NSString *commandName;
@property(nonatomic,retain) TPUIButton *operationButton;
@property(nonatomic,retain) TPHeaderButton *selectAllButton;

@property(nonatomic,retain)UISearchBar *search_bar;
@property(nonatomic,retain)UILabel *middle_digit;
@property(nonatomic,retain)UITableView *content_view;
@property(nonatomic,retain)SelectSearchResultView *search_result_view;
@property(nonatomic,retain)ContactSearchModel *search_engine;

@property(nonatomic,retain) NSMutableArray *tmp_mutablearr;
@property(nonatomic,retain) SectionIndexView *section_index_view;
@property(nonatomic,retain) ClearView *clear_view;
@property(nonatomic,assign) int groupId;
@property(nonatomic,assign)BOOL isChooseSingle;

@property(nonatomic,assign) id <SelectViewProtocalDelegate> select_view_delegate; 

- (id)initWithPersonArray:(NSArray *)person_list;
- (id)initWithPersonArrayAndViewTypeAndCommandName:(NSArray *)person_list_temp ViewType:(SelectViewType)type CommandName:(NSString *)operationName;
- (id)initWithPersonArrayAndViewTypeAndCommandName:(NSArray *)person_list_temp ViewType:(SelectViewType)type CommandName:(NSString *)operationName andIfSingle:(Boolean)ifSingle;
//- (BOOL)isSelectedPerson:(NSInteger)personID;
NSInteger sorttByFirstChar(id obj1, id obj2, void *context);
- (void)onNotiPersonModelReloaded;

@end
