//
//  InnerCellContentViewCreator.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InnerCellContentView.h"
#import "ExpandableNode.h"

@interface InnerCellContentViewCreator : NSObject
- (InnerCellContentView*) createInnerCellContentViewForNode:(ExpandableNode*) node frame:(CGRect)frame controller:(id)con;
- (NSString*) reuseIdentifierForNode:(ExpandableNode*) node;
@end

