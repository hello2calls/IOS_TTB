//
//  GroupDBA.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-8.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "GroupDBA.h"
#import "PersonDBA.h"
#import "DataBaseModel.h"
#include <unistd.h>
#import "BasicUtil.h"
#import "TPAddressBookWrapper.h"
#import "ContactCacheDataManager.h"

@implementation GroupDBA

//Description:Set the group Info
//Input:ABRecordRef
//return:GroupDataModel
+(GroupDataModel *)SetGroupInfoByRecord:(ABRecordRef)group{
	if (group) {
		GroupDataModel *group_info=[[GroupDataModel alloc] init];
		group_info.groupID=[self getGroupIDByRecord:group];
        CFTypeRef tmpName = ABRecordCopyValue(group, kABGroupNameProperty);
		group_info.groupName=(__bridge NSString *)tmpName;
		group_info.memberCount=[self getMembercountOfGroup:group];	 
		group_info.groupRecord=group; 
        SAFE_CFRELEASE_NULL(tmpName);
		return group_info;	 
	}else {
		return nil;
	}
}

//Description:get GroupID
//Input:ABRecordRef
//return:ABRecordID
+(ABRecordID)getGroupIDByRecord:(ABRecordRef)group{
	if (!group) {
		return -1;//unsuccessful
	}
	return ABRecordGetRecordID(group);
}

//Description:get Member count of th group;
//Input:ABRecordRef
//return:ABRecordID
+(NSInteger)getMembercountOfGroup:(ABRecordRef) group{
	if (!group) {
		return 0;
	}
	CFArrayRef members = ABGroupCopyArrayOfAllMembers(group);
	int retCount = 0;
	if (members) {
		retCount = CFArrayGetCount(members);
		CFRelease(members);
	}

	return retCount;
}

//Description:get Member List of th group;
//Input:ABRecordRef
//return:ABRecordID
+(NSArray *)getMemberIDListByGroup:(ABRecordRef)group {
	if (!group) {
		return nil;
	}
	CFArrayRef memberIds = ABGroupCopyArrayOfAllMembers(group);
	if (!memberIds) {
		return nil;
	}
	int member_count = CFArrayGetCount(memberIds);
	NSMutableArray *member_id_list = [NSMutableArray arrayWithCapacity:3];
	for (int i=0; i<member_count; i++) {
		ABRecordRef person=CFArrayGetValueAtIndex(memberIds, i);
        if (person) {
            NSInteger personID = ABRecordGetRecordID(person);
            [member_id_list addObject:[NSNumber numberWithInt:personID]];
        }
	}
	CFRelease(memberIds);
	return member_id_list ;
    // 是否需要release memberIds，待调查
}

+(NSArray *)getMemberListByGroup:(ABRecordRef)group{
    if ([[[UIDevice currentDevice]systemVersion]floatValue]<7.0) {
        return [self getMemberListByGroup:group sortOrdering:kABPersonSortByFirstName];
    }
    ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormatForRecord(NULL);
    if (kABPersonCompositeNameFormatFirstNameFirst == compositeNameFormat) {
        return [self getMemberListByGroup:group sortOrdering:kABPersonSortByFirstName];
    } else {
        return [self getMemberListByGroup:group sortOrdering:kABPersonSortByLastName];
    }
}

+(NSArray *)getMemberListByGroup:(ABRecordRef)group sortOrdering:(ABPersonSortOrdering)sortOrdering {
	if (!group) {
		return nil;
	}
	CFArrayRef members=ABGroupCopyArrayOfAllMembersWithSortOrdering(group, sortOrdering);
    //                 
	if (!members) {
		return nil;
	}
	int member_count=CFArrayGetCount(members);
	NSMutableArray *member_list=[NSMutableArray arrayWithCapacity:3];
	for (int i=0; i<member_count; i++) {
		ABRecordRef person=CFArrayGetValueAtIndex(members, i);
		ContactCacheDataModel *person_info=[PersonDBA contactCacheDataModelByRecord:person];
		[member_list addObject:person_info];
	
	}
	CFRelease(members);
	return member_list ;
}

///Get all Group 
///parameter:NULL
///return:NSArray
+(NSArray *)getAllGroups{
	NSMutableArray *group_list=[NSMutableArray arrayWithCapacity:3];
		CFArrayRef all_group_in_address_book = ABAddressBookCopyArrayOfAllGroups([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread]);
		int group_count=CFArrayGetCount(all_group_in_address_book);
		for (int i=0; i<group_count;i++) {
			ABRecordRef group=CFArrayGetValueAtIndex(all_group_in_address_book, i);
			GroupDataModel *group_info=[self SetGroupInfoByRecord:group];
			if (group_info.groupName) {
				[group_list addObject:group_info];
			}		
		}
	if (all_group_in_address_book) {
		CFRelease(all_group_in_address_book);
	}
    return group_list;
}

///Get all Group ID
///parameter:NULL
///return:NSArray
+(NSArray *)getAllGroupIDs{
	NSMutableArray *groupIDList=[NSMutableArray arrayWithCapacity:3];
    CFArrayRef allGroupInAddressBook = ABAddressBookCopyArrayOfAllGroups([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread]);
    int group_count=CFArrayGetCount(allGroupInAddressBook);
    for (int i=0; i<group_count;i++) {
        ABRecordRef group=CFArrayGetValueAtIndex(allGroupInAddressBook, i);
        [groupIDList addObject:[NSNumber numberWithInt:[self getGroupIDByRecord:group]]];
    }
	if (allGroupInAddressBook) {
		CFRelease(allGroupInAddressBook);
	}
    return groupIDList;
}


///Get all Group ID
///parameter:ABAddressBookRef
///return:NSArray
+(NSArray *)getAllGroupIDs:(ABAddressBookRef)addrBookRef {
	NSMutableArray *groupIDList=[NSMutableArray arrayWithCapacity:3];
    CFArrayRef allGroupInAddressBook = ABAddressBookCopyArrayOfAllGroups(addrBookRef);
    int group_count=CFArrayGetCount(allGroupInAddressBook);
    for (int i=0; i<group_count;i++) {
        ABRecordRef group=CFArrayGetValueAtIndex(allGroupInAddressBook, i);
        [groupIDList addObject:[NSNumber numberWithInt:[self getGroupIDByRecord:group]]];
    }
	if (allGroupInAddressBook) {
		CFRelease(allGroupInAddressBook);
	}
    return groupIDList;    
}


///create a group
///parameter:NSString
///return:NSInteger
+(NSInteger)addNewGroupByGroupName:(NSString *)group_name
{    
	if (group_name&&!([group_name isEqualToString:@""])) {
		BOOL setResult=NO,addResult=NO, saveResult=NO;
		ABAddressBookRef book =[TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
		//ABRecordRef group = ABGroupCreate();
        ABRecordRef localSource = [self sourceWithType:kABSourceTypeLocal];
        ABRecordRef group  = ABGroupCreateInSource(localSource);
        CFErrorRef addError = CFErrorCreate(NULL, ABAddressBookErrorDomain, kABOperationNotPermittedByStoreError, NULL); //
		setResult = ABRecordSetValue(group, kABGroupNameProperty,(__bridge CFStringRef)group_name, &addError);
		if (setResult) {	
			addResult = ABAddressBookAddRecord(book,group,&addError);
			if (addResult) {
				saveResult = ABAddressBookSave(book, &addError);
				if (saveResult) {
					NSInteger groupID=ABRecordGetRecordID(group);	
                    SAFE_CFRELEASE_NULL(addError);
                    SAFE_CFRELEASE_NULL(group);	
					return groupID;
				}
			}
		}
        SAFE_CFRELEASE_NULL(addError);
		SAFE_CFRELEASE_NULL(group);
		return -1;
	}else {
		return -1;//unsucessful
	}
}
+(BOOL)editGroupName:(NSInteger)group_id GroupName:(NSString *)group_name;
{
	if (group_id&&group_name&&!([group_name isEqualToString:@""])) {	
		ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];		
		ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(book, group_id);
		if (groupRef) {	
			BOOL is_Add=ABRecordSetValue(groupRef, kABGroupNameProperty,(__bridge CFTypeRef)(group_name), NULL);
			if (is_Add) {
				ABAddressBookAddRecord(book, groupRef, NULL);
			}	
			return ABAddressBookSave(book, NULL);
		}else {
			return NO;
		}		
	}else {
		return NO;
	}
}
+ (BOOL)deleteGroupByGroupID:(NSInteger)group_id{
	if(group_id&&group_id>0) {
		ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
		ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(ab, group_id);
		if (groupRef) {		
			CFErrorRef err = NULL;
			ABAddressBookRemoveRecord(ab, groupRef, &err);
			err = NULL;
			return ABAddressBookSave(ab, &err);
		}else {
			return NO;
		}		
	}else {
		return NO;
	}
}
//组员是否存在组内
//输入：group,person
//return:BOOL
+(BOOL)isExistsMemberOfGroup:(ABRecordRef)group Person:(ABRecordRef)person
{
	if (group&&person) {
      	CFArrayRef members=ABGroupCopyArrayOfAllMembers(group);
		if (!members) {
			return NO;
		}
		int member_count=CFArrayGetCount(members);
		for (int i=0; i<member_count; i++) {
			ABRecordRef personRef=CFArrayGetValueAtIndex(members, i);
			if (personRef==person) {
				CFRelease(members);
				return YES;
			}
		}
		CFRelease(members);
		return NO;
	}else {
		return NO;
	}
}
//移除指定组组员
//输入：group_id,person_id
//return:BOOL
+(BOOL)removeMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id
{
	if (!group_id||!person_id||group_id<=0||person_id<=0) {
		return NO;
	}
	CFErrorRef err = NULL;
	ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, person_id);
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(ab, group_id);
	if (personRef&&groupRef) {
		if ([self isExistsMemberOfGroup:groupRef Person:personRef]) {		
			ABGroupRemoveMember(groupRef,personRef,&err);
			err = NULL;
			return  ABAddressBookSave (ab,&err);	
		}else {
			return NO;
		}

	}else {
		return NO;
	}
}

//批量删除组员
//输入：group_id,person_id_array
//return:BOOL
+(BOOL)removeMultiMemberOfGroup:(NSInteger)group_id Person:(NSArray *)person_id_array
{
	if (!group_id||!person_id_array||group_id<=0||[person_id_array count]<=0) {
		return NO;
	}
	CFErrorRef err = NULL;
	ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(ab, group_id);
	if (groupRef) {
		for (int i=0; i<[person_id_array count]; i++) {
			NSInteger person_id=[[person_id_array objectAtIndex:i] integerValue];
			ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, person_id);
			if (personRef) {
				if ([self isExistsMemberOfGroup:groupRef Person:personRef])
				{
					ABGroupRemoveMember(groupRef,personRef,&err);
					err = NULL;
				}
			}			
		}
		return  ABAddressBookSave (ab,&err);			
	}else {return NO;}
}
//添加组员
//输入：group_id,person_id
//return:BOOL
+(BOOL)addMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id {
    ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    return [self addMemberOfGroup:group_id Person:person_id addressBook:ab];
}

+(BOOL)addMemberOfGroup:(NSInteger)group_id Person:(NSInteger)person_id addressBook:(ABAddressBookRef)ab;
{
	if (!group_id||!person_id||group_id<=0||person_id<=0) {
		return NO;
	}
	CFErrorRef err;
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(ab, group_id);
	ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, person_id);
	if (personRef&&groupRef) {
		if (![self isExistsMemberOfGroup:groupRef Person:personRef]) {
			if (ABGroupAddMember(groupRef,personRef,&err)) {
				return  ABAddressBookSave (ab,&err);
			}
		}			
	}
	return NO;

}

//批量添加组员
//输入：group_id,person_id_array
//return:BOOL
+(BOOL)addMultiMemberOfGroup:(NSInteger)group_id Person:(NSArray *)person_id_array
{
	if (!group_id||!person_id_array||group_id<=0||[person_id_array count]<=0) {
		return NO;
	}
	CFErrorRef err = NULL;
	ABAddressBookRef ab =  [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(ab, group_id);
	if (groupRef) {
		for (int i=0; i<[person_id_array count]; i++) {
			ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [[person_id_array objectAtIndex:i] integerValue]);
			if (personRef) {
				if (![self isExistsMemberOfGroup:groupRef Person:personRef]) 
				{
                    bool isResult =	ABGroupAddMember(groupRef,personRef,&err);
                    if (!isResult) {
                        cootek_log(@"ABGroupAddMember falied, error:%@", err);
                    }
					err = NULL;
				}
			}		
		}	
		return ABAddressBookSave (ab,&err);	

		 
	}else {
		return NO;
	}
}

+(NSArray *)getMemberIDListByGroupID:(NSInteger)group_id {
    if (!group_id||group_id<=0) {
		return nil;
	}
	ABAddressBookRef ab =  [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(ab, group_id);
	return [self getMemberIDListByGroup:groupRef];	
    
}

+(NSArray *)getMemberIDListByGroupID:(NSInteger)group_id addressbookRef:(ABAddressBookRef)addressbookRef {
    if (!group_id||group_id<=0) {
		return nil;
	}
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(addressbookRef, group_id);
	return [self getMemberIDListByGroup:groupRef];	
}


//获取指定组的所有组员
//输入：group_id
//return:BOOL
+(NSArray *)getMemberListByGroupID:(NSInteger)group_id
{
	if (!group_id||group_id<=0) {
		return nil;
	}
	ABAddressBookRef ab =  [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef groupRef =  ABAddressBookGetGroupWithRecordID(ab, group_id);
	return [self getMemberListByGroup:groupRef];	
	
}

//获取除制定组外的所有连系人
//输入：group_id
//return:NSArray
+(NSArray *)getAllContractIDsBesideGroup:(NSInteger)group_id {
	if (!group_id||group_id<=0) {
		return nil;
	}
	NSArray *all_person_list = [[ContactCacheDataManager instance] getAllCacheContact];
	NSMutableDictionary *except_person=[[NSMutableDictionary alloc] init];
	int member_count=[all_person_list count];
	for (int i=0; i<member_count; i++) {
		ContactCacheDataModel *person=[all_person_list objectAtIndex:i];
		[except_person setObject:person forKey:[NSNumber numberWithInt:person.personID]];
	}
    NSArray *member_list=[self getMemberListByGroupID:group_id];
    int group_member_count=0;
	for (int i=0; i<group_member_count; i++) {
		ContactCacheDataModel *person=[member_list objectAtIndex:i];
		ContactCacheDataModel *temp=[except_person objectForKey:[NSNumber numberWithInt:person.personID]];
		if (temp) {
			[except_person removeObjectForKey:[NSNumber numberWithInt:person.personID]];
		}
	}
	NSArray *not_in_group_list=[[NSArray alloc] initWithArray:[except_person allKeys]];
	return  not_in_group_list;
}

+(NSArray *)getAllContractBesideGroup:(NSInteger)group_id
{
	if (!group_id||group_id<=0) {
		return nil;
	}
	NSArray *all_person_list =[[ContactCacheDataManager instance] getAllCacheContact];
	NSMutableDictionary *except_person=[[NSMutableDictionary alloc] init];
	int member_count=[all_person_list count];
	for (int i=0; i<member_count; i++) {
		ContactCacheDataModel *person=[all_person_list objectAtIndex:i];
		[except_person setObject:person forKey:[NSNumber numberWithInt:person.personID]];
	}
    NSArray *member_list=[self getMemberListByGroupID:group_id];
    int group_member_count=0;
	for (int i=0; i<group_member_count; i++) {
		ContactCacheDataModel *person=[member_list objectAtIndex:i];
		ContactCacheDataModel *temp=[except_person objectForKey:[NSNumber numberWithInt:person.personID]];
		if (temp) {
			[except_person removeObjectForKey:[NSNumber numberWithInt:person.personID]];
		}
	}
	NSArray *not_in_group_list=[[NSArray alloc] initWithArray:[except_person allValues]];
	return  not_in_group_list;
}


//未分组
+(NSArray *)getAllContractIDsNotInGroup {
	NSArray *all_person_list = [[ContactCacheDataManager instance] getAllCacheContact];
	NSMutableDictionary *except_person=[[NSMutableDictionary alloc] init];
	int member_count=[all_person_list count];
	for (int i=0; i<member_count; i++) {
		ContactCacheDataModel *person=[all_person_list objectAtIndex:i];
		[except_person setObject:person forKey:[NSNumber numberWithInt:person.personID]];
	}
	NSArray *group_list=[self getAllGroups];
	int group_count=[group_list count];
	for (int i=0; i<group_count; i++) {
		GroupDataModel *group=[group_list objectAtIndex:i];
		NSArray *member_list=[self getMemberListByGroupID:group.groupID];
		int group_member_count=[member_list count];
		for (int j=0; j<group_member_count; j++) {
			ContactCacheDataModel *member=[member_list objectAtIndex:j];
			ContactCacheDataModel *tem_person=[except_person objectForKey:[NSNumber numberWithInt:member.personID]];
			if (tem_person) {
				[except_person removeObjectForKey:[NSNumber numberWithInt:member.personID]];
			}
		}	
	}
	NSArray *not_in_group_list=[[NSArray alloc] initWithArray:[except_person allKeys]];
	return  not_in_group_list;
}

+(NSArray *)getAllContractNotInGroup
{
	NSArray *all_person_list = [[ContactCacheDataManager instance] getAllCacheContact];
	NSMutableDictionary *except_person=[[NSMutableDictionary alloc] init];
	int member_count=[all_person_list count];
	for (int i=0; i<member_count; i++) {
		ContactCacheDataModel *person=[all_person_list objectAtIndex:i];
		[except_person setObject:person forKey:[NSNumber numberWithInt:person.personID]];
	}
	NSArray *group_list=[self getAllGroups];
	int group_count=[group_list count];
	for (int i=0; i<group_count; i++) {
		GroupDataModel *group=[group_list objectAtIndex:i];
		NSArray *member_list=[self getMemberListByGroupID:group.groupID];
		int group_member_count=[member_list count];
		for (int j=0; j<group_member_count; j++) {
			ContactCacheDataModel *member=[member_list objectAtIndex:j];
			ContactCacheDataModel *tem_person=[except_person objectForKey:[NSNumber numberWithInt:member.personID]];
			if (tem_person) {
				[except_person removeObjectForKey:[NSNumber numberWithInt:member.personID]];
			}
		}	
	}
	NSArray *not_in_group_list=[[NSArray alloc] initWithArray:[except_person allValues]];
	return  not_in_group_list;
}
//获取指定组
//输入：group_id
//return:NSArray
+(GroupDataModel *)getGroupByGroupID:(NSInteger)group_id
{	
	if(group_id&&group_id>0) {
		ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
		ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(ab, group_id);
		if (groupRef) {return [self SetGroupInfoByRecord:groupRef];	}
		else {return nil;}
	}else {
		return nil;
	}
}

+(BOOL)createGroupByGroupName:(NSString*)groupName{
	sqlite3 *database;
	NSString *filepath = @"/var/mobile/Library/AddressBook/AddressBook.sqlitedb";
	if (sqlite3_open([filepath UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
	}
	BOOL result = YES;
	const char *createLogSql = "INSERT INTO ABGroup(Name,StoreID) VALUES(?,0)";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(database, createLogSql, -1, &stmt, NULL) == SQLITE_OK) {
		sqlite3_bind_text(stmt, 1, [groupName UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(stmt) == SQLITE_ERROR) {
			result = NO;
		}
	}else {
		result = NO;
	}
	sqlite3_finalize(stmt);
	return result;
}

+(NSInteger)getMaxGroupId{
	NSInteger groupId = -1;
	sqlite3 *database;
	NSString *filepath = @"/var/mobile/Library/AddressBook/AddressBook.sqlitedb";
	if (sqlite3_open([filepath UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
	}
	sqlite3_stmt *stmt;
	const char *getCountSql = "SELECT ROWID FROM ABGroup ORDER BY ROWID DESC limit 0,1";
	if (sqlite3_prepare_v2(database, getCountSql, -1, &stmt, NULL) == SQLITE_OK) {
		if (sqlite3_step(stmt) == SQLITE_ROW){
			groupId = sqlite3_column_int(stmt, 0);
		}		
	}
	sqlite3_finalize(stmt);
	return groupId;
}
+(BOOL)isJailBreak{
	int res = access("/var/mobile/Library/AddressBook/AddressBook.sqlitedb", 0);
	if (res != 0)
		return NO;
	return YES;
}

+(BOOL)createGroupMembers:(NSInteger)group_id member_id:(NSInteger)member_id{
	BOOL result = YES;
	sqlite3 *database;
	NSString *filepath = @"/var/mobile/Library/AddressBook/AddressBook.sqlitedb";
	if (sqlite3_open([filepath UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
	}
	const char *createLogSql = "INSERT INTO ABGroupMembers(group_id,member_id,member_type) VALUES(?,?,?)";
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2(database, createLogSql, -1, &stmt, NULL) == SQLITE_OK) {
		sqlite3_bind_int(stmt,1,group_id);
		sqlite3_bind_int(stmt,2,member_id);
		sqlite3_bind_int(stmt,3,0);
		if (sqlite3_step(stmt) == SQLITE_ERROR) {
			result = NO;
		}
	}else {
		result = NO;
	}
	sqlite3_finalize(stmt);
	return result;
}

#define CFRELEASE_AND_NIL(x) CFRelease(x); x=nil;
+(ABRecordRef) sourceWithType:(ABSourceType) mySourceType
{
    ABAddressBookRef addressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    CFArrayRef sources = ABAddressBookCopyArrayOfAllSources(addressBook);
    CFIndex sourceCount = CFArrayGetCount(sources);
    ABRecordRef resultSource = NULL;
    for (CFIndex i = 0 ; i < sourceCount; i++) {
        ABRecordRef currentSource = CFArrayGetValueAtIndex(sources, i);
        CFTypeRef sourceType = ABRecordCopyValue(currentSource, kABSourceTypeProperty);
        
        BOOL isMatch = mySourceType == [(__bridge NSNumber *)sourceType intValue];
        CFRELEASE_AND_NIL(sourceType);
        
        if (isMatch) {
            resultSource = CFRetain(currentSource);
            CFRELEASE_AND_NIL(currentSource);
            break;
        }
    }
     
    CFRELEASE_AND_NIL(sources);
    
    return resultSource;
}

+(ABRecordRef) localSource
{
    return [self sourceWithType:kABSourceTypeLocal];
}

+(ABRecordRef) exchangeSource
{
    return [self sourceWithType:kABSourceTypeExchange];
}

+(ABRecordRef) mobileMeSource
{
    return [self sourceWithType:kABSourceTypeMobileMe];
}
@end
