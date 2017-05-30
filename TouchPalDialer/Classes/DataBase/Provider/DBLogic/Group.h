//
//  Group.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupDataModel.h"

@interface Group : NSObject {

}
/*
 #####################################################
 ############Group Operation##########################
 #####################################################
 */

///Get all Group 
///parameter:NULL
///return:NSArray
+(NSArray *)getAllGroups;

///Get all Group
///parameter:NULL
///return:NSArray
+(NSArray *)getAllGroupIDs;

///Get all Group 
///parameter:ABAddressBookRef
///return:NSArray
+(NSArray *)getAllGroupIDs:(ABAddressBookRef)addrBookRef;

///create a group
///parameter:NSString
///return:NSInteger
+(NSInteger)addNewGroupByGroupName:(NSString *)group_name;

///update a group name
///parameter:NSInteger:groupid,NSString: group_name;
///return:BOOL
+(BOOL)editGroupName:(NSInteger)group_id GroupName:(NSString *)group_name;

///delete a group
///parameter:NSInteger:groupid
///return:BOOL
+ (BOOL)deleteGroupByGroupID:(NSInteger)group_id;

//移除指定组组员
//输入：group_id,person_id
//return:BOOL
+(BOOL)removeMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id;

//批量删除组员
//输入：group_id,person_id_array
//return:BOOL
+(BOOL)removeMultiMemberOfGroup:(NSInteger)group_id Person:(NSArray *)person_id_array;

//添加组员
//输入：group_id,person_id
//return:BOOL
+(BOOL)addMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id;
+(BOOL)addMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id addressBook:(ABAddressBookRef)ab;

//批量组员
//输入：group_id,person_id_array
//return:BOOL
+(BOOL)addMultiMemberOfGroup:(NSInteger)group_id Person:(NSArray *)person_id_array;

//获取指定组的所有组员
//输入：group_id
//return:BOOL
+(NSArray *)getMemberIDListByGroupID:(NSInteger)group_id;
+(NSArray *)getMemberIDListByGroupID:(NSInteger)group_id addressbookRef:(ABAddressBookRef)addressbookRef;
+(NSArray *)getMemberListByGroupID:(NSInteger)group_id;
+(NSArray *)getAllMembersIDUnGrouped;

//获取除制定组外的所有连系人
//输入：group_id
//return:NSArray
+(NSArray *)getAllContractIDsBesideGroup:(NSInteger)group_id;
+(NSArray *)getAllContractBesideGroup:(NSInteger)group_id;

//获取未分组成员
+(NSArray *)getAllContractIDsNotInGroup;
+(NSArray *)getAllContractNotInGroup;

//获取指定组
//输入：group_id
//return:NSArray
+(GroupDataModel *)getGroupByGroupID:(NSInteger)group_id;

+(BOOL)isExchangeType;
+(BOOL)isMobileType;
@end
