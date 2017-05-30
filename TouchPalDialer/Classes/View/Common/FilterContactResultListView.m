//
//  ContactContainersForExpandableCellView.m
//  TouchPalDialer
//
//  Created by Liangxiu on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterContactResultListView.h"
#import "SkinHandler.h"
#import "ContactItemCell.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "LeafNode.h"
#import "UITableView+TP.h"
#import "ContactInfoManager.h"
#import "CootekNotifications.h"
#import "RootScrollViewController.h"
#import "FunctionUtility.h"

@interface FilterContactResultListView() {
//    LongGestureController *longGestureController_;
}
@property (nonatomic, retain) BaseContactCell *longModeCell;
@end

@implementation FilterContactResultListView
@synthesize datas = datas_;
@synthesize m_tableview;
@synthesize CellIdentifier;
@synthesize titleLabel;
@synthesize longGestureController = longGestureController_;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITableView *tmp_view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        [tmp_view setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];
        [tmp_view setExtraCellLineHidden];
        tmp_view.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.m_tableview = tmp_view;
        m_tableview.delegate = self;
        m_tableview.dataSource = self;
        [self addSubview:m_tableview];
        
        longGestureController_ = [[LongGestureController alloc] initWithViewController:((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController
                                                                             tableView:m_tableview
                                                                              delegate:self
                                                                         supportedType:LongGestureSupportedTypeFilterContactResult];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        recognizer.delegate = self;
        [m_tableview addGestureRecognizer:recognizer];
        RootScrollViewController *ctl = [((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers objectAtIndex:0];
        ctl.filterViewController = self;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkinTheme) name:N_SKIN_DID_CHANGE object:nil];
        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
    }
    return self;
    
}


- (void)changeSkinTheme
{
    self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultBackground_color"];
}

- (void)dealloc
{
    
    for (UITapGestureRecognizer *gesture in [m_tableview gestureRecognizers]) {
        [m_tableview removeGestureRecognizer:gesture];
    }
    [longGestureController_ tearDown];
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare:indexPath] == NSOrderedSame) {
        return CONTACT_CELL_HEIGHT * 2;
    } else {
        return CONTACT_CELL_HEIGHT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return datas_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(datas_.count==0)
        return nil;
    
	int row = [indexPath row];
	long contactId = [((NSNumber *)[datas_ objectAtIndex:row]) longValue];
	
    ContactCacheDataModel* cachePersonData = [[ContactCacheDataManager instance] contactCacheItem:contactId];
    ContactItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ContactItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier
                                              personId:cachePersonData.personID
                                       isRequiredCheck:NO
                                          withDelegate:nil
                                                  size:CGSizeMake(TPScreenWidth(), CONTACT_CELL_HEIGHT)];
        [cell setSkinStyleWithHost:self forStyle:@"ContactItemCell_style"];
    }
    [cell showPartBLine];
    cell.operView.hidden = YES;
    if ( [longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare: indexPath] == NSOrderedSame) {
        [cell.operView addSubview:longGestureController_.operView.bottomView];
        cell.operView.hidden = NO;
        [cell hidePartBLine];
        [cell showAnimation];
        self.longModeCell = cell;
    }
    [(ContactItemCell *)cell setMemberCellDataWithCacheItemData:cachePersonData displayType:DisplayTypeLastModifiedTime];
    
    TPUIButton *photoButton = [[TPUIButton alloc] initWithFrame:cell.faceSticker.frame];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![longGestureController_ inLongGestureMode]){
        long contactId = [((NSNumber *)[datas_ objectAtIndex:indexPath.row]) longValue];
        if (contactId > 0) {
            [[ContactInfoManager instance] showContactInfoByPersonId:contactId];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"%@", NSStringFromClass([touch.view class]));
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

#pragma  mark Enter_or_exit_multiselect_mode
- (void)enterLongGestureMode
{
    if (longGestureController_.showScrollToShow) {
        longGestureController_.showScrollToShow = NO;
        [m_tableview scrollToRowAtIndexPath:longGestureController_.currentSelectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [m_tableview reloadData];
}

- (void)exitLongGestureMode
{
    [self.longModeCell exitAnimation];
    [m_tableview reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
}

-(void)refreshTable
{
    BOOL dataChanged = NO;
    for(int i=0;i<datas_.count;i++){
        ContactCacheDataModel* cachePersonData = [[ContactCacheDataManager instance] contactCacheItem:[((NSNumber *)[datas_ objectAtIndex:i]) longValue]];
        if(cachePersonData==nil){
            [datas_ removeObjectAtIndex:i];
            dataChanged = YES;
        }
        
    }
    if(dataChanged){
        [[NSNotificationCenter defaultCenter] postNotificationName:N_FILTER_CONTACT_NUMBER_CHANGED object:[NSNumber numberWithInt:datas_.count]];
    }
    [m_tableview reloadData];
}

- (void)reloadTable
{
    [m_tableview reloadData];
    if([m_tableview numberOfRowsInSection:0]>0){
        [m_tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

-(void)refreshTableWithSelectedNode:(ExpandableNode *)node
{
    if([node isKindOfClass:[LeafNodeWithContactIds class]]){
        self.datas = [NSMutableArray arrayWithArray:((LeafNodeWithContactIds *)node).contactIds];
        [self reloadTable];
    }
}

@end
