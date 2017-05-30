    //
//  SearchResultViewController.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/29/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "SearchResultViewController.h"
#import "consts.h"
#import "ContactPropertyCacheManager.h"
#import "ContactSearchModel.h"
#import "ContactSearchResultCell.h"
#import "TouchPalDialerAppDelegate.h"
#import "CootekNotifications.h"
#import "ContactModelNew.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "TPDialerResourceManager.h"
#import "UITableView+TP.h"
#import "ContactInfoManager.h"
#import "RootScrollViewController.h"
#import "FunctionUtility.h"

@interface SearchResultViewController() {
//    LongGestureController *longGestureController_;
}
@property (nonatomic, retain) ContactSearchResultCell *longModeCell;
@end

@implementation SearchResultViewController
@synthesize m_tableview, result_arr, delegate;
@synthesize CellIdentifier;
@synthesize longGestureController = longGestureController_;

- (void)refreshMyResult:(SearchResultModel *)result {
	self.result_arr = result;
    [longGestureController_ exitLongGestureMode];
	[m_tableview reloadData];
}

- (void)refreshView{
    [m_tableview reloadData];
}

- (void)viewDidLoad {
	cootek_log(@"search result view controller will did load.");
    [super viewDidLoad];
    
	UITableView *tmp_view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(320)) style:UITableViewStylePlain];
    [tmp_view setExtraCellLineHidden];
    [tmp_view setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
	self.m_tableview = tmp_view;
	m_tableview.delegate = self;
	m_tableview.dataSource = self;
//    m_tableview.rowHeight = 50;
    m_tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_tableview.frame = CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(320));
	[self.view addSubview:m_tableview];
    
	self.view.frame = CGRectMake(0, TPHeaderBarHeight() - TPHeaderBarHeightDiff(), TPScreenWidth(), TPHeightFit(320));
	[self registerPersonDataChangeNotification];
    
    longGestureController_ = [[LongGestureController alloc] initWithViewController:((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController
                                                                         tableView:m_tableview
                                                                          delegate:self
                                                                     supportedType:LongGestureSupportedTypeSearchContactResult];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    recognizer.delegate = self;
    [m_tableview addGestureRecognizer:recognizer];
    
    self.view.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];

    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in SearchResultViewController.");
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self unregisterPersonDataChangeNotification];
}

- (void)dealloc {
    for (UITapGestureRecognizer *gesture in [m_tableview gestureRecognizers]) {
        [m_tableview removeGestureRecognizer:gesture];
    }
    [longGestureController_ tearDown];
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare:indexPath] == NSOrderedSame) {
        return CONTACT_CELL_HEIGHT * 2;
    } else {
        return CONTACT_CELL_HEIGHT;
    }
}

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
   if(result_arr.searchResults == nil)
        return nil;
	int row = [indexPath row];
	ContractResultModel* item = [result_arr.searchResults objectAtIndex:row];
    ContactSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ContactSearchResultCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier withContactData:item];
    } else {
        [cell updateData:item];
    }
    cell.operViewCon.hidden = YES;
    if ( [longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare: indexPath] == NSOrderedSame) {
        [cell.operViewCon addSubview:longGestureController_.operView.bottomView];
        cell.operViewCon.hidden = NO;
        [cell showAnimation];
        self.longModeCell = cell;
    }

    TPUIButton *photoButton = [[TPUIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 50)];
    photoButton.backgroundColor = [UIColor clearColor];
    [cell addSubview:photoButton];
    photoButton.titleLabel.text =  [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    [photoButton addTarget:self action:@selector(showOperView:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)showOperView:(UIButton *)sender {
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    } else {
        NSArray *tmp = [sender.titleLabel.text componentsSeparatedByString:@":"];
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[tmp[1] integerValue] inSection:[tmp[0] integerValue]];
        NSArray *indexPathArray = [m_tableview indexPathsForVisibleRows];
        for (int i = [indexPathArray count]-1; i >= [indexPathArray count]-2; i --) {
            if ([currentIndex compare:indexPathArray[i]] == NSOrderedSame) {
                longGestureController_.showScrollToShow = YES;
                break;
            }
        }
        longGestureController_.currentSelectIndexPath = currentIndex;
        [longGestureController_ enterLongGestureMode];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
    if(row > result_arr.searchResults.count-1){
        return;
    }
    ContractResultModel* item = [result_arr.searchResults objectAtIndex:row];
	NSInteger person_id=item.personID;
    
	if(![longGestureController_ inLongGestureMode]){
         if (person_id > 0) {
             [[ContactInfoManager instance] showContactInfoByPersonId:person_id];
         }
     }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
	// resign the keyboard.
	[delegate resignKeyboard];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewWrapperView"]) {
        return YES;
    }
    return  NO;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {
    
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    
}

-(void)doWhenPersonChanged:(id)personChange{
    [self performSelectorOnMainThread:@selector(doWhenPersonChangedOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)doWhenPersonChangedOnMainThread {
	[delegate research];
}

- (void)registerPersonDataChangeNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenPersonChanged:) name:N_PERSON_DATA_CHANGED object:nil];
}

- (void)unregisterPersonDataChangeNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:N_PERSON_DATA_CHANGED  object:nil];
}

#pragma  mark Enter_or_exit_multiselect_mode
- (void)enterLongGestureMode{
    [delegate resignKeyboard];
    if (longGestureController_.showScrollToShow) {
        longGestureController_.showScrollToShow = NO;
        [m_tableview scrollToRowAtIndexPath:longGestureController_.currentSelectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [m_tableview reloadData];
}

- (void)exitLongGestureMode{
    [self.longModeCell exitAnimation];
    [m_tableview reloadData];
}

@end
