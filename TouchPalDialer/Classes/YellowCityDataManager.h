//
//  YellowCityDataManager.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YellowCityModel.h"

#define TIME_INTERVAL_FOR_CITY_UPDATE_CHECK 1*24*60*60

@interface YellowCityDataManager : NSObject

+ (void)initCallerTellSearch;

+ (NSString *)sourcePathCityData:(NSString *)relativePath;

+ (NSString *)relativePathCityData:(NSString *)cityID;

//+ (void)addSearchResouce:(YellowCityModel *)city;
//
//+ (void)delSearchResouce:(NSString *)cityId;
//
//+ (void)updateSearchResouce:(YellowCityModel *)city;
//
//+ (YellowCityModel *)queryInstallCityById:(NSString *)cityId;
//
//+ (NSArray *)queryNewsUnLoadCity:(NSArray *)installCitys
//              withUnInstallCitys:(NSArray *)loacalUnInstallCitys
//                  withServeCitys:(NSArray *)serviceCitys;
//
//+ (BOOL)isNetWorkToCheckCityData;
//
//+ (void)doCheckUpdateCityData;
//
//+ (void)onWillQueryCityData;
//
//+ (void)onDidQueryCityData:(NSNumber *)flag;
//
//+ (NSDictionary *) updateCitysAfterCompareWithNewlyQueryedCitys:(NSArray *)citys;

@end
