//
//  InnerCellContentViewCreator.m
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InnerCellContentViewCreator.h"
#import "UIView+WithSkin.h"


@implementation InnerCellContentViewCreator
- (InnerCellContentView*) createInnerCellContentViewForNode:(ExpandableNode*) node frame:(CGRect)frame controller:(id)con{
    // check node.data and return corresponding view
    InnerCellContentView *contentView = [[DefaultCellContentView alloc] initWithFrame:frame];
    [contentView setSkinStyleWithHost:con forStyle:@""];
    return contentView;
}
- (NSString*) reuseIdentifierForNode:(ExpandableNode*) node {
    // check node.data and return corresponding identifier
    if(node.canHaveChildren){
        return @"ParentCell";
    }else{
        return @"LeafCell";
    }
}

@end
