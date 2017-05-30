//
//  CellNodeBase.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  ExpandableNode;

@protocol  LoadDataDelegate <NSObject>
- (void) onBeginLoadData;
- (void) onEndLoadData:(ExpandableNode *)node;
@end

@interface ExpandableNode : NSObject

#pragma mark the node's own data
@property (nonatomic, retain) id data;
@property(nonatomic, retain)NSString *nodeDescription;
@property (nonatomic, retain) NSString *imageName;
- (id) initWithData:(id) nodeData;
- (void)observePersonDataChange;
#pragma mark the node's hierarchy
//@property (nonatomic, retain) ExpandableNode* parent;
@property (nonatomic, readonly) NSArray* children;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL canHaveChildren;
@property (nonatomic, assign) ExpandableNode *parent;

// The depth of the node. 
// If it does not have parent, the depth is 0;
// If it has a parent and a grand-parent, but no grand-grand-parent, then the depth is 2.
@property (nonatomic) NSInteger depth;

// The count of all items under this node, including the node itself, and it's children, grand-children...
- (NSInteger) totalVisibleItemCount;

// Get the item at given index.
// The item might be the node itsef, or it's child/grandchild nodes, if the children nodes are expanded
- (ExpandableNode*) visibleItemAtIndex:(NSInteger) index;

#pragma mark loading data
@property (nonatomic) BOOL isDataLoaded;
@property (nonatomic) BOOL isDataLoading;
@property (nonatomic) BOOL hidden;
@property (nonatomic, assign) id<LoadDataDelegate> loadDataDelegate;
- (void) loadDataSync;
- (void) loadDataAsync;

// The subclass override this function to load data
- (void) onLoadData;
- (void) addChild:(ExpandableNode*) child;
- (void) refreshDataAsync;
- (void) refreshDataSync;
- (void) reloadData;
- (void) onPersonDataChange;
- (void) onEndLoadData;
- (void) onBeginLoadData;
- (void) notifyBeginLoad;
- (void) notifyEndLoad;
- (ExpandableNode *)isNodeExist:(ExpandableNode *)node;
@end
