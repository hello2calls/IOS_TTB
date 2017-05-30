//
//  SelectView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-23.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SelectView.h"
#import "HeaderBar.h"
#import "ContactCacheDataModel.h"
#import "LangUtil.h"
#import "SelectCellView.h"
#import "SelectModel.h"
#import "TPHeaderButton.h"
#import "CootekNotifications.h"
#import "SearchResultModel.h"
#import "ContactModelNew+IndexA_Z.h"
#import "ContactCacheDataManager.h"
#import "ContactCacheDataModel.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "UIButton+DoneButton.h"
#import "ContactGroupDBA.h"
#import "AllViewController.h"
#import "UILabel+DynamicHeight.h"
#import "FunctionUtility.h"
#import "GroupOperationCommandCreator.h"
#import "GroupSendSMSCommand.h"
#import "UserDefaultsManager.h"
@interface SelectView ()

- (void)buildContactsAndKeys;
@property (nonatomic,strong) NSMutableDictionary *personListMap;
@end

@implementation SelectView {
    TPUIButton *_deleteButton;
    TPUIButton *_selectedButton;
    TPUIButton *_smsButton;
    UIView *_bottomHolderView;
    BOOL _isSpecialMode;
}

@synthesize select_count;
@synthesize person_list;
@synthesize contact_dic;
@synthesize keys_arr;
@synthesize person_check_list;
@synthesize commandName;
@synthesize operationButton;
@synthesize selectAllButton;

@synthesize select_view_delegate;
@synthesize search_bar;
@synthesize middle_digit;
@synthesize content_view;
@synthesize search_result_view;
@synthesize search_engine;
@synthesize section_index_view;
@synthesize clear_view;
@synthesize section_map;

@synthesize tmp_mutablearr;

- (NSMutableDictionary *)personListMap
{
    if (!_personListMap) {
        _personListMap = [NSMutableDictionary dictionary];
    }
    return _personListMap;
}

- (id)initWithPersonArrayAndViewTypeAndCommandName:(NSArray *)person_list_temp ViewType:(SelectViewType)type CommandName:(NSString *)operationName andIfSingle:(Boolean)ifSingle{
    self = [super initWithFrame:CGRectMake(0,0,TPScreenWidth(),TPAppFrameHeight()+TPHeaderBarHeightDiff())];
    if (self) {
        _isSpecialMode = NO;
        viewType = type;
        _isChooseSingle = ifSingle;
        if (operationName != nil) {
            commandName = [[NSString alloc] initWithString:operationName];
        } else {
            commandName =@"";
        }
        
        if (viewType != SelectViewGroupCommandAll && viewType != SelectViewGroupCommandGroup) {
            viewType = SelectViewNormal;
        }
        self.backgroundColor=[UIColor clearColor];
        self.person_list = person_list_temp;
        for (ContactCacheDataModel *contactCacheModel in person_list_temp) {
            NSNumber *personID = [NSNumber numberWithInteger:contactCacheModel.personID];
            [self.personListMap setObject:contactCacheModel forKey:personID];
        }
        
        self.select_count=0;
        int person_count=[self.person_list count];
        NSMutableDictionary *check_list=[[NSMutableDictionary alloc] init];
        for (int i=0; i<person_count; i++) {
            ContactCacheDataModel *person=[self.person_list objectAtIndex:i];
            SelectModel *tmp_select=[[SelectModel alloc] init];
            tmp_select.personID=person.personID;
            tmp_select.isChecked=NO;
            [check_list setObject:tmp_select forKey:[NSNumber numberWithInt:tmp_select.personID]];
        }
        
        // view generation
        CGFloat gY = 0;
        UIFont *commonFont = [UIFont systemFontOfSize:FONT_SIZE_3];
        
        // header bar
        self.person_check_list=check_list;
        HeaderBar *header = [[HeaderBar alloc] initHeaderBar];
        [header setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
        
        // done button
        CGRect frame = CGRectMake(TPScreenWidth() - 50, gY, 50, 45);
        TPHeaderButton *finish_but = [[TPHeaderButton alloc] initRightBtnWithFrame:frame];
        [finish_but setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
        [finish_but setTitle:NSLocalizedString(@"Done",@"") forState:UIControlStateNormal ];
        [finish_but addTarget:self action:@selector(selectFinish) forControlEvents:UIControlEventTouchUpInside];
        if (viewType != SelectViewNormal || _isChooseSingle) {
            finish_but.hidden = YES;
        }
        finish_but.titleLabel.font = commonFont;
        
        BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:isVersionSix ?@"skinHeaderBarOperationText_normal_color":@"header_btn_disabled_color"];

        
        //select_all button
        TPHeaderButton *all_but = [[TPHeaderButton alloc] initWithFrame:CGRectMake(TPScreenWidth() - 55, gY, 50, 45)];
        [all_but setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style "];
        [all_but setTitle:NSLocalizedString(@"Select_all",@"") forState:UIControlStateNormal];
        [all_but addTarget:self action:@selector(selectAll) forControlEvents:UIControlEventTouchUpInside];
        all_but.titleLabel.font = commonFont;
        if(isVersionSix) {
            [all_but setTitleColor:tColor forState:UIControlStateNormal];
        }
        all_but.hidden = YES;
        if (viewType != SelectViewNormal) {
            all_but.hidden = NO;
        }
        selectAllButton = all_but;
        
        // back button
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [backBtn setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        if (isVersionSix) {
            [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        } else {
            UIColor *htColor =[TPDialerResourceManager getColorForStyle:@"header_btn_disabled_color"];
            [backBtn setTitleColor:htColor forState:UIControlStateHighlighted];
            

        }
        [backBtn addTarget:self action:@selector(selectCancel) forControlEvents:UIControlEventTouchUpInside];
        
        // middle label
        UILabel *middle_digit_tmp=[[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-220)/2, 8+TPHeaderBarHeightDiff(), 220, 30)];
        middle_digit_tmp.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
        [middle_digit_tmp setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        middle_digit_tmp.textAlignment=NSTextAlignmentCenter;
        if (viewType == SelectViewNormal && !_isChooseSingle) {
            middle_digit_tmp.text=[NSString stringWithFormat:NSLocalizedString(@"%d selected",@""),select_count];
        } else {
            middle_digit_tmp.text=commandName;
        }
        if (isVersionSix) {
            UIColor *color =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
            middle_digit_tmp.textColor = color;
        }
        self.middle_digit=middle_digit_tmp;
        
        // view tree: header bar
        [header addSubview:finish_but];
        [header addSubview:all_but];
        [header addSubview:backBtn];
        [header addSubview:middle_digit_tmp];
        
        gY += header.frame.size.height;
        
        // search bar
        self.search_bar = [[TPUISearchBar alloc] initWithFrame:CGRectMake(0, gY, TPScreenWidth(), 45)];
        [search_bar setSkinStyleWithHost:self forStyle:@"TPUISearchBar_default_style"];
        search_bar.delegate = self;
        if (viewType == SelectViewGroupCommandGroup) {
            search_bar.hidden = YES;
        }
        search_bar.placeholder = NSLocalizedString(@"search", @"");
        gY += search_bar.frame.size.height;
        
        // holder view for bottom buttons
        _isSpecialMode = [commandName isEqualToString:NSLocalizedString(@"batch_delete_contacts_and_send_sms", @"删除联系人和发送短信")];
        
        CGFloat bottomHolderHeight = TAB_BAR_HEIGHT;
        CGFloat bottomHolderY = TPScreenHeight() - bottomHolderHeight;
        if ([FunctionUtility systemVersionFloat] < 7.0) {
            bottomHolderY = bottomHolderY - 20;
        }
        _bottomHolderView = [self getBottomHolderViewWithFrame:CGRectMake(0, bottomHolderY, TPScreenWidth(), bottomHolderHeight)];
        if (viewType == SelectViewNormal) {
            _bottomHolderView.hidden = YES;
        }
        if (_isSpecialMode) {
            // special, delete contacts AND send sms
            _isSpecialMode = YES;
            _deleteButton.hidden = NO;
            _smsButton.hidden = NO;
            
        } else {
            // 这种模式下，显示一个按钮且按钮放在右边
            _smsButton.hidden = NO;
            UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectFinish)];
            [_smsButton addGestureRecognizer:clickRecognizer];
            [_smsButton setTitle:NSLocalizedString(@"Confirm", @"确定") forState:UIControlStateNormal];
        }
        
        // table view frame: list or search result
        CGFloat resultHeight = TPScreenHeight() - 20;
        if ([FunctionUtility systemVersionFloat] >= 7.0) {
            resultHeight = TPScreenHeight();
        }
        
        CGFloat tableViewMarginTop = 0;
        if (viewType == SelectViewGroupCommandAll) {
            tableViewMarginTop = gY;
            
        } else if (viewType == SelectViewGroupCommandGroup) {
            tableViewMarginTop = TPHeaderBarHeight();
        } else {
            tableViewMarginTop = gY;
        }
        resultHeight = resultHeight - tableViewMarginTop - bottomHolderHeight;
        frame = CGRectMake(0, tableViewMarginTop, TPScreenWidth(), TPScreenHeight() - tableViewMarginTop);
        
        // table view: search result
        search_result_view = [[SelectSearchResultView alloc] initWithArray:nil andFrame:frame];
        search_result_view.select_delegate=self;
        
        SearchType selectViewSearchType = PickerSearch;
        if ([commandName isEqualToString:NSLocalizedString(@"Contact", @"联系人")]) {
            selectViewSearchType = ContactWithPhoneSearch;
        }
        ContactSearchModel *tmpEngine = [[ContactSearchModel alloc] initWithSearchType:selectViewSearchType];
        self.search_engine = tmpEngine;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchDidFinish:)
                                                     name:N_CONTACT_SEARCH_RESULT_CHANGED object:nil];
        
        // table view: list
        content_view = [[UITableView alloc] initWithFrame:
                                         frame style:UITableViewStylePlain];
        [content_view setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        [content_view setExtraCellLineHidden];
        content_view.delegate = self;
        content_view.dataSource = self;
        content_view.rowHeight = CONTACT_CELL_HEIGHT;
        content_view.sectionHeaderHeight = 24;
        content_view.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // load all contacts
        [self onNotiPersonModelReloaded];
        
        // set section index view.
        CGFloat indexSearchHeight = TPScreenHeight() * INDEX_SECTION_VIEW_HEIGHT_PERCENT;
        CGFloat searchY = frame.origin.y + (content_view.frame.size.height - indexSearchHeight ) / 2;
        section_index_view = [[SectionIndexView alloc] initSectionIndexView:CGRectMake(TPScreenWidth() - INDEX_SECTION_VIEW_WIDTH, searchY, INDEX_SECTION_VIEW_WIDTH, indexSearchHeight)];
        section_index_view.delegate = self;
        
        // init clear view. when sectionindexview touching, show this.
        ClearView *tmp_clear = [[ClearView alloc] initWithFrame:CGRectMake(190, 120, 70, 70)];
        [tmp_clear setSkinStyleWithHost:self forStyle:[SelectView colorClearString]];
        tmp_clear.layer.masksToBounds = YES;
        tmp_clear.layer.cornerRadius = tmp_clear.frame.size.width/2;
        self.clear_view = tmp_clear;
        clear_view.alpha = 0.8;
        
        
        // view tree: self
        [self addSubview:header];
        [self addSubview:search_bar];
        [self addSubview:content_view];
        [self addSubview:_bottomHolderView];
        [self addSubview:section_index_view]; // index search bar on the right
        
        // view debug
//        [FunctionUtility setBorderForView:header color:[UIColor blueColor]];
//        [FunctionUtility setBorderForView:content_view color:[UIColor redColor]];
    }
    return self;
    
}


- (id)initWithPersonArrayAndViewTypeAndCommandName:(NSArray *)person_list_temp ViewType:(SelectViewType)type CommandName:(NSString *)operationName {
    return [self initWithPersonArrayAndViewTypeAndCommandName:person_list_temp ViewType:type CommandName:operationName andIfSingle:NO];
}

- (id)initWithPersonArray:(NSArray *)person_list_temp {
    return [self initWithPersonArrayAndViewTypeAndCommandName:person_list_temp ViewType:SelectViewNormal CommandName:@""];
}

- (void)buildContactsAndKeys{
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithCapacity:28];
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:28];
    NSMutableArray *tmpIDArray = [[NSMutableArray alloc] initWithCapacity:person_list.count];
    for(ContactCacheDataModel * item in self.person_list){
        [tmpIDArray addObject:[NSNumber numberWithLong:item.personID]];
    }
    [ContactModelNew buildIndexArray:tmpIDArray toNewContactsContainer:tmpDic andKeyContainers:tmpArray];
    
    self.contact_dic = tmpDic;
    self.keys_arr = tmpArray;
}
- (void)onNotiPersonModelReloaded {
    [self performSelectorOnMainThread:@selector(onNotiPersonModelReloadedOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)onNotiPersonModelReloadedOnMainThread {
    [self buildContactsAndKeys];
    NSArray *marr = [NSArray arrayWithObjects:@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"*", nil];
    NSMutableDictionary *section_navigate_dic = [NSMutableDictionary dictionaryWithCapacity:[marr count]];
    int section = -1;
    for (int i = 0; i < [marr count]; i++) {
        if ([keys_arr indexOfObject:[marr objectAtIndex:i]] != NSNotFound) {
            section++;
        }
        NSString *content = [marr objectAtIndex:i];
        [section_navigate_dic setObject:[NSNumber numberWithInt:(section == -1 ? 0 : section)] forKey:content];
    }
    section_index_view.hidden = section==-1 ? YES : NO;
    self.section_map = section_navigate_dic;
    [content_view reloadData];
    
}
-(void)cancelInput{
	[search_bar resignFirstResponder];
}
-(void)selectAll{
    if (!content_view.hidden) {
        if ([self allSelected]) {
            select_count = 0;
            for (SelectModel *person in [person_check_list allValues]) {
                person.isChecked=NO;
            }
        } else {
            self.select_count=[self.person_list count];
    
            for (SelectModel *person in [person_check_list allValues]) {
                person.isChecked=YES;
            }
        }
    } else {
        if ([self allSelected]) {

            for (ContractResultModel *item in search_result_view.result_arr.searchResults) {
                SelectModel *person = [person_check_list objectForKey:[NSNumber numberWithInt:item.personID]];
                
                select_count -= 1;
                person.isChecked = NO;
            }
        } else {
            for (ContractResultModel *item in search_result_view.result_arr.searchResults) {
                SelectModel *person = [person_check_list objectForKey:[NSNumber numberWithInt:item.personID]];
                if (!person.isChecked) {
                    select_count += 1;
                    person.isChecked = YES;
                }
            }

        }
    }
    [content_view reloadData];
    [search_result_view.m_tableview reloadData];
    [self checkAllButtonTitle];
    
    [self updateStateForButtons:select_count];
}

- (BOOL)allSelected {
    if (!content_view.hidden) {
        if (self.select_count==[self.person_list count]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        for (ContractResultModel *item in search_result_view.result_arr.searchResults) {
            SelectModel *person = [person_check_list objectForKey:[NSNumber numberWithInt:item.personID]];
            if (!person.isChecked) {
                return NO;
            }
        }
        return YES;
    }
}

- (void)checkAllButtonTitle {
    [selectAllButton setTitle:([self allSelected]) ?  NSLocalizedString(@"Unselect_all",@"") : NSLocalizedString(@"Select_all",@"") forState:UIControlStateNormal];
}

-(void)selectCancel{
	[select_view_delegate selectViewCancel];
}

-(void)selectFinish
{
	NSMutableArray *select_list_back=[[NSMutableArray alloc] init];
	for (SelectModel *item in [person_check_list allValues]) {
		if(item.isChecked) {
			[select_list_back addObject:[NSNumber numberWithInt:item.personID]];
		}
	}
    if([select_view_delegate respondsToSelector:@selector(selectViewFinish:)]){
        [select_view_delegate selectViewFinish:select_list_back];
    }
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keys_arr count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 23)];
    holderView.backgroundColor = [UIColor clearColor];
    
    CGRect contentFrame = CGRectMake(0, 0, TPScreenWidth() - INDEX_SECTION_VIEW_WIDTH, 23);
    // user contentView
    UIView *userContentView = [[UIView alloc] initWithFrame:contentFrame];
    userContentView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellHeaderBG_color"];
    
    // index label
    UILabel *indexLabel = [[UILabel alloc] initWithFrame:holderView.frame];
    indexLabel.font = [UIFont systemFontOfSize:14];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.text = [keys_arr objectAtIndex:section];
    indexLabel.textColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
    [FunctionUtility setXOffset:15 forView:indexLabel];
    
    // view tree
    [userContentView addSubview:indexLabel];
    
    [holderView addSubview:userContentView];
    
	return holderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[contact_dic objectForKey:[keys_arr objectAtIndex:section]] count];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifierForSelectView = @"SelectView";
    SelectCellView *cell = (SelectCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierForSelectView];
    if (cell == nil) {
        cell = [[SelectCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForSelectView];
        [cell setSkinStyleWithHost:self forStyle:@"searchResultView_cell_style"];
    }
    [cell hideBottomLine];
    if ((int)[indexPath row]+1 == (int)[tableView numberOfRowsInSection:[indexPath section]]) {
        [cell hideBottomLine];
    } else {
        [cell showBottomLine];
    }
    
	int section = [indexPath section];
	int row = [indexPath row];
	if ([keys_arr count] >0 &&[contact_dic  count]>0) {
        ContactCacheDataModel* item = (ContactCacheDataModel *)([[contact_dic objectForKey:[keys_arr objectAtIndex:section]] objectAtIndex:row]);
        [cell refreshDefault:item withIsCheck:[self isSelectedPerson:item.personID]];
         cell.select_delegate=self;
	}
    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self willSelectView];
	return indexPath;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 	return [keys_arr objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectCellView *cell = (SelectCellView *)[tableView cellForRowAtIndexPath:indexPath];
	[cell setCheckImage];
}

#pragma mark SelectViewProtocalDelegate
-(void)willSelectView{
    [search_bar resignFirstResponder];
}

-(void)selectItem:(SelectModel *)select_item{
    if (_isChooseSingle){
        [select_view_delegate selectItem:select_item];
        return;
    }
    
	SelectModel *item=[person_check_list objectForKey:[NSNumber numberWithInt:select_item.personID]];
	if (item) {
		item.isChecked=select_item.isChecked;
		if (item.isChecked) {
			select_count=select_count+1;
		}
		else {
			if(select_count>0)
			{
				select_count=select_count-1;
			}
		}
	}
    if (viewType == SelectViewNormal) {
        self.middle_digit.text=[NSString stringWithFormat:NSLocalizedString(@"%d selected",@""),select_count];
    } else {
        [operationButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Confirm (%d)",@""),select_count] forState:UIControlStateNormal];
    }
    [self updateStateForButtons:select_count];
    
    [self checkAllButtonTitle];
    [content_view reloadData];
}

-(BOOL)isSelectedPerson:(NSInteger)personID
{
	SelectModel *select=[person_check_list objectForKey:[NSNumber numberWithInt:personID]];
	if (select) {
		return select.isChecked;
	}else {
		return NO;
	}
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[search_bar resignFirstResponder];
}

#pragma mark searchbar delegate methods.
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [search_bar showBorder];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [search_bar hideBorder];
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[search_bar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if (searchText == nil || [searchText length] == 0 || [searchText length] > SEARCH_INPUT_MAX_LENGTH) {
		search_result_view.hidden=YES;
		content_view.hidden=NO;
        section_index_view.hidden = NO;
		[search_result_view refreshMyResult:nil];
	} else {
		[search_engine query:searchText];
	}
    [self checkAllButtonTitle];
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    search_bar.text = @"";
	[search_result_view refreshMyResult:nil];
	search_result_view.hidden=YES;
	section_index_view.hidden = NO;
	content_view.hidden=NO;
    [self checkAllButtonTitle];
}
- (void)searchDidFinish:(id)tmpArray{

    SearchResultModel *result_arr = [[tmpArray userInfo] objectForKey:KEY_RESULT_LIST_CHANGED];
    cootek_log(@"sresult array count is %d", [result_arr.searchResults count]);
    if ([search_bar.text length] == 0 ||
        (result_arr.searchType != PickerSearch && result_arr.searchType != ContactWithPhoneSearch) ||
        ![search_bar.text isEqualToString:result_arr.searchKey]){
        return;
    }
    
    NSMutableArray *searchResults = [NSMutableArray array];
    
    for (int i = 0; i < result_arr.searchResults.count; i++) {
        ContractResultModel *resultModel = result_arr.searchResults[i];
        
        NSNumber *personID = [NSNumber numberWithInteger:resultModel.personID];
        if ([self.personListMap objectForKey:personID]) {
            [searchResults addObject:resultModel];
        }
        
        
   }
    
    result_arr.searchResults = searchResults;
    
    if (![search_result_view isDescendantOfView:self])
    {
       [self addSubview:search_result_view];
    }
    NSMutableArray *filterSearchResultArr = [NSMutableArray array];
    for (ContractResultModel *item in result_arr.searchResults) {
        BOOL inGroup = NO;
        NSArray *groupIds = [ContactGroupDBA getMemberGroups:item.personID];
        for (NSString *groupId in groupIds) {
            if (self.groupId == [groupId intValue]) {
                inGroup = YES;
            }
        }
        if (!inGroup) {
            [filterSearchResultArr addObject:item];
        }
    }
    SearchResultModel *filterResult = [[SearchResultModel alloc]init];
    filterResult.searchKey = result_arr.searchKey;
    filterResult.searchType = result_arr.searchType;
    filterResult.searchResults = filterSearchResultArr;
    [search_result_view refreshMyResult:filterResult];
    content_view.hidden=YES;
    search_result_view.hidden=NO;
    section_index_view.hidden = YES;
    [self checkAllButtonTitle];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[search_bar resignFirstResponder];
	 search_bar.text = @"";
	[search_result_view refreshMyResult:nil];
	search_result_view.hidden=YES;
	section_index_view.hidden = NO;
	content_view.hidden=NO;
    [self checkAllButtonTitle];
}

#pragma mark views 
- (TPUIButton *) getButtonWithFrame:(CGRect)frame contentEdgeInsets:(UIEdgeInsets)edgeInset title:(NSString *)title {
    
    TPUIButton *btn = [TPUIButton  buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.contentEdgeInsets = edgeInset;
    btn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    btn.enabled = NO;
    [btn setBackgroundColor:[UIColor clearColor]];
    return btn;
}

- (UIView *) getBottomHolderViewWithFrame:(CGRect)frame {
    UIView *holderView = [[UIView alloc] initWithFrame:frame];
    holderView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"selectViewButtonColor_normal_color"];
    
    // top border line
    CGFloat lineHeight = 0.5;
    UILabel *topBorderLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, lineHeight)];
    [FunctionUtility setHeight:0.5 forView:topBorderLine];
    topBorderLine.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
    
    CGSize btnSize = CGSizeMake(100, frame.size.height);
    
    // batch delete, 批量删除
    CGRect deleteFrame =  CGRectMake(0, 0, btnSize.width, btnSize.height);
    UIEdgeInsets deleteInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    _deleteButton = [self getButtonWithFrame:deleteFrame contentEdgeInsets:deleteInsets title:@"删除"];
    _deleteButton.hidden = YES;
    
    // send SMS, 发短信
    CGRect smsFrame = CGRectMake(TPScreenWidth() - btnSize.width, 0, btnSize.width, btnSize.height);
    UIEdgeInsets smsInsets = UIEdgeInsetsMake(0, 15, 0, 15);
    _smsButton = [self getButtonWithFrame:smsFrame contentEdgeInsets:smsInsets title:@"发短信"];
    _smsButton.hidden = YES;
    
    // selected count, 选中的个数
    CGRect selectedFrame = CGRectMake((TPScreenWidth() - btnSize.width) / 2, 0, btnSize.width, btnSize.height);
    UIEdgeInsets selectedInsets = UIEdgeInsetsZero;
    _selectedButton = [self getButtonWithFrame:selectedFrame contentEdgeInsets:selectedInsets title:nil];
    _selectedButton.userInteractionEnabled = NO;
    
    // view actions
    if (_isSpecialMode) {
        [_deleteButton addTarget:self action:@selector(selectFinish) forControlEvents:UIControlEventTouchUpInside];
        [_smsButton addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // view settings
    _deleteButton.backgroundColor = [UIColor clearColor];
    _selectedButton.backgroundColor = [UIColor clearColor];
    _smsButton.backgroundColor = [UIColor clearColor];
    [self setColorsBySytlePrefix:[SelectView colorString] forButtons:@[_deleteButton, _selectedButton, _smsButton]];
    
    [self updateStateForButtons:0];
    
    // view tree
    [holderView addSubview:topBorderLine];
    [holderView addSubview:_deleteButton];
    [holderView addSubview:_selectedButton];
    [holderView addSubview:_smsButton];
    
    return holderView;
}

- (void) setColorsBySytlePrefix:(NSString *)prefix forButtons:(NSArray *)buttons {
    for(TPUIButton *button in buttons) {
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            NSString *normalStyle =  prefix;
            NSString *disabledStyle = [NSString stringWithFormat:@"%@_disable_color", prefix];
            
            [button setTitleColor:[TPDialerResourceManager getColorForStyle:normalStyle] forState:UIControlStateNormal];
            [button setTitleColor:[[TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"] colorWithAlphaComponent:.3] forState:UIControlStateDisabled];

        }else{
            NSString *normalStyle = [NSString stringWithFormat:@"%@_normal_color", prefix];
            NSString *pressedStyle = [NSString stringWithFormat:@"%@_pressed_color", prefix];
            NSString *disabledStyle = [NSString stringWithFormat:@"%@_disable_color", prefix];
            
            [button setTitleColor:[TPDialerResourceManager getColorForStyle:normalStyle] forState:UIControlStateNormal];
            [button setTitleColor:[TPDialerResourceManager getColorForStyle:pressedStyle] forState:UIControlStateHighlighted];
            [button setTitleColor:[TPDialerResourceManager getColorForStyle:disabledStyle] forState:UIControlStateDisabled];

        }
        
    }
   
}

#pragma mark logics
- (void) updateStateForButtons:(NSInteger)selectedCount {
    BOOL selected = selectedCount > 0;
    _deleteButton.enabled = selected;
    _smsButton.enabled = selected;
    _selectedButton.enabled = selected;
    
    if (selectedCount < 0) {
        selectedCount = 0;
    }
    NSString *selectedString = [NSString stringWithFormat:@"（%d）", selectedCount];
    [_selectedButton setTitle:selectedString forState:UIControlStateDisabled];
    [_selectedButton setTitle:selectedString forState:UIControlStateNormal];
    [_selectedButton setTitle:selectedString forState:UIControlStateHighlighted];
}

#pragma mark actions
- (void) sendSMS {
    NSMutableArray *select_list_back = [[NSMutableArray alloc] init];
    for (SelectModel *item in [person_check_list allValues]) {
        if(item.isChecked) {
            [select_list_back addObject:[NSNumber numberWithInt:item.personID]];
        }
    }
    GroupSendSMSCommand *sendSMSCommand = (GroupSendSMSCommand *)[GroupOperationCommandCreator commandForType:CommandTypeSendSMS withData:nil];
    if ([sendSMSCommand respondsToSelector:@selector(selectViewFinish:)]) {
        [sendSMSCommand performSelector:@selector(selectViewFinish:) withObject:select_list_back];
    }
}

#pragma mark SectionIndexDelegate

- (void)addClearView {
	[self addSubview:clear_view];
}
- (void)move:(double)top{   
    clear_view.frame = CGRectMake(clear_view.frame.origin.x, top,clear_view.frame.size.width , clear_view.frame.size.height);
}
- (void)beginNavigateSection:(NSString *)section_key{
	[search_bar resignFirstResponder];
    if (0 == [keys_arr count]) {
        return;
    }
	cootek_log(@"init section key is %@", section_key);
	NSNumber *section_number = [section_map objectForKey:section_key];
	cootek_log(@"section number is %d", [section_number intValue]);
	
	NSIndexPath *mpath = [NSIndexPath indexPathForRow:0 inSection:[section_number intValue]];
	[content_view scrollToRowAtIndexPath:mpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
	[clear_view setSectionKey:[keys_arr objectAtIndex:[section_number intValue]]];
}

- (void)endNavigateSection {
	cootek_log(@"end navigation section.");
	[clear_view removeFromSuperview];
}

+ (NSString *)colorString {
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return @"skinSectionIndexPopupBackground_color";
    }else{
        return @"selectViewButtonTitleColor";
    }
}


+ (NSString *)colorClearString {
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        return @"skinSectionIndexPopupBackground_color";
    }else{
        return @"ClearViewBackground_color";
    }
}
- (void)dealloc {
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter]  removeObserver:self];
}



@end
