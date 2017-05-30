//
//  NumberPersonMappingModel.m
//  Untitled
//
//  Created by Alice on 11-8-11.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "NumberPersonMappingModel.h"
#import "PhoneDataModel.h"
#import "PhoneNumber.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "CallLogDBA.h"
#import "NSString+PhoneNumber.h"
#import "UserDefaultsManager.h"
#import "OrlandoEngine+Contact.h"

@implementation NumberPersonMappingModel

NSMutableDictionary *numberPersonMappingDict = nil;

+ (void)initialize{
    numberPersonMappingDict = [[NSMutableDictionary alloc] init];
}

+ (NSInteger)queryContactIDByNumber:(NSString *)number
{
    NSInteger personID = [self getCachePersonIDByNumber:number];
    if (personID > 0) {
        return personID;
    }
    
    NSString *normalNumber = [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:number];
    NSInteger result = -1;
    if ([normalNumber hasPrefix:@"+"]) {
        result = [[OrlandoEngine instance] queryNumberToContact:normalNumber withLength:9];
    }else{
        result = [[OrlandoEngine instance] queryNumberToContact:normalNumber];
    }
    return result > 0 ? result : -1;
}

+ (NSInteger)getCachePersonIDByNumber:(NSString *)number
{
	if (number) {
		number = [[PhoneNumber sharedInstance] getNormalizedNumber:number];
        @synchronized(numberPersonMappingDict){
            NSInteger personID = [[numberPersonMappingDict objectForKey:number] intValue];
            if (personID == 0) {
                personID=-1;
            }
            return personID;
        }
	}else {
		return -1;
	}
}

+ (void)setPersonID:(NSInteger)personID
          forNumber:(NSString *)number
{
    @synchronized(numberPersonMappingDict){
        [numberPersonMappingDict setObject:@(personID) forKey:number];
    }

}
+ (void)setContactNumberMapping:(ContactCacheDataModel *)contact{
    NSArray *phones = contact.phones;
    NSInteger personID = contact.personID;
    for (PhoneDataModel *model in phones) {
        [self setPersonID:personID forNumber:model.normalizedNumber];
    }
}
+ (void)removePersonIDForNumber:(NSString *)number
{
    @synchronized(numberPersonMappingDict){
       [numberPersonMappingDict removeObjectForKey:number];
    }
}

+ (void)refreshLocalCache
{
     @synchronized(numberPersonMappingDict){
         NSArray *keyList = [numberPersonMappingDict allKeys];
         for (NSString *key in keyList) {
             NSString *newKey = [[PhoneNumber sharedInstance] getNormalizedNumber:key];
             if (![newKey isEqualToString:key]) {  
                 [numberPersonMappingDict setObject:[numberPersonMappingDict objectForKey:key] forKey:newKey];
                 [numberPersonMappingDict removeObjectForKey:key];
             }
         }
     }
}
@end
