//
//  CommandDataHelper.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-13.
//
//

#import "CommandDataHelper.h"
#import "CallLogDataModel.h"
#import "SearchResultModel.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"

@implementation CommandDataHelper

+ (NSString *)displayNameFromData:(id)data
{
    if([data isKindOfClass:[CallLogDataModel class]]){
        CallLogDataModel *c = (CallLogDataModel *)data;
        if(c.personID < 0){
            if (c.shopID >0 && c.name!=nil && c.name.length>0){
                return  c.name;
            }else {
                return c.number;
            }
        }else{
            if(c.name!=nil && c.name.length>0)
                return  c.name;
            else
                return c.number;
        }
    }else if([data isKindOfClass:[SearchItemModel class]]){
        SearchItemModel *s = (SearchItemModel *)data;
        if(s.personID < 0){
            if ( s.name.length>0){
                return  s.name;
            }else {
                return s.number;
            }
        }else{
            if(s.name!=nil && s.name.length>0)
                return  s.name;
            else
                return s.number;
        }
    }else if([data isKindOfClass:[ContactCacheDataModel class]]){
        return [(ContactCacheDataModel *)data displayName];
    }
    
    return nil;
    
}

+ (NSString *)phoneNumberFromData:(id)data
{
    if([data isKindOfClass:[CallLogDataModel class]]){
        return [(CallLogDataModel *)data number];
    }else if([data isKindOfClass:[SearchItemModel class]]){
        return [(SearchItemModel *)data number];
    }else if([data isKindOfClass:[ContactCacheDataModel class]]){
        return nil;
    }
    return nil;
}

+ (NSString *)defaultPhoneNumberFromData:(id)data
{
    if ([data isKindOfClass:[ContactCacheDataModel class]]) {
        return [((ContactCacheDataModel *)data) mainPhone].number;
    }
    
    if ([data isKindOfClass:[SearchItemModel class]]) {
        NSString *result = [self phoneNumberFromData:data];
        if ([result length] == 0) {
            NSInteger personId = [self personIdFromData:data];
            if (personId > 0) {
                result = [[[ContactCacheDataManager instance] contactCacheItem:personId] mainPhone].number;
            }
        }
        
        return result;
    }
    return [self phoneNumberFromData:data];
}

+ (NSInteger)personIdFromData:(id)data
{
    if([data isKindOfClass:[CallLogDataModel class]]){
        return [(CallLogDataModel *)data personID];
    }else if([data isKindOfClass:[SearchItemModel class]]){
        return [(SearchItemModel *)data personID];
    }else if([data isKindOfClass:[ContactCacheDataModel class]]){
        return [(ContactCacheDataModel *)data personID];
    }    
    // Refacotring note: should return -1? the origianl code returns 0
    return 0;
}
@end
