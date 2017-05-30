//
//  VoipUtils.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/4.
//
//

#import "VoipUtils.h"
#import "FunctionUtility.h"
#import <Usage_iOS/GTMBase64.h>
#import "MagicUltis.h"
#import <AddressBook/AddressBook.h>
#import "AddressBookAccessUtility.h"
#import "TPAddressBookWrapper.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "NumberPersonMappingModel.h"
#import "SmartDailerSettingModel.h"
#import "ContactCacheDataManager.h"
#import "SyncContactInApp.h"
#import "PersonDBA.h"
#import "ContactCacheDataManager.h"
#import "SeattleFeatureExecutor.h"
#import "Reachability.h"
#import "LocalStorage.h"
#import "ScheduleInternetVisit.h"
#import <AFNetworkOperation/AFHTTPRequestOperation.h>
#import "NSString+TPHandleNil.h"
#import "DateTimeUtil.h"
#import "NSString+TPHandleNil.h"
#import "HangupCommercialManager.h"
#import "TouchPalVersionInfo.h"

@implementation VoipUtils

+ (NSDictionary *)extractCallInfo:(NSString *)sipMessage {
    NSRange range = [sipMessage rangeOfString:@"X-Time-Bonus"];
    if (range.length > 0) {
        NSString *promotion = @"";
        NSString *subMessage = [sipMessage substringFromIndex:range.location];
        NSString *type = [FunctionUtility getTagString:@"type=" inString:subMessage];
        NSString *balance = [FunctionUtility getTagString:@"balance=" inString:subMessage];
        NSString *registered = [FunctionUtility getTagString:@"registered=" inString:subMessage];
        NSString *promotionData = [FunctionUtility getTagString:@"reason=" inString:subMessage];
        NSString *isActivity = [FunctionUtility getTagString:@"activity=" inString:subMessage];
        NSString *ratio = [FunctionUtility getTagString:@"ratio=" inString:subMessage];
        NSString *isActive = [FunctionUtility getTagString:@"active=" inString:subMessage];
        if (promotionData && [isActivity isEqualToString:@"1"]) {
            if ([promotionData rangeOfString:@"-"].length > 0) {
                promotionData = [promotionData stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
            }
            if ([promotionData rangeOfString:@"."].length > 0) {
                promotionData = [promotionData stringByReplacingOccurrencesOfString:@"." withString:@"="];
            }
            if ([promotionData rangeOfString:@"_"].length > 0) {
                promotionData = [promotionData stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
            }
            NSData *decodedData = [GTMBase64 decodeString:promotionData];
            promotion = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            if ([promotion rangeOfString:@"X"].length > 0) {
                long long value = [balance longLongValue];
                promotion = [promotion stringByReplacingOccurrencesOfString:@"X" withString:[NSString stringWithFormat:@"%lld", value/60]];
            }
            
            if ([promotion rangeOfString:@"{n}"].length > 0) {
                promotion = [promotion stringByReplacingOccurrencesOfString:@"{n}" withString:@"\n"];
            }
        }
        return @{@"type":[VoipUtils dictString:type], @"balance":[VoipUtils dictString:balance], @"registered":[VoipUtils dictString:registered], @"promotion":[VoipUtils dictString:promotion], @"ratio":[VoipUtils dictString:ratio], @"isActive": [VoipUtils dictString:isActive]};
    } else {
        return nil;
    }
}

+ (NSString *)getVoipEnvironmentString:(NSString *)mode {
    NSString *model = [FunctionUtility deviceName];
    cootek_log(@"ios model: %@", model);
    NSString *networkType = [FunctionUtility networkType];
    NSMutableString *headerInfo = [NSMutableString string];
    NSString *iOS= [[UIDevice currentDevice] systemVersion];
    [headerInfo appendFormat:@"manufacturer=%@;model=%@;system=%@;network=%@;roaming=%d;intl-roaming=%d", @"apple", model, iOS,networkType, [[MagicUltis instance] getRoaming], ![FunctionUtility isInChina]];
    if ([mode length] > 0) {
        [headerInfo appendFormat:@";mode=%@",mode];
    }
#ifdef DEBUG
    [headerInfo appendFormat:@";cert=development"];
#else
    [headerInfo appendFormat:@";cert=producttion"];
#endif
    NSString *bssid = [FunctionUtility currentWifiBase];
    if (bssid.length > 0 ){
        [headerInfo appendFormat:@";bssid=%@", bssid];
    }
    NSString *simMnc = [SmartDailerSettingModel settings].simMnc;
    if (simMnc.length > 0) {
        [headerInfo appendFormat:@";simmnc=%@", simMnc];
    }
    
    NSString *tmp = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
    if (tmp.length > 0) {
        [headerInfo appendFormat:@";city=%@",[MagicUltis chineseFullPing:tmp]];
    }
    cootek_log(@"header: %@", headerInfo);
    return headerInfo;
}



+ (NSString *)dictString:(NSString *)string {
    if (string == nil) {
        return @"";
    }
    return string;
}

/**
 *  add the special contact "V 触宝免费电话" when booting
 */
+ (void)checkBackCallNumberPerson{
    if (!ENABLE_LOCAL_TOUCHPAL_V_NUMBER) {
        NSString *versionBeforeUpgrade = [UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE defaultValue:nil];
        BOOL removed = [UserDefaultsManager boolValueForKey:VOIP_BACK_CALL_NAME_REMOVED defaultValue:NO];
        if (![NSString isNilOrEmpty:versionBeforeUpgrade] && !removed) {
            [UserDefaultsManager setBoolValue:YES forKey:VOIP_BACK_CALL_NAME_REMOVED];
            // delete the "V 触宝免费电话" contact item
            [VoipUtils deleteVoipBackCallNumbers];
        }
        return;
    }
    NSInteger personId = [NumberPersonMappingModel queryContactIDByNumber:@"4001183315"];
    BOOL hasSaved = [UserDefaultsManager boolValueForKey:VOIP_BACK_CALL_NAME_SAVED];
    if (personId < 0 && !hasSaved) {
        [self addVoipBackCallNumberToAddressBookWithNumbers:nil];
    } else if (personId > 0) {
        NSString *oldName = [[ContactCacheDataManager instance] contactCacheItem:personId].displayName;
        if (![oldName isEqualToString:VOIP_CALL_NAME]) {
            ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
            ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book, personId);
            ABRecordRemoveValue(personRef, kABPersonFirstNameProperty, NULL);
            ABRecordSetValue(personRef, kABPersonFirstNameProperty, VOIP_CALL_NAME, NULL);
            ABRecordRemoveValue(personRef, kABPersonNoteProperty, NULL);
            ABRecordSetValue(personRef, kABPersonNoteProperty, @"这是触宝免费电话专线号码，请勿删除 :)", NULL);
            if (ABAddressBookSave(book, NULL)) {
                [SyncContactInApp editPerson:[PersonDBA contactCacheDataModelByRecord:personRef]];
            }
        }
        NSInteger tmpPersonId = [NumberPersonMappingModel getCachePersonIDByNumber:@"04001183315"];
        if (tmpPersonId < 0) {
            ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
            ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book, personId);
            ABMutableMultiValueRef multiPhone =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMultiValueAddValueAndLabel(multiPhone, @"4001183315", kABPersonPhoneMainLabel, NULL);
            ABRecordSetValue(personRef, kABPersonPhoneProperty, multiPhone,nil);
            if (ABAddressBookSave(book, NULL)) {
                [SyncContactInApp editPerson:[PersonDBA contactCacheDataModelByRecord:personRef]];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 *  add an array of phone numbers into the contact "V触宝免费电话" by noah pushing
 *
 *  @param numbers number array to be inserted
 */
+ (void)updateBackCallNumberPerson:(NSArray *)numbers{
    NSInteger personId = [NumberPersonMappingModel queryContactIDByNumber:@"4001183315"];
    BOOL hasSaved = [UserDefaultsManager boolValueForKey:VOIP_BACK_CALL_NAME_SAVED];
    if (personId < 0 && !hasSaved) {
        [self addVoipBackCallNumberToAddressBookWithNumbers:numbers];
    } else if (personId > 0) {
        ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book, personId);
        ABMutableMultiValueRef multiPhone =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, @"4001183315", kABPersonPhoneMainLabel, NULL);
        for (NSString *number in numbers) {
            if ([number isEqualToString:@"4001183315"]) {
                continue;
            }
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), kABOtherLabel, NULL);
        }
        ABRecordSetValue(personRef, kABPersonPhoneProperty, multiPhone,nil);
        if (ABAddressBookSave(book, NULL)) {
            [SyncContactInApp editPerson:[PersonDBA contactCacheDataModelByRecord:personRef]];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)addVoipBackCallNumberToAddressBookWithNumbers:(NSArray*)array {
    CFErrorRef error = NULL;
    NSLog(@"%@", [self description]);
    ABAddressBookRef iPhoneAddressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef newPerson = ABPersonCreate();
    
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, VOIP_CALL_NAME, &error);
    ABMutableMultiValueRef multiPhone =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiPhone, @"4001183315", kABPersonPhoneMainLabel, NULL);
    for (NSString *number in array) {
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), kABOtherLabel, NULL);
    }
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    ABRecordSetValue(newPerson, kABPersonNoteProperty, @"这是触宝免费电话专线号码，请勿删除 :)", &error);
    CFRelease(multiPhone);
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    if (error != NULL)
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);
        return NO;
    }else{
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_BACK_CALL_NAME_SAVED];
    }
    
    return YES;
}

+ (BOOL) deleteVoipBackCallNumbers {
    NSInteger personId = [NumberPersonMappingModel queryContactIDByNumber:@"4001183315"];
    if (personId > 0) {
        ABAddressBookRef book = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(book, personId);
        ContactCacheDataModel *cacheDataModel = [PersonDBA contactCacheDataModelByRecord:personRef];
        ABAddressBookRemoveRecord(book, personRef, NULL);
        ABMutableMultiValueRef multiPhone =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone, @"4001183315", kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(personRef, kABPersonPhoneProperty, multiPhone,nil);
        if (ABAddressBookSave(book, NULL)) {
            [SyncContactInApp deletePerson:cacheDataModel];
            return YES;
        }
    }
    return NO;
}

+ (BOOL)addVoipBackCallNumberToAddressBook {
    CFErrorRef error = NULL;
    NSLog(@"%@", [self description]);
    ABAddressBookRef iPhoneAddressBook = [TPAddressBookWrapper RetrieveAddressBookRefForCurrentThread];
    ABRecordRef newPerson = ABPersonCreate();
    
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, VOIP_CALL_NAME, &error);
    ABMutableMultiValueRef multiPhone =  ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiPhone, @"4001183315", kABPersonPhoneMainLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"4009602620", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"4009603650", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"4006920508", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"04001183315", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"04009602620", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"04009603650", kABOtherLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"04006920508", kABOtherLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    ABRecordSetValue(newPerson, kABPersonNoteProperty, @"这是触宝免费电话专线号码，请勿删除 :)", &error);
    CFRelease(multiPhone);
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    if (error != NULL)
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);
        return NO;
    }else{
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_BACK_CALL_NAME_SAVED];
    }

    return YES;
}

+ (NSDictionary *)translateJSONWithErrorCode:(int)errorCode
{
    NSDictionary *dic = [UserDefaultsManager dictionaryForKey:error_code_dic];
    if ([[dic allKeys] containsObject:[NSString stringWithFormat:@"%d",errorCode]]) {
        NSDictionary *dicDetail = [dic objectForKey:[NSString stringWithFormat:@"%d",errorCode]];
        return dicDetail;
    }
    else{
        return nil;
    }

}

+ (void)translateErrorCode:(int)errorCode withCallBack:(void(^)(
        NSString *errorMessage,
        NSString *extraInfo,
        NSString *remind,
        NSString *solution,
        NSString* solution_action,
        NSString *dialog_solution_action,
        NSString *dialog_solution_btn,
        NSString *dialog_solution_main                                                    ))callBack {
    NSString *errorMessage = nil;
    NSString *detail = nil;
    NSString *remind = nil;
    NSString *solution = nil;
    NSString *solution_action = nil;
    NSString *dialog_solution_action = nil;
    NSString *dialog_solution_main = nil;
    NSString *dialog_solution_btn = nil;
    NSDictionary *dic = [UserDefaultsManager dictionaryForKey:error_code_dic];
    if ([[dic allKeys] containsObject:[NSString stringWithFormat:@"%d",errorCode]]) {
        NSDictionary *dicDetail = [dic objectForKey:[NSString stringWithFormat:@"%d",errorCode]];
        errorMessage = dicDetail[@"title"];
        detail = dicDetail[@"content"];
        remind = dicDetail[@"guide"];
        solution = dicDetail[@"solution"];
        solution_action = dicDetail[@"solution_action"];
        dialog_solution_action = dicDetail[@"dialog_solution_action"];
        dialog_solution_main = dicDetail[@"dialog_solution_main"];
        dialog_solution_btn = dicDetail[@"dialog_solution_btn"];
    }
    else{
        errorMessage = @"啊呃，遇到问题了";
        detail = @"说好的服务器就在那儿\n就是找不着。";
        remind = @"专家说，重拨一下就好了";        
    }

    if (callBack) {
        callBack(errorMessage, detail, remind,solution,solution_action,dialog_solution_action,dialog_solution_btn,dialog_solution_main);
    }
}




+(void)getErrorCodeInfo{
    NSString *boundleFile = [[NSBundle mainBundle] pathForResource:@"error_code" ofType:@"json"];
    [VoipUtils updateVoipErrorCodeJsonWithPath:boundleFile withVersion:LOCAL_ERROR_CODE_VERSION];
}

+(BOOL)ifShowADWithErrorCode:(NSInteger)error_code ifOutging:(BOOL)outgoing{
    return YES;
}
+(void)updateVoipErrorCodeJsonWithPath:(NSString *)path withVersion:(NSString *)version{
     NSString *errorCodePath =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"error_code.json"];
    if (version.integerValue > [UserDefaultsManager stringForKey:voip_error_code_version defaultValue:@"0"].integerValue) {
        NSError *fileCopyError;
        if (![FileUtils fileExistAtAbsolutePath:path]) {
            return;
        }
        if ([FileUtils fileExistAtAbsolutePath:errorCodePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:errorCodePath error:nil];
        }
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:errorCodePath error:&fileCopyError];
        if (fileCopyError) {
            cootek_log(@"%@",fileCopyError);
            return;
        }
        if ([path rangeOfString:@"Documents"].length>0) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        [UserDefaultsManager setObject:version forKey:voip_error_code_version];
        
    }

    NSData *date = [NSData dataWithContentsOfFile:errorCodePath];
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:date options:(NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers) error:&error];
    if (error==nil && dic!=nil) {
        NSMutableDictionary *all_error_code_dic = [[UserDefaultsManager dictionaryForKey:error_code_dic] mutableCopy];
        if (all_error_code_dic==nil) {
            all_error_code_dic = [NSMutableDictionary dictionary];
        }
        NSArray *array = dic[@"error_code"];
        for (NSDictionary *codeDic in array) {
            NSString *codeString =[[codeDic allKeys] objectAtIndex:0];
            [all_error_code_dic  setObject:[codeDic objectForKey:codeString] forKey:codeString];
        }
        [UserDefaultsManager setObject:all_error_code_dic forKey:error_code_dic];
        
        NSDictionary *ad_strategy_dic = dic[@"ad_strategy"];
        
        
        NSMutableString *ad_incoming_string =ad_strategy_dic[@"incoming"];
        if ([ad_incoming_string rangeOfString:@"NOTIN"].length>0) {
            [UserDefaultsManager setBoolValue:NO forKey:if_ad_strategy_incoming_inarr];
        }else{
            [UserDefaultsManager setBoolValue:YES forKey:if_ad_strategy_incoming_inarr];
        }
        NSRange code_range = NSMakeRange([ad_incoming_string rangeOfString:@"["].location+1, [ad_incoming_string rangeOfString:@"]"].location- [ad_incoming_string rangeOfString:@"["].location-1);
        NSString *strincoming = [ad_incoming_string substringWithRange:code_range];
        NSArray *ad_coming_array = [strincoming componentsSeparatedByString:@","];
        [UserDefaultsManager setObject:ad_coming_array forKey:ad_strategy_incoming_arr];
        
        
        
        
        NSString *ad_outgoing_string =ad_strategy_dic[@"outgoing"];
        
        if ([ad_strategy_dic[@"outgoing"] rangeOfString:@"NOTIN"].length>0) {
            [UserDefaultsManager setBoolValue:NO forKey:if_ad_strategy_outgoing_inarr];
        }else{
            [UserDefaultsManager setBoolValue:YES forKey:if_ad_strategy_outgoing_inarr];
        }
        code_range =  NSMakeRange([ad_outgoing_string rangeOfString:@"["].location+1, [ad_outgoing_string rangeOfString:@"]"].location- [ad_outgoing_string rangeOfString:@"["].location-1);
        NSString *stroutgoing = [ad_outgoing_string substringWithRange:code_range];
        NSArray *ad_outgoing_array = [stroutgoing  componentsSeparatedByString:@","];
        [UserDefaultsManager setObject:ad_outgoing_array forKey:ad_strategy_outgoing_arr];
        
        
    }
}


+ (void)uploadCallLog:(NSString *)log{
    NSString *logCopy = [log copy];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        if ([Reachability network] < network_3g) {
            [ScheduleInternetVisit writeVoipLog:logCopy];
            return;
        }
        NSString *logBefore = [ScheduleInternetVisit getStoredVoipLog];
        if (logBefore == nil) {
            if ([UserDefaultsManager boolValueForKey:VOIP_UPLOAD_CALLLOG defaultValue:NO]
                && ![SeattleFeatureExecutor uploadVoipCallLog:logCopy]) {
                [ScheduleInternetVisit writeVoipLog:logCopy];
            } else {
                [ScheduleInternetVisit cleanVoipLog];
            }
            return;
        }
        NSString *totalLogs = [NSString stringWithFormat:@"%@\n%@", logBefore, logCopy];
        if ([UserDefaultsManager boolValueForKey:VOIP_UPLOAD_CALLLOG defaultValue:NO] &&
            ![SeattleFeatureExecutor uploadVoipCallLog:totalLogs]) {
            [ScheduleInternetVisit writeVoipLog:logCopy];
        } else {
            [ScheduleInternetVisit cleanVoipLog];
        }
    });
}

+ (void)uploadCallStat:(NSDictionary *)attr {
    cootek_log(@"uploadCallStat = %d",attr.count);
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [ScheduleInternetVisit recordVoipAttr:attr];
    });
}


+(void)checkVersionIfDownLoadSourceWithdestString:(NSString *)destString
                                        srcString:(NSString *)srcString
                                              ver:(NSString *)ver
                                               tu:(NSString *)tu {
    NSString *storeArr = ad_resource_arr;
    NSString *nowstoreArr = ad_now_resource_arr;
    NSString * destPath = [NSString stringWithFormat:@"/%@/%@/%@",Commercial,ADResource,destString];
    NSMutableArray *arr = [[UserDefaultsManager arrayForKey:storeArr] mutableCopy];
    NSMutableArray *nowarr = [[UserDefaultsManager arrayForKey:nowstoreArr] mutableCopy];
    
    if (arr==nil) {
        arr = [NSMutableArray array];
    }
    if (nowarr==nil) {
         nowarr = [NSMutableArray array];
    }
    [nowarr addObject:@{@"dest":destString,@"ver":ver,@"src":srcString}];
    [UserDefaultsManager setObject:nowarr forKey:ad_now_resource_arr];
    [UserDefaultsManager synchronize];
    
    NSInteger index = -1;
     __block NSMutableDictionary *coverDic = [NSMutableDictionary dictionary];
    
    for (NSDictionary *adInfo in arr) {
        if ([adInfo[@"dest"] isEqualToString:destString]) {
            index =[arr indexOfObject:adInfo];
            coverDic = [adInfo mutableCopy];
            break;
        }
    }
    [VoipUtils checkIfCreatAdDir];
    NSString *oldVer = coverDic[@"ver"];
    if ([FileUtils checkFileExist:destPath] && oldVer.length!=0 && oldVer.integerValue>=ver.integerValue) {
        if (index != -1) {
            [arr removeObjectAtIndex:index];
        }
        coverDic = [@{@"dest":destString,@"src":srcString,@"ver":oldVer,@"ready":@"YES"} mutableCopy];
        
        [arr addObject:coverDic];
        [UserDefaultsManager setObject:arr forKey:storeArr];
        [VoipUtils checkIfDownLoadAllResource:tu];
        [UserDefaultsManager synchronize];
        return;
    }
    if (oldVer.integerValue<ver.integerValue){
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [FileUtils removeFileInAbsolutePath:[documentDirectory stringByAppendingPathComponent:
                                             [NSString stringWithFormat:@"%@/%@/%@",Commercial,ADResource,destString]]];
    }
    if (oldVer.length==0 || oldVer.integerValue<ver.integerValue ||
        ![FileUtils checkFileExist: [NSString stringWithFormat:@"%@/%@/%@",Commercial,ADResource,destString]]){
        
        NSInteger indexArr1=-1;
        arr = [[UserDefaultsManager arrayForKey:storeArr] mutableCopy];
        if (arr==nil) {
            arr =[NSMutableArray array];
        }
        for (NSDictionary *adInfo in arr) {
            if ([adInfo[@"dest"] isEqualToString:destString]) {
                indexArr1 =[arr indexOfObject:adInfo];
                coverDic = [adInfo mutableCopy];
                break;
            }
        }
            if (indexArr1!=-1) {
                [arr removeObjectAtIndex:indexArr1];
            }
            coverDic = [@{@"dest":destString,@"src":srcString,@"ready": @"NO"} mutableCopy];
        
            [arr addObject:coverDic];
        
        
            [UserDefaultsManager setObject:arr forKey:storeArr];
            [UserDefaultsManager synchronize];
            
            NSString *downLoadPath =  [FileUtils getAbsoluteFilePath:destPath];
            [VoipUtils downloadFileFrom:srcString to:downLoadPath withSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                cootek_log(@"ADCHECK  downLoad  %@",srcString);
                    NSMutableArray *arr2 = [[UserDefaultsManager arrayForKey:storeArr] mutableCopy];
                    if (arr2==nil) {
                        arr2 =[NSMutableArray array];
                    }
                    NSInteger indexArr2 = -1;
                    for (NSDictionary  *adInfo in arr2) {
                        if ([adInfo[@"dest" ] isEqualToString:destString]) {
                            indexArr2 =[arr2 indexOfObject:adInfo];
                            break;
                        }
                    }
                    if (indexArr2!=-1) {
                        [arr2 removeObjectAtIndex:indexArr2];
                    }
                    coverDic[@"ver"] =ver;
                    coverDic[@"ready"] =@"YES";
                    [arr2 addObject:coverDic];
                    [UserDefaultsManager setObject:arr2 forKey:storeArr];
                    [UserDefaultsManager synchronize];
                    if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
                        cootek_log(@"ad_pu, resource download: %@", [srcString lastPathComponent]);
                    }
                    [VoipUtils checkIfDownLoadAllResource:tu];
            } withFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSInteger indexArr1=-1;
                for (NSDictionary *adInfo in arr) {
                    if ([adInfo[@"dest"] isEqualToString:destString]) {
                        indexArr1 =[arr indexOfObject:adInfo];
                        break;
                    }
                }
                if (indexArr1!=-1) {
                    [arr removeObjectAtIndex:indexArr1];
                }
                [UserDefaultsManager setObject:arr forKey:storeArr];
                [UserDefaultsManager synchronize];
                cootek_log(@"%@downLoadAdResourceError",[error description]);
            }];
        }
}

+(void)checkIfDownLoadAllResource:(NSString *)tu{

    NSInteger number = [UserDefaultsManager intValueForKey:@"downResourceNumber" defaultValue:0];
    number++;
    cootek_log(@"downResourceNumber%d  resourceNumber %d",[UserDefaultsManager intValueForKey:@"downResourceNumber" defaultValue:0],[UserDefaultsManager intValueForKey:@"resourceNumber" defaultValue:0]);
    [UserDefaultsManager setIntValue:number forKey:@"downResourceNumber"];
    if ([UserDefaultsManager intValueForKey:@"downResourceNumber" defaultValue:0]!=0&&[UserDefaultsManager intValueForKey:@"resourceNumber" defaultValue:0]!=0 && [UserDefaultsManager intValueForKey:@"downResourceNumber" defaultValue:0]==[UserDefaultsManager intValueForKey:@"resourceNumber" defaultValue:0]) {
        
        cootek_log(@"%@",[UserDefaultsManager arrayForKey:ad_resource_arr]);
        
        if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
            cootek_log(@"ad_pu, tu=36, resource ready");
            [UserDefaultsManager setBoolValue:YES forKey:CALL_POPUP_HTML_READY];
        }
        
        if (![UserDefaultsManager boolValueForKey:if_any_ad_resource]) {
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:N_AD_READY_FOR_SHOW object:nil userInfo:@{@"tu":tu}];
    }
}

+(void)checkIfCreatAdDir{
    NSString *commercailPath = [VoipUtils absoluteCommercialDirectoryPath:nil];
    [FileUtils createDir:commercailPath];
    NSString *ADResourcePath  =[commercailPath stringByAppendingPathComponent:ADResource];
    
    [FileUtils createDir:ADResourcePath];
    [FileUtils createDir:[NSString stringWithFormat:@"%@/js",ADResourcePath]];
    [FileUtils createDir:[NSString stringWithFormat:@"%@/img",ADResourcePath]];
    [FileUtils createDir:[NSString stringWithFormat:@"%@/css",ADResourcePath]];
}

+ (void) updateHtmlFileWithString:(NSString *)string tu:(NSString *)tu {
    [VoipUtils checkIfCreatAdDir];
    if ([NSString isNilOrEmpty:tu]) {
        return;
    }
    if ([NSString isNilOrEmpty:string]) {
        if (![tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
            [UserDefaultsManager setBoolValue:NO forKey:if_any_ad_resource];
        }
        return;
    }
    
    if (![tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
        [UserDefaultsManager setBoolValue:YES forKey:if_any_ad_resource];
    }
    
    NSString *htmlPath = nil;
    if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
        id info = [VoipUtils jsonObjectFromString:string byPattern:REG_PATTERN_COOTEK_AD];
        if (info != nil) {
            NSDictionary *ad = [VoipUtils firstADFromDict:(NSDictionary *)info byTu:tu];
            htmlPath = [VoipUtils absoluteCommercialHTMLPathForTu:tu adInfo:ad];
            cootek_log(@"ad_pu, tu=36, write html: %@", [htmlPath lastPathComponent]);
        }
        
    } else {
        htmlPath = [VoipUtils absoluteCommercialHTMLPathForTu:tu];
    }
    
    if (htmlPath == nil) {
        return;
    }
    
    NSError *error = nil;
    BOOL writeSuccess = [string writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!writeSuccess || error != nil) {
        cootek_log(@"%@",[error description]);
    }
}

+ (void)downloadFileFrom:(NSString *)urlString to:(NSString *)filePath withSuccessBlock:(void (^)(AFHTTPRequestOperation *, id))success withFailure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, responseObject);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    [operation start];
    
}


+(BOOL)stringByRegularExpressionWithstring:(NSString *)string pattern:(NSString *)pattern tu:(NSString *)tu{
    if (string ==nil) {
        return NO;
    }
    NSError *error = nil;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:&error];
    NSArray *results = [regular matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *result in results) {
        if (result.numberOfRanges >=2 && result.range.length > 0 ) {
            NSRange adRange = [result rangeAtIndex:1]; // the group[1]
            if (adRange.length == 0) {
                continue;
            }
            NSString *adInfo = [string substringWithRange:[result rangeAtIndex:1]];
            if ([NSString isNilOrEmpty:adInfo]){
                continue;
            }
            NSError *error = nil;
            NSDictionary *adDict  = [NSJSONSerialization JSONObjectWithData:[adInfo dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableLeaves) error:&error];
            if (adDict != nil
                && error == nil) {
                return [self checkifShowADIFDic:adDict tu:tu];
            } else {
                cootek_log(@"%s\n, adDict= %@\n, error= %@", __func__, adDict, error);
            }
        }
    }
    return NO;
}


+ (id) jsonObjectFromString:(NSString *)sourceString byPattern:(NSString *)pattern {
    if ([NSString isNilOrEmpty:sourceString]) {
        return nil;
    }
    NSError *error = nil;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:&error];
    NSArray *results = [regular matchesInString:sourceString options:NSMatchingReportCompletion range:NSMakeRange(0, sourceString.length)];
    if (error != nil || results == nil || results.count == 0) {
        return nil;
    }
    NSTextCheckingResult *result = results[0];
    NSString *adSource = [sourceString substringWithRange:[result rangeAtIndex:1]]; // the first group
    NSError *jsonError = nil;
    id ret = [NSJSONSerialization JSONObjectWithData:[adSource dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    if (jsonError != nil) {
        return nil;
    }
    return ret;
}

+ (NSDictionary *) firstADFromDict:(NSDictionary *)info byTu:(NSString *)tu {
    if ([NSString isNilOrEmpty:tu]
        || info == nil) {
        return nil;
    }
    
    NSArray *adPackages = [((NSDictionary *)info) objectForKey:@"ad"];
    if (adPackages == nil) {
        return nil;
    }
    
//    NSArray *adPackages = [ad objectForKey:@"ads"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tu == %@", kAD_TU_CALL_POPUP_HTML];
    NSArray *popPackages = [adPackages filteredArrayUsingPredicate:predicate];
    if (popPackages.count == 0) {
        return nil;
    }
    
    NSDictionary *adPackage = adPackages[0];
    NSArray *ads = [adPackage objectForKey:@"ads"];
    if (ads == nil || ads.count == 0) {
        return nil;
    }
    return ads[0];
}

+ (NSDictionary *) firstADFromHTMLFile:(NSString *)path byTu:(NSString *)tu {
    if ([NSString isNilOrEmpty:path]
        || [NSString isNilOrEmpty:tu]) {
        return nil;
    }
    NSError *error = nil;
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        return nil;
    }
    id info = [VoipUtils jsonObjectFromString:string byPattern:REG_PATTERN_COOTEK_AD];
    return [VoipUtils firstADFromDict:(NSDictionary *)info byTu:tu];
}

+ (NSDictionary *) firstADFromHTMLFileAtTu:(NSString *)tu {
    NSString *path = [VoipUtils absoluteCommercialHTMLPathForTu:tu];
    return [VoipUtils firstADFromHTMLFile:path byTu:tu];
}

+(NSString *)getAdnfromAdDic:(NSDictionary *)dic withTu:(NSString *)tu{
    NSArray *arr = dic[@"ad"];
    for (NSDictionary *dic in arr) {
        NSString *adTu = dic[@"tu"];
        if ([adTu isEqualToString:tu]) {
            cootek_log(@"%@",dic[@"adn"]);
            return [NSString stringWithFormat:@"%@",dic[@"adn"]];
            
        }
    }
    return nil;
}
+(BOOL)getOpenAppInfofromAdDic:(NSDictionary *)dic{
    NSArray *adArr = dic[@"ad"];
    for (NSDictionary *dicAd in adArr){
        NSArray *adsArr =dicAd [@"ads"];
        for (NSDictionary *ad in adsArr) {
            if (((NSString *)ad[@"is_deeplink"]).boolValue ==YES) {
                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ad[@"app_package"]]]){
                    return YES;
                }
                    return NO;
            }
        }
    }
    
    return YES;
}
+(BOOL)checkifShowADIFDic:(NSDictionary *)dic tu:(NSString *)tu{
    return [self getAdnfromAdDic:dic withTu:tu].integerValue>0 && [self getOpenAppInfofromAdDic:dic];
}

+ (BOOL) isCommercialCacheReadyForTu:(NSString *)tu {
    if ([NSString isNilOrEmpty:tu]) {
        return NO;
    }
    switch (tu.intValue) {
        case 36: {
            if (![UserDefaultsManager boolValueForKey:CALL_POPUP_HTML_READY defaultValue:NO]) {
                return NO;
            }
            NSString *fileName = [VoipUtils popupHTMLName];
            if (fileName == nil) {
                return NO;
            }
            NSCharacterSet *sep = [NSCharacterSet characterSetWithCharactersInString:@"_."];
            NSArray *comps = [fileName componentsSeparatedByCharactersInSet:sep];
            if (comps != nil && comps.count >= 3) {
                NSString *expireTimestamp = comps[comps.count - 2];
                BOOL valid = ([expireTimestamp longLongValue] >= [DateTimeUtil currentTimestampInMillis]);
                if (!valid) {
                    /* html file is outdated, so delete it */
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                   ^{
                                       cootek_log(@"ad_pu, outdated, delete: %@", fileName);
                                       NSString *adDir = [VoipUtils absoluteCommercialDirectoryPath:ADResource];
                                       [FileUtils removeFileInAbsolutePath:[adDir stringByAppendingPathComponent:fileName]];
                                       [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_READY];
                                   });
                }
                return valid;
            }
            break;
        }
        case 40: {
            NSString *fileName = [VoipUtils popupHTMLName];
            if (fileName == nil) {
                return NO;
            }
            NSCharacterSet *sep = [NSCharacterSet characterSetWithCharactersInString:@"_."];
            NSArray *comps = [fileName componentsSeparatedByCharactersInSet:sep];
            if (comps != nil && comps.count >= 3) {
                NSString *expireTimestamp = comps[comps.count - 2];
                BOOL valid = ([expireTimestamp longLongValue] >= [DateTimeUtil currentTimestampInMillis]);
                if (!valid) {
                    /* html file is outdated, so delete it */
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                   ^{
                                       cootek_log(@"ad_pu, outdated, delete: %@", fileName);
                                       NSString *adDir = [VoipUtils absoluteCommercialDirectoryPath:ADResource];
                                       [FileUtils removeFileInAbsolutePath:[adDir stringByAppendingPathComponent:fileName]];
                                   });
                }
                return valid;
            }
            break;
        }
        default:
            break;
    }
    return NO;
}

+ (NSString *) absoluteCommercialDirectoryPath:(NSString *)subDir {
    NSString *commercialFolder = [FileUtils getAbsoluteFilePath:Commercial];
    if (subDir != nil) {
        commercialFolder = [commercialFolder stringByAppendingPathComponent:subDir];
    }
    return commercialFolder;
}


+ (NSString *) commercialHTMLNameForTu:(NSString *)tu adInfo:(NSDictionary *)info {
    if ([NSString isNilOrEmpty:tu]) {
        return nil;
    }
    NSString *fileName = nil;
    if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML]) {
        fileName = [VoipUtils popupHTMLName];
        if (info != nil) {
            NSString *deleteFileName = fileName;
            long long etime = [[info objectForKey:@"etime"] longLongValue];
            long long expireTime = (etime + [DateTimeUtil currentTimestampInMillis]);
            fileName = [NSString stringWithFormat:@"%@_%lld.%@", NAME_AD_POPUP_CALL, expireTime, SUFFIX_HTML];
            NSString *subPath = [NSString stringWithFormat:@"%@/%@", ADResource, deleteFileName];
            if (![deleteFileName isEqualToString:fileName]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [FileUtils removeFileInAbsolutePath:[VoipUtils absoluteCommercialDirectoryPath:subPath]];
                });
            }
        }
        
    } else {
        if ([tu isEqualToString:kAD_TU_HANGUP]) {
            fileName = ADDirectCallHTML;
        }else if([tu isEqualToString:kAD_TU_NUMPAD_HTML]){
            fileName = ADNumPadHTML;
        }else if([tu isEqualToString:kAD_TU_LAUNCH]) {
            fileName = ADLaunchHTML;
        }else{
            fileName = ADBackCallHTML;
        }
    }
    return fileName;
}

+ (NSString *) absoluteCommercialHTMLPathForTu:(NSString *)tu adInfo:(NSDictionary *)info {
    if ([NSString isNilOrEmpty:tu]) {
        return nil;
    }
    NSString *fileName = [VoipUtils commercialHTMLNameForTu:tu adInfo:info];
    if (fileName == nil) {
        return nil;
    }
    NSString *subPath = [NSString stringWithFormat:@"%@/%@", ADResource, fileName];
    return [VoipUtils absoluteCommercialDirectoryPath:subPath];
}


+ (NSString *) absoluteCommercialHTMLPathForTu:(NSString *)tu {
    return [VoipUtils absoluteCommercialHTMLPathForTu:tu adInfo:nil];
}

+ (NSString *) commercialHTMLNameForTu:(NSString *)tu {
    return [VoipUtils commercialHTMLNameForTu:tu adInfo:nil];
}

+ (NSString *) numPadHTMLName {
    NSString *fileName = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@ AND SELF ENDSWITH %@", NAME_AD_POPUP_CALL, [NSString stringWithFormat:@".%@", SUFFIX_HTML]];
    NSArray *fileNames = [FileUtils fileNamesInFolder:[VoipUtils absoluteCommercialDirectoryPath:ADResource] byPredicate:predicate];
    if (fileNames.count >= 1) {
        fileName = fileNames[0];
    }
    return fileName;
}


+ (NSString *) popupHTMLName {
    NSString *fileName = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@ AND SELF ENDSWITH %@", NAME_AD_POPUP_CALL, [NSString stringWithFormat:@".%@", SUFFIX_HTML]];
    NSArray *fileNames = [FileUtils fileNamesInFolder:[VoipUtils absoluteCommercialDirectoryPath:ADResource] byPredicate:predicate];
    if (fileNames.count >= 1) {
        fileName = fileNames[0];
    }
    return fileName;
}

#pragma mark - Async get ad

+ (void) asyncGetCallPopupADWithSetting:(NSDictionary *)settings {
    if ([UserDefaultsManager boolValueForKey:CALL_POPUP_HTML_IS_QUERYING defaultValue:NO]) {
        cootek_log(@"ad_pn, async get, is quering, return");
        return;
    }
    if ([VoipUtils isCommercialCacheReadyForTu:kAD_TU_CALL_POPUP_HTML]) {
        cootek_log(@"ad_pn, async get, ready, return");
        return;
    }
    
    NSString *tu = kAD_TU_CALL_POPUP_HTML;
    NSDictionary *sizeInfo = [FunctionUtility getADViewSizeWithTu:tu];
    if (sizeInfo == nil) {
        return;
    }
    [UserDefaultsManager setBoolValue:YES forKey:CALL_POPUP_HTML_IS_QUERYING];
    [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_READY];
    [UserDefaultsManager synchronize];
  
    [UserDefaultsManager removeObjectForKey:ad_now_resource_arr];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        cootek_log(@"ad_pu, commercial NOT_ready");
        NSDictionary *settings = @{
           @"at": @"IMG",
           @"tu": tu,
           @"w": sizeInfo[@"w"],
           @"h": sizeInfo[@"h"],
           @"other_phone" : AD_DEBUG_TU_POPHTML_OTHERPHONE
        };
        [[HangupCommercialManager instance] asyncCommercialAd:tu param:settings];
    });
}
+(void)saveNoAdReasonWithKey:(NSString *)key value:(NSObject *)value{
    NSMutableDictionary *dic = [[UserDefaultsManager dictionaryForKey:HANGUP_NO_AD_REASON] mutableCopy];
    if (dic==nil) {
        dic = [NSMutableDictionary dictionary];
    }
    dic[key] = value;
    [UserDefaultsManager setObject:dic forKey:HANGUP_NO_AD_REASON];
    [UserDefaultsManager synchronize];
}

+ (NSString *) pathForResoucePlist:(NSString *)fileName {
    NSString *fullPath = [NSString stringWithFormat:@"/%@/%@/%@",
                          Commercial,ADResource, fileName];
    NSString *destPath = [FileUtils getAbsoluteFilePath:fullPath];
    return destPath;
}

+ (NSArray *) getResource:(NSString *)fileName {
    NSString *destPath = [VoipUtils pathForResoucePlist:fileName];
    NSArray *res = [[NSArray alloc] init];
    if ([FileUtils fileExistAtAbsolutePath:destPath]) {
        res = [NSArray arrayWithContentsOfFile:destPath];
    }
    return res;
}

+ (NSArray *) notFetchedFromRequestResource:(NSArray *)requestedList withReadyResources:(NSArray *)readyList {
    NSMutableArray *notFetched = [[NSMutableArray alloc] initWithArray:requestedList];
    if (readyList == nil
        || readyList.count == 0) {
        return notFetched;
    }
    
    for(NSDictionary *readyRes in readyList) {
        for (NSDictionary *requestRes in requestedList) {
            if ([requestRes[@"src"] isEqualToString:readyRes[@"src"]]
                && [requestRes[@"ver"] isEqualToNumber:readyRes[@"ver"]]) {
                [notFetched removeObject:requestRes];
            }
        }
    }
    return notFetched;
}


@end
