//
//  ContactModelNew.m
//  TouchPalDialer
//
//  Created by Sendor on 12-1-18.
//  Copyright 2012 Cootek. All rights reserved.
//

#import "ContactModelNew.h"
#import "LangUtil.h"
#import "Person.h"
#import "CootekNotifications.h"
#import "ContactCacheDataManager.h"
#import "FavoriteModel.h"
#import "ContactSpecialManager.h"
#import "ContactSpecialInfo.h"

static ContactModelNew *SharedModel_ = nil;

@implementation ContactModelNew

@synthesize all_contacts;
@synthesize all_contact_keys;
@synthesize predefinedKeys;

+ (void)initialize
{
    SharedModel_ = [[self alloc] init];
}

+ (ContactModelNew *)getSharedContactModel
{
	return SharedModel_;
}

- (id)init
{
	self = [super init];
    if (self) {
        predefinedKeys = [[NSMutableArray alloc] initWithObjects:
                          @"♡", @"special", @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                          @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"*",
                          nil];
    }
    return self;
}

- (void)buildAZtoAllContacts
{
    @autoreleasepool {
        cootek_log(@"queryAllContact start");
        NSMutableDictionary *tmp_all_contacts = [[NSMutableDictionary alloc] initWithCapacity:28];
        NSMutableArray *tmp_all_contact_keys = [[NSMutableArray alloc] initWithCapacity:28];
        NSArray *contacts = [[ContactCacheDataManager instance] getAllCacheContact];
        [self buildIndexContacts:tmp_all_contacts andIndexKeys:tmp_all_contact_keys forPersonList:contacts];
        all_contacts = tmp_all_contacts;
        all_contact_keys = tmp_all_contact_keys;
        cootek_log(@"queryAllContact end");
    }
}

- (void)buildAZtoAllContactsWithContactIDs:(NSArray *)contacts
{
    @autoreleasepool {
        cootek_log(@"queryAllContact start");
        NSMutableDictionary *tmp_all_contacts = [[NSMutableDictionary alloc] initWithCapacity:28];
        NSMutableArray *tmp_all_contact_keys = [[NSMutableArray alloc] initWithCapacity:28];
        [self buildIndexContacts:tmp_all_contacts andIndexKeys:tmp_all_contact_keys forPersonList:contacts];
        all_contacts = tmp_all_contacts;
        all_contact_keys = tmp_all_contact_keys;
        cootek_log(@"queryAllContact end");
    }
}

- (void)buildIndexContacts:(NSMutableDictionary *)contactsDict
              andIndexKeys:(NSMutableArray *)contactKeys
             forPersonList:(NSArray *)persons{
    
    [contactKeys addObjectsFromArray:self.predefinedKeys];
    
    for (NSString *keyItem in contactKeys) {
        NSMutableArray *contactsForKey = [[NSMutableArray alloc] init];
        [contactsDict setObject:contactsForKey forKey:keyItem];
    }
    
    // index contacts
    NSInteger personCount = 0;
    for (; personCount < [persons count]; personCount++) {
        ContactCacheDataModel *item = [persons objectAtIndex:personCount];
        NSString *candidateKey = wcharToNSString(getFirstLetter(NSStringToFirstWchar(item.displayName)));
        NSMutableArray *contactsForKey = [contactsDict objectForKey:candidateKey];
        if (contactsForKey != nil) {
            [self insertObjectInOrder:contactsForKey InsertObject:item];
        }
    }
    
    if (personCount > 0) {
        NSArray *favArray = [[FavoriteModel Instance] getFavriteList];
        for (FavoriteDataModel *fav in favArray) {
            ContactCacheDataModel *item = [[ContactCacheDataManager instance] contactCacheItem:fav.personID];
            NSMutableArray *contactsForKey = [contactsDict objectForKey:@"♡"];
            if (item != nil) {
                [contactsForKey addObject:item];
            }
        }
        
        NSArray *specialArray = [[ContactSpecialManager instance] getSpecialArray];
        NSInteger count = specialArray.count;
        for (NSInteger index = 0; index < count; index++){
            ContactSpecialInfo *info = specialArray[index];
            NSMutableArray *contactsForKey = [contactsDict objectForKey:@"special"];
            [contactsForKey addObject:info];
        }
    }
    
    // remove empty keys
    for (int i = 0; i<[contactKeys count]; i++) {
        NSString *keyItem = [contactKeys objectAtIndex:i];
        NSMutableArray *contactsForKey = [contactsDict objectForKey:keyItem];
        if ([contactsForKey count] <= 0) {
            [contactsDict removeObjectForKey:keyItem];
            [contactKeys removeObjectAtIndex:i];
            i--;
        }
    }
    
    //sort all dic
    for (NSString *key in [contactsDict allKeys]) {
        if ( ![key isEqualToString:@"special"] ){
            NSMutableArray *contactsForKey = [contactsDict objectForKey:key];
            [contactsForKey sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                ContactCacheDataModel *item1 = (ContactCacheDataModel*)obj1;
                ContactCacheDataModel *item2 = (ContactCacheDataModel*)obj2;
                return [item1.displayName localizedCompare:item2.displayName];
            }];
        }
    }
}

- (void)insertObjectInOrder:(NSMutableArray *)Dict InsertObject:(ContactCacheDataModel *)num
{
    if (Dict.count == 0) {
        [Dict addObject:num];
    } else {
        NSInteger left = 0;
        NSInteger right = Dict.count-1;
        NSInteger middle;
        NSInteger j;

      // 二分法查找插入位置
        while( right >= left) {
            middle = ( left + right ) / 2;
            if( [num.displayName compare:((ContactCacheDataModel *)([Dict objectAtIndex:middle])).displayName] == NSOrderedAscending){
                right = middle-1;
            }
            else {
            left = middle + 1;
            }
        }
        for( j = Dict.count - 1;j >= left;j-- ) {
            [Dict setObject:[Dict objectAtIndex:j] atIndexedSubscript:j+1];
        }
        [Dict setObject:num atIndexedSubscript:left];
    }
    
}

@end
