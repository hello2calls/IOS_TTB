//
//  ExpandableTableViewController.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartGroupNode.h"
#import "ExpandableCell.h"
#import "InnerCellContentViewCreator.h"
#import "HeadTabBar.h"
#import "GroupManagerViewController.h"
#import "LeafNode.h"
#import "PushRightView.h"


#define LEFT_DRAWER_WIDTH (TPScreenWidth())


@protocol DataContainersProtocol
- (void)refreshTableWithSelectedNode:(ExpandableNode *)node;
@optional
- (void)restoreViewLocationWithNoChange;
- (void)restoreViewLocation;
- (void)refreshTableWithSelectedNodeWithoutRestore:(ExpandableNode *)node;
- (void)noFilter;
@end

@interface ExpandableListView : UIView<UITableViewDelegate,UITableViewDataSource, LoadDataDelegate, BaseTabBarDelegate, RestoreLastSelectedCell, RefreshTableViewDelegate>
{
    NSInteger loadDataCount;
    NSInteger currentPageIndex;
    NSArray __strong *rootNodeSets;
    NSArray __strong *rootNodeKeys;
    
    TPUIButton *groupManage;
    GroupManagerViewController *groupManageView;
}

@property (nonatomic, assign) NSInteger loadDataCount;
@property (nonatomic, retain) SmartGroupNode *rootNode;
@property (nonatomic, retain) LeafNodeWithContactIds *currentNode;
@property (nonatomic, retain) InnerCellContentViewCreator *cellCreator;
@property (nonatomic, assign) id<DataContainersProtocol> dataContainer;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) HeadTabBar *headerTab;
@property (nonatomic, retain) UILabel *headerLoadingLabel;
@property (nonatomic, retain) TPUIButton *groupManage;
@property (nonatomic, retain) GroupManagerViewController *groupManageView;
@property (nonatomic, assign) ExpandableCell *lastSelectedCell;
@property (nonatomic, retain) UIActivityIndicatorView * loadingIndicator;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic, retain) PushRightView *filterView;

- (void)setNodeSet:(NSArray *)nodeSets keySet:(NSArray *)keySets;
- (ExpandableCell *)cellRowAtIndex:(NSIndexPath *)indexPath table:(UITableView *)tableView;
@end
