//
//  CroupedContactsModel.m
//  TouchPalDialer
//
//  Created by Sendor on 11-10-31.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "GroupedContactsModel.h"
#import "ContactSort.h"
#import "Group.h"
#import "Person.h"
#import "CootekNotifications.h"
#import "ContactGroupDBA.h"
#import "DataBaseModel.h"
#import "TPAddressBookWrapper.h"
#import "UserDefaultsManager.h"



/////////// class GroupMemberData //////////
@implementation GroupMemberData

@synthesize cache_item_data;
@synthesize is_checked;

#pragma mark GroupMemberData life cycle
-(id)initWithPerson:(ContactCacheDataModel*)cacheItemData {
    self = [super init];
    if (self) {
        cache_item_data = cacheItemData;
        is_checked = NO;
    }
    return self;
}

@end
/////////// end class GroupMemberData //////////




@implementation GroupedContactsModel

static GroupedContactsModel *_pseudoSingletonInstance = nil;

@synthesize group_id;
@synthesize members_array;
@synthesize members_check_status;

+ (GroupedContactsModel*)pseudoSingletonInstance {
	if(_pseudoSingletonInstance)
		return _pseudoSingletonInstance;
	
	@synchronized([GroupedContactsModel class])
	{
		if (!_pseudoSingletonInstance){
			_pseudoSingletonInstance = [[GroupedContactsModel alloc] init];
		}
	}
	return _pseudoSingletonInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
        members_array = [[NSMutableArray alloc] init];
        members_check_status = MembersCheckStatusDisable;
        
        if ([UserDefaultsManager objectForKey:CURRENT_CHECKED_GROUP_ID]) {
            group_id = [UserDefaultsManager intValueForKey:CURRENT_CHECKED_GROUP_ID];
            //[self reloadGroupMembers];
        }else{
            group_id = -1;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiPersonDataChanged:) name:N_PERSON_DATA_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiPersonChangeGroup:) name:N_PERSON_GROUP_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiGroupSynchronized) name:N_GROUP_SYNCHRONIZED object:nil];
    }
    return self;
}


- (void)onNotiGroupSynchronized {
    [self performSelectorOnMainThread:@selector(onNotiGroupSynchronizedOnMainThread) withObject:nil waitUntilDone:YES];
}

- (void)onNotiGroupSynchronizedOnMainThread {
    [self reloadGroupMembers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)addMemberById:(NSInteger)personId toGroup:(NSInteger)groupId {
    // 1 add to system address book
    ABAddressBookRef addrBookRef = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    BOOL isSucceeded = [Group addMemberOfGroup:groupId Person:personId addressBook:addrBookRef];

    // 2 add to db
    NSInteger sourceType = 0;
    if (!isSucceeded) {
        sourceType = 1;
    }
    [ContactGroupDBA addGroupMember:personId sourceType:sourceType toGroup:groupId];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                        object:nil
                                                      userInfo:nil];
}
//NO notification method
+ (void)addMembersById:(NSInteger)personId toGroup:(NSInteger)groupId {
    // 1 add to system address book
    ABAddressBookRef addrBookRef = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    BOOL isSucceeded = [Group addMemberOfGroup:groupId Person:personId addressBook:addrBookRef];

    // 2 add to db
    NSInteger sourceType = 0;
    if (!isSucceeded) {
        sourceType = 1;
    }
    [ContactGroupDBA addGroupMember:personId sourceType:sourceType toGroup:groupId];

}

+ (void)addMemberOnMainThreadById:(NSInteger)personId toGroup:(NSInteger)groupId {
    // 1 add to system address book
    BOOL isSucceeded = [Group addMemberOfGroup:groupId Person:personId addressBook:[TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread]];
    // 2 add to db
    NSInteger sourceType = 0;
    if (!isSucceeded) {
        sourceType = 1;
    }
    [ContactGroupDBA addGroupMember:personId sourceType:sourceType toGroup:groupId];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)addMembers:(NSArray*)memberIds  toGroup:(NSInteger)groupId {
    for (NSNumber *item in memberIds) {
        NSInteger personId = [item intValue];
        [self addMembersById:personId toGroup:groupId];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_GROUP_CHANGE
                                                        object:nil
                                                      userInfo:nil];
}

+ (void)deleteMemberById:(NSInteger)personId fromGroup:(NSInteger)groupId {
    // 1 remove from system address book
    [Group removeMemberOfGroup:groupId Person:personId];
    // 2 remove from db
    [ContactGroupDBA deleteGroupMember:personId fromGroup:groupId];
}

- (void)onNotiPersonDataChanged:(NSNotification*)noti {
    NotiPersonChangeData* changedData = [[noti userInfo] objectForKey:KEY_PERSON_CHANGED];
    switch (changedData.change_type) {
        case ContactChangeTypeAdd:
			if (UNGROUPED_GROUP_ID == group_id) {
				if (([self innerAddMemberToCacheById:changedData.person_id])) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_RELOADED
                                                                        object:nil
                                                                      userInfo:nil];
                }
			}
            break;
        case ContactChangeTypeDelete:
            [self removeMember:changedData.person_id];
            break;
        case ContactChangeTypeModify:
            // notification
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_RELOADED
                                                                object:nil
                                                              userInfo:nil];
            break;
        default:
            break;
    }
}

- (void)onNotiPersonChangeGroup:(id)group{
	NotiPersonGroupChangeData *groupContactData =[[group userInfo] objectForKey:KEY_GROUP_PERSON_ID];
	if (groupContactData.groupID == group_id) {
		if (groupContactData.change_type == ContactChangeTypeAddToGroup) {
            [self reloadGroupMembers];
		}else if (groupContactData.change_type == ContactChangeTypeDeleteFromGroup) {
			[self removeMember:groupContactData.personID];
		}
	}
    
}

- (void)reloadGroupMembers {
    cootek_log(@"GrouperContactsModel::reloadGroupMembers start");
    [members_array removeAllObjects];
    
    NSArray* groupMemebers = nil;
    if (group_id == UNGROUPED_GROUP_ID) {
        groupMemebers = [self innerGetMembersUngrouped];
    } else {
        groupMemebers = [self innerGetMembersInGroup];
    }
    
    cootek_log(@"groupMemebers count is:%lu", (unsigned long)[groupMemebers count]);
    
    NSArray* sortedMembers = [ContactSort sortContactByFirstLetter:groupMemebers itemType:ContactItemTypeContactCacheDataModel];
    
    ContactCacheDataManager* syncCacheObj = [ContactCacheDataManager instance];
    NSInteger count = [sortedMembers count];
    int i = 0;
    for (; i<count; i++) {
        NSInteger personId = ((ContactCacheDataModel *)[sortedMembers objectAtIndex:i]).personID;
        ContactCacheDataModel *item = [syncCacheObj contactCacheItem:personId];
        if (item) { // show member in sync only
            GroupMemberData* memberData = [[GroupMemberData alloc] initWithPerson:item];
            [self innerAddMemberToCache:memberData];
        }
    }
    
    members_check_status = [self innerCalculateMembersCheckStatus];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_RELOADED
                                                            object:nil
                                                          userInfo:nil];
    });
}

- (void)changeGroupId:(NSInteger)groupId ifReload:(BOOL)ifReload{
    if (group_id != groupId) {
        group_id = (int)groupId;
        if ( ifReload ){
            [self reloadGroupMembers];
        }
        [UserDefaultsManager setObject:[NSNumber numberWithInt:group_id] forKey:CURRENT_CHECKED_GROUP_ID];
        [UserDefaultsManager synchronize];
        
    }
}

- (void)addMemberById:(NSInteger)personId {
    [[self class] addMemberOnMainThreadById:personId toGroup:group_id];
    [self reloadGroupMembers];
}


- (void)addMembers:(NSArray*)memberIds {
    [[self class] addMembers:memberIds toGroup:group_id];
    [self reloadGroupMembers];
}

- (NSInteger)removeMember:(NSInteger)personId {
    // 1 remove from system address book
    [Group removeMemberOfGroup:group_id Person:personId];
    // 2 remove from db
    [ContactGroupDBA deleteGroupMember:personId fromGroup:group_id];
    // 3 remove from cache
    NSInteger oldMembersCount = [members_array count];
    NSInteger newMembersCount = [self innerRemoveMember:personId];
    if (newMembersCount < oldMembersCount) {
        [self innerPostCheckedUpdateNotificationIfNessary];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_MEMBERS_CHANGED object:nil userInfo:nil];
    }
    return newMembersCount;
}

- (NSInteger)removeMembers:(NSArray*)personIds {
    NSInteger oldMembersCount = [members_array count];
    for (NSNumber* item in personIds) {
        NSInteger personId = [item intValue];
        // 1 remove from system address book
        [Group removeMemberOfGroup:group_id Person:personId];
        // 2 remove from db
        [ContactGroupDBA deleteGroupMember:personId fromGroup:group_id];
        // 3 remove from cache
        [self innerRemoveMember:personId];
    }
    if ([members_array count] < oldMembersCount) {
        [self innerPostCheckedUpdateNotificationIfNessary];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_MEMBERS_CHANGED object:nil userInfo:nil];
    }
    return [members_array count];
}

- (void)updateMember:(NSInteger)personId {
    ContactCacheDataManager* syncCacheObj = [ContactCacheDataManager instance];
    ContactCacheDataModel *item = [syncCacheObj contactCacheItem:personId];
    if (item) { // show member in sync only
        GroupMemberData* memberData = [[GroupMemberData alloc] initWithPerson:item];
        NSInteger index = [self getMemberIndexById:personId];
        [members_array replaceObjectAtIndex:index withObject:memberData];
    }
}

- (void)setAllMembersChecked:(BOOL)isChecked {
    
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* memberItem = [members_array objectAtIndex:i];
        memberItem.is_checked = isChecked;
    }
    if ([members_array count] == 0) {
        members_check_status = MembersCheckStatusDisable;
    } else {
        if (isChecked) {
            members_check_status = MembersCheckStatusAll;
        } else {
            members_check_status = MembersCheckStatusNone;
        }
    }
    [self innerPostCheckedUpdateNotification];
}

- (void)setMemersChecked:(BOOL)isChecked persons:(NSArray*)personIds {
    NSInteger count = [personIds count];
    int i = 0;
    for (; i<count; i++) {
        NSInteger personIdItem = [[personIds objectAtIndex:i] intValue];
        [self innerSetMemerChecked:isChecked person:personIdItem];
    }
    [self innerPostCheckedUpdateNotificationIfNessary];
}

- (void)setMemerChecked:(BOOL)isChecked person:(NSInteger)personId {
    [self innerSetMemerChecked:isChecked person:personId];
    [self innerPostCheckedUpdateNotificationIfNessary];
}

- (NSArray*)getMemberIds {
    NSMutableArray* memberIds = [[NSMutableArray alloc] init];
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* item = [members_array objectAtIndex:i];
        [memberIds addObject:[NSNumber numberWithInteger:item.cache_item_data.personID]];
    }
    return memberIds;
}

- (NSArray*)getCheckedMemberIds {
    NSMutableArray* checkedMemberIds = [[NSMutableArray alloc] init];
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* memberItem = [members_array objectAtIndex:i];
        if (memberItem.is_checked) {
            [checkedMemberIds addObject:[NSNumber numberWithInteger:memberItem.cache_item_data.personID]];
        }
    }
    return checkedMemberIds;
}

- (NSInteger)getMembersCount {
    return [members_array count];
}

- (NSInteger)getCheckedMembersCount {
    int count = 0;
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* item = [members_array objectAtIndex:i];
        if (item.is_checked) {
            count++;
        }
    }
    return count;
}

- (NSArray*)getMembersNotInCurrentGroup {
    NSMutableArray* personsNotInGroup = [NSMutableArray arrayWithArray:[[ContactCacheDataManager instance] getAllCacheContact]];
    NSArray* groupMemberIDs = [Group getMemberIDListByGroupID:group_id];
    for (int i=0; i<[personsNotInGroup count]; i++) {
        ContactCacheDataModel* personDataItem = [personsNotInGroup objectAtIndex:i];
        for (NSNumber *item in groupMemberIDs) {
            if ([item intValue] == personDataItem.personID) {
                [personsNotInGroup removeObjectAtIndex:i];
                i--;
            }
        }
    }
    return personsNotInGroup;
}


#pragma mark private

- (NSArray*)innerGetMembersInGroup {
    NSMutableArray* groupMembers = [NSMutableArray arrayWithCapacity:1];
    NSArray* notLocalMembers = [Group getMemberIDListByGroupID:group_id];
    for (NSNumber *item in notLocalMembers) {
        NSInteger personID = [item intValue];
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personID];
        if (personData) {
            [groupMembers addObject:personData];
        }
    }
    return groupMembers;
}

- (NSArray*)innerGetMembersUngrouped {
    NSMutableArray* ungroupedMembers = [NSMutableArray arrayWithArray:[[ContactCacheDataManager instance] getAllCacheContact]];
    NSMutableArray* allMembersInAllGroups =  [NSMutableArray arrayWithArray:[ContactGroupDBA getAllMembersInAllGroups]];
    for (int i=0; i<[ungroupedMembers count]; i++) {
        BOOL bIsMember = NO;
        ContactCacheDataModel* item = [ungroupedMembers objectAtIndex:i];
        for (int j=0; j<[allMembersInAllGroups count]; j++) {
            if (item.personID == [[allMembersInAllGroups objectAtIndex:j] intValue]) {
                bIsMember = YES;
                [allMembersInAllGroups removeObjectAtIndex:j];
                break;
            }
        }
        if (bIsMember) {
            [ungroupedMembers removeObjectAtIndex:i];
            i--;
        }
    }
    return ungroupedMembers;
}

- (NSArray *)getMembersIDUngrouped {
    NSMutableArray* ungroupedMembers = [NSMutableArray arrayWithArray:[[ContactCacheDataManager instance] getAllCacheContactID]];
    NSMutableArray* allMembersInAllGroups =  [NSMutableArray arrayWithArray:[Group getAllMembersIDUnGrouped]];
    for (int i=0; i<[ungroupedMembers count]; i++) {
        BOOL bIsMember = NO;
        NSInteger item = [[ungroupedMembers objectAtIndex:i] intValue];
        for (int j=0; j<[allMembersInAllGroups count]; j++) {
            if (item == [[allMembersInAllGroups objectAtIndex:j] intValue]) {
                bIsMember = YES;
                [allMembersInAllGroups removeObjectAtIndex:j];
                break;
            }
        }
        if (bIsMember) {
            [ungroupedMembers removeObjectAtIndex:i];
            i--;
        }
    }
    return allMembersInAllGroups;

}

- (void)innerPostCheckedUpdateNotificationIfNessary {
    MembersCheckStatus newCheckStatus = [self innerCalculateMembersCheckStatus];
    if (members_check_status != newCheckStatus) {
        members_check_status = newCheckStatus;
        [self innerPostCheckedUpdateNotification];
        if (MembersCheckStatusAll == members_check_status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_MEMBERS_CHECKED_ALL object:nil userInfo:nil];
        } else if (MembersCheckStatusNone == members_check_status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_MEMBERS_CHECKED_NONE object:nil userInfo:nil];
        }
    }
}

- (void)innerPostCheckedUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_MEMBER_MODEL_MEMBERS_CHECK_CHANGED object:nil userInfo:nil];
}

- (void)innerAddMemberById:(NSInteger)personId {
    [[self class] addMemberById:personId toGroup:group_id];
    // add to cache
    [self innerAddMemberToCacheById:personId];
}

- (BOOL)innerAddMemberToCacheById:(NSInteger)personId {
    if ([self checkMemberIsAlreadyInGroup:personId]) {
        return NO;
    }
    ContactCacheDataManager* syncCacheObj = [ContactCacheDataManager instance];
    ContactCacheDataModel *item = [syncCacheObj contactCacheItem:personId];
    if (item) { // show member in sync only
        GroupMemberData* memberData = [[GroupMemberData alloc] initWithPerson:item];
        [self innerAddMemberToCache:memberData];
        return YES;
    }
    return NO;
}

- (void)innerAddMemberToCache:(GroupMemberData*)memberData {
    [members_array addObject:memberData];
}

- (NSInteger)innerRemoveMember:(NSInteger)personId {
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* memberItem = [members_array objectAtIndex:i];
        if (memberItem.cache_item_data.personID == personId) {
            [members_array removeObjectAtIndex:i];
            break;
        }
    }
    return [members_array count];
}

- (void)innerSetMemerChecked:(BOOL)isChecked person:(NSInteger)personId {
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* memberItem = [members_array objectAtIndex:i];
        if (memberItem.cache_item_data.personID == personId) {
            memberItem.is_checked = isChecked;
            return;
        }
    }
}

- (MembersCheckStatus)innerCalculateMembersCheckStatus {
    NSInteger count = [self getMembersCount];
    NSInteger checkCount = [self getCheckedMembersCount];
    if (count == 0) {
        return MembersCheckStatusDisable;
    } else {
        if (checkCount == 0) {
            return MembersCheckStatusNone;
        } else if (checkCount == count) {
            return MembersCheckStatusAll;
        } else {
            return MembersCheckStatusPart;
        }
    }
}

- (NSInteger)getMemberIndexById:(NSInteger)personId {
    int i = 0;
    for (; i<[members_array count]; i++) {
        GroupMemberData* memberItem = [members_array objectAtIndex:i];
        if (memberItem.cache_item_data.personID == personId) {
            return i;
        }
    }
    return -1;
}


- (BOOL)checkMemberIsAlreadyInGroup:(NSInteger)personId {
    for (GroupMemberData *item in members_array) {
        if (item.cache_item_data.personID == personId) {
            return YES;
        }
    }
    return NO;
}

@end
