//
//  LeafNode.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpandableNode.h"


@interface StringNumberPair : NSObject
@property (nonatomic,retain) NSString *string;
@property (nonatomic,assign) int number;
@property (nonatomic,readonly) NSString *stringNumberPair;
@end

@interface LeafNode : ExpandableNode

+ (LeafNode*) leafNodeWithData:(id) nodeData;
//- (void) loadLeafDataAsync
@end


@interface LeafNodeWithContactIds : LeafNode 
@property(nonatomic, retain)NSArray *contactIds;
@end

@interface LeafNodeWithDisplayRequirements : LeafNode 
@property(nonatomic, retain)NSArray *contactIds;
@property(nonatomic, retain)NSString *nodeDescription;
@property(nonatomic, assign)BOOL needAZScrollist;
@property(nonatomic, assign)BOOL needDisplayNote;
@end


