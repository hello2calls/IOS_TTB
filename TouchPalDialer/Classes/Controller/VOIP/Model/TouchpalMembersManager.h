//
//  TouchpalMembersManager.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/1/27.
//
//

#import <Foundation/Foundation.h>
#import "ContactCacheDataModel.h"


@protocol TouchpalsChangeDelegate
- (void)onTouchpalChanges;
@end

@interface TouchpalMembersManager : NSObject
+ (void)init;
+ (void)checkTouchpals:(BOOL)isTimeUp;
+ (void)addListener:(id<TouchpalsChangeDelegate>)listener;
+ (void)removeListener:(id)listener;
+ (NSInteger)isNumberRegistered:(NSString *)number;
+ (NSInteger)insertNumber:(NSString *)number andIfCootekUser:(BOOL) boolValue andIfRefreshNow:(BOOL) refresh;
+ (void)deInit;
+ (void)getTouchpaler:(NSMutableDictionary*)keyDic andKeys:(NSMutableArray*)keyArray;
+ (NSInteger) getTouchpalerArrayCount;
+ (NSInteger) getNewTouchpalerArraycount;
+ (NSInteger) getTouchpalerFamilyArrayCount;
+ (BOOL)ifAlertNumberShown;
+ (void)removeAllNewTouchpaler;
+ (void)generateInitialData;
+ (void)deleteFriend:(NSInteger)personId ifRefreash:(BOOL)ifRefresh;
+ (BOOL) isRegisteredByContactCachedModel:(ContactCacheDataModel *)model;
+ (BOOL) isRegisteredByPersonId:(NSInteger)personId;

@end
