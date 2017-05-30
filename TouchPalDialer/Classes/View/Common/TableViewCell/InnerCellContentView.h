//
//  InnerCellContentView.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandableNode.h"

@interface InnerCellContentView : UIView

// Consider improve: the source for innerCellContentView should not be ExpandableNode,
// but should be node.data
- (void) fillWithSource:(ExpandableNode*) sourceNode;
@end


@interface DefaultCellContentView : InnerCellContentView{

}
@property(nonatomic,retain)UILabel *headLabel;
@property(nonatomic,retain)UILabel *icon;
@end
