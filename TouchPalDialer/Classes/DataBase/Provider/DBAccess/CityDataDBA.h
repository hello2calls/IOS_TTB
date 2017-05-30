//
//  CityDataDBA.h
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YellowCityModel.h"

@interface CityDataDBA : NSObject

+ (NSArray *)queryAllInstallCity;

+ (NSArray *)queryAllUnloadCity;

+ (NSArray *)queryAllValidateUnloadCity;

+ (YellowCityModel *)queryInstallCityById:(NSString *)cityId;

+ (YellowCityModel *)queryUnstallCityById:(NSString *)cityId;

+ (void)updateCity:(YellowCityModel *)city;

+ (void)insertCity:(YellowCityModel *)city;

+ (void)deleteInstallCityById:(NSString *)cityId;

+ (void)deleteInstallCitys:(NSArray *)citys;

@end
