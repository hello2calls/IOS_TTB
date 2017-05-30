//
//  Group.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "Group.h"
#import "GroupDBA.h"
#import "CootekNotifications.h"

@implementation Group
/*
 #####################################################
 ############Group Operation##########################
 #####################################################
 */

///Get all Group 
///parameter:NULL
///return:NSArray
+(NSArray *)getAllGroups{
	return [GroupDBA getAllGroups];
}

///Get all GroupIDs
///parameter:NULL
///return:NSArray
+(NSArray *)getAllGroupIDs{
	return [GroupDBA getAllGroupIDs];
}

///Get all Group 
///parameter:ABAddressBookRef
///return:NSArray
+(NSArray *)getAllGroupIDs:(ABAddressBookRef)addrBookRef {
	return [GroupDBA getAllGroupIDs:addrBookRef];
}


///create a group
///parameter:NSString
///return:NSInteger
+(NSInteger)addNewGroupByGroupName:(NSString *)group_name{
	return [GroupDBA addNewGroupByGroupName:group_name];
}

///update a group name
///parameter:NSInteger:groupid,NSString: group_name;
///return:BOOL
+(BOOL)editGroupName:(NSInteger)group_id GroupName:(NSString *)group_name{
	return [GroupDBA editGroupName:group_id GroupName:group_name];
}

///delete a group
///parameter:NSInteger:groupid
///return:BOOL
+ (BOOL)deleteGroupByGroupID:(NSInteger)group_id{
	return [GroupDBA deleteGroupByGroupID:group_id];
}

//移除指定组组员
//输入：group_id,person_id
//return:BOOL
+(BOOL)removeMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id{
	return [GroupDBA removeMemberOfGroup:group_id Person:person_id];
}

//批量删除组员
//输入：group_id,person_id_array
//return:BOOL
+(BOOL)removeMultiMemberOfGroup:(NSInteger)group_id Person:(NSArray *)person_id_array{
	return [GroupDBA removeMultiMemberOfGroup:group_id Person:person_id_array];
}

//添加组员
//输入：group_id,person_id
//return:BOOL
+(BOOL)addMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id{
	return [GroupDBA addMemberOfGroup:group_id Person:person_id];
}

+(BOOL)addMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id addressBook:(ABAddressBookRef)ab {
    return [GroupDBA addMemberOfGroup:group_id Person:person_id addressBook:ab];
}


//批量组员
//输入：group_id,person_id_array
//return:BOOL
+(BOOL)addMultiMemberOfGroup:(NSInteger)group_id Person:(NSArray *)person_id_array{
	return [GroupDBA addMultiMemberOfGroup:group_id Person:person_id_array];
}

+(NSArray *)getMemberIDListByGroupID:(NSInteger)group_id {
	return [GroupDBA getMemberIDListByGroupID:group_id];
}

+(NSArray *)getMemberIDListByGroupID:(NSInteger)group_id addressbookRef:(ABAddressBookRef)addressbookRef {
	return [GroupDBA getMemberIDListByGroupID:group_id addressbookRef:addressbookRef];
}

+(NSArray *)getAllMembersIDUnGrouped{
    return [GroupDBA getAllContractIDsNotInGroup];
}

//获取指定组的所有组员
//输入：group_id
//return:BOOL
+(NSArray *)getMemberListByGroupID:(NSInteger)group_id{
	return [GroupDBA getMemberListByGroupID:group_id];
}

//获取除制定组外的所有连系人
//输入：group_id
//return:NSArray
+(NSArray *)getAllContractIDsBesideGroup:(NSInteger)group_id {
	return [GroupDBA getAllContractIDsBesideGroup:group_id];
}

+(NSArray *)getAllContractBesideGroup:(NSInteger)group_id{
	return [GroupDBA getAllContractBesideGroup:group_id];
}
//获取未分组成员
+(NSArray *)getAllContractIDsNotInGroup {
	return [GroupDBA getAllContractIDsNotInGroup];
}

+(NSArray *)getAllContractNotInGroup{
	return [GroupDBA getAllContractNotInGroup];
}
//获取指定组
//输入：group_id
//return:NSArray
+(GroupDataModel *)getGroupByGroupID:(NSInteger)group_id{
	return [GroupDBA getGroupByGroupID:group_id];

}

+(BOOL) isExchangeType {
    return [GroupDBA exchangeSource] != nil;
}

+(BOOL) isMobileType {
    return [GroupDBA mobileMeSource] != nil;
}
@end
