//
//  GroupModel.h
//  TouchPalDialer
//
//  Created by Sendor on 12-2-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


////////////////////////////////
@interface GroupItemData : NSObject
{
    NSInteger group_id;
    NSString __strong *group_name;
}
@property(nonatomic, readonly) NSInteger group_id;
@property(nonatomic, retain) NSString *group_name;

+ (GroupItemData*)createUngroup;
- (id)initWithId:(NSInteger)groupId name:(NSString*)groupName;

@end
////////////////////////////////


@interface GroupModel : NSObject {
    NSInteger current_index;
    NSMutableArray* groups;
}

@property(nonatomic, readonly) NSInteger current_index;
@property(nonatomic, retain, readonly) NSArray* groups;

+ (GroupModel*)pseudoSingletonInstance;
+ (void)destory;

- (id)init;
- (void)loadSortedGroups;

- (BOOL)isGroupExisted:(NSString*)checkGroupName;

- (NSInteger)addGroup:(NSString*)groupName;
- (void)deleteGroup:(NSInteger)index;
- (BOOL)renameGroup:(NSInteger)groupId name:(NSString*)newName;
- (void)moveGroupFrom:(NSInteger)fromIndex to:(NSInteger)toIndex;
- (void)updateCurrentIndex:(NSInteger)index ifReload:(BOOL)ifReload;
- (NSString*)getGroupNameById:(NSInteger)groupId;
- (NSInteger)getCurrentGroupId;
- (void)saveSortedGroups;

+ (NSArray*)getAllMemebersNotInGroup:(NSInteger)groupID;

// private method
/*
- (NSArray*)loadLocalSortedGroupIds;
- (NSInteger)getGroupIndexFromSystemGroups:(NSArray*)systemGroups byGroupId:(NSInteger)groupIdp;
- (void)saveSortedGroups;
 */
- (NSInteger)getIndexById:(NSInteger)groupId;
NSInteger sortGroupByFirstChar(id obj1, id obj2, void *context);
- (BOOL)isExchangeType;
- (BOOL)isMobileType;
@end
