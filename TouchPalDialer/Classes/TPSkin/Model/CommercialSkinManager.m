//
//  CommerciaSkinManager.m
//  TouchPalDialer
//
//  Created by wen on 16/9/7.
//
//

#import "CommercialSkinManager.h"
#import "TPDialerResourceManager.h"
#import "SkinDownloadManager.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"
#import "DateTimeUtil.h"
#import "Reachability.h"
#import "DialerUsageRecord.h"
#import "CootekNotifications.h"
@implementation CommercialSkinManager

+ (NSDictionary *)getDicFromCommercialSkinPlist {
    NSString *downloadedRootDir = [TPDialerResourceManager downloadSkinPath];
    NSString *commercialSkinInfoDirPlistPath = [downloadedRootDir stringByAppendingPathComponent:CommercialSkinExistPlist];
    BOOL downLoadSkinExist = [[NSFileManager defaultManager] fileExistsAtPath:commercialSkinInfoDirPlistPath];
    NSDictionary *dic = nil;
    if (downLoadSkinExist) {
        dic = [NSDictionary dictionaryWithContentsOfFile:commercialSkinInfoDirPlistPath];
    }
    if (dic==nil || dic.allKeys.count == 0) {
        dic = [NSDictionary dictionary];
    }
    return dic;
}


+ (void)asyncGetSkinInfo{
    NSString *urlString = [[SkinInfoUrlSource stringByAppendingString:[NSString stringWithFormat:@"%@&os=ios",[SeattleFeatureExecutor getToken]]]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError ==nil && data!=nil) {
            NSError *error = nil;
            NSDictionary *commercialSkin = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&error];
            if (error ==nil && commercialSkin != nil) {
                NSString *idString = commercialSkin[@"id"];
                NSString *resourceString = commercialSkin[@"resource"];
                NSString *resourceURLString = commercialSkin[@"resourceURL"];
                NSString *end_show_time = commercialSkin[@"end_show_time"];
                NSString *begin_show_time = commercialSkin[@"begin_show_time"];
                BOOL    sound = [commercialSkin[@"sound"] boolValue];
                if (idString != nil &&
                    resourceString != nil &&
                    resourceURLString != nil) {
                    NSDictionary *skinInfoDic = @{
                             @"id" : idString,
                             @"resource" :resourceString,
                            @"resourceURL":resourceURLString,
                            @"sound" :@(sound)
                            };
                    TPSkinInfo *info = [[SkinDownloadManager sharedInstrance] genereateSkinInfo:skinInfoDic];
                    
                    __block NSString* skinID = info.skinID;
                    __weak typeof(self) weakSelf = self;
                    if ([self ifDownLoadCommercialSkin:skinID andBegintime:begin_show_time andEndtime:(NSString *)end_show_time]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(self) strongSelf = weakSelf;
                        [[SkinDownloadManager sharedInstrance] startSkinDownload:info andStepBlock:^(NSInteger result){
                            [DialerUsageRecord recordpath:PATH_COMMERCIAL_SKIN kvs:Pair(DOWNLOAD_SKIN,skinID), nil];
                            [strongSelf saveCommercialSkinInfoWithSkinId:skinID andInfoDic:commercialSkin];
                        }];
                    });

                }
                
            }
     

           };
        }
    }];
}

+ (BOOL)ifDownLoadCommercialSkin:(NSString *)skinID andBegintime:(NSString *)begin_show_time andEndtime:(NSString *)end_show_time{
    BOOL ifDownLoad = [[TPDialerResourceManager sharedManager] isUsingDefaultSkin]
    && [self compareNowTimeIfBetweenBeginTime:begin_show_time andEndTime:end_show_time]==NSOrderedAscending
    && ![self checkSkinInPlistAndFileWithSkinID:skinID]
    && ![UserDefaultsManager boolValueForKey:[@"ifAutoShowSkin" stringByAppendingString:skinID] defaultValue:NO];
    if ([Reachability network] < network_wifi ) {
        return NO;
    } 
    return ifDownLoad;
}

+ (void)saveCommercialSkinInfoWithSkinId:(NSString *)skinid andInfoDic:(NSDictionary *)infoDic {
    NSMutableDictionary *CommercialSkinInfoMDic = [NSMutableDictionary dictionaryWithDictionary:[self getDicFromCommercialSkinPlist]];
    if (infoDic) {
        [CommercialSkinInfoMDic setObject:infoDic forKey:skinid];
        NSString *downloadedRootDir = [TPDialerResourceManager downloadSkinPath];
        NSString *commercialSkinInfoDirPlistPath = [downloadedRootDir stringByAppendingPathComponent:CommercialSkinExistPlist];
        [CommercialSkinInfoMDic writeToFile:commercialSkinInfoDirPlistPath atomically:YES];
    }
}

+ (void)deleteCommercialSkinInfoWithSkinId:(NSString *)skinid {
    NSMutableDictionary *CommercialSkinInfoMDic = [NSMutableDictionary dictionaryWithDictionary:[self getDicFromCommercialSkinPlist]];
    [CommercialSkinInfoMDic removeObjectForKey:skinid];
    NSString *downloadedRootDir = [TPDialerResourceManager downloadSkinPath];
    NSString *commercialSkinInfoDirPlistPath = [downloadedRootDir stringByAppendingPathComponent:CommercialSkinExistPlist];
    [CommercialSkinInfoMDic writeToFile:commercialSkinInfoDirPlistPath atomically:YES];
}
+ (BOOL)checkSkinInPlistAndFileWithSkinID:(NSString *)skinID {
    NSDictionary *allCommercialSkinDic = [NSDictionary dictionaryWithDictionary:[CommercialSkinManager getDicFromCommercialSkinPlist]];
    NSArray *downLoadSkinArray = [NSArray arrayWithArray:[TPDialerResourceManager getDownLoadSkinDirArray]];
    BOOL ifFileExit = NO;
    for (NSString *skinFileName in downLoadSkinArray) {
        if ([skinID rangeOfString:skinFileName].length > 0) {
            ifFileExit =YES;
        }
    }
    if ([allCommercialSkinDic.allKeys containsObject:skinID] && ifFileExit) {
        return YES;
    }
    return NO;
}


+ (BOOL)checkIfCommercialSkinAndFileExistWithSkinID:(NSString *)skinID {
    NSDictionary *allCommercialSkinDic = [NSDictionary dictionaryWithDictionary:[CommercialSkinManager getDicFromCommercialSkinPlist]];
    
    if ([self checkSkinInPlistAndFileWithSkinID:skinID]) {
        NSDictionary *commercialSkinDic = allCommercialSkinDic[skinID];
        NSString *begin_show_time = commercialSkinDic[@"begin_show_time"];
        NSString *end_show_time = commercialSkinDic[@"end_show_time"];
        return  ([self compareNowTimeIfBetweenBeginTime:begin_show_time andEndTime:end_show_time]==NSOrderedSame);
    }
    return NO;
}
+ (NSDictionary *)getInAppInfoFromCommercialSkinExistPlistWithSkinID:(NSString *)skinID {
    NSDictionary *allCommercialSkinDic = [NSDictionary dictionaryWithDictionary:[CommercialSkinManager getDicFromCommercialSkinPlist]];

    if ([allCommercialSkinDic.allKeys containsObject:skinID]) {
        NSDictionary *commercialSkinDic = allCommercialSkinDic[skinID];
        if ((BOOL)commercialSkinDic[@"need_show_inapp"] == YES) {
            NSDictionary *inAppInfo = [NSDictionary dictionaryWithDictionary: commercialSkinDic[@"inapp_info"]];
            NSString *begin_time = inAppInfo[@"beg_time"];
            NSString *end_time = inAppInfo[@"end_time"];
            if ([self compareNowTimeIfBetweenBeginTime:begin_time andEndTime:end_time] != NSOrderedSame) {
                return nil;
            }
            return inAppInfo;
        }
    }
    return nil;
}

+ (void)getAnySkinIDFromExtiPlistRightTimeAndUseIt {
    NSString *skinTheme = [TPDialerResourceManager sharedManager].skinTheme;
    NSDictionary *allCommercialSkinDic = [NSDictionary dictionaryWithDictionary:[CommercialSkinManager getDicFromCommercialSkinPlist]];
    if ([skinTheme isEqualToString:DEFAULT_SKIN_THEME]) {
        for (NSString *skinID in allCommercialSkinDic) {
            NSDictionary *commercialSkinDic = allCommercialSkinDic[skinID];
            NSString *begin_show_time = commercialSkinDic[@"begin_show_time"];
            NSString *end_show_time = commercialSkinDic[@"end_show_time"];
            if (([self compareNowTimeIfBetweenBeginTime:begin_show_time andEndTime:end_show_time]==NSOrderedSame)
                ) {
                [[SkinDownloadManager sharedInstrance] useSkin:skinID];
                [UserDefaultsManager setBoolValue:YES forKey:[@"ifAutoShowSkin" stringByAppendingString:skinID]];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_NOAH_LOAD_LOCAL object:nil];
                if ([skinTheme rangeOfString:@".AD."].length > 0) {
                    [DialerUsageRecord recordpath:PATH_COMMERCIAL_SKIN kvs:Pair(SHOW_SKIN,skinTheme), nil];
                }
                return;
            }
        }
    } else {
        if ([self checkSkinInPlistAndFileWithSkinID:skinTheme]) {
            NSDictionary *commercialSkinDic = allCommercialSkinDic[skinTheme];
            NSString *end_show_time = commercialSkinDic[@"end_show_time"];
            if ([self checkNowTimeIfExperidWithEndTime:end_show_time] && ![UserDefaultsManager boolValueForKey:[NSString stringWithFormat:@"selfUseSkin:%@",skinTheme]defaultValue:NO]) {
                [[SkinDownloadManager sharedInstrance] useSkin:DEFAULT_SKIN_THEME];
            } else {
               
                [DialerUsageRecord recordpath:PATH_COMMERCIAL_SKIN kvs:Pair(SHOW_SKIN,[TPDialerResourceManager sharedManager].skinTheme), nil];
                }
        }
    }
    
}

+ (NSComparisonResult )compareNowTimeIfBetweenBeginTime:(NSString *)BeginTime andEndTime:(NSString *)EndTime {
    NSDate *begin_show_date = [DateTimeUtil getDateFromCommercialSkinInTimeZoneByFormat:@"yyyy-MM-dd HH:mm:ss" fromString:BeginTime];
    NSDate *end_show_date = [DateTimeUtil getDateFromCommercialSkinInTimeZoneByFormat:@"yyyy-MM-dd HH:mm:ss" fromString:EndTime];
    if ([[NSDate date] compare:begin_show_date] < NSOrderedSame) {
        return NSOrderedAscending;
    } else if([[NSDate date] compare:end_show_date] > NSOrderedSame){
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
    return -1;
}


+ (BOOL)checkNowTimeIfExperidWithEndTime:(NSString *)EndTime {
    NSDate *end_show_date = [DateTimeUtil getDateFromCommercialSkinInTimeZoneByFormat:@"yyyy-MM-dd HH:mm:ss" fromString:EndTime];
    if ([[NSDate date] compare:end_show_date] <= NSOrderedSame) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkLocalSkinShouldShowWithSkinID:(NSString *)skinID {
    NSDictionary *allCommercialSkinDic = [NSDictionary dictionaryWithDictionary:[CommercialSkinManager getDicFromCommercialSkinPlist]];
    
    if ([self checkSkinInPlistAndFileWithSkinID:skinID]) {
        NSDictionary *commercialSkinDic = allCommercialSkinDic[skinID];
        NSString *begin_show_time = commercialSkinDic[@"begin_show_time"];
        return  [self checkNowTimeIfShowWithStartTime:begin_show_time];
    }
    return NO;
}

+ (BOOL)checkNowTimeIfShowWithStartTime:(NSString *) begin_show_time{
    NSDate *begin_show_date = [DateTimeUtil getDateFromCommercialSkinInTimeZoneByFormat:@"yyyy-MM-dd HH:mm:ss" fromString:begin_show_time];
    if ([[NSDate date] compare:begin_show_date] >= NSOrderedSame) {
        return YES;
    }
    return NO;
}



@end
