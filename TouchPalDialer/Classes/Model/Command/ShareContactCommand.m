//
//  ShareContactCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "ShareContactCommand.h"
#import "CommandDataHelper.h"
#import "TPMFMessageActionController.h"
#import "CallLogDataModel.h"
#import "SearchResultModel.h"
#import "ContactCacheDataModel.h"
#import "CallerIDInfoModel.h"
#import "DialResultModel.h"
#import "TPShareController.h"
#import "ContactInfoUtil.h"
#import "DialerUsageRecord.h"


@implementation ShareContactCommand

- (void)onExecute
{
    if ([self.targetData isKindOfClass:[ContactCacheDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CONTACT_ACTION, @"share"), nil];
    }
    
    if ([self.targetData isKindOfClass:[CallLogDataModel class]]) {
         [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"share"), nil];
    }
    
    NSString *title = [ShareContactCommand shareTitleFromData:self.targetData];
    NSString *message = [ShareContactCommand shareMessageFromData:self.targetData];
    if ([self canExcuteTPShareController:self.targetData]) {
        [self holdUntilNotified];
        [[TPShareController controller] showShareActionSheet:title
                                                     message:message
                                              naviController:self.navController
                                                 actionBlock:^(){
                                                     [self notifyCommandExecuted];
                                                 }];
    }else{
        [TPMFMessageActionController sendMessageToNumber:nil
                                                          withMessage:message
                                                          presentedBy:self.navController];
    }
}
- (BOOL)canExcuteTPShareController:(id)data{
     if([data conformsToProtocol:@protocol(BaseContactsDataSource)] &&
        [data conformsToProtocol:@protocol(BaseCallerIDDataSource)])
     {
         id <BaseContactsDataSource,BaseCallerIDDataSource> datasource = (id<BaseContactsDataSource,BaseCallerIDDataSource>)data;
         if (datasource.personID < 0 ) {
              CallerIDInfoModel *caller = datasource.callerID;
             if (!caller || ![caller isCallerIdUseful]) {
                return NO;
             }
         }
     }
    return YES;
}
+ (NSString*)shareTitleFromData:(id)data
{
    if([data isKindOfClass:[CallLogDataModel class]]){
        return [self shareTitleFromCallLog:(CallLogDataModel *)data];
    }else if([data isKindOfClass:[SearchItemModel class]]){
        return [self shareTitleFromSearchResult:(SearchItemModel *)data];
    }else if([data isKindOfClass:[ContactCacheDataModel class]]){
        return [self shareTitleFromCacheItem:(ContactCacheDataModel *)data];
    }
    return @"";
}

+ (NSString*)shareMessageFromData:(id)data
{
    if([data isKindOfClass:[CallLogDataModel class]]){
        return [self shareMessageFromCallLog:(CallLogDataModel *)data];
    }else if([data isKindOfClass:[SearchItemModel class]]){
        return [self shareMessageFromSearchResult:(SearchItemModel *)data];
    }else if([data isKindOfClass:[ContactCacheDataModel class]]){
        return [self shareMessageFromCacheItem:(ContactCacheDataModel *)data];
    }
    
    return [CommandDataHelper phoneNumberFromData:data];
}
+ (NSString *)shareTitleFromCallLog:(CallLogDataModel *)calllog
{
    if(calllog.personID > 0){
        return calllog.name;
    }else if ([calllog respondsToSelector:@selector(callerID)]){
        CallerIDInfoModel *caller = calllog.callerID;
        if ([caller isCallerIdUseful]) {
            return [caller.name length] > 0 ? caller.name : [caller localizedTag];
        }
    }
    return @"";
}
+ (NSString *)shareMessageFromCallLog:(CallLogDataModel *)calllog
{
    if(calllog.personID > 0){
        return [ContactInfoUtil shareNumberEmailsByPersonID:calllog.personID];
    }else if ([calllog respondsToSelector:@selector(callerID)]){
        CallerIDInfoModel *caller = calllog.callerID;
        if ([caller isCallerIdUseful]) {
            NSString *tag = [caller.name length] > 0 ? [caller localizedTag] : @"" ;
            return [tag length] > 0 ? [NSString stringWithFormat:@"%@\n%@",tag,calllog.number]:calllog.number;
        }
    }
    return calllog.number;
}

+ (NSString *)shareTitleFromSearchResult:(SearchItemModel *)searchResult
{
    if(searchResult.personID > 0){
        return searchResult.name;
    }else if ([searchResult isMemberOfClass:[DialResultModel class]]&&
              [searchResult respondsToSelector:@selector(callerID)]){
        DialResultModel *data = (DialResultModel *)searchResult;
        CallerIDInfoModel *caller = data.callerID;
        if ([caller isCallerIdUseful]) {
            return [caller.name length] > 0 ? caller.name : [caller localizedTag];
        }
    }
    return @"";
}

+ (NSString *)shareMessageFromSearchResult:(SearchItemModel *)searchResult
{
    if(searchResult.personID > 0){
        return [ContactInfoUtil shareNumberEmailsByPersonID:searchResult.personID];
    }else if ([searchResult isMemberOfClass:[DialResultModel class]]&&
              [searchResult respondsToSelector:@selector(callerID)]){
        DialResultModel *data = (DialResultModel *)searchResult;
        CallerIDInfoModel *caller = data.callerID;
        if ([caller isCallerIdUseful]) {
            NSString *tag = [caller.name length] > 0 ? [caller localizedTag] : @"" ;
            return [NSString stringWithFormat:@"%@\n%@",tag,searchResult.number];
        }
    }
    return searchResult.number;

}

+ (NSString *)shareTitleFromCacheItem:(ContactCacheDataModel *)cacheItem
{
    return [ContactInfoUtil shareNameByPersonID:cacheItem.personID];
}
+ (NSString *)shareMessageFromCacheItem:(ContactCacheDataModel *)cacheItem
{
    return [ContactInfoUtil shareNumberEmailsByPersonID:cacheItem.personID];;
}
@end
