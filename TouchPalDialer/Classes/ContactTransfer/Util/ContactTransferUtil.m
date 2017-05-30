//
//  ContactTransferUtil.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/9.
//
//
#import "ContactTransferUtil.h"
#import "ContactTransferItem.h"
#import "FunctionUtility.h"
#import "AddressDataModel.h"
#import "NSString+TPHandleNil.h"
#import "IMDataModel.h"
#import "ContactGroupDBA.h"
#import "Group.h"
#import "NSString+TPHandleNil.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"
#import "DateTimeUtil.h"
#import "NSString+TPHandleNil.h"

@implementation ContactTransferUtil

+ (NSString *) getMimeStringByItemType: (ContactTransferItemType) itemType {
    switch (itemType) {
        case ITEM_NOTE: {
            return MIME_TYPE_NOTE;
        }
        case ITEM_EVENT: {
            return MIME_TYPE_EVENT;
        }
        case ITEM_EMAIL: {
            return MIME_TYPE_EMAIL;
        }
        case ITEM_NICK_NAME: {
            return MIME_TYPE_NICK_NAME;
        }
        case ITEM_DISPLAY_NAME: {
            return MIME_TYPE_DISPLAY_NAME;
        }
        case ITEM_NUMBER: {
            return MIME_TYPE_NUMBER;
        }
        case ITEM_ADDRESS: {
            return MIME_TYPE_ADDRESS;
        }
        case ITEM_URL: {
            return MIME_TYPE_URL;
        }
        default: {
            break;
        }
    }
    return ITEM_UNKNOWN;
}

+ (NSString *) getRecordTypeString: (ContactTransferRecordType) recordType {
    switch (recordType) {
        case RECORD_TYPE_SYSTM: {
            return NAME_RECORD_SYSTEM;
        }
        case RECORD_TYPE_PRIVATE: {
            return NAME_RECORD_PRIVATE;
        }
        default: {
            break;
        }
    }
    return nil;
}

+ (ContactTransferRecordType) getRecordTypeByString: (NSString *) typeStr {
    if (!typeStr) {
        return RECORD_TYPE_UNKNOWN;
    } else if ([typeStr hasPrefix:NAME_RECORD_SYSTEM]) {
        return RECORD_TYPE_SYSTM;
    } else if ([typeStr hasSuffix:NAME_RECORD_PRIVATE]) {
        return RECORD_TYPE_PRIVATE;
    } else {
        return RECORD_TYPE_UNKNOWN;
    }
}

 + (ContactTransferRecordType) getRecordType: (NSInteger) recordID {
     return RECORD_TYPE_SYSTM;
 }

+ (NSString *) getRecordKeyByType: (ContactTransferRecordType) recordType recordID: (NSString *) recordID {
    NSString *recordTypeString = [ContactTransferUtil getRecordTypeString:recordType];
    if (!recordTypeString) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@_%@", recordTypeString, recordID];
}

+ (ContactTransferCommonItem *) getItemByCachedModel: (ContactCacheDataModel *) model
                                          itemType: (ContactTransferItemType) itemType {
    switch (itemType) {
        case ITEM_NOTE: {
            return nil;
        }
        case ITEM_EVENT: {
            return nil;
        }
        case ITEM_EMAIL: {
            return nil;
        }
        case ITEM_NICK_NAME: {
            return nil;
        }
        case ITEM_DISPLAY_NAME: {
            return nil;
        }
        case ITEM_NUMBER: {
            return nil;
        }
        case ITEM_ADDRESS: {
            return nil;
        }
        case ITEM_URL: {
            return nil;
        }
        default: {
            break;
        }
    }
    return nil;
}

+ (NSArray *) getItemsByCachedModel: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSMutableArray *targetItems = [[NSMutableArray alloc] init];
    
    NSArray *numberItems = [ContactTransferUtil getNumberItems: model];
    if (numberItems) {
        [targetItems addObjectsFromArray: numberItems];
    }
    
    NSArray *addressItems = [ContactTransferUtil getAddressItems: model];
    if (addressItems) {
        [targetItems addObjectsFromArray: addressItems];
    }
    
    NSArray *displayNameItems = [ContactTransferUtil getDisplayNameItems: model];
    if (displayNameItems) {
        [targetItems addObjectsFromArray: displayNameItems];
    }
    
    NSArray *emailItems = [ContactTransferUtil getEmailItems: model];
    if (emailItems) {
        [targetItems addObjectsFromArray: emailItems];
    }
    
    NSArray *noteItems = [ContactTransferUtil getNoteItems: model];
    if (noteItems) {
        [targetItems addObjectsFromArray: noteItems];
    }
    
    NSArray *nicknameItems = [ContactTransferUtil getNicknameItems: model];
    if (nicknameItems) {
        [targetItems addObjectsFromArray: nicknameItems];
    }
    
    if (targetItems.count == 0) {
        return nil;
    }
    return [targetItems copy];
}

+ (NSArray *) getItemsByRecordID: (NSInteger)recordID {
    NSMutableArray *targetItems = [[NSMutableArray alloc] init];
    
    NSArray *numberItems = [ContactTransferUtil getNumberItemsByRecordID:recordID];
    if (numberItems) {
        [targetItems addObjectsFromArray: numberItems];
    }
    
    NSArray *dateItems = [ContactTransferUtil getDateItemsByRecordID:recordID];
    if (dateItems) {
        [targetItems addObjectsFromArray: dateItems];
    }
    
    NSArray *imItems = [ContactTransferUtil getIMItemsByRecordID:recordID];
    if (imItems) {
        [targetItems addObjectsFromArray: imItems];
    }
    
    NSArray *urlItems = [ContactTransferUtil getURLItemsByRecordID:recordID];
    if (urlItems) {
        [targetItems addObjectsFromArray: urlItems];
    }
    
    NSArray *addressItems = [ContactTransferUtil getAddressItemsByRecordID:recordID];
    if (addressItems) {
        [targetItems addObjectsFromArray: addressItems];
    }
    
    NSArray *displayNameItems = [ContactTransferUtil getDisplayNameItemsByRecordID:recordID];
    if (displayNameItems) {
        [targetItems addObjectsFromArray: displayNameItems];
    }
    
    NSArray *emailItems = [ContactTransferUtil getEmailItemsByRecordID:recordID];
    if (emailItems) {
        [targetItems addObjectsFromArray: emailItems];
    }
    
    NSArray *groupItems = [ContactTransferUtil getGroupItemsByRecordID:recordID];
    if (groupItems) {
        [targetItems addObjectsFromArray:groupItems];
    }
    
    NSArray *orgItems = [ContactTransferUtil getOrganizationItemsByRecordID:recordID];
    if (orgItems) {
        [targetItems addObjectsFromArray: orgItems];
    }
    
    NSArray *noteItems = [ContactTransferUtil getNoteItemsByRecordID:recordID];
    if (noteItems) {
        [targetItems addObjectsFromArray: noteItems];
    }
    
    NSArray *nicknameItems = [ContactTransferUtil getNicknameItemsByRecordID:recordID];
    if (nicknameItems) {
        [targetItems addObjectsFromArray: nicknameItems];
    }
    
    if (targetItems.count == 0) {
        return nil;
    }
    return [targetItems copy];
}


+ (NSArray *) getNumberItems: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSArray *numbers = [PersonDBA getPhonesByRecordID:model.personID];
    if (!numbers || numbers.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:numbers.count];
    for (LabelDataModel *model in numbers) {
        NSString *key = model.labelRawKey;
        id value = model.labelValue;
        if (!key || !value) {
            continue;
        }
        NSString *type = [ContactTransferUtil getTypeByRecordKey:key];
        if (!type) {
            continue;
        }
        NSDictionary *item = @{
            KEY_MIME_TYPE: MIME_TYPE_NUMBER,
            KEY_IS_IRIMARY : @(0),
            KEY_NUMBER: value,
            KEY_TYPE: type,
        };
        //ContactTransferNumberItem *item = [[ContactTransferNumberItem alloc] initWithDict: dict];
        if (item) {
            [mutableItems addObject: item];
        }
    } 
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

+ (NSArray *) getAddressItems: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSArray *addrList = model.address;
    if (!addrList || addrList.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity: addrList.count];
    for(LabelDataModel *model in addrList) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        AddressDataModel *addressModel = model.labelValue;
        if (!key || !addressModel) {
            continue;
        }
        NSString *type = [ContactTransferUtil getTypeByRecordKey: key];
        if (!type) {
            continue;
        }
        NSString *street = @"";
        if (addressModel.streetArray) {
            street = [addressModel.streetArray componentsJoinedByString:@" "];
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_ADDRESS forKey:KEY_MIME_TYPE];
        [item setObject:type forKey:KEY_TYPE];
        if (![NSString isNilOrEmpty:addressModel.city]) {
            [item setObject:addressModel.city forKey:ADDRESS_CITY];
        }
        if (![NSString isNilOrEmpty:addressModel.zip]) {
            [item setObject:addressModel.zip forKey:ADDRESS_ZIP];
        }
        if (![NSString isNilOrEmpty:addressModel.state]) {
            [item setObject:addressModel.state forKey:ADDRESS_STATE];
        }
        if (![NSString isNilOrEmpty:addressModel.country]) {
            [item setObject:addressModel.country forKey:ADDRESS_COUNTRY];
        }
        if (![NSString isNilOrEmpty:addressModel.countryCode]) {
            [item setObject:addressModel.countryCode forKey:ADDRESS_COUNTRY_CODE];
        }
        if (![NSString isNilOrEmpty:street]) {
            [item setObject:street forKey:ADDRESS_STREET];
        }
        //ContactTransferAddressItem *item = [[ContactTransferAddressItem alloc] initWithDict: dict];
        if (item) {
            [mutableItems addObject: [item copy]];
        }
    }
    return nil;
}

+ (NSArray *) getDisplayNameItems: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSDictionary *item = @{
        KEY_MIME_TYPE: MIME_TYPE_DISPLAY_NAME,
        NAME_FIRST: @"",
        NAME_LAST: @"",
        NAME_MIDDLE: @"",
        NAME_PREFIX: @"",
        NAME_SUFFIX: @"",
        NAME_DISPLAY: [NSString nilToEmpty: model.displayName]
    };
    return @[item];
}

+ (NSArray *) getEmailItems: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSArray *emails = model.emails;
    if (!emails || emails.count == 0) return nil;
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity: emails.count];
    for (LabelDataModel *model in emails) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        id value = model.labelValue;
        if (!key || !value) {
            continue;
        }
        NSString *type = [ContactTransferUtil getTypeByRecordKey: key];
        if (!type) {
            return nil;
        }
        NSDictionary *item = @{
            KEY_MIME_TYPE: MIME_TYPE_EMAIL,
            KEY_TYPE: type,
            KEY_EMAIL: value  
        };
        //ContactTransferEmailItem *item = [[ContactTransferEmailItem alloc] initWithDict: dict];
        if (item) {
            [mutableItems addObject: item];
        }
    }
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

+ (NSArray *) getNoteItems: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSString *note = model.note;
    if (!note) {
        return nil;
    }
    NSDictionary *item = @{
        KEY_MIME_TYPE: MIME_TYPE_NOTE,
        KEY_NOTE: note  
    };
    //ContactTransferNoteItem *item = [[ContactTransferNoteItem alloc] initWithDict: dict];
    if (!item) {
        return nil;
    }
    return @[item];
}

+ (NSArray *) getNicknameItems: (ContactCacheDataModel *) model {
    if (!model) {
        return nil;
    }
    NSString *nickname = model.nickName;
    if (!nickname) {
        return nil;
    }
    NSDictionary *item = @{
        KEY_MIME_TYPE: MIME_TYPE_NICK_NAME,
        KEY_NICK_NAME: nickname  
    };
    //ContactTransferNicknameItem *item = [[ContactTransferNicknameItem alloc] initWithDict: dict];
    if (!item) {
        return nil;
    }
    return @[item];
}

+ (NSString *) convertToNSString: (CFStringRef) stringRef {
    return nil;
}

// get items by recordID

// nickname
+ (NSArray *) getNicknameItemsByRecordID: (NSInteger) recordID {
    NSString *nickname = [PersonDBA getNickNameByRecordID:recordID];
    if ([NSString isNilOrEmpty:nickname]) {
        return nil;
    }
    NSDictionary *item = @{
         KEY_MIME_TYPE: MIME_TYPE_NICK_NAME,
         KEY_NICK_NAME: nickname
    };
    return @[item];
}

// displayName
+ (NSArray *) getDisplayNameItemsByRecordID: (NSInteger) recordID {
    ContactCacheDataModel *model = [PersonDBA getConatctInfoByRecordID:recordID usingCNContact:NO];
    if (!model) {
        return nil;
    }
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSString *displayName = model.displayName;
    if (![NSString isNilOrEmpty:displayName]) {
        [item setValue:displayName forKey:NAME_DISPLAY];
    }
    NSString *firstName = nil;
    NSString *lastName = nil;
    NSString *middleName = nil;
    ABRecordRef recordRef = [PersonDBA getPersonByPersonID:recordID];
    if (recordRef) {
        // firstname
        CFTypeRef firstNameRef =  ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);
        if (firstNameRef) {
            firstName = (__bridge NSString *)firstNameRef;
            if (![NSString isNilOrEmpty:firstName]) {
                [item setValue:firstName forKey:NAME_LAST]; // android does it!!!
            }
            CFRelease(firstNameRef);
        }
        
        // lastname
        CFTypeRef lastNameRef =  ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
        if (lastNameRef) {
            lastName = (__bridge NSString *)lastNameRef;
            if (![NSString isNilOrEmpty:lastName]) {
                [item setValue:lastName forKey:NAME_FIRST]; // android does it!!!
            }
            CFRelease(lastNameRef);
        }
        
        // middlename
        CFTypeRef middleNameRef =  ABRecordCopyValue(recordRef, kABPersonMiddleNameProperty);
        if (middleNameRef) {
            middleName = (__bridge NSString *)middleNameRef;
            if (![NSString isNilOrEmpty:middleName]) {
                [item setValue:middleName forKey:NAME_MIDDLE];
            }
            CFRelease(middleNameRef);
        }
    }
    if (item.count == 0) {
        return nil;
    }
    [item setValue:MIME_TYPE_DISPLAY_NAME forKey:KEY_MIME_TYPE];
    NSDictionary *targetItem = [item copy];
    return @[targetItem];
}

// note
+ (NSArray *) getNoteItemsByRecordID: (NSInteger) recordID {
    NSString *note = [PersonDBA getNoteByRecordID:recordID];
    if ([NSString isNilOrEmpty:note]) {
        return nil;
    }
    NSDictionary *item = @{
        KEY_MIME_TYPE: MIME_TYPE_NOTE,
        KEY_NOTE: note
   };
    return @[item];
}

+ (NSArray *) getGroupItemsByRecordID: (NSInteger) recordID {
    NSArray* personGroupIds = [ContactGroupDBA getMemberGroups:recordID];
    if (!personGroupIds || personGroupIds.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSNumber* item in personGroupIds) {
        GroupDataModel *group = [Group getGroupByGroupID:[item intValue]];
        if (group) {
            NSString *groupName = group.groupName;
            if (groupName && groupName.length > 0) {
                NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
                [item setValue:MIME_TYPE_GROUP forKey:KEY_MIME_TYPE];
                [item setValue:groupName forKey:KEY_GROUP];
                [mutableItems addObject:[item copy]];
            }
        }
    }
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

// emails
+ (NSArray *) getEmailItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getEmailsByRecordID:recordID];
    if (!rawItems || rawItems.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(LabelDataModel *model in rawItems) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        id value = model.labelValue;
        if (!key || !value) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:key];
        if (!type) {
            continue;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setValue:MIME_TYPE_EMAIL forKey:KEY_MIME_TYPE];
        [item setValue:type forKey:KEY_TYPE];
        [item setValue:value forKey:KEY_EMAIL];
        if (item.count > 0) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

// urls
+ (NSArray *) getURLItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getURLsByRecordID:recordID];
    if (!rawItems || rawItems.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(LabelDataModel *model in rawItems) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        id value = model.labelValue;
        if (!key || !value) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:key];
        if (!type) {
            continue;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setValue:MIME_TYPE_URL forKey:KEY_MIME_TYPE];
        [item setValue:type forKey:KEY_TYPE];
        [item setValue:value forKey:KEY_URL];
        if (item.count > 0) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

// organization
+ (NSArray *) getOrganizationItemsByRecordID: (NSInteger) recordID {
    NSString *company = [PersonDBA getCompanyByRecordID:recordID];
    NSString *jobTitle = [PersonDBA getJobTitleByRecordID:recordID];
    NSString *department = [PersonDBA getDepartmentByRecordID:recordID];
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (![NSString isNilOrEmpty:jobTitle]) {
        [item setObject:jobTitle forKey:ORG_JOB_TITLE];
    }
    if (![NSString isNilOrEmpty:department]) {
        [item setObject:department forKey:ORG_DEPARTMENT];
    }
    if (![NSString isNilOrEmpty:company]) {
        [item setObject:company forKey:KEY_ORG];
    }
    if (item.count == 0){
        return nil;
    }
    [item setObject:MIME_TYPE_ORG forKey:KEY_MIME_TYPE];
    NSDictionary *targetItem = [item copy];
    return @[targetItem];
}

// numbers
+ (NSArray *) getNumberItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getPhonesByRecordID:recordID];
    if (!rawItems || rawItems.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(LabelDataModel *model in rawItems) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        id value = model.labelValue;
        if (!key || !value) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:key];
        if (!type) {
            continue;
        }
        NSInteger isPrimaryInt = [self isMainPhoneNumber:key] ? 1: 0;
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_NUMBER forKey:KEY_MIME_TYPE];
        [item setObject:type forKey:KEY_TYPE];
        [item setObject:value forKey:KEY_NUMBER];
        [item setObject:@(isPrimaryInt) forKey:KEY_IS_IRIMARY];
        if (item.count > 0) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}


// IMs
+ (NSArray *) getIMItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getIMsByRecordID:recordID];
    if (!rawItems || rawItems.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(LabelDataModel *model in rawItems) {
        if (!model) {
            continue;
        }
        IMDataModel *imModel = model.labelValue;
        if (!imModel) {
            continue;
        }
        NSString *service = imModel.service;
        NSString *username = imModel.username;
        if (!service || !username) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:service];
        if (!type) {
            continue;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_IM forKey:KEY_MIME_TYPE];
        [item setObject:type forKey:KEY_TYPE];
        [item setObject:username forKey:KEY_IM];
        if (item.count > 0) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

// social profiles, like blogs
+ (NSArray *) getSocialProfileItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getLocalSocialProfilesByRecordID:recordID];
    if (!rawItems || rawItems.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(NSDictionary *model in rawItems) {
        if (!model) {
            continue;
        }
        NSString *servicetype = [model objectForKey:@"servicetype"];
        if (!servicetype) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:servicetype];
        if (!type) {
            continue;
        }
        
        NSString *username = [model objectForKey:@"username"];
//        NSString *userid = [model objectForKey:@"userid"];
//        NSString *url = [model objectForKey:@"url"];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_IM forKey:KEY_MIME_TYPE];
        [item setObject:type forKey:KEY_TYPE];
        [item setObject:username forKey:KEY_IM];
        if (item.count > 0) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

// addresses
+ (NSArray *) getAddressItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getAddressByRecordID:recordID];
    if (!rawItems || rawItems.count == 0) {
        return nil;
    }
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(LabelDataModel *model in rawItems) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        AddressDataModel *value = model.extra;
        if (!key || !value) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:key];
        if (!type) {
            continue;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_ADDRESS forKey:KEY_MIME_TYPE];
        [item setObject:type forKey:KEY_TYPE];
        
        NSArray *streetArray = value.streetArray;
        if (streetArray) {
            NSString *street = [streetArray componentsJoinedByString:@" "];
            if (street) {
                [item setObject:street forKey:ADDRESS_STREET];
            }
        }
        NSString *city = value.city;
        if (city) {
              [item setObject:city forKey:ADDRESS_CITY];
        }
        
        NSString *zip = value.zip;
        if (zip) {
            [item setObject:zip forKey:ADDRESS_ZIP];
        }
        
        NSString *state = value.state;
        if (state) {
            [item setObject:state forKey:ADDRESS_STATE];
        }
        
        NSString *country = value.country;
        if (country) {
            [item setObject:country forKey:ADDRESS_COUNTRY];
        }
        
        NSString *countryCode = value.countryCode;
        if (countryCode) {
            [item setObject:countryCode forKey:ADDRESS_COUNTRY_CODE];
        }
        
        if (item) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}

// dates
+ (NSArray *) getDateItemsByRecordID: (NSInteger) recordID {
    NSArray *rawItems = [PersonDBA getDatesByRecordID:recordID];
    NSMutableArray *mutableItems = [[NSMutableArray alloc] initWithCapacity:1];
    for(LabelDataModel *model in rawItems) {
        if (!model) {
            continue;
        }
        NSString *key = model.labelRawKey;
        NSString *value = model.labelValue;
        if (!key || !value) {
            continue;
        }
        NSString *type = [self getTypeByRecordKey:key];
        if (!type) {
            continue;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_EVENT forKey:KEY_MIME_TYPE];
        [item setObject:type forKey:KEY_TYPE];
        [item setObject:value forKey:KEY_DATE];
        if (item) {
            [mutableItems addObject:[item copy]];
        }
    }
    
    NSDate *birthdayDate = [PersonDBA getBirthdayDateByRecordID:recordID];
    NSString *birthday = [DateTimeUtil dateStringByFormat:@"MM-dd" fromDate:birthdayDate];
    if (birthday) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger year = components.year;
        birthday = [NSString stringWithFormat:@"%d-%@", year, birthday];
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:3];
        [item setObject:MIME_TYPE_EVENT forKey:KEY_MIME_TYPE];
        [item setObject:EVENT_TYPE_BIRTHDAY forKey:KEY_TYPE];
        [item setObject:birthday forKey:KEY_DATE];
        [mutableItems addObject:[item copy]];
    }
    
    if (mutableItems.count == 0) {
        return nil;
    }
    return [mutableItems copy];
}


#pragma mark resovle contact
/**
 *  merge items by mimetypes
 *
 *  @param items raw item array
 *
 *  @return merge group
 */
+ (NSDictionary *) resovle: (NSArray *) items {
    NSMutableDictionary *groupedItems = [[NSMutableDictionary alloc] initWithCapacity:3];
    for (NSDictionary *item in items) {
        NSString *mimetype = [item objectForKey:KEY_MIME_TYPE];
        if (!mimetype) {
            continue;
        }
        NSMutableArray *container = [groupedItems objectForKey:mimetype];
        if (!container) {
            container = [[NSMutableArray alloc] initWithCapacity:1];
            [groupedItems setObject:container forKey:mimetype];
        }
        [container addObject:item];
    }
    if (groupedItems.count == 0) {
        return nil;
    }
    return [groupedItems copy];
}

+ (void) resovleForRecord: (NSArray *)rawInfo recordRef:(ABRecordRef)recordRef {
    if (!rawInfo) {
        return;
    }
    
    NSDictionary *wholeItems = [self resovle:rawInfo];
    if (!wholeItems) {
        return;
    }
    
    // notes
    NSArray *notes = [wholeItems objectForKey:MIME_TYPE_NOTE];
    if (notes) {
        [self setNoteMultiValue:notes toRecordRef:recordRef];
    }
    
    // nicknames
    NSArray *nicknames = [wholeItems objectForKey:MIME_TYPE_NICK_NAME];
    if (nicknames) {
        [self setNicknameMultiValue:nicknames toRecordRef:recordRef];
    }
    
    // urls
    NSArray *urls = [wholeItems objectForKey:MIME_TYPE_URL];
    if (urls) {
        [self setUrlMultiValue:urls toRecordRef:recordRef];
    }
    
    // addressed
    NSArray *addresses = [wholeItems objectForKey:MIME_TYPE_ADDRESS];
    if (addresses) {
        [self setAddressMutilValue:addresses toRecordRef:recordRef];
    }
    
    // names
    NSArray *names = [wholeItems objectForKey:MIME_TYPE_DISPLAY_NAME];
    if (names) {
        [self setDisplayNameMultiValue:names toRecordRef:recordRef];
    }
    
    // nubmers
    NSArray *numbers = [wholeItems objectForKey:MIME_TYPE_NUMBER];
    if (numbers) {
        [self setNumberMultiValue:numbers toRecordRef:recordRef];
    }
    
    // orgnanization
    NSArray *orgs = [wholeItems objectForKey:MIME_TYPE_ORG];
    if (orgs) {
        [self setOrgMultiValue:orgs toRecordRef:recordRef];
    }
    
    // event
    NSArray *events = [wholeItems objectForKey:MIME_TYPE_EVENT];
    if (events) {
        [self setEventMultiValue:events toRecordRef:recordRef];
    }
    
    // IM
    NSArray *ims = [wholeItems objectForKey:MIME_TYPE_IM];
    if (ims) {
        [self setIMMultiValue:ims toRecordRef:recordRef];
    }
    
    // photo
    NSArray *photos = [wholeItems objectForKey:MIME_TYPE_PHOTO];
    if (photos) {
        [self setPhotoMultiValue:photos toRecordRef:recordRef];
    }

    // group
    NSArray *groups = [wholeItems objectForKey:MIME_TYPE_PHOTO];
    if (groups) {
        [self setGroupMultiValue:groups toRecordRef:recordRef];
    }
    
    // emails
    NSArray *emails = [wholeItems objectForKey:MIME_TYPE_EMAIL];
    if (emails) {
        [self setEmailMutilValue:emails toRecordRef:recordRef];
    }
}

+ (CNContact *) resovleForCNContact: (NSArray *)rawInfo {
    // not supported yet, still use the ABPerson
    return nil;
}


#pragma mark get contact entry from dictionary
+ (void) setPhotoMultiValue:(NSArray *)entries toRecordRef:(ABRecordRef)recordRef {
    // do not support now
    // related api: `ABPersonSetImageData`
}

+ (void) setGroupMutilValue: (NSArray *)entries toRecordRef: (ABRecordRef)recordRef {
    if (!entries) {
        return;
    }
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for(NSDictionary *email in entries) {
        NSString *type = [email objectForKey:KEY_TYPE];
        NSString *value = [email objectForKey:KEY_VALUE];
        if ([NSString isNilOrEmpty:value]) {
            continue;
        }
        CFTypeRef refType = NULL;
        NSString *contactType = nil;
        refType = [self getRecordLabelByType:type mimetype:MIME_TYPE_EMAIL];
        if (refType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)value, refType, NULL);
        } else if (contactType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)(value), (__bridge CFTypeRef)(contactType), NULL);
        }
    }
    if (ABMultiValueGetCount(mutablePairs)) {
        ABRecordSetValue(recordRef, kABPersonEmailProperty, mutablePairs, NULL);
    }
    CFRelease(mutablePairs);
}

+ (void) setEmailMutilValue: (NSArray *)entries toRecordRef: (ABRecordRef)recordRef {
    if (!entries) {
        return;
    }
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    for(NSDictionary *email in entries) {
        NSString *type = [email objectForKey:KEY_TYPE];
        NSString *value = [email objectForKey:KEY_VALUE];
        if ([NSString isNilOrEmpty:value]) {
            continue;
        }
        CFTypeRef refType = NULL;
        NSString *contactType = nil;
        refType = [self getRecordLabelByType:type mimetype:MIME_TYPE_EMAIL];
        if (refType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)value, refType, NULL);
        } else if (contactType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)(value), (__bridge CFTypeRef)(contactType), NULL);
        }
    }
    if (ABMultiValueGetCount(mutablePairs)) {
        ABRecordSetValue(recordRef, kABPersonEmailProperty, mutablePairs, NULL);
    }
    CFRelease(mutablePairs);
}

+ (void) setAddressMutilValue: (NSArray *)entries toRecordRef: (ABRecordRef)recordRef {
    if (!entries) {
        return;
    }
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    CFErrorRef error = NULL;
    for (NSDictionary *entry in entries) {
        if (!entry) {
            continue;
        }
        NSString *type = [entry objectForKey:KEY_TYPE];
        NSString *fullStreet = [entry objectForKey:ADDRESS_STREET];
        if ([NSString isNilOrEmpty:fullStreet]) {
            continue;
        }
        NSString *city = [entry objectForKey:ADDRESS_CITY];
        NSString *zip = [entry objectForKey:ADDRESS_ZIP];
        NSString *country = [entry objectForKey:ADDRESS_COUNTRY];
        NSString *countryCode = [entry objectForKey:ADDRESS_COUNTRY_CODE];
        NSString *state = [entry objectForKey:ADDRESS_STATE];
        
        CFTypeRef refType = [self getRecordLabelByType:type mimetype:MIME_TYPE_ADDRESS];
        
        NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        [addressDict setObject:[NSString nilToEmpty:fullStreet] forKey:(NSString *)kABPersonAddressStreetKey];
        [addressDict setObject:[NSString nilToEmpty:city] forKey:(NSString *)kABPersonAddressCityKey];
        [addressDict setObject:[NSString nilToEmpty:zip] forKey:(NSString *)kABPersonAddressZIPKey];
        [addressDict setObject:[NSString nilToEmpty:country] forKey:(NSString *)kABPersonAddressCountryCodeKey];
        [addressDict setObject:[NSString nilToEmpty:countryCode] forKey:(NSString *)kABPersonAddressCountryCodeKey];
        [addressDict setObject:[NSString nilToEmpty:state] forKey:(NSString *)kABPersonAddressStateKey];
        
        ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)(addressDict), refType, NULL);
    }
    if (ABMultiValueGetCount(mutablePairs) > 0) {
        ABRecordSetValue(recordRef, kABPersonAddressProperty, mutablePairs, &error);
    }
    CFRelease(mutablePairs);
}

+ (void) setNoteMultiValue: (NSArray *)entries toRecordRef: (ABRecordRef)recordRef {
    if (!entries || !recordRef) {
        return;
    }
    for (NSDictionary *entry in entries) {
        NSString *value = [entry objectForKey:KEY_NOTE];
        if (!value) {
            continue;
        }
        CFErrorRef error = NULL;
        ABRecordSetValue(recordRef, kABPersonNoteProperty, (__bridge CFTypeRef)value, &error);
        if (error) {
            //usage record
        }
    }
}

+ (void) setNicknameMultiValue: (NSArray *)entries toRecordRef: (ABRecordRef)recordRef {
    if (!entries || !recordRef) {
        return;
    }
    for (NSDictionary *entry in entries) {
        NSString *value = [entry objectForKey:KEY_NICK_NAME];
        if (!value) {
            continue;
        }
        CFErrorRef error = NULL;
        ABRecordSetValue(recordRef, kABPersonNicknameProperty, (__bridge CFTypeRef)value, &error);
        if (error) {
            //usage record
        }
    }
}

+ (void) setDisplayNameMultiValue:(NSArray *)entries toRecordRef:(ABRecordRef)recordRef {
    if (!entries || !recordRef) {
        return;
    }
    BOOL isChinaLocale = [[[NSLocale currentLocale] localeIdentifier] hasPrefix:@"zh"]; // by android
    for (NSDictionary *entry in entries) {
        if (!entry) {
            continue;
        }
        NSString *displayName = [entry objectForKey:NAME_DISPLAY];
        
        // family name, 姓
        NSString *lastName = [entry objectForKey:NAME_LAST];
        // first name, 名
        NSString *firstName = [entry objectForKey:NAME_FIRST];
        NSString *middleName = [entry objectForKey:NAME_MIDDLE];
        if (isChinaLocale) {
            NSString *tmp = firstName;
            firstName = lastName;
            lastName = tmp;
        }
        if ([NSString isNilOrEmpty:firstName] && [NSString isNilOrEmpty:lastName]) {
            lastName = displayName;
        }
        
        if (![NSString isNilOrEmpty:lastName]) {
            ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)lastName, NULL);
        }
        if (![NSString isNilOrEmpty:firstName]) {
            ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)firstName, NULL);
        }
        
        if (![NSString isNilOrEmpty:middleName]) {
            ABRecordSetValue(recordRef, kABPersonMiddleNameProperty, (__bridge CFTypeRef)middleName, NULL);
        }
        
        NSString *prefix = [entry objectForKey:NAME_PREFIX];
        NSString *suffix = [entry objectForKey:NAME_SUFFIX];
        if (![NSString isNilOrEmpty:prefix]) {
            ABRecordSetValue(recordRef, kABPersonPrefixProperty, (__bridge CFTypeRef)prefix, NULL);
        }
        if (![NSString isNilOrEmpty:suffix]) {
            ABRecordSetValue(recordRef, kABPersonSuffixProperty, (__bridge CFTypeRef)suffix, NULL);
        }
    }
}

+ (void) setNumberMultiValue:(NSArray *)numbers toRecordRef:(ABRecordRef)recordRef {
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    CFErrorRef error = NULL;
    for(NSDictionary *entry in numbers) {
        NSString *type = [entry objectForKey:KEY_TYPE];
        NSString *value = [entry objectForKey:KEY_VALUE];
        if ([NSString isNilOrEmpty:value]) {
            continue;
        }
        CFTypeRef refType = NULL;
        NSString *contactType = nil;
        refType = [self getRecordLabelByType:type mimetype:MIME_TYPE_NUMBER];
        if (refType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)value, refType, NULL);
        } else if (contactType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)(value), (__bridge CFTypeRef)(contactType), NULL);
        }
    }
    if (ABMultiValueGetCount(mutablePairs) > 0) {
        ABRecordSetValue(recordRef, kABPersonPhoneProperty, mutablePairs, &error);
    }
    CFRelease(mutablePairs);
}

+ (void) setUrlMultiValue:(NSArray *)urls toRecordRef:(ABRecordRef)recordRef {
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    CFErrorRef error = NULL;
    for(NSDictionary *entry in urls) {
        NSString *type = [entry objectForKey:KEY_TYPE];
        NSString *value = [entry objectForKey:KEY_VALUE];
        if ([NSString isNilOrEmpty:value]) {
            continue;
        }
        CFTypeRef refType = NULL;
        NSString *contactType = nil;
        refType = [self getRecordLabelByType:type mimetype:MIME_TYPE_URL];
        if (refType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)value, refType, NULL);
        } else if (contactType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)(value), (__bridge CFTypeRef)(contactType), NULL);
        }
    }
    if (ABMultiValueGetCount(mutablePairs) > 0) {
        ABRecordSetValue(recordRef, kABPersonURLProperty, mutablePairs, &error);
    }
    CFRelease(mutablePairs);
}

+ (void) setOrgMultiValue:(NSArray *)entries toRecordRef:(ABRecordRef)recordRef {
    if (!entries || !recordRef) {
        return;
    }
    for (NSDictionary *entry in entries) {
        if (!entry) {
            continue;
        }
        NSString *jobTitle = [entry objectForKey:ORG_JOB_TITLE];
        NSString *organization = [entry objectForKey:KEY_ORG];
        NSString *department = [entry objectForKey:ORG_DEPARTMENT];
        
        if (![NSString isNilOrEmpty:jobTitle]) {
            ABRecordSetValue(recordRef, kABPersonJobTitleProperty, (__bridge CFTypeRef)jobTitle, NULL);
        }
        if (![NSString isNilOrEmpty:organization]) {
            ABRecordSetValue(recordRef, kABPersonOrganizationProperty, (__bridge CFTypeRef)organization, NULL);
        }
        
        if (![NSString isNilOrEmpty:department]) {
            ABRecordSetValue(recordRef, kABPersonDepartmentProperty, (__bridge CFTypeRef)department, NULL);
        }
    }

}

+ (void) setEventMultiValue:(NSArray *)entries toRecordRef:(ABRecordRef)recordRef {
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiDateTimePropertyType);
    CFErrorRef error = NULL;
    for(NSDictionary *entry in entries) {
        NSString *type = [entry objectForKey:KEY_TYPE];
        NSString *value = [entry objectForKey:KEY_VALUE];
        if ([NSString isNilOrEmpty:type] || [NSString isNilOrEmpty:value]) {
            continue;
        }
        NSDate *dateValue = [DateTimeUtil dateByFormat:@"yyyy-MM-dd" fromString:value];
        if ([type isEqualToString:EVENT_TYPE_BIRTHDAY]) {
            ABRecordSetValue(recordRef, kABPersonBirthdayProperty, (__bridge CFTypeRef)(dateValue), NULL);
            continue;
        }
        CFTypeRef refType = NULL;
        NSString *contactType = nil;
        refType = [self getRecordLabelByType:type mimetype:MIME_TYPE_EVENT];
        
        if (!dateValue) {
            continue;
        }
        cootek_log(@"contact_transfer, item_event, date: %@", dateValue);
        if (refType) {
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)dateValue, refType, NULL);
        } else if (contactType) {
            //            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)homepageUrlString, kABPersonHomePageLabel, NULL);
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)(dateValue), (__bridge CFTypeRef)(contactType), NULL);
        }
    }
    if (ABMultiValueGetCount(mutablePairs) > 0) {
        ABRecordSetValue(recordRef, kABPersonDateProperty, mutablePairs, &error);
    }
    CFRelease(mutablePairs);
}

+ (void) setGroupMultiValue:(NSArray *)entries toRecordRef:(ABRecordRef)recordRef {
    if (!entries || entries.count ==0 || !recordRef) {
        return;
    }
    for (NSDictionary *entry in entries) {
        NSString *value = [entry objectForKey:KEY_GROUP];
        if (value) {
            ABRecordSetValue(recordRef, kABGroupNameProperty, (__bridge CFTypeRef)(value), NULL);
        }
    }
}

+ (void) setIMMultiValue:(NSArray *)entries toRecordRef:(ABRecordRef)recordRef {
    ABMutableMultiValueRef mutablePairs = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    CFErrorRef error = NULL;
    for(NSDictionary *entry in entries) {
        NSString *type = [entry objectForKey:KEY_TYPE];
        NSString *value = [entry objectForKey:KEY_VALUE];
        if ([NSString isNilOrEmpty:type] || [NSString isNilOrEmpty:value]) {
            continue;
        }
        CFTypeRef profileType = NULL;
        if ([type isEqualToString:IM_PROTOCOL_QQ]) {
            profileType = kABPersonInstantMessageServiceQQ;
        } else if ([type isEqualToString:IM_PROTOCOL_AIM]) {
            profileType = kABPersonInstantMessageServiceAIM;
        } else if ([type isEqualToString:IM_PROTOCOL_ICQ]) {
            profileType = kABPersonInstantMessageServiceICQ;
        } else if ([type isEqualToString:IM_PROTOCOL_MSN]) {
            profileType = kABPersonInstantMessageServiceMSN;
        } else if ([type isEqualToString:IM_PROTOCOL_SKYPE]) {
            profileType = kABPersonInstantMessageServiceSkype;
        } else if ([type isEqualToString:IM_PROTOCOL_YAHOO]) {
            profileType = kABPersonInstantMessageServiceYahoo;
        } else if ([type isEqualToString:IM_PROTOCOL_JABBER]) {
            profileType = kABPersonInstantMessageServiceJabber;
        } else if ([type isEqualToString:IM_PROTOCOL_FACEBOOK]) {
            profileType = kABPersonInstantMessageServiceJabber;
        } else if ([type isEqualToString:IM_PROTOCOL_GOOGLE_TALK]) {
            profileType = kABPersonInstantMessageServiceJabber;
        }
        if (profileType) {
            NSDictionary *dict = @{
                                   (NSString *)kABPersonInstantMessageServiceKey: (__bridge NSString *)profileType,
                                   (NSString *)kABPersonInstantMessageUsernameKey: value
                                   };
            ABMultiValueAddValueAndLabel(mutablePairs, (__bridge CFTypeRef)dict, profileType, NULL);
        }
    }
    
    if (ABMultiValueGetCount(mutablePairs) > 0) {
        ABRecordSetValue(recordRef, kABPersonInstantMessageProperty, mutablePairs, &error);
    }
    CFRelease(mutablePairs);
}

#pragma mark help functions
+ (NSString *) getTypeByRecordKey: (NSString *) recordKey {
    if ([FunctionUtility systemVersionFloat] < 9.0) {
        // types for common
        if ([recordKey isEqualToString:(NSString *) kABWorkLabel]) {
            return COMMAN_TYPE_WORK;
        } else if ([recordKey isEqualToString: (NSString *) kABHomeLabel]) {
            return COMMAN_TYPE_HOME;
        } else if ([recordKey isEqualToString: (NSString *) kABOtherLabel]) {
            return COMMAN_TYPE_OTHER;
        }
        
        // types for im
        if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceQQ]) {
            return IM_PROTOCOL_QQ;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceAIM]) {
            return IM_PROTOCOL_AIM;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceFacebook]) {
            return IM_PROTOCOL_FACEBOOK;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceGoogleTalk]) {
            return IM_PROTOCOL_GOOGLE_TALK;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceSkype]) {
            return IM_PROTOCOL_SKYPE;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceJabber]) {
            return IM_PROTOCOL_JABBER;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceMSN]) {
            return IM_PROTOCOL_MSN;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonInstantMessageServiceYahoo]) {
            return IM_PROTOCOL_YAHOO;
        }
        
        // types for phone number
        if ([recordKey isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
            return NUMBER_TYPE_MAIN;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonPhonePagerLabel]) {
            return NUMBER_TYPE_PAGER;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]) {
            return NUMBER_TYPE_FAX_HOME;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]) {
            return NUMBER_TYPE_FAX_WORK;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonPhoneOtherFAXLabel]) {
            return NUMBER_TYPE_FAX_OTHER;
        } else if ([recordKey isEqualToString:(NSString *)kABPersonPhoneMobileLabel]
                   || [recordKey isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel]) {
            return NUMBER_TYPE_MOBILE;
        }
        
        //types for date
        // types for date
        if ([recordKey isEqualToString:(NSString *)kABPersonAnniversaryLabel]) {
            return EVENT_TYPE_ANNIVERSARY;
        }
        
        // types for url
        if ([recordKey isEqualToString:(NSString *)kABPersonHomePageLabel]) {
            return URL_TYPE_HOME_PAGE;
        }

    } else {
        // for ios 9.0 and higher
        // types for common
        if ([recordKey isEqualToString:CNLabelWork]) {
            return COMMAN_TYPE_WORK;
        } else if ([recordKey isEqualToString:CNLabelHome]) {
            return COMMAN_TYPE_HOME;
        } else if ([recordKey isEqualToString:CNLabelOther]) {
            return COMMAN_TYPE_OTHER;
        }
        
        // types for im
        if ([recordKey isEqualToString:CNInstantMessageServiceQQ]) {
            return IM_PROTOCOL_QQ;
        } else if ([recordKey isEqualToString:CNInstantMessageServiceAIM]) {
            return IM_PROTOCOL_AIM;
        } else if ([recordKey isEqualToString:CNInstantMessageServiceFacebook]) {
            return IM_PROTOCOL_FACEBOOK;
        } else if ([recordKey isEqualToString:CNInstantMessageServiceMSN]) {
            return IM_PROTOCOL_MSN;
        } else if ([recordKey isEqualToString:CNInstantMessageServiceYahoo]) {
            return IM_PROTOCOL_YAHOO;
        } else if ([recordKey isEqualToString:CNInstantMessageServiceJabber]) {
            return IM_PROTOCOL_JABBER;
        } else if ([recordKey isEqualToString:CNInstantMessageServiceSkype]) {
            return IM_PROTOCOL_SKYPE;
        }
        
        // types for phone number
        if ([recordKey isEqualToString:CNLabelPhoneNumberMain]) {
            return NUMBER_TYPE_MAIN;
        } else if ([recordKey isEqualToString:CNLabelPhoneNumberPager]) {
            return NUMBER_TYPE_PAGER;
        } else if ([recordKey isEqualToString:CNLabelPhoneNumberHomeFax]) {
            return NUMBER_TYPE_FAX_HOME;
        } else if ([recordKey isEqualToString:CNLabelPhoneNumberWorkFax]) {
            return NUMBER_TYPE_FAX_WORK;
        } else if ([recordKey isEqualToString:CNLabelPhoneNumberOtherFax]) {
            return NUMBER_TYPE_FAX_OTHER;
        } else if ([recordKey isEqualToString:CNLabelPhoneNumberMobile]
                   || [recordKey isEqualToString:CNLabelPhoneNumberiPhone]) {
            return NUMBER_TYPE_MOBILE;
        }
        
        // types for date
        if ([recordKey isEqualToString:CNLabelDateAnniversary]) {
            return EVENT_TYPE_ANNIVERSARY;
        }
        
        // types for url
        if ([recordKey isEqualToString:CNLabelURLAddressHomePage]) {
            return URL_TYPE_HOME_PAGE;
        }
        
    }
    return nil;
}

+ (CFTypeRef) getRecordLabelByType:(NSString *)type mimetype:(NSString *)mimetype {
    //number
    if (![type isKindOfClass:[NSString class]]) {
        return kABOtherLabel;
    }
    
    if ([mimetype isEqualToString:MIME_TYPE_NUMBER]) {
        if ([type isEqualToString:NUMBER_TYPE_MOBILE]) {
            return kABPersonPhoneMobileLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_MAIN]) {
            return kABPersonPhoneMainLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_PAGER]) {
            return kABPersonPhonePagerLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_FAX_HOME]) {
            return kABPersonPhoneHomeFAXLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_FAX_WORK]) {
            return kABPersonPhoneWorkFAXLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_FAX_OTHER]) {
            return kABPersonPhoneOtherFAXLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_HOME]) {
            return kABHomeLabel;
        } else if([type isEqualToString:NUMBER_TYPE_WORK]) {
            return kABWorkLabel;
        } else if ([type isEqualToString:NUMBER_TYPE_OTHER]) {
            return kABOtherLabel;
        }
    }
    
    // url
    if ([mimetype isEqualToString:MIME_TYPE_URL]) {
        if ([type isEqualToString:URL_TYPE_HOME_PAGE]) {
            return kABPersonHomePageLabel;
        } else if ([type isEqualToString:URL_TYPE_HOME]) {
            return kABHomeLabel;
        } else if ([type isEqualToString:URL_TYPE_WORK]) {
            return kABWorkLabel;
        } else if ([type isEqualToString:URL_TYPE_OTHER]) {
            return kABOtherLabel;
        }
        
    }
    
    // address
    if ([mimetype isEqualToString:MIME_TYPE_ADDRESS]) {
        if ([type isEqualToString:ADDRESS_TYPE_HOME]) {
            return kABHomeLabel;
        } else if ([type isEqualToString:ADDRESS_TYPE_WORK]) {
            return kABWorkLabel;
        } else if ([type isEqualToString:ADDRESS_TYPE_OTHER]) {
            return kABOtherLabel;
        }
    }
    
    // email
    if ([mimetype isEqualToString:MIME_TYPE_EMAIL]) {
        if ([type isEqualToString:EMAIL_TYPE_HOME]) {
            return kABHomeLabel;
        } else if([type isEqualToString:EMAIL_TYPE_WORK]) {
            return kABWorkLabel;
        } else if ([type isEqualToString:EMAIL_TYPE_OTHER]) {
            return kABOtherLabel;
        }
    }
    
    // org, none
    
    // event
    if ([mimetype isEqualToString:MIME_TYPE_EVENT]) {
        if ([type isEqualToString:EVENT_TYPE_ANNIVERSARY]) {
            return kABPersonAnniversaryLabel;
        }
    }
    
    return kABOtherLabel;
}

+ (NSString * const) getContactKeyByType:(NSString *)type mimetype:(NSString *)mimetype{
    // number
    if ([mimetype isEqualToString:MIME_TYPE_NUMBER]) {
        if ([type isEqualToString:NUMBER_TYPE_MOBILE]) {
            return CNLabelPhoneNumberMobile;
        } else if ([type isEqualToString:NUMBER_TYPE_MAIN]) {
            return CNLabelPhoneNumberMain;
        } else if ([type isEqualToString:NUMBER_TYPE_PAGER]) {
            return CNLabelPhoneNumberPager;
        } else if ([type isEqualToString:NUMBER_TYPE_FAX_HOME]) {
            return CNLabelPhoneNumberHomeFax;
        } else if ([type isEqualToString:NUMBER_TYPE_FAX_WORK]) {
            return CNLabelPhoneNumberWorkFax;
        } else if ([type isEqualToString:NUMBER_TYPE_FAX_OTHER]) {
            return CNLabelPhoneNumberOtherFax;
        } else if ([type isEqualToString:NUMBER_TYPE_HOME]) {
            return CNLabelHome;
        } else if ([type isEqualToString:NUMBER_TYPE_WORK]) {
            return CNLabelWork;
        } else if ([type isEqualToString:NUMBER_TYPE_OTHER]) {
            return CNLabelOther;
        }
    }
    
    // url
    if ([mimetype isEqualToString:MIME_TYPE_URL]) {
        if ([type isEqualToString:URL_TYPE_HOME_PAGE]) {
            return CNLabelURLAddressHomePage;
        } else if ([type isEqualToString:URL_TYPE_HOME]) {
            return CNLabelHome;
        } else if ([type isEqualToString:URL_TYPE_WORK]) {
            return CNLabelWork;
        } else if ([type isEqualToString:URL_TYPE_OTHER]) {
            return CNLabelOther;
        }
    }
    
    // address
    if ([mimetype isEqualToString:MIME_TYPE_ADDRESS]) {
        if ([type isEqualToString:ADDRESS_TYPE_HOME]) {
            return CNLabelHome;
        } else if ([type isEqualToString:ADDRESS_TYPE_WORK]) {
            return CNLabelWork;
        } else if ([type isEqualToString:ADDRESS_TYPE_OTHER]) {
            return CNLabelOther;
        }
    }
    
    return CNLabelOther;
}


+ (BOOL) isMainPhoneNumber: (NSString *)label {
    if (!label) {
        return NO;
    }
    if ([FunctionUtility systemVersionFloat] < 9.0) {
        if ([label isEqualToString:(NSString *)kABPersonPhoneMainLabel]) {
            return YES;
        }
    } else {
        if ([label isEqualToString:CNLabelPhoneNumberMain]) {
            return YES;
        }
    }
    return NO;
}

+ (void) addElementsFor: (NSMutableDictionary *) dict fromSource:(NSDictionary *) source {
    if (!dict || !source) {
        return;
    }
    for(NSString *key in source) {
        if (![NSString isNilOrEmpty:key]) {
            id value = [source objectForKey:key];
            [dict setObject:value forKey:key];
        }
    }
}

#pragma mark helper for network opeation
+ (NSString *) getQRString {
    NSString *uuid = [UserDefaultsManager stringForKey:ACTIVATE_IDENTIFIER];;
    if (!uuid || uuid.length == 0) {
        uuid = [SeattleFeatureExecutor getToken];
    }
    if (!uuid) {
        return nil;
    }
    uuid = [NSString stringWithFormat:@"%@_%@", uuid, [DateTimeUtil stringTimestampInMillis]];
    cootek_log(@"contact_transfer, uuid: %@", uuid);
    [UserDefaultsManager setObject:uuid forKey:CONTACT_TRANSFER_QR_CODE_STRING];
    return uuid;
}
@end
