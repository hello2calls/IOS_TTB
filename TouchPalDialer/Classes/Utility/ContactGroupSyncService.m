//
//  ContactGroupSyncService.m
//  TouchPalDialer
//
//  Created by Sendor on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContactGroupSyncService.h"
#import "Group.h"
#import "ContactGroupDBA.h"
#import "CootekNotifications.h"
#import "TPAddressBookWrapper.h"
#import "UserDefaultsManager.h"

static ContactGroupSyncService *singletonInstance = nil;

@implementation ContactGroupSyncService

+ (void)initialize
{
    singletonInstance = [[ContactGroupSyncService alloc] init];
}

+ (ContactGroupSyncService *)instance
{
    return singletonInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiSystemContactDataWillChange) name:N_SYSTEM_CONTACT_DATA_WILL_CHANGE object:nil];
    }
    return self;
}

+ (void)startContactGroupSync {
    [[ContactGroupSyncService instance] startContactGroupSyncInner];
}

+ (void)asyncContactGroup
{
    if (![UserDefaultsManager boolValueForKey:KEY_IS_GROUP_FIRST_SYNCHRONIZED]) {
        [NSThread detachNewThreadSelector:@selector(threadFunContactGroupSync)
                                 toTarget:[ContactGroupSyncService instance]
                               withObject:nil];
        [UserDefaultsManager setBoolValue:YES forKey:KEY_IS_GROUP_FIRST_SYNCHRONIZED];
    }
}

+ (void)setSyncStatus:(SyncStatus)status
{
    [[ContactGroupSyncService instance] setSyncStatusInner:status];
}

+ (SyncStatus)getSyncStatus
{
    return [[ContactGroupSyncService instance] getSyncStatusInner];
}

- (void)onNotiSystemContactDataWillChange
{
    [self startContactGroupSyncInner];
}

- (void)startContactGroupSyncInner
{
    NSThread *synThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadFunContactGroupSync) object:nil];
    synThread.threadPriority = 0.3;
    [synThread start];
}

- (void)setSyncStatusInner:(SyncStatus)status
{
    @synchronized(self) {
        sync_status = status;
    }
}

- (SyncStatus)getSyncStatusInner
{
    @synchronized(self) {
        return sync_status;
    }
}

- (void)threadFunContactGroupSync
{
    @autoreleasepool {
        [TPAddressBookWrapper CreateAddressBookRefForCurrentThread];
        [self doContactGroupSync];
        [TPAddressBookWrapper ReleaseAddressBookForCurrentThread];
    }
}

- (void)doContactGroupSync
{
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_SYNCHRONIZING object:nil];
    [self setSyncStatusInner:SyncStatusSynchronizing];
    NSArray *groupIDs = nil;
    ABAddressBookRef abRef = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    if (abRef) {
        groupIDs = [Group getAllGroupIDs:abRef];
    } else {
        cootek_log(@"error when creating ABAddressBookRef entity");
    }
    // merge group
    [ContactGroupDBA mergeAddressbookAllGroups:groupIDs];
    // sync group members
    [ContactGroupDBA copyAddressbookAllGroupMembers:groupIDs];
    [self setSyncStatusInner:SyncStatusSynchronized];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_GROUP_SYNCHRONIZED object:nil];
}

@end
