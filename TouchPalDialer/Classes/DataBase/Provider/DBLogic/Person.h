//
//  Person.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-12.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataModel.h"
#import <AddressBook/ABAddressBook.h>

@interface Person : NSObject {

}

+ (NSArray *)queryAllContactsWhenNonCache;

+ (NSArray *)queryAllContacts;

+ (NSArray *)queryAllContactsHavePhones;

+ (ContactCacheDataModel *)getConatctInfoByRecordID:(NSInteger)personID;

+ (ABRecordRef )getPersonByPersonID:(NSInteger)personID
                        addressBook:(ABAddressBookRef)abab;

+ (ABRecordRef)recordRefByPersonID:(NSInteger)personID;

+ (BOOL)isExistsPerson:(NSInteger)record_id;

+ (BOOL)deletePersonByRecordID:(NSInteger)record_id;

+ (BOOL)deletePersonByRecordIDs:(NSInteger)record_id;

+(void)deletePersonByRecordIDsArray:(NSArray *)record_idsArray;

//获取邮件
+ (NSArray *)getEmailsByRecordID:(NSInteger )person_id;

//获取电话号码
+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id;

+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id
                       mainIndex:(NSInteger *)index;

+ (UIImage *)getImageByRecordID:(NSInteger)personID;

//Test
+ (void)makeContact:(NSInteger)iCount;

@end
