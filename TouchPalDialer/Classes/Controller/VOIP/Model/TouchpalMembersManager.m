//
//  TouchpalMembersManager.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/1/27.
//
//

#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "ContactCacheDataModel.h"
#import "ContactCacheDataManager.h"
#import "CootekNotifications.h"
#import "SeattleFeatureExecutor.h"
#import "TouchpalNumbersDBA.h"
#import "Reachability.h"
#import "ContactModelNew.h"
#import "ContactModelNew+IndexA_Z.h"
#import "ContactSpecialManager.h"
#import "ContactSpecialInfo.h"

static volatile bool sRefreshQueryNewUser = NO;
static BOOL sIsPersonCacheReady = NO;
static NSMutableArray __strong *sListeners = nil;
static NSMutableDictionary __strong *sNumberCacheDict = nil;
static NSMutableArray __strong *newTouchpalerArray;
static NSMutableArray __strong *newTouchpalerNumberArray;
static NSMutableArray __strong *touchpalerArray;

@implementation TouchpalMembersManager

+ (void)init{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheDoneQueryUserExist) name:N_ENGINE_INIT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryAfterPersonChanged:)
                                                 name:N_PERSON_DATA_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryTouchpalsOnEvent)
                                                 name:N_REFRESH_IS_VOIP_ON
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryTouchpalsOnEvent)
                                                 name:N_SYSTEM_CONTACT_DATA_CHANGED
                                               object:nil];
    sListeners = [NSMutableArray arrayWithCapacity:2];
    sNumberCacheDict = [TouchpalNumbersDBA getAllTouchPalNumbers];
    @synchronized (newTouchpalerNumberArray) {
        
        if ( [UserDefaultsManager objectForKey:NEW_TOUCHPALER_NUMBER_ARRAY defaultValue:nil] == nil ){
            newTouchpalerNumberArray = [NSMutableArray array];
        }else{
            newTouchpalerNumberArray = (NSMutableArray *)[UserDefaultsManager objectForKey:NEW_TOUCHPALER_NUMBER_ARRAY defaultValue:nil];
        }
    }
    newTouchpalerArray = [NSMutableArray array];
}


+ (void)generateInitialData{
    [self generateNewTouchpalArray];
    touchpalerArray = [self generateTouchpalArray];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
}


+ (void)cacheDoneQueryUserExist{
    sIsPersonCacheReady = YES;
    [self queryUserExistForUnknownOnly:YES];
}

+ (void)deInit {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

+ (void)checkTouchpals:(BOOL)isTimeUp{
    if (!sIsPersonCacheReady) {
        return;
    }
    [self queryUserExistForUnknownOnly:!isTimeUp];
}

+ (BOOL)queryTouchpalsForAllNumber:(NSArray *)numbers{
    BOOL isReallyQuery = NO;
    if (numbers.count == 0) {
        return isReallyQuery;
    }
    NSInteger cycleLength = [numbers count]/100 + 1;
    NSInteger sleepTime = 0;
    for (int i = 0 ; i < cycleLength ; i ++ ){
        NSRange range = NSMakeRange(i*100, 100);
        if ( i == cycleLength - 1){
            range = NSMakeRange(i*100, [numbers count]%100);
        }
        
        NSArray *subArray = [numbers subarrayWithRange:range];
        sleepTime = [self queryTouchpalsWithLimitSize:subArray];
        
        if (sleepTime == -1){
            break;
        }
        isReallyQuery = YES;
        if ( i != cycleLength -1){
            cootek_log(@"Is getting touchpal members before sleeping: %d", sleepTime);
            sleep(sleepTime);
            cootek_log(@"Is getting touchpal members after sleeping: %d", sleepTime);
        }
    }
    return isReallyQuery;
}

+ (void)queryUserExistForUnknownOnly:(BOOL)unknonwOnly {
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        return;
    }
    if (sRefreshQueryNewUser) {
        return;
    }
    if ( [Reachability network] < network_2g ){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
            if (sRefreshQueryNewUser)
                return;
            sRefreshQueryNewUser = YES;
            NSArray *contacts = [[ContactCacheDataManager instance] getAllCacheContact];
            NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:contacts.count + 10];
            for (ContactCacheDataModel *model in contacts) {
                for (PhoneDataModel *phone in model.phones) {
                    NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
                    if ([number hasPrefix:@"+861"] && number.length == 14){
                        NSInteger resultCode = [self isNumberRegistered:number];
                        if (unknonwOnly && resultCode == -1) {
                            [numbers addObject:number];
                        } else if (!unknonwOnly && resultCode != 1) {
                            [numbers addObject:number];
                        }
                    }
                }
            }
            if ([self queryTouchpalsForAllNumber:numbers]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self notifyListeners];
                });
            }
            sRefreshQueryNewUser = NO;
        }
    });
}

+ (NSInteger)queryTouchpalsWithLimitSize:(NSArray*) numbers{
    NSArray *resultList = [SeattleFeatureExecutor queryVoipUserExist:numbers];
    if ([resultList count] < 3){
        return -1;
    }
    NSInteger resultCode = [[resultList objectAtIndex:0] integerValue];
    if (resultCode != 2000){
        return -1;
    }
    NSInteger sleepTime = [[resultList objectAtIndex:1] integerValue];
    NSArray *resultArray = [resultList subarrayWithRange:NSMakeRange(2, [resultList count]-2)];
    
    if ( [numbers count] != [resultArray count]){
        return -1;
    }
    
    for ( int i = 0 ; i < [resultArray count] ; i ++){
        NSInteger isCootekUser = [[resultArray objectAtIndex:i] integerValue];
        [self insertNumber:[numbers objectAtIndex:i] andIfCootekUser:isCootekUser andIfRefreshNow:NO];
    }
    return sleepTime;
}

+ (void)addListener:(id<TouchpalsChangeDelegate>)listener {
    @synchronized(self) {
        if ([sListeners containsObject:listener]) {
            return;
        }
        [sListeners addObject:listener];
    }
}

+ (void)queryTouchpalsOnEvent{
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        [self queryUserExistForUnknownOnly:YES];
    }
}

+ (void)queryAfterPersonChanged:(id)personChange{
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        NotiPersonChangeData* changedData = [[personChange userInfo] objectForKey:KEY_PERSON_CHANGED];
        if (changedData.change_type == ContactChangeTypeDelete || changedData == nil){
            return;
        } else {
            if ( [Reachability network] < network_2g ){
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
                    ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:changedData.person_id];
                    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:1];
                    for (PhoneDataModel *phone in personData.phones){
                        NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
                        if ([number hasPrefix:@"+861"] && number.length == 14){
                            NSInteger resultCode = [self isNumberRegistered:number];
                            if (resultCode == -1){
                                [numbers addObject:number];
                            }
                        }
                    }
                    if ([numbers count] == 0){
                        return;
                    }
                    NSArray *subArray = numbers;
                    if ( [subArray count] > 100){
                        subArray = [subArray subarrayWithRange:NSMakeRange(0,100)];
                    }
                    NSInteger sleepTime = [self queryTouchpalsWithLimitSize:subArray];
                    if (sleepTime == -1)
                        return;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self notifyListeners];
                    });
                }
            });
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self generateNewTouchpalArray];
        touchpalerArray = [self generateTouchpalArray];
    });
}

+ (void)notifyListeners {
    @synchronized(self) {
        [self generateTouchpalArray];
        [self generateNewTouchpalArray];
        if (sListeners.count > 0) {
            [sListeners makeObjectsPerformSelector:@selector(onTouchpalChanges)];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[ContactModelNew getSharedContactModel]buildAZtoAllContacts];
            });
        }
    }
}


+ (void)removeListener:(id)listener {
    @synchronized(self) {
        [sListeners removeObject:listener];
    }
}

+ (NSInteger) isNumberRegistered:(NSString *)number{
    NSString *normalNumber = [PhoneNumber getCNnormalNumber:number];
    NSObject *object = [sNumberCacheDict objectForKey:normalNumber];
    if (object){
        return [(NSNumber *)object intValue];
    }else{
        return -1;
    }
}

+ (void) generateNewTouchpalArray{
    @synchronized (newTouchpalerNumberArray) {
        if ( [newTouchpalerNumberArray count] == 0 ){
            return;
        }
        NSArray *contacts = [[ContactCacheDataManager instance] getAllCacheContact];
        for (ContactCacheDataModel *model in contacts) {
            for (PhoneDataModel *phone in model.phones) {
                NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
                if ( [newTouchpalerNumberArray containsObject:number] ){
                    if ( ![newTouchpalerArray containsObject:[NSNumber numberWithInt:model.personID]]){
                        [newTouchpalerArray addObject:[NSNumber numberWithInt:model.personID]];
                        break;
                    }
                }
            }
        }
        [UserDefaultsManager setObject:newTouchpalerNumberArray forKey:NEW_TOUCHPALER_NUMBER_ARRAY];
    }
    
}

+ (NSInteger) insertNumber:(NSString *)number andIfCootekUser:(BOOL) boolValue andIfRefreshNow:(BOOL) refresh{
    NSInteger ifCootekUser = boolValue;
    if (![number hasPrefix:@"+86"]) {
        number = [PhoneNumber getCNnormalNumber:number];
    }
    NSInteger resultCode = [TouchpalNumbersDBA insertNumber:number andIfCootekUser:ifCootekUser];
    if (resultCode != 0){
        [sNumberCacheDict setObject:@(ifCootekUser) forKey:number];
        if ( ifCootekUser )
            @synchronized (newTouchpalerNumberArray) {
                
                [newTouchpalerNumberArray addObject:number];
            }
        if (refresh){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyListeners];
            });
        }
    }
    return resultCode;
}

+ (void)getTouchpaler:(NSMutableDictionary*)keyDic andKeys:(NSMutableArray*)keyArray{
    NSMutableArray *contactsIds = [touchpalerArray copy];
    NSMutableArray *newUserArray = [newTouchpalerArray copy];
    NSMutableArray *temptKeyArray = [NSMutableArray array];
    [ContactModelNew buildIndexArray:contactsIds toNewContactsContainer:keyDic andKeyContainers:temptKeyArray];
    NSInteger count = [newUserArray count];
    if ( count > 0 ){
        [keyArray addObject:@"新增好友"];
        NSMutableArray *temptArray = [[NSMutableArray alloc] init];
        [keyDic setObject:temptArray forKey:@"新增好友"];
        
        for (NSNumber *personId in newUserArray) {
            ContactCacheDataModel *item = [[ContactCacheDataManager instance] contactCacheItem:[personId integerValue]];
            if (item) {
                NSMutableArray *contactsForKey = [keyDic objectForKey:@"新增好友"];
                [contactsForKey addObject:item];
            }
        }
    }
    for (NSString *key in temptKeyArray){
        [keyArray addObject:key];
    }
}

+ (NSMutableArray *)generateTouchpalArray{
    NSMutableArray *contactsIds = [NSMutableArray array];
    NSArray *contacts = [[ContactCacheDataManager instance] getAllCacheContact];
    for (ContactCacheDataModel *model in contacts) {
        for (PhoneDataModel *phone in model.phones) {
            NSString *number = [PhoneNumber getCNnormalNumber:phone.number];
            NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:number];
            if (resultCode == 1){
                [contactsIds addObject:[NSNumber numberWithInt:model.personID]];
                break;
            }
        }
    }
    touchpalerArray = contactsIds;
    return contactsIds;
}

+ (NSInteger) getTouchpalerArrayCount{
    return [touchpalerArray count];
}

+ (NSInteger) getTouchpalerFamilyArrayCount{
    return  [UserDefaultsManager intValueForKey:ACTIVITY_FAMILY_NEWS_NUMBER defaultValue:0];
}

+ (NSInteger) getNewTouchpalerArraycount{
    return [newTouchpalerArray count];
}

+ (BOOL)ifAlertNumberShown{
    if ( [UserDefaultsManager boolValueForKey:IS_VOIP_ON] )
        if ( ![UserDefaultsManager boolValueForKey:VOIP_FIRST_VISIT_TOUCHPAL_PAGE_WITH_ALERT defaultValue:NO] )
            if ( [touchpalerArray count] >= 5)
                return NO;
    return YES;
}

+ (void)removeAllNewTouchpaler{
    [newTouchpalerArray removeAllObjects];
    @synchronized (newTouchpalerNumberArray) {
        
        [newTouchpalerNumberArray removeAllObjects];
        [UserDefaultsManager setObject:newTouchpalerNumberArray forKey:NEW_TOUCHPALER_NUMBER_ARRAY];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_ALL_VIEW_CONTROLLER object:nil];
}

+ (void)deleteFriend:(NSInteger)personId ifRefreash:(BOOL)ifRefresh{
    [newTouchpalerArray removeObject:[NSNumber numberWithInt:personId]];
    [touchpalerArray removeObject:[NSNumber numberWithInt:personId]];
    if ( ifRefresh  )
        [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
}

+ (BOOL) isRegisteredByContactCachedModel:(ContactCacheDataModel *)model {
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        return NO;
    }
    if (model == nil || model.phones == nil || model.phones.count == 0) {
        return NO;
    }
    
    BOOL registered = NO;
    for (PhoneDataModel *phone in model.phones) {
        NSString *normalizeNumber = [PhoneNumber getCNnormalNumber:phone.number];
        NSInteger resultCode = [TouchpalMembersManager isNumberRegistered:normalizeNumber];
        if (resultCode == 1){
            registered = YES;
            break;
        }
    }
    return registered;
}

+ (BOOL) isRegisteredByPersonId:(NSInteger)personId {
    ContactCacheDataModel *model = [[ContactCacheDataManager instance] contactCacheItem:personId];
    if (model == nil) {
        return NO;
    }
    return [TouchpalMembersManager isRegisteredByContactCachedModel:model];
}

@end
