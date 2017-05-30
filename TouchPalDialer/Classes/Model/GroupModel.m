//
//  GroupModel.m
//  TouchPalDialer
//
//  Created by Sendor on 12-2-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GroupModel.h"
#import "GroupDataModel.h"
#import "Group.h"
#import "Person.h"
#import "CootekNotifications.h"
#import "GroupedContactsModel.h"
#import "ContactGroupDBA.h"
#import "LangUtil.h"
/////////// class GroupItemData //////////
@implementation GroupItemData

@synthesize group_id;
@synthesize group_name;


+ (GroupItemData*)createUngroup {
    return [[GroupItemData alloc] initWithId:UNGROUPED_GROUP_ID name:NSLocalizedString(@"Ungrouped", @"Ungrouped")];
}

#pragma mark GroupItemData life cycle
- (id)initWithId:(NSInteger)groupId name:(NSString*)groupName {
    self = [super init];
    if (self) {
        group_id = groupId;
        group_name = groupName;
    }
    return self;
}

@end
/////////// end class GroupItemData //////////


@implementation GroupModel

static GroupModel *_pseudoSingletonInstance = nil;

@synthesize current_index;
@synthesize groups;

- (NSArray*)groups {
    return groups;
}

+ (GroupModel*)pseudoSingletonInstance {
	if(_pseudoSingletonInstance)
		return _pseudoSingletonInstance;
	
	@synchronized([GroupModel class])
	{
		if (!_pseudoSingletonInstance){
			_pseudoSingletonInstance = [[GroupModel alloc] init];
            [_pseudoSingletonInstance loadSortedGroups];
		}		
		return _pseudoSingletonInstance;
	}	
	return nil;
}

+ (NSArray*)getAllMemebersNotInGroup:(NSInteger)groupID {
    NSMutableArray* allMembersNotInGroup =[NSMutableArray arrayWithArray:[[ContactCacheDataManager instance] getAllCacheContact]];
    NSArray *groupMemberIDs = [ContactGroupDBA getMembersInGroup:groupID];
    for (int i=0; i<[allMembersNotInGroup count]; i++) {
        ContactCacheDataModel* personItem = [allMembersNotInGroup objectAtIndex:i];
        for (NSNumber *memberIDItem in groupMemberIDs) {
            if (personItem.personID == [memberIDItem intValue]) {
                [allMembersNotInGroup removeObjectAtIndex:i];
                i--;
                break;
            }
        }
    }
    return allMembersNotInGroup;
}

- (id)init {
    self = [super init];
    if (self) {
        current_index = INVALID_GROUP_INDEX;
        groups = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadSortedGroups {
//    [groups removeAllObjects];
//    NSArray *allGroupIDs = [Group getAllGroupIDs];
//    for (NSNumber* item in allGroupIDs) {
//        if ([item intValue] != 0) {
//            GroupDataModel* groupData = [Group getGroupByGroupID:[item intValue]];
//            GroupItemData* item = [[GroupItemData alloc] initWithId:groupData.groupID name:groupData.groupName];
//            [groups addObject:item];
//            [item release];
//        } else {
//            [ContactGroupDBA deleteGroup:[item intValue]];
//        }
//    }
//    [groups addObject:[GroupItemData createUngroup]];
//    if ([allGroupIDs count] > 0 && [GroupedContactsModel pseudoSingletonInstance].group_id == -1) {
//        [[GroupedContactsModel pseudoSingletonInstance] changeGroupId:[[allGroupIDs objectAtIndex:0] intValue]];
//    }
//    [self updateCurrentIndex:[self getIndexById:[GroupedContactsModel pseudoSingletonInstance].group_id]];
    
    [groups removeAllObjects];
    NSArray *allGroupIDsFromAddBook = [Group getAllGroupIDs];
    NSArray *allGroupIDs = [ContactGroupDBA getAllGroups];
    
    allGroupIDs = [self equalArray:allGroupIDs andArray2:allGroupIDsFromAddBook];

    for (NSNumber *addItem in allGroupIDs) {
        GroupDataModel* groupData = [Group getGroupByGroupID:[addItem intValue]];
        GroupItemData* item = [[GroupItemData alloc] initWithId:groupData.groupID name:groupData.groupName];
        [groups addObject:item];
    }
    
    
    [groups addObject:[GroupItemData createUngroup]];
    if ([allGroupIDsFromAddBook count] > 0 && [GroupedContactsModel pseudoSingletonInstance].group_id == -1) {
        [[GroupedContactsModel pseudoSingletonInstance] changeGroupId:[[allGroupIDsFromAddBook objectAtIndex:0] intValue] ifReload:NO];
    }
    [self updateCurrentIndex:[self getIndexById:[GroupedContactsModel pseudoSingletonInstance].group_id] ifReload:NO];
}

- (NSArray*)equalArray:(NSArray *)array1 andArray2:(NSArray*)array2{
    BOOL arrayEqual = YES;
    for (NSNumber* item in array1) {
        BOOL hasInAddsBook = NO;
        for (NSNumber *addItem in array2) {
            if ([item intValue] == [addItem intValue]) {
                hasInAddsBook = YES;
                break;
            }
        }
        if (!hasInAddsBook) {
            arrayEqual = NO;
            [ContactGroupDBA deleteGroup:[item intValue]];
        }
    }
    if (!arrayEqual) {
        array1 = [ContactGroupDBA getAllGroups];
    }
    return array1;
}

- (BOOL)isGroupExisted:(NSString*)checkGroupName {
    for (GroupItemData *item in groups) {
        if ([item.group_name isEqualToString:checkGroupName]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isExchangeType {
    return [Group isExchangeType];
}

-(BOOL) isMobileType {
    return [Group isMobileType];
}

- (NSInteger)addGroup:(NSString*)groupName {
    NSInteger groupId = [Group addNewGroupByGroupName:groupName];
    if (groupId > 0) {
        // add into database
        [ContactGroupDBA addGroup:groupId];
        // cache
        GroupItemData* item = [[GroupItemData alloc] initWithId:groupId name:groupName];
        NSInteger insertIndex = [groups count] - 1;
        [groups insertObject:item atIndex:insertIndex];
        // Notification
        NotiGroupChangeData* changedData = [[NotiGroupChangeData alloc] initWithGroupIndex:insertIndex
																				 changeType:ContactChangeTypeAdd];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:changedData forKey:KEY_GROUP_MODEL_CHANGED];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MODEL_ADDED object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MODEL_CHANGED object:nil userInfo:userInfo];
        NSInteger newCurrentIndex = [groups count] - 2;
        [self updateCurrentIndex:newCurrentIndex ifReload:YES];
    }
    return groupId;
}


- (void)deleteGroup:(NSInteger)deleteIndex {
    // Calculate current index after deleting
    NSInteger newCurrentIndex = current_index;
    if (newCurrentIndex < deleteIndex) {
        // do not change
    } else if(newCurrentIndex == deleteIndex) {
        if (deleteIndex < [groups count] - 2 ) {
            // do not change
        } else {
            if (deleteIndex > 0) {
                newCurrentIndex = deleteIndex - 1;
            } else {
                // do not change
            }
        }
    } else if (newCurrentIndex > deleteIndex) {
        newCurrentIndex -= 1; 
    }
    
    // delete group and notification
    NSInteger groupId = ((GroupItemData*)[groups objectAtIndex:deleteIndex]).group_id;
    [groups removeObjectAtIndex:deleteIndex];
    [Group deleteGroupByGroupID:groupId];
    [ContactGroupDBA deleteGroup:groupId];
    NotiGroupChangeData* changedData = [[NotiGroupChangeData alloc] initWithGroupIndex:newCurrentIndex changeType:ContactChangeTypeDelete];
    NotiPersonGroupChangeData* deletedGroup = [[NotiPersonGroupChangeData alloc] initWithGroupContact:groupId withPersonID:0 changeType:ContactChangeTypeDeleteFromGroup];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:changedData forKey:KEY_GROUP_MODEL_CHANGED];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MODEL_CHANGED object:nil userInfo:userInfo];
    userInfo = [NSDictionary dictionaryWithObject:deletedGroup forKey:KEY_GROUP_NODE_DELETED];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_NODE_DELETED object:nil userInfo:userInfo];
    [self updateCurrentIndex:newCurrentIndex ifReload:YES];
}

- (BOOL)renameGroup:(NSInteger)groupId name:(NSString*)newName{
    BOOL result = [Group editGroupName:groupId GroupName:newName];
    if (result) {
        NSInteger index = [self getIndexById:groupId];
        if (index < [groups count]) {
            GroupItemData* item = [groups objectAtIndex:index];
            item.group_name = newName;
            NotiGroupChangeData* changedData = [[NotiGroupChangeData alloc] initWithGroupIndex:index changeType:ContactChangeTypeModify];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:changedData forKey:KEY_GROUP_MODEL_CHANGED];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MODEL_CHANGED object:nil userInfo:userInfo];
            if (current_index != index) {
                [self updateCurrentIndex:index ifReload:YES];
            }
        }
    }
    return result;
}

- (void)moveGroupFrom:(NSInteger)fromIndex to:(NSInteger)toIndex {
    // update cache data
    GroupItemData* fromItem = [groups objectAtIndex:fromIndex];
    [groups removeObjectAtIndex:fromIndex];
    [groups insertObject:fromItem atIndex:toIndex];
    // update databse
    NSMutableArray* groupIDs = [[NSMutableArray alloc] init];
    for (GroupItemData* item in groups) {
        [groupIDs addObject:[NSNumber numberWithInteger:item.group_id]];
    }
    [ContactGroupDBA resetGroups:groupIDs];
    // Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MODEL_REORDERED object:nil userInfo:nil];
    [self updateCurrentIndex:toIndex ifReload:YES];
}

- (void)updateCurrentIndex:(NSInteger)index ifReload:(BOOL)ifReload{
    if (index != current_index) {
        current_index = index;
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:current_index] forKey:KEY_GROUP_MODEL_INDEX];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MODEL_INDEX_CHANGED 
                                                            object:nil 
                                                          userInfo:userInfo];
    }
    NSInteger newGroupId = [self getCurrentGroupId];
    GroupedContactsModel* groupedContactsModel = [GroupedContactsModel pseudoSingletonInstance];
    if ( ifReload ){
        [groupedContactsModel changeGroupId:newGroupId ifReload:YES];
    }
}

- (NSInteger)getCurrentGroupId {
    if (current_index >= 0 && current_index < [groups count]) {
        return ((GroupItemData*)[groups objectAtIndex:current_index]).group_id;
    }
    return INVALID_GROUP_ID;
}

- (void)saveSortedGroups {
    NSMutableArray * groupIds = [[NSMutableArray alloc] initWithCapacity:[groups count]];
    for (GroupItemData *item in groups) {
        [groupIds addObject:[NSNumber numberWithInteger:item.group_id]];
    }
    if ([groupIds count] > 0) {
        [groupIds removeObjectAtIndex:[groupIds count]-1];
    }
    [ContactGroupDBA resetGroups:groupIds];
}

- (NSString*)getGroupNameById:(NSInteger)groupId {
    NSInteger index = [self getIndexById:groupId];
    if (index < [groups count]) {
        GroupItemData* item = [groups objectAtIndex:index];
        return item.group_name;
    }
    return nil;
}

NSInteger sortGroupByFirstChar(id obj1, id obj2, void *context){
    NSString *obj1Str = ((GroupItemData *)obj1).group_name;
    NSString *obj2Str = ((GroupItemData *)obj2).group_name;
    
    wchar_t char_1 = getFirstLetter(NSStringToFirstWchar(obj1Str));
    wchar_t char_2 = getFirstLetter(NSStringToFirstWchar(obj2Str));
    if (char_1 > char_2) {
        return NSOrderedDescending;
    } else if (char_1 == char_2) {
        return NSOrderedSame;
    } else {
        return NSOrderedAscending;
    }

}

#pragma mark private methods
/*
- (NSArray *)loadLocalSortedGroupIds {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    NSString *filePathName = [dir stringByAppendingPathComponent:@"sorted_group_ids.plist"];
    NSArray *localSortedGroupIds = [NSArray arrayWithContentsOfFile:filePathName];
    return localSortedGroupIds;
}

- (NSInteger)getGroupIndexFromSystemGroups:(NSArray*)systemGroups byGroupId:(NSInteger)groupId {
    int count = [systemGroups count];
    int i = 0;
    for (; i<count; i++) {
        GroupDataModel* item = [systemGroups objectAtIndex:i];
        if (item.groupID == groupId) {
            return i;
        }
    }
    return INVALID_GROUP_INDEX;
}

- (void)saveSortedGroups {
    // save to file
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];
    NSString *filePathName = [dir stringByAppendingPathComponent:@"sorted_group_ids.plist"];
    
    NSMutableArray* newLocalSortedGroupIds = [[NSMutableArray alloc] init]; 
    int allSortedGroupsCount = [groups count];
    int i = 0;
    for (; i<allSortedGroupsCount; i++) {
        GroupItemData* item = [groups objectAtIndex:i];
        [newLocalSortedGroupIds addObject:[NSNumber numberWithInt:item.group_id]];
    }
    [newLocalSortedGroupIds writeToFile:filePathName atomically:YES];
	[newLocalSortedGroupIds release];
}
 */

- (NSInteger)getIndexById:(NSInteger)groupId {
    int i = 0;
    for (; i<[groups count]; i++) {
        GroupItemData* item = [groups objectAtIndex:i];
        if (item.group_id == groupId) {
            break;
        }
    }
    if(i >= [groups count]){i = 0;}
    return i;
}

+ (void)destory {
    
    if(!_pseudoSingletonInstance) {
        _pseudoSingletonInstance = nil;

    }
}



@end
