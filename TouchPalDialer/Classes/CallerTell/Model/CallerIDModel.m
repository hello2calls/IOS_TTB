//
//  CallerIDModel.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-9-24.
//
//

#import "CallerIDModel.h"
#import "CallerDBA.h"
#import "AppSettingsModel.h"
#import "TouchPalDialerAppDelegate.h"
#import "FunctionUtility.h"
#import "SeattleExecutorHelper.h"
#import "NumberPersonMappingModel.h"
#import "SmartDailerSettingModel.h"
#import "Reachability.h"
#import "CommonUtil.h"
#import "QueryCallerid.h"
#import "TouchPalDialerLaunch.h"

@interface CallerIDModel ()
+(CallerIDInfoModel *)queryCallerIDByNumber:(NSString *)number needQueryFromRemote:(BOOL)remote;
@end

@implementation CallerIDModel

+(CallerIDInfoModel *)queryCallerIDByNumberWithOutNotification:(NSString *)number{
    return [self queryCallerIDByNumber:number needQueryFromRemote:NO];
}

+(CallerIDInfoModel *)queryCallerIDByNumber:(NSString *)number{
    return [self queryCallerIDByNumber:number needQueryFromRemote:YES];
}

+(CallerIDInfoModel *)queryCallerIDByNumber:(NSString *)number needQueryFromRemote:(BOOL)remote{
    CallerIDInfoModel *callerID = nil;
    if(!SmartDailerSettingModel.isChinaSim){
        return nil;
    }
    if(number == nil || [number length] < 3) {
        cootek_log(@"The number is too short. Skip the query for callerID.");
        return callerID;
    }
    
    if(![TouchPalDialerLaunch getInstance].isDataInitialized) {
        // The database is not initialized yet, ignore the query request
        return callerID;
    }
    number = [PhoneNumber getCNnormalNumber:number];
    
    callerID = [CallerDBA queryCacheCallerIdByNumber:number];
    if(callerID) {
        return callerID;
    }
    
    callerID = [[QueryCallerid shareInstance]getLocalCallerid:number];
    
    if(!callerID && remote) {
        [CallerIDModel willQueryCallerIDsFromService:[NSArray arrayWithObject:number]];
    }
    
    return callerID;
}
+(void)willQueryCallerIDsFromService:(NSArray *)numbers{
    if([Reachability network] >= network_2g &&SmartDailerSettingModel.isChinaSim){
        [NSThread detachNewThreadSelector:@selector(doQueryCallerIDsFromService:) toTarget:self withObject:numbers];
    }
}
+(void)doQueryCallerIDsFromService:(NSArray *)numbers{
    @autoreleasepool {
        NSArray *CallerIDs = [SeattleExecutorHelper queryCallerIdInfo:numbers];
        [self performSelectorOnMainThread:@selector(didQueryCallerIDsFromService:) withObject:CallerIDs waitUntilDone:NO];
    }
}
+(void)didQueryCallerIDsFromService:(NSArray *)CallerIDs{
    @autoreleasepool {
        if ([CallerIDs count] > 0) {
            [CallerDBA addCallers:CallerIDs];
            BOOL needNotify = NO;
            for(CallerIDInfoModel *callerID in CallerIDs){
                if([callerID isCallerIdUseful]){
                    needNotify = YES;
                    break;
                }
            }
            if(needNotify){
                [[NSNotificationCenter defaultCenter] postNotificationName:N_DID_QUERY_CALLERIDS_CALLBACK object:CallerIDs];
            }
        }
    }
}

+(void)queryCallerIDInBackgroundThread:(NSDictionary *)parameterDic{
    @autoreleasepool {
        CallerIDInfoModel *callerID = nil;
        NSString *number = [parameterDic objectForKey:@"number"];
        void (^callBackBlock)(CallerIDInfoModel *)  = (void (^)(CallerIDInfoModel *))[parameterDic objectForKey:@"callBackBlock"];
        if(number.length>0){
            if([TouchPalDialerLaunch getInstance].isDataInitialized){
                callerID = [CallerDBA queryCacheCallerIdByNumber:number];
                if(!callerID){
                    callerID = [[QueryCallerid shareInstance]getLocalCallerid:number];
                    if (!callerID) {
                        if ([CommonUtil isValidNormalizedPhoneNumber:number]){
                            NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:number];
                            if (personID < 0) {
                                NSArray *callerIDs = [SeattleExecutorHelper queryCallerIdInfo:[NSArray arrayWithObject:number]];
                                if(callerIDs.count > 0){
                                    callerID = [callerIDs objectAtIndex:0];
                                }
                            }
                        }
                    }
                    if (callerID) {
                        [CallerDBA addCallers:[NSArray arrayWithObject:callerID] notify:NO];
                    }
                }
            }
        }
        if(callerID!=nil && [callerID isCallerIdUseful]){
            NSDictionary *parameterDic = [NSDictionary dictionaryWithObjectsAndKeys:callerID,@"callerID",callBackBlock,@"callBackBlock", nil];
            [self performSelectorOnMainThread:@selector(didQueryCallerIDs:) withObject:parameterDic waitUntilDone:NO];
        }
    }
}

+(void)didQueryCallerIDs:(NSDictionary *)parameterDic{
   void (^callBackBlock)(CallerIDInfoModel *)  = (void (^)(CallerIDInfoModel *))[parameterDic objectForKey:@"callBackBlock"];
    CallerIDInfoModel *callerID = [parameterDic objectForKey:@"callerID"];
    callBackBlock(callerID);
}

+(void)queryCallerIDWithNumber:(NSString *)number callBackBlock:(void (^)(CallerIDInfoModel *))callBackBlock{
    void (^callBack_copy)(CallerIDInfoModel *) = [callBackBlock copy];
    if (![number hasPrefix:@"+"]) {
        number = [PhoneNumber getNormalizedNumber:number];
    }
    NSDictionary *parameterDic = [[NSDictionary alloc] initWithObjectsAndKeys:number,@"number",callBack_copy,@"callBackBlock", nil];
    [NSThread detachNewThreadSelector:@selector(queryCallerIDInBackgroundThread:) toTarget:self withObject:parameterDic];
}
+(void)queryCallerIDs:(NSArray *)numbers
{
    @autoreleasepool {
        NSMutableArray *callerDBAs = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *services = [NSMutableArray arrayWithCapacity:1];
        for (NSString *number in numbers) {
            CallerIDInfoModel *callerID = [[QueryCallerid shareInstance]getLocalCallerid:number];
            if (!callerID) {
                [services addObject:number];
            } else {
                [callerDBAs addObject:callerID];
            }
        }
        if ([callerDBAs count] > 0) {
            [CallerDBA addCallers:callerDBAs];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:N_DID_QUERY_CALLERIDS_CALLBACK object:nil userInfo:nil];
            });
        }
        if ([services count] > 0) {
            [CallerIDModel willQueryCallerIDsFromService:services];
        }
    }
}
@end
