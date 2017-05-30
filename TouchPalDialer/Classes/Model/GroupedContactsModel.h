//
//  GroupedContactsModel.h
//  TouchPalDialer
//
//  Created by Sendor on 11-10-31.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataManager.h"

#define INVALID_GROUP_ID -1
#define INVALID_GROUP_INDEX -1
#define UNGROUPED_GROUP_ID 0xFFFF

typedef enum _tagMembersCheckStatus {
    MembersCheckStatusDisable,
    MembersCheckStatusNone,
    MembersCheckStatusAll,
    MembersCheckStatusPart,
} MembersCheckStatus;

/////////// class GroupMemberData //////////
@interface GroupMemberData : NSObject {
    ContactCacheDataModel* __strong cache_item_data;
    BOOL is_checked;
}

@property(nonatomic, retain, readonly) ContactCacheDataModel* cache_item_data;
@property(nonatomic) BOOL is_checked;

- (id)initWithPerson:(ContactCacheDataModel*)cacheItemData;

@end
/////////// end class GroupMemberData //////////


@interface GroupedContactsModel : NSObject {
    int group_id;
    NSMutableArray* members_array;
    MembersCheckStatus members_check_status;
}

@property(nonatomic, readonly) int group_id;
@property(nonatomic, retain, readonly) NSMutableArray* members_array;
@property(nonatomic, readonly) MembersCheckStatus members_check_status;

+ (GroupedContactsModel*)pseudoSingletonInstance;

+ (void)addMemberById:(NSInteger)personId toGroup:(NSInteger)groupId;
+ (void)addMembersById:(NSInteger)personId toGroup:(NSInteger)groupId;
+ (void)addMemberOnMainThreadById:(NSInteger)personId toGroup:(NSInteger)groupId;
+ (void)addMembers:(NSArray*)memberIds  toGroup:(NSInteger)groupId;
+ (void)deleteMemberById:(NSInteger)personId fromGroup:(NSInteger)groupId;

- (id)init;
- (void)reloadGroupMembers;
- (void)changeGroupId:(NSInteger)groupId ifReload:(BOOL)ifReload;
- (void)addMemberById:(NSInteger)personId;
- (void)addMembers:(NSArray*)memberIds;
- (NSInteger)removeMember:(NSInteger)personId;
- (NSInteger)removeMembers:(NSArray*)personIds;
- (void)updateMember:(NSInteger)personId;

- (void)setAllMembersChecked:(BOOL)isChecked;
- (void)setMemersChecked:(BOOL)isChecked persons:(NSArray*)personIds;
- (void)setMemerChecked:(BOOL)isChecked person:(NSInteger)personId;
- (NSArray*)getMemberIds;
- (NSArray*)getCheckedMemberIds;
- (NSInteger)getMembersCount;
- (NSInteger)getCheckedMembersCount;
- (NSArray*)getMembersNotInCurrentGroup;

// private
- (NSArray*)innerGetMembersInGroup;
- (NSArray*)innerGetMembersUngrouped;
- (NSArray *)getMembersIDUngrouped;
- (void)innerPostCheckedUpdateNotificationIfNessary;
- (void)innerPostCheckedUpdateNotification;
- (void)innerAddMemberById:(NSInteger)personId;
- (BOOL)innerAddMemberToCacheById:(NSInteger)personId;
- (void)innerAddMemberToCache:(GroupMemberData*)memberData;
- (NSInteger)innerRemoveMember:(NSInteger)personId;
- (void)innerSetMemerChecked:(BOOL)isChecked person:(NSInteger)personId;
- (MembersCheckStatus)innerCalculateMembersCheckStatus;
- (NSInteger)getMemberIndexById:(NSInteger)personId;
- (BOOL)checkMemberIsAlreadyInGroup:(NSInteger)personId;

@end
