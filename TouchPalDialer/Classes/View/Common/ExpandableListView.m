//
//  ExpandableTableViewController.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExpandableListView.h"
#import "InnerCellContentViewCreator.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "SmartGroupNode.h"
#import "LeafNode.h"
#import "HeadTabBar.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "UITableView+TP.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"
#import "ContactCacheDataManager.h"
#import "FunctionUtility.h"

@interface ExpandableListView () {
    UIView *waitView_;
}
- (void)foldAllExpandedCell;
- (void)cellChecked:(int)row;
@end
@implementation ExpandableListView

@synthesize rootNode;
@synthesize currentNode;
@synthesize cellCreator;
@synthesize dataContainer;
@synthesize groupManage;
@synthesize groupManageView;
@synthesize currentPageIndex;
@synthesize loadDataCount;
@synthesize tableView = tableView_;
@synthesize headerTab= headerTab_;
@synthesize headerLoadingLabel = headerLoadingLabel_;


@synthesize lastSelectedCell;
@synthesize loadingIndicator = loadingIndicator_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // ???
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TPHeightFit(460) + TPHeaderBarHeightDiff())];
        [headerView setSkinStyleWithHost:self forStyle:@"ExpandableListViewBack_image"];
        [self addSubview:headerView];
        
        CGFloat titleLabelHeight = 45;
        
        // the title label
        CGSize headerTabSize = CGSizeMake(100, 30);
        headerTab_ = [[HeadTabBar alloc] initWithFrame:CGRectMake((TPScreenWidth() - headerTabSize.width) / 2, 7.5 + TPHeaderBarHeightDiff(), headerTabSize.width, headerTabSize.height) buttonCount:1];
        headerTab_.expandableHeadTabBar = YES;
        currentPageIndex = 0;
        [headerTab_ setSkinStyleWithHost:self forStyle:@"expandableList_new_headtabbar_style"];
        headerTab_.delegate = self;
        [self addSubview:headerTab_];
        
        headerLoadingLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width-10, titleLabelHeight)];
        [headerLoadingLabel_ setSkinStyleWithHost:self forStyle:@"expandableList_loading_label_style"];
        headerLoadingLabel_.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        headerLoadingLabel_.text = NSLocalizedString(@"Now loading",@"");
        headerLoadingLabel_.textAlignment = NSTextAlignmentLeft;
        headerLoadingLabel_.hidden = YES;
        [self addSubview:headerLoadingLabel_];
        
        
        CGFloat indicatorSize = 24;
        loadingIndicator_ = [UIActivityIndicatorView alloc];
        loadingIndicator_ = [loadingIndicator_ initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadingIndicator_.hidesWhenStopped = YES;
        loadingIndicator_.frame = CGRectMake((frame.size.width - indicatorSize - 10), (45 - indicatorSize)/2, indicatorSize, indicatorSize);
        
        
        tableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, titleLabelHeight + TPHeaderBarHeightDiff(), frame.size.width,frame.size.height - titleLabelHeight - TPHeaderBarHeightDiff()) style:UITableViewStylePlain];
        tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [tableView_ setExtraCellLineHidden];
        [tableView_ setSkinStyleWithHost:self forStyle:@"expandableListView_table_style"];
        tableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView_.delegate = self;
        tableView_.dataSource = self;
        tableView_.rowHeight = 50;
        [self addSubview:tableView_];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectLastRow) name:N_CONTACT_BACK_TO_ALL object:nil];
        self.loadDataCount = 0;
        
        // right button: manage group
        CGFloat headerTabY = 7.5 + TPHeaderBarHeightDiff();
        CGRect groupManageRect = CGRectMake(LEFT_DRAWER_WIDTH - 65, headerTabY, 60, 30);
        groupManage = [[TPUIButton alloc] initWithFrame:groupManageRect];
        groupManage.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        groupManage.titleLabel.numberOfLines = 2;
        [groupManage setSkinStyleWithHost:self forStyle:@"ExpandableViewController_groupManage_style"];
        [groupManage setTitle:NSLocalizedString(@"Manage groups", @"")  forState:UIControlStateNormal];
        [groupManage addTarget:self action:@selector(navigate2GroupManage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:groupManage];
        groupManageView = [[GroupManagerViewController alloc] init];
        
        if (![ContactCacheDataManager isEngineInited]) {
            groupManage.hidden = YES;
            [self addWaitView];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWaitView) name:N_ENGINE_INIT object:nil];
        }
        self.currentNode = (LeafNodeWithContactIds *)[rootNode defaultNode];
        
        TPUIButton *backButton = [[TPUIButton alloc] initWithFrame:CGRectMake(5, headerTabY, 50, 30)];
        [backButton setSkinStyleWithHost:self forStyle:@"ExpandableViewController_groupManage_style"];
        [backButton setTitle:@"0" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backButton addTarget:self action:@selector(onClickBackButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:backButton];
    }
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self];
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
    
    return self;
}

- (void)setNodeSet:(NSArray *)nodeSets keySet:(NSArray *)keySets {
    [headerTab_ tabBarTitle:keySets];
    if (keySets.count == 1) {
        headerTab_.userInteractionEnabled = NO;
    }
    rootNodeSets = [NSArray arrayWithArray:nodeSets];
    rootNodeKeys = keySets;
}

- (void) addWaitView {
        // wait view
        CGFloat indicatorSize = 48;
        waitView_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LEFT_DRAWER_WIDTH, TPScreenHeight())];
        waitView_.backgroundColor = [UIColor clearColor];
        CGRect frame = CGRectMake((LEFT_DRAWER_WIDTH - indicatorSize)/2, TPScreenHeight() / 2,indicatorSize,indicatorSize);
        UIActivityIndicatorView *indicator = nil;
        if([UIActivityIndicatorView instancesRespondToSelector:NSSelectorFromString(@"color")]) {
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.color = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellDetailText_color"];
        } else {
            NSString* backgroundColor = [[TPDialerResourceManager sharedManager] getResourceNameByStyle:@"defaultCellBackground_color"];
            // change the indicator color. otherwise, it might be same as the background color and be invisible.
            if( [backgroundColor isEqualToString:@"0xFFFFFF"] ) {
                indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            } else {
                indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            }
        }
        
        indicator.hidesWhenStopped = YES;
        indicator.frame = frame;
        [indicator startAnimating];
        [waitView_ addSubview:indicator];
        [self addSubview:waitView_];

}

- (void) dismissWaitView {
    groupManage.hidden = NO;
    if(waitView_ != nil) {
        [waitView_ removeFromSuperview];
        waitView_ = nil;
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if (recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        [self.filterView restoreViewLocation];
    }
}

#pragma mark HeadTabBarDelegate
- (void)onClickAtIndexBar:(NSInteger)index{
    if (currentPageIndex == index) {
        return;
    }
    currentPageIndex = index;
    cootek_log(@"~~~~~~~~~~~~~~~~~~~~~~ %d",[self numberOfSectionsInTableView:tableView_]);
    for (int i=0; i < [rootNodeSets count]; i++) {
        if (i == index) {
            rootNode = rootNodeSets [i];
            if (index == 1) {
                groupManage.hidden = NO;
                [tableView_ setFrame:CGRectMake(00, TPHeaderBarHeight(), LEFT_DRAWER_WIDTH,TPHeightFit(460) - 90)];
            } else {
                groupManage.hidden = YES;
                [tableView_ setFrame:CGRectMake(00, TPHeaderBarHeight(), LEFT_DRAWER_WIDTH,TPHeightFit(460) - 45)];
            }
            [self refreshTable];
        }
    }
}


- (void)dealloc
{
    [SkinHandler removeRecursively:self];
    self.currentNode = nil;
    //[rootNode release];
    
    for (UISwipeGestureRecognizer *recognizer in [self gestureRecognizers]) {
        [self removeGestureRecognizer:recognizer];
    }
    self.filterView = nil;
}

- (void)navigate2GroupManage {
    [groupManageView popUpToTop];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rootNode totalVisibleItemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellRowAtIndex:indexPath table:tableView];
}

- (ExpandableCell *)cellRowAtIndex:(NSIndexPath *)indexPath table:(UITableView *)tableView
{
    ExpandableNode* item = [rootNode visibleItemAtIndex:[indexPath row]];
    NSString* identifier = [cellCreator reuseIdentifierForNode:item];
    
    ExpandableCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil) {
        cell = [[ExpandableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.parentTableView = self;
        cell.container = self;
        CGRect tmpframe = cell.frame;
        if (item.depth > 0) {
            tmpframe = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width - (item.depth - 1) * 20 - cell.frame.size.height, cell.frame.size.height);
        }
        cell.cellContent = [cellCreator createInnerCellContentViewForNode:item frame:tmpframe controller:self];
    }
    if([(ExpandableCell*)cell respondsToSelector:@selector(setCellSource:)]){
        [cell setCellSource:item];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpandableNode* item = [rootNode visibleItemAtIndex:[indexPath row]];
    ExpandableCell *cell = (ExpandableCell *)[tableView cellForRowAtIndexPath:indexPath];
    if([item isKindOfClass:[LeafNode class]]){
        self.currentNode = (LeafNodeWithContactIds *)item;
        if ([currentNode isKindOfClass:[AllContactsNode class]]) {
            [self restoreToAllContactView];
            return;
        }
        [self.dataContainer refreshTableWithSelectedNode:currentNode];
    } else {
        [cell onExpanderClicked];
        if (cell.cellSource.isExpanded){
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
    lastSelectedCell = cell;
}

- (void)refreshTable
{
    if (self.loadDataCount == 0) {
        [tableView_ reloadData];
    }
}

- (void)refreshParentTable
{
    [tableView_ reloadData];
}

- (void)foldAllExpandedCell
{
    NSArray *cells = [tableView_ visibleCells];
    for(int i=0;i<cells.count;i++){
        ExpandableCell *cell = [cells objectAtIndex:i];
        if(cell.cellSource.isExpanded){
            [cell onExpanderClicked];
        }
    }
}

- (void)cellChecked:(int)row
{
    if(lastSelectedCell){
        //UITableViewCell *lastcell = [tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedRow inSection:0]];
        UIView *selectedView = [[UIView alloc] initWithFrame:lastSelectedCell.frame];
        selectedView.backgroundColor = [UIColor clearColor];
        lastSelectedCell.backgroundView = selectedView;
    }
    UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    NSDictionary *operDic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"expandableListView_table_style"];
    selectedView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:[operDic objectForKey:@"selected_color"]];
    cell.backgroundView = selectedView;
    lastSelectedCell = (ExpandableCell *)cell;
    
}

-(void)deselectLastRow
{
    [tableView_ deselectRowAtIndexPath:[tableView_ indexPathForCell:lastSelectedCell] animated:NO];
}

#pragma mark rootNode loading delegate
-(void)onBeginLoadData
{
    if(![NSThread currentThread].isMainThread) {
        [self performSelectorOnMainThread:@selector(onBeginLoadData) withObject:nil waitUntilDone:YES];
        return;
    }
    loadDataCount ++;
    cootek_log(@"begin load data count: %d", loadDataCount);
}

-(void)onEndLoadData:(ExpandableNode *)node
{
    if(![NSThread currentThread].isMainThread) {
        [self performSelectorOnMainThread:@selector(onEndLoadData) withObject:nil waitUntilDone:YES];
        return;
    }
    if (loadDataCount == 0) {
        return;
    }
    loadDataCount --;
    cootek_log(@"end load data count: %d", loadDataCount);
    if (loadDataCount == 0) {
        ExpandableNode *newNode = [rootNode isNodeExist:currentNode];
        if (newNode) {
            self.currentNode = (LeafNodeWithContactIds *)newNode;
            [self.dataContainer refreshTableWithSelectedNodeWithoutRestore:currentNode];
        } else {
            if ([(id)self.dataContainer respondsToSelector:@selector(noFilter)]) {
                [self.dataContainer noFilter];
            }
            self.currentNode = (LeafNodeWithContactIds *)[rootNode defaultNode];
        }
        [self refreshTable];
        headerTab_.hidden = NO;
        headerLoadingLabel_.hidden = YES;
    }
}

-(id)returnLastSelected
{
    return currentNode;
}

#pragma mark actions
- (void) onClickBackButton {
    // should set the _currentNode when clicking the back button
    ExpandableNode *item = [rootNode defaultNode];
    if ([item isKindOfClass:[LeafNode class]]) {
        self.currentNode = (LeafNodeWithContactIds *)item;
    }
    [self restoreToAllContactView];
}

- (void) restoreToAllContactView {
    [self.dataContainer noFilter];
    [self.dataContainer restoreViewLocationWithNoChange];
}

@end


