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

@interface NoteNode : LeafNodeWithContactIds
+ (NoteNode *)noteNode;
@end

@interface GroupNode : LeafNodeWithContactIds
@property (nonatomic,assign)int groupID;
@property (nonatomic,retain)NSString *groupName;
+ (GroupNode *)groupNodeForGroupID:(int)groupID andGroupName:(NSString *)groupName;
@end

@interface MembersGroupNode :ExpandableNode

@property(nonatomic,assign) bool needReloadData;
@property(nonatomic,assign) bool canReloadData;
+ (MembersGroupNode *)membersGroupNode;

@end

@interface TouchpalsNode : LeafNodeWithContactIds
+ (TouchpalsNode *)node;
+ (TouchpalsNode*)getNode;
//- (void)refreshIds:(NSArray *)contactIds;
+ (NSArray *)getContactsIds;
@end

@interface CompanyNode : LeafNodeWithContactIds
+ (CompanyNode*) companyNodeWithName:(NSString *)companyName andIds:(NSArray *)Ids;
@end

@interface RecentlyCreatedNode : LeafNodeWithContactIds
+ (RecentlyCreatedNode*) recentlyCreatedNode;
@end

@interface AllContactsNode : LeafNodeWithContactIds
+ (AllContactsNode*) allContactsNode;
@end

@interface CityGroupNode : ExpandableNode
+ (CityGroupNode*) cityGroupNode;
@end

@interface CityNode : LeafNodeWithContactIds
+ (CityNode*) cityNodeWithName:(NSString*) cityName;
@end

@interface CompanyGroupNode : ExpandableNode
@property(nonatomic,retain) NSArray *sortedCompanies;
@property(nonatomic,retain) NSDictionary *companiesDictionary;
+ (CompanyGroupNode*) companyGroupNode;
@end

@interface SmartGroupNode : ExpandableNode
+ (SmartGroupNode*) smartGroupNodeWithDelegate:(id<LoadDataDelegate>)delegate;
- (ExpandableNode *)defaultNode;
@end

