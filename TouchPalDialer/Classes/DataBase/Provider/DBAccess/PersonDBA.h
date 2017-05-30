//
//  PersonDBA.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-8.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataModel.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABMultiValue.h>
#import <ContactsUI/ContactsUI.h>

#define LOCAL_SOCIAL_WEIBO @"weibo"
#define LOCAL_SOCIAL_TWITTER @"twitter"
#define LOCAL_SOCIAL_FACEBOOK @"facebook"

@interface PersonDBA : NSObject {

}

+ (NSArray *)queryAllContactsWhenNonCache;

+ (NSArray *)queryAllContacts;

+ (NSArray *)queryAllContactsHavePhones;

+ (NSArray *)queryAllContactsNotRegisterHaveHavePhones;

+ (NSArray *)getAsyncAllContact:(ABAddressBookRef)addrBookRef;

+ (NSArray *)getAsyncAllContactWhenAddressBookChanged:(ABAddressBookRef)addrBookRef;

+ (ContactCacheDataModel *)getConatctInfoByRecordID:(NSInteger)personID;
+ (ContactCacheDataModel *)getConatctInfoByRecordID:(NSInteger)personID usingCNContact:(BOOL)usingCNContact;

+ (ContactCacheDataModel *)contactCacheDataModelByRecord:(ABRecordRef)person;

+ (ContactCacheDataModel *)contactCacheDataModelByContact:(CNContact*)contact;

+ (ABRecordRef)getPersonByPersonID:(NSInteger)personID
                       addressBook:(ABAddressBookRef)abab;

+ (ABRecordRef)getPersonByPersonID:(NSInteger)personID;

+ (CNContact*)getContactByPersonID:(NSInteger)personID;

+ (BOOL)isExistsPerson:(NSInteger)record_id;

+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id
                       mainIndex:(NSInteger *)index;

+ (NSArray *)getEmailsByRecordID:(NSInteger )person_id;

+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id;

+ (NSArray *)getAddressByRecordID:(NSInteger)personID;

+ (NSArray *)getDatesByRecordID:(NSInteger)personID;

+ (NSArray *)getURLsByRecordID:(NSInteger)personID;

+ (NSArray *)getIMsByRecordID:(NSInteger)personID;

+ (NSArray *)getRelatedNamesByRecordID:(NSInteger)personID;

+ (NSArray *)getLocalSocialProfilesByRecordID:(NSInteger)personID;

+ (NSString *)getNoteByRecordID:(NSInteger)personID;

+ (NSString *)getCreateDateByRecordID:(NSInteger)personID;

+ (NSString *)getBirthdayByRecordID:(NSInteger)personID;
+ (NSDate *)getBirthdayDateByRecordID:(NSInteger)recordID;

+ (NSString *)getCompanyByRecordID:(NSInteger)personID;

+ (NSString *)getNickNameByRecordID:(NSInteger)personID;

+ (NSString *)getDepartmentByRecordID:(NSInteger)personID;

+ (NSString *)getJobTitleByRecordID:(NSInteger)personID;

+ (UIImage *)getImageByRecordID:(NSInteger)personID;

+ (UIImage *)getDefaultImageByPersonID:(NSInteger)personID isCootekUser:(BOOL)isCootekUser;

+ (UIImage *)getDefaultImageWithoutNameByPersonID:(NSInteger)personID;


+ (UIImage *)getDefaultColorImageWithoutPersonID;

+ (BOOL)deletePersonByRecordID:(NSInteger)record_id;

+ (BOOL)deletePersonByRecordIDs:(NSInteger)record_ids;

+ (void)deletePersonByRecordIDsArray:(NSArray *)record_idsArray;

+ (LabelDataModel *)mainNumberByRecordID:(NSInteger)personID;

/*test create note and contacts*/
+ (void)createContact:(NSString *)username
          usercontact:(NSString*)usercontact;

+ (CFStringRef)switchLabel;

+ (void)makeContact:(NSInteger)iCount;

+ (BOOL)saveNoteInfo:(NSString *)note
           ByRecordId:(int)Id;

+(void)getAllios9IdDic;
@end
