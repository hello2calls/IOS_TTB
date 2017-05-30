//
//  GesturePersonPickerViewController.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-5-29.
//  Copyright (c) 2012Âπ?__MyCompanyName__. All rights reserved.
//

#import "GesturePersonPickerViewController.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "SelectCellView.h"
#import "ContactCacheDataManager.h"
#import "GestureEditViewController.h"
#import "GestureActionPickerViewController.h"
#import "ContactSort.h"
#import "ContactSearchModel.h"
#import "CootekNotifications.h"
#import "ContactPropertyCacheManager.h"
#import "GestureUtility.h"
#import "CallLogDataModel.h"
#import "TPDialerResourceManager.h"
#import "SkinHandler.h"
#import "GestureSelectCell.h"
#import "UITableView+TP.h"
#import "NSString+PhoneNumber.h"
#import "Person.h"
#import "VoipUtils.h"
#import "ContactItemCell.h"
#import "UserDefaultsManager.h"
#define OFTEN_CONTACTS_PERSON_COUNT 5

#define SECTION_OFTEN_CONTACT_INDEX 0
#define SECTION_ALL_CONTACT_INDEX   1

@interface GesturePersonPickerViewController (){
    SelectSearchResultView *searchResultView;
    TPHeaderButton *tmpOk;
    BOOL shouldPopToRoot_;
}
@end

@implementation GesturePersonPickerViewController

@synthesize m_searchbar;
@synthesize m_contentView;
@synthesize selectItem;
@synthesize personList;
@synthesize actionKey;
@synthesize preTableViewCell;
@synthesize searchEngine;
@synthesize oftenContactsList;

- (id)initWithPopToRoot:(BOOL)shouldPopToRoot;
{
    self = [super init];
    if (self) {
        shouldPopToRoot_ = shouldPopToRoot;
    }
    return self;
}

- (void) loadView
{
    UIView *emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight())];
	emptyview.backgroundColor = [UIColor clearColor];
	self.view = emptyview;
    
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    
    //HeaderBar
    HeaderBar* headBar = [[HeaderBar alloc] initHeaderBar] ;
    [headBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headBar];
    
    UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
    [headerTitle setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    headerTitle.font = [UIFont systemFontOfSize:CELL_FONT_XTITLE];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = NSLocalizedString(@"Choose a contact", @"");
	[headBar addSubview:headerTitle];
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];

    if(isVersionSix) {
        // back button
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        backBtn.autoresizingMask = UIViewAutoresizingNone;
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:backBtn];
        
        headerTitle.textColor = [TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"];
    
    } else {
        // back button
        TPHeaderButton *back_but = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [back_but setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [back_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:back_but];

        
    }

    
    // search bar
	TPUISearchBar *tmpSearchBar = [[TPUISearchBar alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), 45)];
	self.m_searchbar = tmpSearchBar;
    [m_searchbar setSkinStyleWithHost:self forStyle:@"TPUISearchBar_default_style"];
	self.m_searchbar.delegate = self;
    self.m_searchbar.placeholder = NSLocalizedString(@"search", @"");
	[self.view addSubview:self.m_searchbar];
    
    UITableView *tmp_view_content = [[UITableView alloc] initWithFrame:
                                     CGRectMake(0, 90+TPHeaderBarHeightDiff(), TPScreenWidth(), TPHeightFit(370)) style:UITableViewStylePlain];
    [tmp_view_content setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
    [tmp_view_content setExtraCellLineHidden];
	self.m_contentView = tmp_view_content;
	self.m_contentView.delegate = self;
	self.m_contentView.dataSource = self;
    self.m_contentView.rowHeight = CONTACT_CELL_HEIGHT;
    self.m_contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.m_contentView.sectionHeaderHeight = 23;
	[self.view addSubview:self.m_contentView];
    
    searchResultView = [[SelectSearchResultView alloc] initWithArray:nil andFrame:
                        CGRectMake(0, 90+TPHeaderBarHeightDiff(), TPScreenWidth(), TPHeightFit(370))];
    searchResultView.select_delegate = self;
    searchResultView.isSingleCheckMode = YES;
    
    ContactSearchModel *tmpEngine = [[ContactSearchModel alloc] initWithSearchType:GestureSearch];
    self.searchEngine = tmpEngine;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchDidFinish:)
                                                 name:N_CONTACT_SEARCH_RESULT_CHANGED object:nil];
    
}

-(void)okFinish
{
    NSString *key = [GestureUtility serializerName:selectItem.number withPersonID:selectItem.personID withAction:actionKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_PERSON_SELECTED object:key];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //data
    NSMutableArray *tmpNumberArray = [NSMutableArray arrayWithCapacity:1] ;
    NSArray *tmpArray = [Person queryAllContacts];
    for (int i=0;i<[tmpArray count];i++) {
        ContactCacheDataModel *item = [tmpArray objectAtIndex:i];
        int count = [item.phones count];
        if ( count > 0) {
            if([item.fullName isEqualToString:VOIP_CALL_NAME]){
                continue;
            }
            for (int i =0; i< count; i++) {
                ContactCacheDataModel *tmpItem = [[ContactCacheDataModel alloc] init];
                tmpItem.personID = item.personID;
                tmpItem.displayName = item.displayName;
                tmpItem.fullName = item.fullName;
                tmpItem.number = [[item.phones objectAtIndex:i] number];
                if ([self isForGesture:tmpItem]) {
                    [tmpNumberArray addObject:tmpItem];
                }
            }
        }
    }
    self.personList = [ContactSort sortContactByFirstLetter:tmpNumberArray itemType:ContactItemTypeContactCacheDataModel];
    
    NSMutableArray *contactsArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *call_list = [GestureUtility getOftenContactsList];
    for (int i =0 ; i< OFTEN_CONTACTS_PERSON_COUNT && i<[call_list count]; i++) {
        CallLogDataModel *item = [call_list objectAtIndex:i];
        ContactCacheDataModel *tmpItem = [[ContactCacheDataModel alloc] init];
        tmpItem.personID = item.personID;
        tmpItem.displayName = item.name;
        tmpItem.fullName = item.name;
        tmpItem.number = item.number;
        ContactCacheDataModel *itemPerson = [[ContactCacheDataManager instance] contactCacheItem:item.personID];
        for (int j = 0; j<[itemPerson.phones count]; j++) {
            PhoneDataModel *model = [itemPerson.phones objectAtIndex:j];
            NSString *number = [model number];
            if ([[item.number digitNumber] hasSuffix:[number digitNumber]]
                || [[number digitNumber] hasSuffix:[item.number  digitNumber]]) {
                tmpItem.number = number;
            }
        }
        if ([self isForGesture:tmpItem]) {
            [contactsArray addObject:tmpItem];
        }
    }
    self.oftenContactsList  = contactsArray;
    cootek_log(@"********personCount = %d",[self.personList count]);
}

- (BOOL)isForGesture: (ContactCacheDataModel *)item
{
    NSRange range1 = [item.number rangeOfString:@";"];
    NSRange range2 = [item.number rangeOfString:@","];
    NSRange range3 = [item.number rangeOfString:@"；"];
    NSRange range4 = [item.number rangeOfString:@"，"];
    if ((range1.location == NSNotFound) && (range2.location == NSNotFound) &&
        (range3.location == NSNotFound) && (range4.location == NSNotFound)) {
        return YES;
    } else {
        return NO;
    }
}
- (void)sort:(NSArray *)tmpNumberArray{
    @autoreleasepool {
        [ContactSort sortContactByFirstLetter:tmpNumberArray itemType:ContactItemTypeContactCacheDataModel];
        
        [self performSelectorOnMainThread:@selector(reloadTable:) withObject:tmpNumberArray waitUntilDone:NO];
    }
}
-(void)reloadTable:(NSArray *)tmpNumberArray{
    self.personList = tmpNumberArray;
    [self.m_contentView reloadData];
}
- (void)gotoBack{
	[self.navigationController popViewControllerAnimated:YES];
}
#pragma UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int section = 0;
    if ([self.personList count] > 0) {
        section = section +1;
    }
    if ([self.oftenContactsList count] > 0) {
        section = section +1;
    }
    return section;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	UIImageView *tmpview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 23)];
	[tmpview setBackgroundColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellHeaderBG_color"]];
	
	UILabel *mlabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, TPScreenWidth(), 18)];
    mlabel.font = [UIFont systemFontOfSize:14];
	mlabel.backgroundColor = [UIColor clearColor];
    mlabel.textColor =[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"contactCellSectionHeader_color"];
    
    switch (section) {
        case SECTION_OFTEN_CONTACT_INDEX:
        {
            if ([self.oftenContactsList count] > 0){
                mlabel.text = NSLocalizedString(@"Frequent contacts",@"");
            }else {
                mlabel.text = NSLocalizedString(@"All contacts",@"");
            }
            break;
        }
        case SECTION_ALL_CONTACT_INDEX:
        {
            mlabel.text = NSLocalizedString(@"All contacts",@"");
            break;
        }
        default:
            break;
    }
	
	[tmpview addSubview:mlabel];
    return tmpview;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_OFTEN_CONTACT_INDEX && [self.oftenContactsList count] > 0) {
        return [self.oftenContactsList count];
    }
    return [self.personList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifierForSelectView = @"Cell_selectView";
    SelectCellView *cell = (SelectCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierForSelectView];
    if (cell == nil) {
        cell = [[GestureSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForSelectView];
        [cell setSkinStyleWithHost:self forStyle:@"searchResultView_cell_style"];
    }
    cell.isSingleCheckMode = YES;
    cell.select_delegate=self;
    
	int row = [indexPath row];
    int section = [indexPath section];
    ContactCacheDataModel* item = nil;
    if (section == SECTION_OFTEN_CONTACT_INDEX && [self.oftenContactsList count] > 0) {
        item = [self.oftenContactsList objectAtIndex:row];
    }else {
        item = [self.personList objectAtIndex:row];
    }
    [cell refreshDefault:item withIsCheck:[self isSelectedPerson:item.personID withObject:cell] isShowNumber:YES];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectCellView *cell = (SelectCellView *)[tableView cellForRowAtIndexPath:indexPath];
	[cell setCheckImage];
}

#pragma mark searchBar_delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText == nil || [searchText length] == 0 || [searchText length] > SEARCH_INPUT_MAX_LENGTH) {
		[searchResultView refreshMyResult:nil];
		[searchResultView removeFromSuperview];
	} else {
		[self.searchEngine query:searchBar.text];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
    searchBar.text = @"";
	[searchResultView refreshMyResult:nil];
    [searchResultView removeFromSuperview];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [m_searchbar showBorder];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [m_searchbar hideBorder];
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.m_searchbar resignFirstResponder];
}
#pragma mark SelectViewProtocalDelegate
-(void)selectItem:(SelectModel *)select_item withObject:(id)object{
    if(select_item.isChecked == YES){
        tmpOk.enabled = YES;
    }else {
        tmpOk.enabled = NO;
    }
    
    if (![self isForGesture:(ContactCacheDataModel *) select_item] ) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:NSLocalizedString(@"cannot add gesture", @"")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                              otherButtonTitles:nil,
                              nil];
        
        [alert show];
    } else {
        self.selectItem = select_item;
        [self okFinish];
    }
    
    
}
-(BOOL)isSelectedPerson:(NSInteger)personID withObject:(id)object
{
    SelectCellView *currentCell = (SelectCellView *)object;
	if (selectItem.personID == personID) {
        if (selectItem.isChecked) {
            self.preTableViewCell = currentCell;
        }
		return selectItem.isChecked;
	}else {
		return NO;
	}
}
-(void)cancelInput{
	[self.m_searchbar resignFirstResponder];
}
//When searchEngine did Finish
- (void)searchDidFinish:(id)tmpArray{
    SearchResultModel *searchResult = [[tmpArray userInfo] objectForKey:KEY_RESULT_LIST_CHANGED];
    if ([self.m_searchbar.text length] == 0 ||
        searchResult.searchType != GestureSearch ||
        ![self.m_searchbar.text isEqualToString:searchResult.searchKey]){
        return;
    }
    cootek_log(@"sresult array count is = %d,=%@", [searchResult.searchResults count],searchResult.searchKey);
    if (![searchResultView isDescendantOfView:self.view])
    {
        [self.view addSubview:searchResultView];
    }
    [searchResultView refreshMyResult:searchResult];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)dealloc{
    [SkinHandler removeRecursively:self];
}
@end
