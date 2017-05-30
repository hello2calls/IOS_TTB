//
//  PersonDBA.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-8.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "PersonDBA.h"
#import "DataBaseModel.h"
#import "consts.h"
#import "Favorites.h"
#import "SyncContactInApp.h"
#import "CootekNotifications.h"
#import "TPAddressBookWrapper.h"
#import "ContactCacheDataModel.h"
#import "AddressDataModel.h"
#import "IMDataModel.h"
#import "NSString+TPHandleNil.h"
#import "ContactCacheDataManager.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"
#import "AntiharassAdressbookUtil.h"

static NSMutableDictionary *ios9IdDic;
@implementation PersonDBA

+ (NSArray *)queryAllContactsWhenNonCache
{
    //ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormatForRecord(NULL);
    ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormat();
    if (kABPersonCompositeNameFormatFirstNameFirst == compositeNameFormat) {
        return [self allCacaheABDataContact:kABPersonSortByFirstName];
    } else {
        return [self allCacaheABDataContact:kABPersonSortByLastName];
    }
}

+ (ContactCacheDataModel *)contactDataModelByRecord:(ABRecordRef)person
{
	if (person) {
        NSInteger personID = ABRecordGetRecordID(person);
        CFTypeRef tmpName = ABRecordCopyCompositeName(person);
        NSString *fullName = (__bridge NSString *)tmpName;
        
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSMutableArray *cachePhones = [NSMutableArray arrayWithCapacity:1];
        if (phones) {
            int count = ABMultiValueGetCount(phones);
            for (CFIndex i = 0; i < count; i++) {
                CFTypeRef tmpString = ABMultiValueCopyValueAtIndex(phones, i);
                PhoneDataModel *phone =  [[PhoneDataModel alloc] init];
                phone.number = (__bridge NSString*)tmpString;
                SAFE_CFRELEASE_NULL(tmpString);
                [cachePhones addObject:phone];
            }
            SAFE_CFRELEASE_NULL(phones);
        }
		ContactCacheDataModel *contact = [[ContactCacheDataModel alloc] initWithPersonID:personID
                                                                                fullName:fullName
                                                                              lastUpdate:0
                                                                                   Phone:cachePhones];
        SAFE_CFRELEASE_NULL(tmpName);
        
		return contact;
	}
    return nil;
}

+ (ContactCacheDataModel *)contactCacheDataModelByRecord:(ABRecordRef)person
{
	if (person) {
        NSInteger personID = ABRecordGetRecordID(person);
        
        CFTypeRef cfLastModifiedDate = ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSInteger time = 0;
        if (cfLastModifiedDate) {
            NSDate * lastModifiedDate = (__bridge NSDate *)cfLastModifiedDate;
            time = [lastModifiedDate timeIntervalSince1970];
        }

        CFTypeRef tmpName = ABRecordCopyCompositeName(person);
        NSString *fullName = (__bridge NSString *)tmpName;
        
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSMutableArray *cachePhones = [NSMutableArray arrayWithCapacity:1];
        if (phones) {
            int count = ABMultiValueGetCount(phones);
            for (CFIndex i = 0; i < count; i++) {
                CFTypeRef tmpString = ABMultiValueCopyValueAtIndex(phones, i);
                PhoneDataModel *phone =  [[PhoneDataModel alloc] init];
                phone.number = (__bridge NSString*)tmpString;
                SAFE_CFRELEASE_NULL(tmpString);
                [cachePhones addObject:phone];
            }
            SAFE_CFRELEASE_NULL(phones);
        }
		ContactCacheDataModel *contact = [[ContactCacheDataModel alloc] initWithPersonID:personID
                                                                                fullName:fullName
                                                                              lastUpdate:time
                                                                                   Phone:cachePhones];
        
        
        SAFE_CFRELEASE_NULL(cfLastModifiedDate);
        SAFE_CFRELEASE_NULL(tmpName);
        
		return contact;
	}
    return nil;
}

+ (ContactCacheDataModel *)contactCacheDataModelByContact:(CNContact*)contact
{
    if (contact) {
        NSMutableArray *cachePhones = [NSMutableArray arrayWithCapacity:1];
        if (contact.phoneNumbers && contact.phoneNumbers.count > 0) {
            int count = contact.phoneNumbers.count;
            for (int i = 0; i < count; i++) {
                NSString *number = [[[contact.phoneNumbers[i] valueForKey:@"labelValuePair"] valueForKey:@"value" ]  valueForKey:@"stringValue"];
                PhoneDataModel *phone =  [[PhoneDataModel alloc] init];
                phone.number = number;
                [cachePhones addObject:phone];
            }
        }
        int personID = [[contact valueForKey:@"iOSLegacyIdentifier"] integerValue];
        NSString *fullname = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        ContactCacheDataModel *dataModel = [[ContactCacheDataModel alloc] initWithPersonID:personID
                                                                                  fullName:fullname
                                                                              lastUpdate:0
                                                                                   Phone:cachePhones];
        return dataModel;
    }
    return nil;
}

+ (ContactCacheDataModel*) getcontactCacheDataModelFromContact:(CNContact*)cncontact andPerson:(ABRecordRef)person {
    ContactCacheDataModel *contact = [self contactCacheDataModelByContact:cncontact];
    contact.address = [self getAddressByContact:cncontact];
    contact.emails = [self getEmailsByContact:cncontact];
    contact.IMs = [self getIMsByContact:cncontact];
    contact.URLs = [self getURLsByContact:cncontact];
    contact.dates = [self getDatesByContact:cncontact];
    contact.note = [self getNoteByContact:cncontact];
    contact.nickName = [self getNickNameByContact:cncontact];
    contact.birthday = [self getBirthdayByContact:cncontact];
    contact.jobTitle = [self getJobTitleByContact:cncontact];
    contact.department = [self getDepartmentByContact:cncontact];
    contact.company = [self getCompanyByContact:cncontact];
    contact.createDate = [self getCreateDateByRecord:person];
    return contact;
}

+ (ContactCacheDataModel *)contactCacheDataModelFullSearchInfoByRecord:(ABRecordRef)person andContact:(CNContact*)cncontact {
    if (person && cncontact) {
        return [self getcontactCacheDataModelFromContact:cncontact andPerson:person];
    }
    return nil;
}

+ (ContactCacheDataModel *)contactCacheDataModelFullSearchInfoByRecord:(ABRecordRef)person
{
	if (person) {
        ContactCacheDataModel *contact = [self contactCacheDataModelByRecord:person];
        contact.address = [self getAddressByRecord:person];
        contact.emails = [self getEmailsByRecord:person];
        contact.IMs = [self getIMsByRecord:person];
        contact.URLs = [self getURLsByRecord:person];
        contact.dates = [self getDatesByRecord:person];
        contact.note = [self getNoteByRecord:person];
        contact.nickName = [self getNickNameByRecord:person];
        contact.birthday = [self getBirthdayByRecord:person];
        contact.jobTitle = [self getJobTitleByRecord:person];
        contact.department = [self getDepartmentByRecord:person];
        contact.company = [self getCompanyByRecord:person];
        contact.createDate = [self getCreateDateByRecord:person];
        return contact;
        
	}
    return nil;
}

+ (ContactCacheDataModel *)contactCacheDataModelFullInfoByRecord:(ABRecordRef)person
{
	if (person) {
		ContactCacheDataModel *contact = [self contactCacheDataModelFullSearchInfoByRecord:person];
        contact.image = [self getImageByRecord:person];
        contact.abAddressBookPhones = [self getPhonesByRecord:person];
        contact.localSocialProfiles = [self getLocalSocialProfilesByRecord:person];
        contact.relatedNames = [self getRelatedNamesByRecord:person];
		return contact;
	}
    return nil;
}

+ (ContactCacheDataModel *)contactCacheDataModelFullInfoByRecord:(ABRecordRef)person andByContact:(CNContact*)cncontact
{
    if (person && cncontact) {
        ContactCacheDataModel *contact = [self contactCacheDataModelFullSearchInfoByRecord:person andContact:cncontact];
        contact.image = [self getImageByRecord:person];
        contact.abAddressBookPhones = [self getPhonesByRecord:person andContact:cncontact];
        contact.localSocialProfiles = [self getLocalSocialProfilesByRecord:person];
        contact.relatedNames = [self getRelatedNamesByContact:cncontact];
        return contact;
    }
    return nil;
}

+ (NSArray *)allCacaheABDataContact:(ABPersonSortOrdering)order
{
    NSMutableArray *person_array=[NSMutableArray  arrayWithCapacity:1];
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return person_array;
	CFArrayRef all_person_in_address_book = 
    ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(
                            [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread],
                            NULL, 
                            order);
    int person_count_in_address_book = CFArrayGetCount(all_person_in_address_book);
	for (int i=0; i<person_count_in_address_book; i++) {
		ABRecordRef record=CFArrayGetValueAtIndex(all_person_in_address_book,i);
        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:record] ||
            [AntiharassAdressbookUtil isOtherAntiharass:record]) {
            continue;
        }
		ContactCacheDataModel *person=[self contactCacheDataModelByRecord:record];
		if (person) {
            for (PhoneDataModel *tmp in person.phones) {
                NSInteger phoneId = [ContactCacheDataModel getCurrentPhoneId];
                tmp.phoneID = phoneId;
            }
			[person_array addObject:person];
		}		
	}
	CFRelease(all_person_in_address_book);
	return person_array;
}
+ (NSArray *)getAllContact:(ABPersonSortOrdering)order
{
	NSMutableArray *person_array=[[NSMutableArray alloc] init];
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return person_array;
	CFArrayRef all_person_in_address_book = 
    ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread], 
                                                              NULL,
                                                              order);
    int person_count_in_address_book = CFArrayGetCount(all_person_in_address_book);
	for (int i=0; i<person_count_in_address_book; i++) {
		ABRecordRef record=CFArrayGetValueAtIndex(all_person_in_address_book,i);
        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:record] ||
            [AntiharassAdressbookUtil isOtherAntiharass:record]) {
            continue;
        }
		ContactCacheDataModel *person=[self contactDataModelByRecord:record];
		if (person) {
			[person_array addObject:person];
		}		
	}
	CFRelease(all_person_in_address_book);
	return person_array;
}
+ (NSArray *)getAllContactHavePhones:(ABPersonSortOrdering)order
{
	NSMutableArray *person_array=[[NSMutableArray alloc] init];
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return person_array;
	CFArrayRef all_person_in_address_book =
    ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread],
                                                              NULL,
                                                              order);
    int person_count_in_address_book = CFArrayGetCount(all_person_in_address_book);
	for (int i=0; i<person_count_in_address_book; i++) {
		ABRecordRef record=CFArrayGetValueAtIndex(all_person_in_address_book,i);
        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:record] ||
            [AntiharassAdressbookUtil isOtherAntiharass:record]) {
            continue;
        }
		ContactCacheDataModel *person=[self contactDataModelByRecord:record];
		if (person.phones.count > 0) {
			[person_array addObject:person];
		}
	}
	CFRelease(all_person_in_address_book);
	return person_array;
}
+ (NSArray *)getAllContactNotRegisterHavePhones:(ABPersonSortOrdering)order
{
    NSMutableArray *person_array=[[NSMutableArray alloc] init];
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return person_array;
    CFArrayRef all_person_in_address_book =
    ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread],
                                                              NULL,
                                                              order);
    int person_count_in_address_book = CFArrayGetCount(all_person_in_address_book);
    for (int i=0; i<person_count_in_address_book; i++) {
        ABRecordRef record=CFArrayGetValueAtIndex(all_person_in_address_book,i);
        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:record] ||
            [AntiharassAdressbookUtil isOtherAntiharass:record]) {
            continue;
        }
        BOOL  ifAddPerson = NO;
        ContactCacheDataModel *person=[self contactDataModelByRecord:record];
        if (person.phones.count > 0) {
            for (PhoneDataModel *numberModel in person.phones) {
                if ([TouchpalMembersManager isNumberRegistered:numberModel.number]<=0) {
                     ifAddPerson = YES;
                     break;
                }
            }
            if (ifAddPerson) {
                [person_array addObject:person];
            }
        }
    }
    CFRelease(all_person_in_address_book);
    return person_array;
}

//


+ (NSArray *)getAllContactSortByFirstName
{
    return [self getAllContact:kABPersonSortByFirstName];
}

+ (NSArray *)getAllContactSortByLastName
{
    return [self getAllContact:kABPersonSortByLastName];
}

+ (NSArray *)queryAllContacts
{
    //ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormatForRecord(NULL);
    ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormat();
    if (kABPersonCompositeNameFormatFirstNameFirst == compositeNameFormat) {
        return [self getAllContact:kABPersonSortByFirstName];
    } else {
        return [self getAllContact:kABPersonSortByLastName];
    }
}

+ (NSArray *)queryAllContactsHavePhones
{
    //ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormatForRecord(NULL);
    ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormat();
    if (kABPersonCompositeNameFormatFirstNameFirst == compositeNameFormat) {
        return [self getAllContactHavePhones:kABPersonSortByFirstName];
    } else {
        return [self getAllContactHavePhones:kABPersonSortByLastName];
    }
}

+ (NSArray *)queryAllContactsNotRegisterHaveHavePhones
{
    //ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormatForRecord(NULL);
    ABPersonCompositeNameFormat compositeNameFormat = ABPersonGetCompositeNameFormat();
    if (kABPersonCompositeNameFormatFirstNameFirst == compositeNameFormat) {
        return [self getAllContactNotRegisterHavePhones:kABPersonSortByFirstName];
    } else {
        return [self getAllContactNotRegisterHavePhones:kABPersonSortByLastName];
    }
}

+ (NSArray *)getAsyncAllContactWhenAddressBookChanged:(ABAddressBookRef)addrBookRef
{
    NSMutableArray *person_array=[[NSMutableArray alloc] init];
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return person_array;
    ABAddressBookRef book = addrBookRef;
	CFArrayRef all_person_in_address_book = ABAddressBookCopyArrayOfAllPeople(book);
    int person_count_in_address_book = CFArrayGetCount(all_person_in_address_book);
    person_array = [NSMutableArray arrayWithCapacity:person_count_in_address_book];
	for (int i=0; i<person_count_in_address_book; i++) {
		ABRecordRef record=CFArrayGetValueAtIndex(all_person_in_address_book,i);
        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:record] ||
            [AntiharassAdressbookUtil isOtherAntiharass:record]) {
            continue;
        }
		ContactCacheDataModel *person = [self contactCacheDataModelByRecord:record];
		if (person) {
			[person_array addObject:person];
		}
	}
	CFRelease(all_person_in_address_book);
	return person_array;
}

+ (NSArray *)getAsyncAllContact:(ABAddressBookRef)addrBookRef
{
    NSMutableArray *person_array=[[NSMutableArray alloc] init];
    if ( ![UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY] )
        return person_array;
	ABAddressBookRef book = addrBookRef;	
	CFArrayRef all_person_in_address_book = ABAddressBookCopyArrayOfAllPeople(book);
    int person_count_in_address_book = CFArrayGetCount(all_person_in_address_book);
    person_array = [NSMutableArray arrayWithCapacity:person_count_in_address_book];
	for (int i=0; i<person_count_in_address_book; i++) {
		ABRecordRef record=CFArrayGetValueAtIndex(all_person_in_address_book,i);
        if ( [AntiharassAdressbookUtil isTouchpalAntiharass:record] ||
            [AntiharassAdressbookUtil isOtherAntiharass:record]) {
            continue;
        }
		ContactCacheDataModel *person = [self contactCacheDataModelFullSearchInfoByRecord:record];
		if (person) {
			[person_array addObject:person];
		}		
	}
	CFRelease(all_person_in_address_book);
	return person_array;
}

+ (BOOL)isExistsPerson:(NSInteger)record_id
{
	if (!record_id||record_id<=0) {
		return NO;
	}
	ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book,record_id);
	if (personRef) {
		return YES;
	}else {
		return NO;
	}
}

+ (ABRecordID)getPersonIDByRecord:(ABRecordRef) person
{
	if (!person) {
		return -1;
	}
	return ABRecordGetRecordID(person);
}

+ (ContactCacheDataModel *)getConatctInfoByRecordID:(NSInteger)personID
{
    return [PersonDBA getConatctInfoByRecordID:personID usingCNContact:YES];
}

/**
 *  this is method is initially created for warkarounding a memory warning issue in the feature of contact transfer.
 *
 *  @param personID       person id (integer)
 *  @param usingCNContact NO if you do not want to use the CNContact
 *
 *  @return ContactCacheDataModel
 */
+ (ContactCacheDataModel *) getConatctInfoByRecordID:(NSInteger)personID usingCNContact:(BOOL)usingCNContact {
    if(personID > 0)
    {
        
        ContactCacheDataModel *testModel= nil;
        ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book,personID);
        if(personRef){
            if (usingCNContact
                && [[UIDevice currentDevice].systemVersion intValue] >= 9) {
                CNContact *cncontact = [self getContactByPersonID:personID];
                testModel =[self contactCacheDataModelFullInfoByRecord:personRef andByContact:cncontact];
                return testModel;
                
            } else {
                testModel = [self contactCacheDataModelFullInfoByRecord:personRef];
                return 	testModel;
            }
            
        } else {
            return nil;
        }
    }else {
        return nil;
    }
}

+ (CNContact *)getContactByPersonID:(NSInteger)personID {
    if (personID <= 0) {
        return nil;
    }
    if (!ios9IdDic) {
        ios9IdDic = [[NSMutableDictionary alloc]initWithCapacity:1];
    }
    CNContactStore *store = [[CNContactStore alloc]init];
    CNContact *contact = nil;
    if (![[ios9IdDic allKeys]containsObject:[NSNumber numberWithInteger:personID]]) {
        [self getAllios9IdDic];
    }

    NSString *strId = [ios9IdDic objectForKey:[NSNumber numberWithInteger:personID]];
    if (strId == nil) {
        return nil;
    }
    contact = [store unifiedContactWithIdentifier:strId keysToFetch:@[[CNContact descriptorForAllComparatorKeys], [CNContactViewController descriptorForRequiredKeys]] error:nil];
    return contact;
}
+(void)getAllios9IdDic{
    if ([FunctionUtility systemVersionFloat] < 9.0) {
        return;
    }
    CNContactStore *store = [[CNContactStore alloc]init];
    if (!store) {
        return;
    }
    if (!ios9IdDic) {
        ios9IdDic = [[NSMutableDictionary alloc]initWithCapacity:1];
    }
    [store enumerateContactsWithFetchRequest:[[CNContactFetchRequest alloc] initWithKeysToFetch:@[[CNContact descriptorForAllComparatorKeys], [CNContactViewController descriptorForRequiredKeys]]] error:nil usingBlock:^(CNContact * _Nonnull cncontact, BOOL * _Nonnull stop) {
        NSInteger pid = [[cncontact valueForKey:@"iOSLegacyIdentifier"] integerValue];
        
        if(cncontact.phoneNumbers.count<100){
             ios9IdDic[[NSNumber numberWithInteger:pid]] = cncontact.identifier;
        }else{
            cootek_log(@"dsa");
        }
    }];
}

+ (ABRecordRef)getPersonByPersonID:(NSInteger)personID
{
    if (personID <= 0) {
		return nil;
	}
    ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    return [self getPersonByPersonID:personID addressBook:book];
}

+ (ABRecordRef)getPersonByPersonID:(NSInteger)personID
                       addressBook:(ABAddressBookRef)abab
{
	if(personID>0) 
	{
		ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(abab, personID);
        return personRef;
	}else {
		return NULL;
	}
}

+ (BOOL)deletePersonByRecordID:(NSInteger)record_id
{
	if (record_id>0) {	
		ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
		ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab,record_id);
		CFErrorRef err = nil;
		if (personRef) {
            if(ABAddressBookRemoveRecord(ab, personRef, &err)){
                BOOL ret = ABAddressBookSave(ab, &err);
                if (ret) {
                    [TouchpalMembersManager deleteFriend:record_id ifRefreash:YES];
                    ContactCacheDataModel *contact = [ContactCacheDataManager instance].contactsCacheDict[@(record_id)];
                    [SyncContactInApp deletePerson:contact];
                    [Favorites removeFavoriteByRecordId:record_id];
                }
                return ret;
            }
		}
    }
    return NO;
}

+ (BOOL)deletePersonByRecordIDs:(NSInteger)record_ids
{
    if (record_ids>0) {
		ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
		ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab,record_ids);
		CFErrorRef err = nil;
		if (personRef) {
            if(ABAddressBookRemoveRecord(ab, personRef, &err)){
                BOOL ret = ABAddressBookSave(ab, &err);
                if (ret) {
                    [TouchpalMembersManager deleteFriend:record_ids ifRefreash:NO];
                    ContactCacheDataModel *contact = [ContactCacheDataManager instance].contactsCacheDict[@(record_ids)];
                    [SyncContactInApp deletePersons:contact];
                    [Favorites removeFavoriteByRecordId:record_ids];
                }
                return ret;
            }
		}
    }
    return NO;
}

+ (void)deletePersonByRecordIDsArray:(NSArray *)record_idsArray
{
    ABAddressBookRef ab = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    CFErrorRef err = nil;
    for (NSNumber *record_ids in record_idsArray) {
        NSInteger record_id =record_ids.integerValue;
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab,record_id);
        if (record_ids>0) {
            if (personRef) {
                if(ABAddressBookRemoveRecord(ab, personRef, &err)){
                    [TouchpalMembersManager deleteFriend:record_id ifRefreash:NO];
                    ContactCacheDataModel *contact = [ContactCacheDataManager instance].contactsCacheDict[@(record_id)];
                    [SyncContactInApp deletePersons:contact];
                    [Favorites removeFavoriteByRecordId:record_id];
                }
            }
        }
    }
    ABAddressBookSave(ab, &err);

    
}

+ (NSString *)getPropertyLabel:(ABMultiValueRef)property_multivalue index:(int)index
{
	CFStringRef orign=ABMultiValueCopyLabelAtIndex(property_multivalue, index);
	if (orign) {
		CFStringRef local=ABAddressBookCopyLocalizedLabel(orign);
		if (local) {
			NSString* localizedLabel =[(__bridge NSString *)local copy];
            SAFE_CFRELEASE_NULL(orign);
            CFRelease(local);
			return localizedLabel;
		}
		SAFE_CFRELEASE_NULL(orign);
	}
	return nil;
}

+ (NSString *) getRawPropertyLable: (ABMultiValueRef)property_multivalue index:(int)index {
    CFStringRef origin = ABMultiValueCopyLabelAtIndex(property_multivalue, index);
    NSString *label = nil;
    if (origin) {
        label = [(__bridge NSString *)origin copy];
        SAFE_CFRELEASE_NULL(origin);
    }
    return label;
}

+ (NSArray *)getPhonesByRecordID:(NSInteger )person_id
{
	 if (person_id<=0) {
		 return nil;
	 }
	ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
	ABRecordRef person=ABAddressBookGetPersonWithRecordID(book,person_id);
	if (person) {
		return [self getPhonesByRecord:person];
	}else {
		return nil;
	}

}

+ (NSArray *)getPhonesByRecordID:(NSInteger )personID mainIndex:(NSInteger *)index
{
    ABRecordRef person = [self getPersonByPersonID:personID];
	if (person) {		
		NSArray *phones=[self getPhonesByRecord:person];
		if (phones) {
			if ([phones count]>0) {
				int count=[phones count];
				for (int i=0; i<count; i++) {
					LabelDataModel *phone=[phones objectAtIndex:i];
					NSString *phonenum = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
					if ([phone.labelKey isEqualToString:phonenum]) {
						*index=i;
					}
					CFRelease((__bridge CFTypeRef)(phonenum));
				}				
				*index=0;
			}
		}
		return phones;
	}else {
		return nil;
	}	
}

+ (NSArray *)getEmailsByRecordID:(NSInteger )personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
	if (personRecord) {
		return [self getEmailsByRecord:personRecord];
	}else {
		return nil;
	}
	
}

+ (NSArray *)getPhonesByRecord:(ABRecordRef)personRecord andContact:(CNContact*)cncontact {
    if (personRecord && cncontact) {
        if (cncontact.phoneNumbers.count > 0) {
            NSMutableArray *phone_list = [NSMutableArray arrayWithCapacity:cncontact.phoneNumbers.count];
            for (int i = 0; i < cncontact.phoneNumbers.count; i++) {
                id phone = [[cncontact.phoneNumbers objectAtIndex:i] valueForKey:@"labelValuePair"];
                LabelDataModel *labelModel=[[LabelDataModel alloc] init];
                labelModel.labelKey = [CNLabeledValue localizedStringForLabel: [phone valueForKey:@"label"]];
                labelModel.labelValue = [[phone valueForKey:@"value"] valueForKey:@"stringValue"];
                [phone_list addObject:labelModel];
            }
            return phone_list;
        }
    }
    return nil;
}

+ (NSArray *)getPhonesByRecord:(ABRecordRef)personRecord
{
	if (personRecord) {
        ABMultiValueRef phones = ABRecordCopyValue(personRecord, kABPersonPhoneProperty);
        if (phones) {
            NSMutableArray *phone_list = [NSMutableArray arrayWithCapacity:1];
            int count = ABMultiValueGetCount(phones);
            for (CFIndex i = 0; i < count; i++) {
                LabelDataModel *labelModel=[[LabelDataModel alloc] init];
                CFStringRef label = ABMultiValueCopyLabelAtIndex(phones, i);
                
                CFStringRef tmpString = ABAddressBookCopyLocalizedLabel(label);
                labelModel.labelKey = (__bridge NSString*)tmpString;
                labelModel.labelRawKey = [self getRawPropertyLable:phones index:i];
                SAFE_CFRELEASE_NULL(label);
                SAFE_CFRELEASE_NULL(tmpString);
                
                CFStringRef tmpStringValue = ABMultiValueCopyValueAtIndex(phones, i);
                labelModel.labelValue = (__bridge NSString*)tmpStringValue;
                SAFE_CFRELEASE_NULL(tmpStringValue);
                
                [phone_list addObject:labelModel];
            }
            SAFE_CFRELEASE_NULL(phones);
            return phone_list;
        }
    }
	return nil;
}

+ (NSArray *)getEmailsByRecord:(ABRecordRef)personRecord
{
	if (!personRecord) {
		return nil;
	}
	ABMultiValueRef emails = ABRecordCopyValue(personRecord, kABPersonEmailProperty);
	if (emails){
		NSMutableArray  *emailList =[[NSMutableArray alloc] init];
		for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
			NSString *label= [self getPropertyLabel:emails index:i];
            NSString *rawLabel = [self getRawPropertyLable:emails index:i];
            
			CFTypeRef email_value=ABMultiValueCopyValueAtIndex(emails, i);
			if (email_value) {
				NSString *value= (__bridge NSString *)email_value;
				LabelDataModel *labelModel = [[LabelDataModel alloc]init];
				labelModel.labelKey = label;
				labelModel.labelValue = value;
                labelModel.labelRawKey = rawLabel;
				[emailList addObject:labelModel];
				CFRelease(email_value);
			}
		}
		CFRelease(emails);
		return emailList;
	}else {
        return nil;
    }
}

+ (NSArray *)getEmailsByContact:(CNContact*)contact
{
    if (!contact) {
        return nil;
    }
    if (contact.emailAddresses.count > 0){
        NSMutableArray  *emailList =[[NSMutableArray alloc] init];
        for (int i = 0; i < contact.emailAddresses.count; i++) {
            id email = [contact.emailAddresses[i] valueForKey:@"labelValuePair"];
            NSString *label= [CNLabeledValue localizedStringForLabel: [email valueForKey:@"label"]];
            NSString *value = [email valueForKey:@"value"];
            if (value) {
                LabelDataModel *labelModel = [[LabelDataModel alloc]init];
                labelModel.labelKey = label;
                labelModel.labelValue = value;
                [emailList addObject:labelModel];
            }
        }
        return emailList;
    }else {
        return nil;
    }
}

+ (NSArray *)getAddressByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getAddressByRecord:personRecord];
}
+ (NSArray *)getAddressByRecord:(ABAddressBookRef)personRecord
{
	
    if (!personRecord) {
		return nil;
	}
	ABMultiValueRef address = ABRecordCopyValue(personRecord, kABPersonAddressProperty);
	if (!address) {
		return nil;
	}
	else {
		NSMutableArray *addressList = [[NSMutableArray alloc]init];
		for (CFIndex i=0; i<ABMultiValueGetCount(address); i++) {
			LabelDataModel *address_label=[[LabelDataModel alloc] init];
			address_label.labelKey = [self getPropertyLabel:address index:i];
			address_label.labelRawKey = [self getRawPropertyLable:address index:i];
            
			CFTypeRef dic_address=ABMultiValueCopyValueAtIndex(address, i);
			if (dic_address) {
				NSDictionary *dic = (__bridge NSDictionary *)dic_address;
				AddressDataModel *address_info=[[AddressDataModel alloc] init];
				address_info.country=[dic valueForKey:(NSString *)kABPersonAddressCountryKey];
				address_info.city=[dic valueForKey:(NSString *)kABPersonAddressCityKey];
				address_info.streetArray=[[dic valueForKey:(NSString *)kABPersonAddressStreetKey] componentsSeparatedByString:@"\n"];
				address_info.countryCode=[dic valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
				address_info.zip= [dic valueForKey:(NSString *)kABPersonAddressZIPKey];
				address_info.state=[dic valueForKey:(NSString *)kABPersonAddressStateKey];
				
				address_label.labelValue = [self getAddressItem:address_info];
                address_label.extra = address_info;
				[addressList addObject:address_label];
				
				CFRelease(dic_address);
			}
			
		}
		CFRelease(address);
		return addressList;
	}
}

+ (NSArray *)getAddressByContact:(CNContact*)contact
{
    
    if (!contact) {
        return nil;
    }
    if (!contact.postalAddresses || contact.postalAddresses.count == 0) {
        return nil;
    }
    else {
        NSMutableArray *addressList = [[NSMutableArray alloc]init];
        for (int i=0; i<contact.postalAddresses.count; i++) {
            LabelDataModel *address_label=[[LabelDataModel alloc] init];
            id address = [[contact.postalAddresses[i] valueForKey:@"labelValuePair"] valueForKey:@"value"];
            if (address) {
                AddressDataModel *address_info=[[AddressDataModel alloc] init];
                address_info.country=[address valueForKey:@"country"];
                address_info.city=[address valueForKey:@"city"];
                NSString *street = [address valueForKey:@"street"];
                address_info.streetArray= [street componentsSeparatedByString:@"\n"];
                address_info.countryCode=[address valueForKey:@"ISOCountryCode"];
                address_info.zip= [address valueForKey:@"postalCode"];
                address_info.state=[address valueForKey:@"state"];
                
                address_label.labelValue = [self getAddressItem:address_info];
                [addressList addObject:address_label];
                
            }
            
        }
        return addressList;
    }
}


+ (NSString *)getAddressItem:(AddressDataModel *)address
{
	NSString *item=@"";
	for(int i=0;i<[address.streetArray count];i++)
	{
		NSArray *street=address.streetArray;
		item=[item stringByAppendingString:(NSString *)[street objectAtIndex:i]];
	}
	item=[self stringAddressAppend:item targetString:address.city];
	item=[self stringAddressAppend:item targetString:address.state];
	item=[self stringAddressAppend:item targetString:address.zip];
	item=[self stringAddressAppend:item targetString:address.country];
	return item;
}

+ (NSString *)stringAddressAppend:(NSString *)item
                     targetString:(NSString *)str
{
	if (![item isEqualToString:@""]&&str) {
		item=[item stringByAppendingString:@","];
	}
	if (str) {
		item=[item stringByAppendingString:str];
	}
	return item;
}

+ (NSArray *)getDatesByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getDatesByRecord:personRecord];
}
+ (NSArray *)getDatesByRecord:(ABRecordRef)personRecord
{
    if (!personRecord) {
		return nil;
	}
	ABMultiValueRef dates = ABRecordCopyValue(personRecord, kABPersonDateProperty);
	if (!dates){
		return nil;
	}else{
		NSMutableArray *dateList = [NSMutableArray arrayWithCapacity:1];
		for (CFIndex i=0; i<ABMultiValueGetCount(dates); i++) {
			LabelDataModel *labelModel=[[LabelDataModel alloc]init];
			labelModel.labelKey = [self getPropertyLabel:dates index:i];
            labelModel.labelRawKey = [self getRawPropertyLable:dates index:i];
			CFTypeRef time_date=ABMultiValueCopyValueAtIndex(dates, i);
			if (time_date) {
				NSString* strDate = [NSDateFormatter localizedStringFromDate:(__bridge NSDate *)time_date
                                                                   dateStyle:NSDateFormatterMediumStyle
                                                                   timeStyle:NSDateFormatterNoStyle];
				labelModel.labelValue = strDate;
				CFRelease(time_date);
			}
			[dateList addObject:labelModel];
		}
		CFRelease(dates);
		return dateList;
	}
}
+ (NSArray *)getDatesByContact:(CNContact*)contact
{
    if (!contact) {
        return nil;
    }
    if (!contact.dates || contact.dates.count == 0){
        return nil;
    }else{
        NSMutableArray *dateList = [NSMutableArray arrayWithCapacity:1];
        for (int i=0; i<contact.dates.count; i++) {
            LabelDataModel *labelModel=[[LabelDataModel alloc]init];
            id date = [[contact.dates objectAtIndex:i] valueForKey:@"labelValuePair"];
            labelModel.labelKey = [CNLabeledValue localizedStringForLabel:[date valueForKey:@"label"]];
            NSDateComponents *timeComponents = [date valueForKey:@"value"];
            if (timeComponents) {
                NSString* strDate = [NSDateFormatter localizedStringFromDate:timeComponents.date
                                                                   dateStyle:NSDateFormatterMediumStyle
                                                                   timeStyle:NSDateFormatterNoStyle];
                labelModel.labelValue = strDate;
            }
            [dateList addObject:labelModel];
        }
        return dateList;
    }
}


+ (NSArray *)getURLsByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getURLsByRecord:personRecord];
}

+ (NSArray *)getURLsByRecord:(ABRecordRef)personRecord
{
    if (!personRecord) {
		return nil;
	}
	ABMultiValueRef urls = ABRecordCopyValue(personRecord, kABPersonURLProperty);
	if (!urls) {
		return nil;
	}
    NSMutableArray *urlList = [[NSMutableArray alloc]init];
    for (CFIndex i=0; i<ABMultiValueGetCount(urls); i++) {
        
        LabelDataModel *labelModel=[[LabelDataModel alloc]init];
        labelModel.labelKey = [self getPropertyLabel:urls index:i];
        labelModel.labelRawKey = [self getRawPropertyLable:urls index:i];
        CFTypeRef url_value=ABMultiValueCopyValueAtIndex(urls, i);
        if (url_value) {
            labelModel.labelValue = (__bridge NSString *)url_value;
            [urlList addObject:labelModel];
            CFRelease(url_value);
        }
    }
    CFRelease(urls);
    return urlList;
	
}

+ (NSArray *)getURLsByContact:(CNContact*)contact
{
    if (!contact) {
        return nil;
    }
    if (!contact.urlAddresses || contact.urlAddresses.count == 0) {
        return nil;
    }
    NSMutableArray *urlList = [[NSMutableArray alloc]init];
    for (int i = 0; i < contact.urlAddresses.count; i++) {
        
        id url = [contact.urlAddresses[i] valueForKey:@"labelValuePair"];
        LabelDataModel *labelModel=[[LabelDataModel alloc]init];
        labelModel.labelKey = [CNLabeledValue localizedStringForLabel: [url valueForKey:@"label"]];
        
        id url_value = [url valueForKey:@"value"];
        if (url_value) {
            // do NOT forget to add the value
            labelModel.labelValue = url_value;
            
            [urlList addObject:labelModel];
        }
    }
    return urlList;
    
}

+ (NSArray *)getIMsByContact:(CNContact*)contact
{
    if (!contact) {
        return nil;
    }
    if (!contact.instantMessageAddresses || contact.instantMessageAddresses.count == 0) {
        return nil;
    }
    NSMutableArray *imList = [[NSMutableArray alloc]init];
    for (int i=0; i<contact.instantMessageAddresses.count; i++) {
        id ims = [contact.instantMessageAddresses[i] valueForKey:@"labelValuePair"];
        if (ims) {
            
            LabelDataModel *labelModel = [[LabelDataModel alloc]init];
            labelModel.labelKey= [CNLabeledValue localizedStringForLabel: [ims valueForKey:@"label"]];
            
            IMDataModel *ims_info=[[IMDataModel alloc] init];
            ims_info.username= [[ims valueForKey:@"value"] valueForKey:@"username"];
            ims_info.service=[[ims valueForKey:@"value"] valueForKey:@"service"];
            if(!ims_info.service){ims_info.service=@"AIM";}
            labelModel.labelValue=ims_info;
            [imList addObject:labelModel];
            
        }
    }
    return imList;
}

+ (NSArray *)getIMsByRecord:(ABRecordRef)personRecord
{
    if (!personRecord) {
		return nil;
	}
	ABMultiValueRef ims = ABRecordCopyValue(personRecord, kABPersonInstantMessageProperty);
	if (!ims) {
        return nil;
    }
    NSMutableArray *imList = [[NSMutableArray alloc]init];
    for (CFIndex i=0; i<ABMultiValueGetCount(ims); i++) {
        CFTypeRef dic_im=ABMultiValueCopyValueAtIndex(ims, i);
        if (dic_im) {
            NSDictionary *dic = (__bridge NSDictionary *)dic_im;
            
            LabelDataModel *labelModel = [[LabelDataModel alloc]init];
            labelModel.labelKey=[self getPropertyLabel:ims index:i];
            labelModel.labelRawKey = [self getRawPropertyLable:ims index:i];
            
            IMDataModel *ims_info=[[IMDataModel alloc] init];
            ims_info.username=[dic valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            ims_info.service=[dic valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            if(!ims_info.service){ims_info.service=@"AIM";}
            labelModel.labelValue=ims_info;
            [imList addObject:labelModel];
            
            CFRelease(dic_im);
        }
    }
    CFRelease(ims);
    return imList;
}

+ (NSArray *)getIMsByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getIMsByRecord:personRecord];
}

+ (NSArray *)getRelatedNamesByRecord:(ABRecordRef)personRecord
{
    NSMutableArray *relatedNames = [NSMutableArray array];
    
    if (!personRecord) {
        return relatedNames;
    }
    
    ABMultiValueRef namesMulti = ABRecordCopyValue(personRecord, kABPersonRelatedNamesProperty);
    if (!namesMulti) {
        return relatedNames;
    }
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(namesMulti); i++) {
        LabelDataModel *labelModel = [[LabelDataModel alloc] init];
        CFStringRef label = ABMultiValueCopyLabelAtIndex(namesMulti, i);
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(label);
        labelModel.labelKey = (__bridge NSString *)localizedLabel;
        CFRelease(label);
        CFRelease(localizedLabel);
        
        CFStringRef value = ABMultiValueCopyValueAtIndex(namesMulti, i);
        labelModel.labelValue = (__bridge NSString *)value;
        CFRelease(value);
        
        [relatedNames addObject:labelModel];
    }
    
    CFRelease(namesMulti);
    return relatedNames;
}

+ (NSArray *)getRelatedNamesByContact:(CNContact*)contact
{
    NSMutableArray *relatedNames = [NSMutableArray array];
    
    if (!contact || !contact.contactRelations || contact.contactRelations.count == 0) {
        return relatedNames;
    }
    
    for (int i = 0; i < contact.contactRelations.count; i++) {
        LabelDataModel *labelModel = [[LabelDataModel alloc] init];
        id relation = [[contact.contactRelations objectAtIndex:i] valueForKey:@"labelValuePair"];
        labelModel.labelKey = [CNLabeledValue localizedStringForLabel: [relation valueForKey:@"label"]];
        labelModel.labelValue = [[relation valueForKey:@"value"] valueForKey:@"name"];
        [relatedNames addObject:labelModel];
    }
    
    return relatedNames;
}

+ (NSArray *)getRelatedNamesByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getRelatedNamesByRecord:personRecord];
}

+ (NSArray *)getLocalSocialProfilesByRecord:(ABRecordRef)personRecord
{
    NSMutableArray *profiles = [NSMutableArray array];
    
	if (!personRecord) {
		return profiles;
	}
	ABMultiValueRef profileMulti = ABRecordCopyValue(personRecord, kABPersonSocialProfileProperty);
	if (!profileMulti) {
		return profiles;
	}
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(profileMulti); i++) {
        CFTypeRef origin = ABMultiValueCopyValueAtIndex(profileMulti, i);
        NSDictionary *info = (__bridge NSDictionary *)origin;
        NSString *url = [NSString nilToEmpty:[info valueForKey:(NSString*)kABPersonSocialProfileURLKey]];
        NSString *userid = [NSString nilToEmpty:[info valueForKey:(NSString*)kABPersonSocialProfileUserIdentifierKey]];
        NSString *username = [NSString nilToEmpty:[info valueForKey:(NSString*)kABPersonSocialProfileUsernameKey]];
        NSString *service = [NSString nilToEmpty:[info valueForKey:(NSString*)kABPersonSocialProfileServiceKey]];;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:username forKey:@"username"];
        [dict setObject:userid forKey:@"userid"];
        [dict setObject:url forKey:@"url"];
        NSString *serviceType = @"";
        if ([service isEqualToString:@"sinaweibo"] || [service isEqualToString:@"weibo"]) {
            serviceType = LOCAL_SOCIAL_WEIBO;
        } else if ([service isEqualToString:(NSString*)kABPersonSocialProfileServiceFacebook]){
            serviceType = LOCAL_SOCIAL_FACEBOOK;
        } else if ([service isEqualToString:(NSString*)kABPersonSocialProfileServiceTwitter]){
            serviceType = LOCAL_SOCIAL_TWITTER;
        }
        if ([serviceType length] != 0) {
            [dict setObject:serviceType forKey:@"servicetype"];
            [profiles addObject:dict];
        }
        CFRelease(origin);
    }
    CFRelease(profileMulti);
    return profiles;
}
+ (NSArray *)getLocalSocialProfilesByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getLocalSocialProfilesByRecord:personRecord];
}

+ (NSString *)getNoteByRecord:(ABRecordRef)personRecord
{
    if(personRecord){
		CFTypeRef tmpCString=ABRecordCopyValue(personRecord, kABPersonNoteProperty);
		NSString *retstr=@"";
		if (tmpCString) {
			retstr=[(__bridge NSString *) tmpCString copy];
            CFRelease(tmpCString);
		}
		return retstr;
	}else {
		return @"";
	}
}

+ (NSString *)getNoteByContact:(CNContact*)contact
{
    if(contact){
        return contact.note;
    }else {
        return @"";
    }
}

+ (NSString *)getFullNameByRecord:(ABRecordRef)personRecord
{
    if(personRecord){
        CFTypeRef tmpName = ABRecordCopyCompositeName(personRecord);
		NSString *fullName  = @"";
		if (tmpName) {
			fullName = [(__bridge NSString *)tmpName copy];
            CFRelease(tmpName);
		}
		return fullName;
	}else {
		return @"";
	}
}

+ (NSString *)getNoteByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getNoteByRecord:personRecord];
}

+ (NSString *)getCreateDateByRecord:(ABRecordRef)personRecord{
    NSString *modifiedDate=@"";
	if(personRecord){
        do {
            CFTypeRef cfBirthday = ABRecordCopyValue(personRecord, kABPersonCreationDateProperty);
            if (!cfBirthday) {
                break;
            }
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            modifiedDate = [dateFormatter stringFromDate:(__bridge NSDate *)cfBirthday];
            CFRelease(cfBirthday);
        } while (NO);
	}
    return modifiedDate;
}

+ (NSString *)getCreateDateByRecordID:(NSInteger)personID{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getCreateDateByRecord:personRecord];
}

+ (NSDate *) getBirthdayDateByRecordID:(NSInteger)recordID {
    ABRecordRef personRecord = [self getPersonByPersonID:recordID];
    if (!personRecord) {
        return nil;
    }
    CFTypeRef cfBirthday = ABRecordCopyValue(personRecord, kABPersonBirthdayProperty);
    if (!cfBirthday) {
        return nil;
    }
    NSDate *birthday = (__bridge NSDate *)cfBirthday;
    CFRelease(cfBirthday);
    return birthday;
}

+ (NSString *)getBirthdayByRecord:(ABRecordRef)personRecord
{
    NSString *birthday = @"";
	if(personRecord) {
        CFTypeRef cfBirthday = ABRecordCopyValue(personRecord, kABPersonBirthdayProperty);
        if (!cfBirthday) {
            return birthday;
        }
        birthday = [NSDateFormatter localizedStringFromDate:(__bridge NSDate *)cfBirthday
                                                  dateStyle:NSDateFormatterMediumStyle
                                                  timeStyle:NSDateFormatterNoStyle];
        CFRelease(cfBirthday);
	}
    if ([birthday hasPrefix:@"1604"]) {
        birthday = [birthday substringFromIndex:5];
    }
    return birthday;
}

+ (NSString *)getBirthdayByContact:(CNContact*)contact
{
    NSString *birthday = @"";
    if(contact) {
        if (!contact.birthday) {
            return birthday;
        }
        NSDateComponents *birthdayComponents = contact.birthday;
        NSDate *date = birthdayComponents.date;
        birthday = [NSDateFormatter localizedStringFromDate:date
                                                  dateStyle:NSDateFormatterMediumStyle
                                                  timeStyle:NSDateFormatterNoStyle];
    }
    if ([birthday hasPrefix:@"1604"]) {
        birthday = [birthday substringFromIndex:5];
    }
    if ([birthday hasPrefix:@"1年"]) {
        birthday = [birthday substringFromIndex:2];
    }
    return birthday;
}

+ (NSString *)getBirthdayByRecordID:(NSInteger)personID{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getBirthdayByRecord:personRecord];
}

+ (NSString *)getCompanyByRecord:(ABRecordRef)personRecord
{
    if(personRecord){
		CFTypeRef tmpCString=ABRecordCopyValue(personRecord, kABPersonOrganizationProperty);
		NSString *retstr=@"";
		if (tmpCString) {
			retstr=[(__bridge NSString *) tmpCString copy];
            CFRelease(tmpCString);
		}
		return retstr;
	}else {
		return @"";
	}
}
+ (NSString *)getCompanyByContact:(CNContact*)contact
{
    if(contact){
        return contact.organizationName;
    }else {
        return @"";
    }
}
+ (NSString *)getCompanyByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getCompanyByRecord:personRecord];
}
+ (NSString *)getNickNameByRecord:(ABRecordRef)personRecord
{
    if(personRecord){
		CFTypeRef tmpCString=ABRecordCopyValue(personRecord, kABPersonNicknameProperty);
		NSString *retstr=@"";
		if (tmpCString) {
			retstr=[(__bridge NSString *) tmpCString copy];
            CFRelease(tmpCString);
		}
		return retstr;
	}else {
		return @"";
	}
}

+ (NSString *)getNickNameByContact:(CNContact*)contact
{
    if(contact){
        return contact.nickname;
    }else {
        return @"";
    }
}

+ (NSString *)getNickNameByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getNickNameByRecord:personRecord];
}

+ (NSString *)getDepartmentByRecord:(ABRecordRef)personRecord
{
    if(personRecord){
		CFTypeRef tmpCString=ABRecordCopyValue(personRecord, kABPersonDepartmentProperty);
		NSString *retstr=@"";
		if (tmpCString) {
			retstr=[(__bridge NSString *) tmpCString copy];
            CFRelease(tmpCString);
		}
        return retstr;
	}else {
		return @"";
	}
}
+ (NSString *)getDepartmentByContact:(CNContact*)contact
{
    if(contact){
        return contact.departmentName;
    }else {
        return @"";
    }
}

+ (NSString *)getDepartmentByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getDepartmentByRecord:personRecord];
}
+ (NSString *)getJobTitleByRecord:(ABRecordRef)personRecord
{
    if(personRecord){
		CFTypeRef tmpCString=ABRecordCopyValue(personRecord, kABPersonJobTitleProperty);
		NSString *retstr=@"";
		if (tmpCString) {
			retstr=[(__bridge NSString *) tmpCString copy];
            CFRelease(tmpCString);
		}
		return retstr;
	}else {
		return @"";
	}
}

+ (NSString *)getJobTitleByContact:(CNContact*)contact
{
    if(contact){
        return contact.jobTitle;
    }else {
        return @"";
    }
}

+ (NSString *)getJobTitleByRecordID:(NSInteger)personID
{
    ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getJobTitleByRecord:personRecord];
}

+ (UIImage *)getImageByRecordID:(NSInteger)personID
{
	ABRecordRef personRecord = [self getPersonByPersonID:personID];
    return [self getImageByRecord:personRecord];
}
+ (UIImage *)getImageByRecord:(ABRecordRef)personRecord
{
	UIImage* image = nil;
	CGSize imageSize;
	imageSize.width = 160.0f;
	imageSize.height = 160.0f;
    
	if(personRecord && ABPersonHasImageData(personRecord))
	{
		CFDataRef pic_data=ABPersonCopyImageDataWithFormat(personRecord,kABPersonImageFormatThumbnail);
		if (pic_data) {
			NSData* data = (__bridge NSData *)pic_data;
			UIImage *im = [UIImage imageWithData:data];
			image = [self imageByScalingAndCroppingForSize:imageSize sourceImage:im];
			CFRelease(pic_data);
		}
	}

	return image;
}

+ (UIImage *)getDefaultImageByPersonID:(NSInteger)personID isCootekUser:(BOOL)isCootekUser
{
    CGSize imageSize = CGSizeMake(160, 160);
    
    UIGraphicsBeginImageContext(imageSize);
    CGRect rect =CGRectMake(0, 0,imageSize.width ,imageSize.height);
    NSString *colorString = nil;
    if (isCootekUser) {
        colorString = @"tp_color_light_blue_500";
    } else {
        colorString = @"person_default_image_0_color"; // for none-cootek-user avatar in ContactItemCell
    }
    [[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:colorString] withFrame:rect] drawInRect:rect];
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    UIImage *photo = [[TPDialerResourceManager sharedManager] getImageByName:isVersionSix ? @"common_photo_contact_for_list@2x.png" : @"common_photo_contact_big@2x.png" ];

    [photo drawInRect:rect];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)getDefaultImageWithoutNameByPersonID:(NSInteger)personID
{
    CGSize imageSize;
	imageSize.width = 160.0f;
	imageSize.height = 160.0f;
    UIGraphicsBeginImageContext(imageSize);
    CGRect rect =CGRectMake(0, 0,imageSize.width ,imageSize.height);
    [[FunctionUtility imageWithColor:[FunctionUtility getPersonDefaultColorByPersonId:personID] withFrame:rect] drawInRect:rect];
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    [[[TPDialerResourceManager sharedManager] getImageByName:isVersionSix ? @"common_photo_contact_for_list@2x.png" : @"common_photo_contact_big@2x.png" ] drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)getDefaultColorImageWithoutPersonID
{
    CGSize imageSize;
	imageSize.width = 160.0f;
	imageSize.height = 160.0f;
    UIGraphicsBeginImageContext(imageSize);
    CGRect rect =CGRectMake(0, 0,imageSize.width ,imageSize.height);
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    [[FunctionUtility imageWithColor:[FunctionUtility getPersonDefaultColorByPersonId:0] withFrame:rect] drawInRect:rect];
    [[[TPDialerResourceManager sharedManager] getImageByName:isVersionSix ? @"common_photo_contact_for_list@2x.png" : @"common_photo_contact_big@2x.png" ] drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                 sourceImage:(UIImage *)sourceImage
{
	UIGraphicsBeginImageContext(targetSize);
	CGRect imageRect = CGRectMake(0.0, 0.0, targetSize.width, targetSize.height);
	[sourceImage drawInRect:imageRect];
	UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return targetImage;
}


#pragma mark -
#pragma mark for Test
//start-------------
+ (void)makeContact:(NSInteger)iCount
{
	NSArray *userNameArray = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G"
							  ,@"H",@"I",@"J",@"K",@"L",@"M",@"N"
							  ,@"O",@"P",@"Q",@"R",@"S",@"T",@"U"
							  ,@"V",@"W",@"X",@"Y",@"Z",nil];
	
	for (int i=0; i<iCount; i++) {
		int iTurn =(arc4random() % 25);
		int x = (arc4random() % 1000) + 1;
		NSString *contact = [NSString stringWithFormat:@"%d",x];
		if (iTurn>25) {
			iTurn = 0;
		}
		NSString *userName = [userNameArray objectAtIndex:iTurn];
		contact = [userName stringByAppendingString:contact];
		
		[PersonDBA createContact:contact usercontact:userName];
		
		NSLog(@"i====%d",i);
	}
	
}
//联系人生成
+(CFStringRef)switchLabel
{
	int type=(arc4random() % 3);
	switch (type) {
		case 0:return kABWorkLabel;
			break;
		case 1:return kABHomeLabel;
			break;
		default:
			return kABOtherLabel;
			break;
	}

}
+ (void)createContact:(NSString *)username usercontact:(NSString*)usercontact
{
	
	ABRecordRef aRecord = ABPersonCreate(); 
	CFErrorRef  anError = NULL;
	
	// Username
	ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(username), &anError);
	int number = (arc4random() % 1000) + 500;
	NSString *temp = [NSString stringWithFormat:@"%d%@",number,usercontact];
	ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(temp), &anError);
	//Birthday
	number = (arc4random() % 10000000) + 1000000;
	NSDate *temp1 =[NSDate dateWithTimeIntervalSince1970:number];
	ABRecordSetValue(aRecord, kABPersonBirthdayProperty, (__bridge CFTypeRef)(temp1), &anError);
	////Nnik
    //number = (arc4random() % 1500) + 1000;
	//temp = [NSString stringWithFormat:@"NI%dNote",number];
	ABRecordSetValue(aRecord, kABPersonNicknameProperty, (__bridge CFTypeRef)(username), &anError);
	//Note
	//number = (arc4random() % 150000) + 10000;
	//temp = [NSString stringWithFormat:@"NI%dNote",number];
	ABRecordSetValue(aRecord, kABPersonNoteProperty, (__bridge CFTypeRef)(username), &anError);
	//JOB
	number = (arc4random() % 105067) + 10000;
	temp = [NSString stringWithFormat:@"%d",number];
	ABRecordSetValue(aRecord,kABPersonJobTitleProperty ,(__bridge CFTypeRef)(temp), &anError);
	//compary
	//extern const ABPropertyID kABPersonOrganizationProperty;       // Company name - kABStringPropertyType
	number = (arc4random() % 10506) + 1000;
	temp = [NSString stringWithFormat:@"%d",number];
	ABRecordSetValue(aRecord,kABPersonOrganizationProperty ,(__bridge CFTypeRef)(temp), &anError);
	//部门
	number = (arc4random() % 1050670) + 100000;
	temp = [NSString stringWithFormat:@"%d",number];
	ABRecordSetValue(aRecord,kABPersonDepartmentProperty ,(__bridge CFTypeRef)(temp), &anError);
    //Note 
	number = (arc4random() % 10506700) + 1000000;
	temp = [NSString stringWithFormat:@"%d",number];
	ABRecordSetValue(aRecord,kABPersonDepartmentProperty ,(__bridge CFTypeRef)(temp), &anError);
	// Phone Number.
	number = (arc4random() % 10000000) + 1000000;
	temp = [NSString stringWithFormat:@"%d",number];
	ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(multi, (__bridge CFStringRef)temp,[PersonDBA switchLabel], NULL);
	ABRecordSetValue(aRecord, kABPersonPhoneProperty, multi, &anError);
	CFRelease(multi);
	
	//Email
	number = (arc4random() % 100000) + 10000;
	temp = [NSString stringWithFormat:@"%d@126.com",number];
	multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(multi, (__bridge CFStringRef)temp,[PersonDBA switchLabel], NULL);
	ABRecordSetValue(aRecord, kABPersonEmailProperty, multi, &anError);
	CFRelease(multi);
	//date
	number = (arc4random() % 10000000) + 1000000;
	temp1 =[NSDate dateWithTimeIntervalSince1970:number];
	multi = ABMultiValueCreateMutable(kABMultiDateTimePropertyType);
	ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(temp1),kABPersonAnniversaryLabel, NULL);
	ABRecordSetValue(aRecord, kABPersonDateProperty, multi, &anError);
	CFRelease(multi);
	//URL
	number = (arc4random() % 10000) + 1000;
	temp = [NSString stringWithFormat:@"http://www.%d.com",number];
	multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(multi, (__bridge CFStringRef)temp,[PersonDBA switchLabel], NULL);
	ABRecordSetValue(aRecord, kABPersonURLProperty, multi, &anError);
	CFRelease(multi);
	
	//IM
	number = (arc4random() % 1000000) + 100000;
	int t=(arc4random() % 500) + 100;
	temp = [NSString stringWithFormat:@"%d@%d.cn",number,t];
	multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	CFStringRef keys[2];
	CFStringRef value[2];
	keys[0]=kABPersonInstantMessageUsernameKey;
	keys[1]=kABPersonInstantMessageServiceKey;
	value[0]=(__bridge CFStringRef)temp;
	value[1]=kABPersonInstantMessageServiceMSN;
	CFDictionaryRef dic=CFDictionaryCreate(kCFAllocatorDefault, (void *)keys, (void *)value, 2, 
										   &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	ABMultiValueAddValueAndLabel(multi, (CFStringRef)dic,[PersonDBA switchLabel], NULL);
	ABRecordSetValue(aRecord, kABPersonInstantMessageProperty, multi, &anError);
    CFRelease(dic);
	CFRelease(multi);
	
	//address

	multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	CFStringRef keys1[6];
	CFStringRef value1[6];
	keys1[0]=kABPersonAddressStreetKey;
	keys1[1]=kABPersonAddressCityKey;
	keys1[2]=kABPersonAddressStateKey;
	keys1[3]=kABPersonAddressZIPKey;
	keys1[4]=kABPersonAddressCountryKey;
	keys1[5]=kABPersonAddressCountryCodeKey;
	
	number = (arc4random() % 1000000) + 100000;
	temp = [NSString stringWithFormat:@"%d",number];
	value1[0]=(__bridge CFStringRef)temp;
	
	number = (arc4random() % 400) +200;
	temp = [NSString stringWithFormat:@"%d",number];
	value1[1]=(__bridge CFStringRef)temp;
	
	number = (arc4random() % 200) +100;
	temp = [NSString stringWithFormat:@"%d",number];
	value1[2]=(__bridge CFStringRef)temp;
	
	number = (arc4random() % 10000000) +100000;
	temp = [NSString stringWithFormat:@"%d",number];
	value1[3]=(__bridge CFStringRef)temp;
	
	//number = (arc4random() % 200) +1;
	temp = @"中国";
	value1[4]=(__bridge CFStringRef)temp;
	
	//number = (arc4random() % 400) +700;
	temp = @"+86";
	value1[5]=(__bridge CFStringRef)temp;
	
	dic=CFDictionaryCreate(kCFAllocatorDefault, (void *)keys1, (void *)value1, 6, 
										   &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	ABMultiValueAddValueAndLabel(multi, (CFStringRef)dic,[PersonDBA switchLabel], NULL);
	ABRecordSetValue(aRecord, kABPersonAddressProperty, multi, &anError);
    CFRelease(dic);
	CFRelease(multi);

	
	if (anError != NULL)
		NSLog(@"error while creating..");
	
	CFStringRef personname,personcontact;
	
	personname = ABRecordCopyValue(aRecord, kABPersonFirstNameProperty); 
	personcontact  = ABRecordCopyValue(aRecord, kABPersonPhoneProperty); 
	
	//ABAddressBookRef addressBook; 
	CFErrorRef error = NULL; 
	
	BOOL isAdded = ABAddressBookAddRecord ([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread], aRecord, &error);
	
	if(isAdded){
		
		//cootek_log(@"added..");
	}
	if (error != NULL) {
		NSLog(@"ABAddressBookAddRecord %@", error);
	} 
	error = NULL;
	
	BOOL isSaved = ABAddressBookSave ([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread], &error);
	
	if(isSaved) {
	}
	
	if (error != NULL) {
		NSLog(@"ABAddressBookSave %@", error);
	} 
	
	CFRelease(aRecord); 
	CFRelease(personname);
	CFRelease(personcontact);
}
+ (BOOL) saveNoteInfo:(NSString *)note ByRecordId:(int)Id
{
   CFErrorRef  anError = NULL;
   ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
   ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book,Id);  
   ABRecordSetValue(personRef, kABPersonNoteProperty, (__bridge CFTypeRef)(note), &anError);
   BOOL isSaved = ABAddressBookSave ([TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread], &anError);
   if (isSaved) {
        NotiPersonChangeData* changeData = [[NotiPersonChangeData alloc] initWithPersonId:Id
                                                                                changeType:ContactChangeTypeModify];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_PERSON_DATA_CHANGED
                                                            object:nil 
                                                          userInfo:[NSDictionary dictionaryWithObject:changeData
                                                                                               forKey:KEY_PERSON_CHANGED]];
    }

   return isSaved;
}

+(LabelDataModel *)mainNumberByRecordID:(NSInteger)personID
{
	NSArray *phones=[self getPhonesByRecordID:personID];
	if (phones) {
		if ([phones count]>0) {
			int count=[phones count];
			for (int i=0; i<count; i++) {
				LabelDataModel *phone=[phones objectAtIndex:i];
				//是移动电话为主号码
				NSString *phonenum = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(kABPersonPhoneMobileLabel);
				if ([phone.labelKey isEqualToString:phonenum]) {
					CFRelease((__bridge CFTypeRef)(phonenum));
					return phone;
				}
				CFRelease((__bridge CFTypeRef)(phonenum));
			}
			//没有移动电话，返回第一个电话
			return [phones objectAtIndex:0];
		}
	}
	return nil;
}
@end
