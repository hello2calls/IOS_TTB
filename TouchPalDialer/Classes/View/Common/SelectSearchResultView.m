//
//  SelectSearchResultView.m
//  TouchPalDialer
//
//  Created by Alice on 11-8-24.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SelectSearchResultView.h"
#import "ContractResultModel.h"
#import "SelectCellView.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "UITableView+TP.h"
#import "TPDialerResourceManager.h"
#import "AllViewController.h"

@implementation SelectSearchResultView

@synthesize m_tableview;
@synthesize result_arr;
@synthesize select_delegate;
@synthesize isSingleCheckMode;


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkinTheme) name:N_SKIN_DID_CHANGE object:nil];
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    }
    return self;
}

- (void)changeSkinTheme
{
    self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    [self.m_tableview setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
}

- (id)initWithArray:(SearchResultModel *)result_list{
    self = [super initWithFrame:CGRectMake(0,89,TPScreenWidth(),TPHeightFit(371))];
    if (self) {
		self.result_arr=result_list;
		UITableView *tmp_view = [[UITableView alloc] initWithFrame:
                                 CGRectMake(0,0,TPScreenWidth(),TPHeightFit(371)) style:UITableViewStylePlain];
        [tmp_view setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        [tmp_view setExtraCellLineHidden];
		self.m_tableview = tmp_view;
		m_tableview.delegate = self;
		m_tableview.dataSource = self;
        m_tableview.rowHeight = CONTACT_CELL_HEIGHT;
        m_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self addSubview:m_tableview];
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    }
    return self;
}

- (id)initWithArray:(SearchResultModel *)result_list andFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
		self.result_arr=result_list;
        // Initialization code.
		UITableView *tmp_view = [[UITableView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)
                                                             style:UITableViewStylePlain];
        [tmp_view setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        [tmp_view setExtraCellLineHidden];
		self.m_tableview = tmp_view;
		m_tableview.delegate = self;
		m_tableview.dataSource = self;
        m_tableview.rowHeight = CONTACT_CELL_HEIGHT;
        m_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
		[self addSubview:m_tableview];
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    }
    return self;
}
- (void)refreshMyResult:(SearchResultModel *)result {
	self.result_arr = result;
	[m_tableview reloadData];
}

- (void)refreshView{
    [m_tableview reloadData];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[select_delegate cancelInput];
}
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (result_arr.searchResults == nil) {
		return 0;
	} else {
		return [result_arr.searchResults count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifierForSelectView = @"cell_search_select";
	
	int row = [indexPath row];
	ContractResultModel* item = [result_arr.searchResults objectAtIndex:row];
	
	SelectCellView *cell = (SelectCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierForSelectView];
    if (cell == nil) {
        cell = [[SelectCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForSelectView];
        [cell setSkinStyleWithHost:self forStyle:@"searchResultView_cell_style"];
//        cell.showPartBottomLine = YES;
    }
//    CGRect oldFrame = cell.contentView.frame;
//    cell.userContentView.frame = CGRectMake(7, 0, TPScreenWidth(), CELL_HEIGHT);
	
    BOOL isCheck = [self isSelectedPersonInSearch:item.personID withObject:cell];
	cell.select_delegate=self;
    cell.isSingleCheckMode = isSingleCheckMode;
    [cell refreshSearchData:item withIsCheck:isCheck];	
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectCellView *cell = (SelectCellView *)[tableView cellForRowAtIndexPath:indexPath];
	[cell setCheckImage];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (select_delegate && [select_delegate respondsToSelector:@selector(willSelectView)]) {
        [select_delegate willSelectView];

    }
    return indexPath;
}

#pragma mark SelectViewProtocalDelegate
-(BOOL)isSelectedPersonInSearch:(NSInteger)personID withObject:(id)object
{
    if (isSingleCheckMode) {
        return [select_delegate isSelectedPerson:personID withObject:object];
    }else {
        return [select_delegate isSelectedPerson:personID];
    }
}

-(void)selectItem:(SelectModel *)select_item
{
	[select_delegate selectItem:select_item];
}
-(void)selectItem:(SelectModel *)select_item withObject:(id)object{
    [select_delegate selectItem:select_item withObject:object];
}
- (void)dealloc {
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
