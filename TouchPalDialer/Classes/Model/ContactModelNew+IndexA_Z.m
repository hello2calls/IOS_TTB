//
//  ContactModelNew+IndexA_Z.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-22.
//
//

#import "ContactModelNew+IndexA_Z.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "LangUtil.h"

@implementation ContactModelNew (IndexA_Z)

+ (int)buildIndexArray:(NSArray *)allContactIDs
toNewContactsContainer:(NSMutableDictionary *)contactsContainer
      andKeyContainers:(NSMutableArray *)contactsKeys
{
    int contactNums = 0;
    [contactsKeys addObjectsFromArray:[ContactModelNew getSharedContactModel].predefinedKeys];
    for (NSString* keyItem in contactsKeys) {
        NSMutableArray *contactsForKey = [[NSMutableArray alloc] initWithCapacity:1];
        [contactsContainer setObject:contactsForKey forKey:keyItem];
    }
    
    cootek_log(@"Did load all sorted contact from addressbook");
    // indexing contacts
    for (int i=0; i<[allContactIDs count]; i++) {
        ContactCacheDataModel* cachePersonData = [[ContactCacheDataManager instance] contactCacheItem:[((NSNumber *)[allContactIDs objectAtIndex:i]) longValue]];
        if(cachePersonData!=nil){
            NSString *candidateKey;
            candidateKey = wcharToNSString(getFirstLetter(NSStringToFirstWchar(cachePersonData.displayName)));
            NSMutableArray *contactsForKey = [contactsContainer objectForKey:candidateKey];
            if (contactsForKey != nil) {
                [contactsForKey addObject:cachePersonData];
            }
            contactNums++;
        }
    }

    // remove empty keys
    int i = 0;
    for (; i<[contactsKeys count]; i++) {
        NSString* keyItem = [contactsKeys objectAtIndex:i];
        NSMutableArray *contactsForKey = [contactsContainer objectForKey:keyItem];
        if ([contactsForKey count] <= 0) {
            [contactsContainer removeObjectForKey:keyItem];
            [contactsKeys removeObjectAtIndex:i];
            i--;
        }
    }

    // sort contact according to the addressBook
    for (NSString *key in [contactsContainer allKeys]) {
        NSMutableArray *contactsForKey = [contactsContainer objectForKey:key];
        [contactsForKey sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
            ContactCacheDataModel *item1 = (ContactCacheDataModel*)obj1;
            ContactCacheDataModel *item2 = (ContactCacheDataModel*)obj2;
            return [item1.displayName localizedCompare:item2.displayName];
        }];
    }
    return contactNums;
}

@end
