//
//  DemoNode.h
//  ExpandableTableView
//
//  Created by Xu Elfe on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExpandableNode.h"
#import "CityGroupModel.h"
#import "LeafNode.h"

@interface NoteNode : LeafNodeWithDisplayRequirements
+ (NoteNode *)noteNode;
@end

@interface GroupNode : LeafNodeWithDisplayRequirements
+ (GroupNode *)groupNodeWithGroupName:(NSString *)groupName andIds:(NSArray *)Ids;
@end

@interface MembersGroupNode :ExpandableNode 
+ (MembersGroupNode *)membersGroupNode;
@end

@interface CompanyNode : LeafNodeWithDisplayRequirements
+ (CompanyNode*) companyNodeWithName:(NSString *)companyName andIds:(NSArray *)Ids;
@end

@interface LastModifiedNode : LeafNodeWithDisplayRequirements
+ (LastModifiedNode*) lastModifiedNode;
@end

@interface AllContactsNode : LeafNodeWithDisplayRequirements
+ (AllContactsNode*) allContactsNode;
@end

@interface TouchPalersNode :LeafNodeWithDisplayRequirements
 + (TouchPalersNode*) touchPalersNode;
@end

@interface CityGroupNode : ExpandableNode
+ (CityGroupNode*) cityGroupNode;
@end

@interface CityNode : LeafNodeWithDisplayRequirements
+ (CityNode*) cityNodeWithName:(NSString*) cityName;
@end

@interface CompanyGroupNode : ExpandableNode
@property(nonatomic,retain) NSArray *sortedCompanies;
@property(nonatomic,retain) NSDictionary *companiesDictionary;
+ (CompanyGroupNode*) companyGroupNode;
@end

@interface DemoNode : ExpandableNode
+ (DemoNode*) demoNode;
@end
