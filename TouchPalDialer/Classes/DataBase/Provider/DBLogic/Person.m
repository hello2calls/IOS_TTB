//
//  Person.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "Person.h"
#import "PersonDBA.h"

@implementation Person

+(NSArray *)queryAllContactsWhenNonCache
{
    return [PersonDBA  queryAllContactsWhenNonCache];
}

+(ContactCacheDataModel *)getConatctInfoByRecordID:(NSInteger)personID
{
    return [PersonDBA getConatctInfoByRecordID:personID];
}
+ (NSArray *)queryAllContacts
{
    return [PersonDBA queryAllContacts];
}

+ (NSArray *)queryAllContactsHavePhones
{
    return [PersonDBA queryAllContactsHavePhones];
}

+(ABRecordRef)getPersonByPersonID:(NSInteger)personID
                      addressBook:(ABAddressBookRef)abab
{
    return [PersonDBA getPersonByPersonID:personID addressBook:abab];
}

+ (ABRecordRef)recordRefByPersonID:(NSInteger)personID
{
    return [PersonDBA getPersonByPersonID:personID];
}
+(BOOL)isExistsPerson:(NSInteger)record_id
{
	return [PersonDBA isExistsPerson:record_id];
}

+(BOOL)deletePersonByRecordID:(NSInteger)record_id
{
	return [PersonDBA deletePersonByRecordID:record_id];
}

+(BOOL)deletePersonByRecordIDs:(NSInteger)record_id
{
    return [PersonDBA deletePersonByRecordIDs:record_id];
}

+(void)deletePersonByRecordIDsArray:(NSArray *)record_idsArray
{
    return [PersonDBA deletePersonByRecordIDsArray:record_idsArray];
}

+ (NSArray *)getEmailsByRecordID:(NSInteger )person_id
{
	return [PersonDBA getEmailsByRecordID:person_id];
}

+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id
{
	return [PersonDBA getPhonesByRecordID:person_id];
}

+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id
                       mainIndex:(NSInteger *)index
{
	return [PersonDBA getPhonesByRecordID:person_id mainIndex:index];
}

+ (UIImage *)getImageByRecordID:(NSInteger)personID
{
    return [PersonDBA getImageByRecordID:personID];
}

//Test
+ (void)makeContact:(NSInteger)iCount
{
	[PersonDBA makeContact:iCount];
}

@end
