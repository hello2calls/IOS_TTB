//
//  ExpandableCell.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandableNode.h"
#import "InnerCellContentView.h"
#import "CootekTableViewCell.h"
#import "LeafNode.h"

@protocol RestoreLastSelectedCell

@optional
-(LeafNodeWithContactIds *)returnLastSelected;
@end

@protocol RefreshTableViewDelegate <NSObject>

@required

-(void)refreshParentTable;

@end

@interface ExpandableCell : CootekTableViewCell <LoadDataDelegate>

@property (nonatomic, assign) id<RefreshTableViewDelegate> parentTableView;
@property (nonatomic, retain) ExpandableNode* cellSource;
@property (nonatomic, retain) InnerCellContentView* cellContent;
@property(nonatomic, assign) id<RestoreLastSelectedCell> container;

- (void) notifyCellSourceChanged;
- (void) onCellSourceChanged;

- (void) onExpanderClicked;
@end
