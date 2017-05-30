//
//  PredefCountriesUtil.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-3-10.
//
//

#import <Foundation/Foundation.h>

@interface PredefCountriesUtil : NSObject

+ (NSDictionary *)sharedDictionary;

+ (NSDictionary *)allCountryDict;

+ (NSArray *)top10CountryArray;

+ (NSDictionary *)partialCountryDict;

@end
