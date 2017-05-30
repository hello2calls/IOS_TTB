//
//  ContactGroupDBA.h
//  TouchPalDialer
//
//  Created by Sendor on 12-2-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactGroupDBA : NSObject {

}

+ (NSArray*)getAllGroups;
+ (NSArray*)getMembersInGroup:(NSInteger)groupID;
+ (NSArray*)getMembersInGroup:(NSInteger)groupID exceptSource:(NSInteger)sourceType;
+ (NSArray*)getAllMembersInAllGroups;
+ (NSArray*)getMemberGroups:(NSInteger)memberID;
+ (void)addGroup:(NSInteger)groupID;
+ (void)addGroups:(NSArray*)groupIDs;
+ (void)deleteGroup:(NSInteger)groupID;
+ (void)addGroupMember:(NSInteger)memberID sourceType:(NSInteger)sourceType toGroup:(NSInteger)groupID;
+ (void)addGroupMembers:(NSArray*)memberIDs sourceType:(NSInteger)sourceType toGroup:(NSInteger)groupID;
+ (void)deleteGroupMember:(NSInteger)memberID fromGroup:(NSInteger)groupID;
+ (void)resetGroups:(NSArray*)groups;
+ (void)mergeAddressbookAllGroups:(NSArray*)groupIDs;
+ (void)copyAddressbookAllGroupMembers:(NSArray*)groupIDs;
+ (void)addGroupInner:(NSInteger)groupID;
+ (void)innerAddGroupMember:(NSInteger)memberID sourceType:(NSInteger)sourceType toGroup:(NSInteger)groupID;
+ (void)innerDeleteGroupMember:(NSInteger)memberID fromGroup:(NSInteger)groupID;

@end
