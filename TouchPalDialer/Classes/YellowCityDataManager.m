//
//  YellowCityDataManager.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YellowCityDataManager.h"
#import "CityDataDBA.h"
#import "UserDefaultsManager.h"
#import "NetworkDataDownloader.h"
#import "Reachability.h"
#import "SeattleExecutorHelper.h"
#import "AppSettingsModel.h"
#import "OrlandoEngine.h"


#define TIME_INTERVAL  3*24*60*60
#define KEY_VERSION    @"version"

#define DEFALUT_MARKET_VERSION 1

@implementation YellowCityDataManager

+ (void)initCallerTellSearch
{
    [NSThread detachNewThreadSelector:@selector(initCallerTellSearch) toTarget:[OrlandoEngine instance] withObject:nil];
}

+ (NSString *)relativePathCityData:(NSString *)cityID
{
    return [NSString stringWithFormat:@"/cityData/%@/",cityID];
}

+ (NSString *)sourcePathCityData:(NSString *)relativePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return  [documentDirectory stringByAppendingPathComponent:relativePath];
}
//+ (YellowCityModel *)queryInstallCityById:(NSString *)cityId
//{
//    return [CityDataDBA queryInstallCityById:cityId];
//}
//+ (void)delSearchResouce:(NSString *)cityId
//{
//    [CityDataDBA deleteInstallCityById:cityId];
//    [[OrlandoEngine instance] delSearchDataByCityId:cityId];
//}
//+ (void)updateSearchResouce:(YellowCityModel *)city
//{
//    [CityDataDBA updateCity:city];
//    [[OrlandoEngine instance] delSearchDataByCityId:city.cityID];
//    [[OrlandoEngine instance] addCitySearchData:city];
//}
//
//+ (void)addSearchResouce:(YellowCityModel *)city
//{
//    [CityDataDBA insertCity:city];
//    [[OrlandoEngine instance] addCitySearchData:city];
//}
//
//+ (NSArray *)queryNewsUnLoadCity:(NSArray *)installCitys
//              withUnInstallCitys:(NSArray *)loacalUnInstallCitys
//                  withServeCitys:(NSArray *)serviceCitys
//{
//    NSMutableDictionary *citysDic = [NSMutableDictionary dictionaryWithCapacity:1];
//    
//    for (int i= 0; i<[loacalUnInstallCitys count]; i++) {
//        YellowCityModel *city = [loacalUnInstallCitys objectAtIndex:i];
//        [citysDic setObject:city forKey:city.cityID];
//    }
//    for (int i =0; i< [serviceCitys count]; i++) {
//        YellowCityModel *city = [serviceCitys objectAtIndex:i];
//        if ([citysDic objectForKey:city.cityID]) {
//            [CityDataDBA updateCity:city];
//        }
//    }
//    for (int i= 0; i<[installCitys count]; i++) {
//        YellowCityModel *city = [installCitys objectAtIndex:i];
//        [citysDic setObject:city forKey:city.cityID];
//    }
//    NSMutableArray *tmpCitys = [NSMutableArray arrayWithCapacity:1];
//    for (int i =0; i< [serviceCitys count]; i++) {
//        YellowCityModel *city = [serviceCitys objectAtIndex:i];
//        if (![citysDic objectForKey:city.cityID] && ![city.cityID isEqualToString:KEY_NATIONAL_ID]) {
//            [tmpCitys addObject:city];
//            [CityDataDBA insertCity:city];
//        }
//    }
//    return tmpCitys;
//}
//
//+ (BOOL)isNetWorkToCheckCityData
//{
//    NetworkStatus status = [[Reachability shareReachability] currentReachabilityStatus];
//    if (status != NotReachable){
//        if (![CityDownloaderAutoUpdateUtil isExtisBackGroundUpdateTask]) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//+ (void)doCheckUpdateCityData
//{
//    if ([YellowCityDataManager isNetWorkToCheckCityData]) {
//        NSDate *lastCheckDate = [UserDefaultsManager dateForKey:DATE_CITY_LAST_CHECK_UPDATE_AUTO];
//        if(lastCheckDate == nil || [[NSDate date] timeIntervalSinceDate:lastCheckDate] >= TIME_INTERVAL_FOR_CITY_UPDATE_CHECK){
//            [NSThread detachNewThreadSelector:@selector(onWillQueryCityData) toTarget:self withObject:nil];
//            [UserDefaultsManager setObject:[NSDate date] forKey:DATE_CITY_LAST_CHECK_UPDATE_AUTO];
//        }
//    }
//}
//
//+ (void)onWillQueryCityData
//{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    NSArray *citys = [SeattleExecutorHelper queryPackageList];
//    if ([citys count] > 0) {
//        NSDictionary *updateCitys = [self updateCitysAfterCompareWithNewlyQueryedCitys:citys];
//        [self performSelectorOnMainThread:@selector(onDidQueryCityData:)
//                               withObject:[updateCitys allValues] waitUntilDone:NO];
//    }
//    [pool release];
//}
//
//+ (void)onDidQueryCityData:(NSArray *)updateCitys
//{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    if ([updateCitys count] > 0) {
//        [UserDefaultsManager setObject:@YES forKey:KEY_IS_YELLOW_CITY_NEEDS_UPDATE];
//        //[CityDownloaderAutoUpdateUtil startAutoUpdateCityTask:updateCitys];
//    }else{
//        [UserDefaultsManager setObject:@NO forKey:KEY_IS_YELLOW_CITY_NEEDS_UPDATE];
//    }
//    [pool release];
//}
//
//+ (NSDictionary *) updateCitysAfterCompareWithNewlyQueryedCitys:(NSArray *)citys
//{
//    NSMutableDictionary *updateCitys = [NSMutableDictionary dictionaryWithCapacity:1];
//    NSMutableDictionary *cityDic = [NSMutableDictionary dictionaryWithCapacity:[citys count]];
//    for (YellowCityModel *city in citys) {
//        [cityDic setObject:city forKey:city.cityID];
//    }
//    NSArray *installCitys = [CityDataDBA queryAllInstallCity];
//    for(YellowCityModel* oldCity in installCitys) {
//        YellowCityModel *updateCity = [cityDic objectForKey:oldCity.cityID];
//        if(updateCity) {
//            NSInteger oldMainValue = [oldCity.mainVersion integerValue];
//            NSInteger newMainValue = [updateCity.mainVersion integerValue];
//            NSInteger oldUpdateValue = [oldCity.updateVersion integerValue];
//            NSInteger newUpdateValue = [updateCity.updateVersion integerValue];
//            if(newMainValue > oldMainValue || newUpdateValue > oldUpdateValue) {
//                [updateCitys setObject:updateCity forKey:updateCity.cityID];
//            }
//            if ([updateCity.cityID isEqualToString:KEY_NATIONAL_ID]) {
//                if(newMainValue > oldMainValue ) {
//                    updateCity.updatePath = @"";
//                }else if (newUpdateValue > oldUpdateValue){
//                    updateCity.mainPath = @"";
//                }
//            }
//        }
//    }
//    return updateCitys;
//}
@end
