//
//  PredefCountriesUtil.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-3-10.
//
//

#import "PredefCountriesUtil.h"

static NSDictionary * __strong sharedDictionary_;

@implementation PredefCountriesUtil

+ (void)initialize
{
    NSString *countryPath = [self countriesFilePath];
    NSDictionary *countryDict = [NSMutableDictionary dictionaryWithContentsOfFile:countryPath];
    sharedDictionary_ = countryDict;
}

+ (NSDictionary *)sharedDictionary
{
    return sharedDictionary_;
}

// private
+ (NSString *)countriesFilePath
{
	NSString *fileName = NSLocalizedString(@"countries_english.plist", @"国家列表文件");
	return  [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
}

+ (NSDictionary *)allCountryDict
{
    return [sharedDictionary_ objectForKey:@"all"];
}

+ (NSArray *)top10CountryArray
{
    return [sharedDictionary_ objectForKey:@"top10"];
}

+ (NSDictionary *)partialCountryDict
{
    return [sharedDictionary_ objectForKey:@"part"];
}

@end
