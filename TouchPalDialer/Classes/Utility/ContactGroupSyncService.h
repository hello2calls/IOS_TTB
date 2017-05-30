//
//  ContactGroupSyncService.h
//  TouchPalDialer
//
//  Created by Sendor on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum tag_SyncStatus {
    SyncStatusSynchronizing,
    SyncStatusSynchronized,    
}SyncStatus;


@interface ContactGroupSyncService : NSObject {
    SyncStatus sync_status;
}

+ (void)startContactGroupSync;
+ (void)asyncContactGroup;

+ (void)setSyncStatus:(SyncStatus)status;
+ (SyncStatus)getSyncStatus;

+ (ContactGroupSyncService *)instance;
- (id)init;
- (void)startContactGroupSyncInner;
- (void)setSyncStatusInner:(SyncStatus)status;
- (SyncStatus)getSyncStatusInner;
- (void)doContactGroupSync;

@end
