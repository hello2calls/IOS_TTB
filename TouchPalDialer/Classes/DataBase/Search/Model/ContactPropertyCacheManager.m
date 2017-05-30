//
//  ContactPropertyCache.m
//  Untitled
//
//  Created by Alice on 11-8-2.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "ContactPropertyCacheManager.h"
#import "ContactPropertyCacheModel.h"
#import "IMDataModel.h"
#import "ContactCacheDataManager.h"
#import	"OrlandoEngine.h"
#import "PersonDBA.h"
#import "CootekNotifications.h"
#import "TPAddressBookWrapper.h"
#import "NSString+PhoneNumber.h"

@interface ContactPropertyCacheManager() {
    BOOL isDetailInit;
}

@property(nonatomic,retain) NSArray *propertys;
@property(retain) NSMutableDictionary *propertyValuesCacheDict;

@end

@implementation ContactPropertyCacheManager

static ContactPropertyCacheManager *_sharedSingletonModel = nil;

@synthesize propertyValuesCacheDict;
@synthesize propertys;

+ (void)initialize
{
    _sharedSingletonModel = [[self alloc] init];
}
+ (id)shareManager
{
	@synchronized([ContactPropertyCacheManager class])
	{
        return _sharedSingletonModel;
	}
}
- (id)init
{
	self = [super init];
	if(self != nil){
		[self initWithAllSearchAttrInPersons];
	}
	return self;
}
- (BOOL)isPersonDetailInit {
    return isDetailInit;
}
- (void)updateSearchCache:(NSInteger)personID Type:(ContactChangeType)type
{
    if (personID > 0) {
        int attr_count=[propertys count];
        @synchronized([ContactPropertyCacheManager class])
        {
            for (int i=0;i<attr_count; i++) {
                @autoreleasepool {
                    NSInteger attr=[[propertys objectAtIndex:i] integerValue];
                    ContactPropertyCacheModel *attr_item = [propertyValuesCacheDict objectForKey:@(attr)];
                    [attr_item editWithPerson:personID AttributeName:attr withType:type];
                }
            }
        }
    }
}

- (void)initContactsPropertyCache
{
    @autoreleasepool {
        ABAddressBookRef addrBookRef = [TPAddressBookWrapper CreateAddressBookRefForCurrentThread];
        if(addrBookRef)
        {
            if (propertys) {
                NSMutableDictionary *tmpContactCache = [[NSMutableDictionary alloc] init];
                NSArray *person_list=[PersonDBA getAsyncAllContact:addrBookRef];
                int attr_count=[propertys count];
                for (int i=0;i<attr_count; i++) {
                    NSInteger attr=[[propertys objectAtIndex:i] integerValue];
                    ContactPropertyCacheModel *attr_item=[[ContactPropertyCacheModel alloc] initWithPersonList:person_list AttributeName:attr];
                    [tmpContactCache setObject:attr_item forKey:[NSNumber numberWithInt:attr]];
                }
                @synchronized([ContactPropertyCacheManager class])
                {
                    self.propertyValuesCacheDict = tmpContactCache;
                }
            }			
        }	
        isDetailInit = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:N_CONTACT_DETAIL_INIT object:nil];
        [TPAddressBookWrapper ReleaseAddressBookForCurrentThread];
    }
}

- (void)initWithAllSearchAttrInPersons
{
    NSMutableArray* allSearchAttributes = [[NSMutableArray alloc] init];
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonNicknameProperty]];
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonOrganizationProperty]];
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonJobTitleProperty]];
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonDepartmentProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonEmailProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonURLProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonAddressProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonInstantMessageProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonBirthdayProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonCreationDateProperty]];
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonDateProperty]]; 
    [allSearchAttributes addObject:[NSNumber numberWithInt:kABPersonNoteProperty]]; 
    self.propertys=allSearchAttributes;

    NSMutableDictionary *tmpDic=[[NSMutableDictionary alloc] init];
    self.propertyValuesCacheDict=tmpDic;

    [NSThread detachNewThreadSelector:@selector(initContactsPropertyCache) toTarget:self withObject:nil];
}
- (NSArray *)valuesByPropertyID:(NSInteger)attr
{
    NSNumber *key = [NSNumber numberWithInt:attr];
    NSArray *results = nil;
    @synchronized([ContactPropertyCacheManager class]){
        NSArray *single_attr_list = [[propertyValuesCacheDict objectForKey:key] contactPropertyValues];
        if ([single_attr_list count] > 0) {
            results = [NSArray arrayWithArray:single_attr_list];
        }
    }
	return results;
}
- (NSDictionary *)allCachePropertyValuesDict
{
     @synchronized([ContactPropertyCacheManager class]){
        return  [NSDictionary dictionaryWithDictionary:propertyValuesCacheDict];
     }
}
@end
