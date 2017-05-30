//
//  IndexFilter.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-22.
//
//

#import <Foundation/Foundation.h>
#import "IndexFilter.h"
#import "IndexConstant.h"
#import "NSDictionary+Default.h"
#import "LocalStorage.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"

@implementation IndexFilter

- (id) initWithJson:(NSDictionary*) json
{
    self = [super init];
    
    self.os = [json objectForKey:@"os"];
    self.start = [json objectForKey:@"start"];
    self.duration = [json objectForKey:@"duration"];
    self.openCities = [json objectForKey:@"openCities"];
    self.closeCities = [json objectForKey:@"closeCities"];
    self.minApiLevel = [json objectForKey:@"minApiLevelIOS"];
    self.maxApiLevel = [json objectForKey:@"maxApiLevelIOS"];
    self.minVersion = [json objectForKey:@"minVersionIOS"];
    self.maxVersion = [json objectForKey:@"maxVersionIOS"];
    self.minOSVersion = [json objectForKey:@"minSysVersionIOS"];
    self.maxOSVersion = [json objectForKey:@"maxSysVersionIOS"];
    self.minZip = [json objectForKey:@"minZip"];
    self.maxZip = [json objectForKey:@"maxZip"];
    
    return self;
}

- (BOOL) isValid
{
    if (self.os != nil && ![self.os isEqualToString:OS_NAME]) {
        return NO;
    }

    long long now = [[NSDate date] timeIntervalSince1970];
    if (self.start != nil) {
        if (self.start.longLongValue > now) {
            return NO;
        }
        
        if (self.duration != nil && self.start.longLongValue + self.duration.longLongValue <= now) {
            return NO;
        }
    }
    
    NSString* city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY];
    if (self.openCities != nil && city != nil && ![self.openCities containsObject:city]) {
        return NO;
    }
    
    if (self.closeCities != nil && city != nil && [self.closeCities containsObject:city]) {
        return NO;
    }

    if (self.minApiLevel != nil && [WEBVIEW_JAVASCRIPT_API_LEVEL intValue] < self.minApiLevel.intValue) {
        return NO;
    }
    
    if (self.maxApiLevel != nil && [WEBVIEW_JAVASCRIPT_API_LEVEL intValue] > self.maxApiLevel.intValue) {
        return NO;
    }

    int version = [CURRENT_TOUCHPAL_VERSION intValue];
    if (self.minVersion != nil && version < self.minVersion.intValue) {
        return NO;
    }
    
    if (self.maxVersion != nil && version > self.maxVersion.intValue) {
        return NO;
    }

    int zipVersion = [[UserDefaultsManager stringForKey:ZIP_CURRENT_VERSION] intValue];
    if (self.minZip != nil && zipVersion < self.minZip.intValue) {
        return NO;
    }
    
    if (self.maxZip != nil && zipVersion > self.maxZip.intValue) {
        return NO;
    }
    
    if (self.minOSVersion != nil && [[UIDevice currentDevice]systemVersion].floatValue < self.minOSVersion.floatValue) {
        return NO;
    }
    
    if (self.maxOSVersion != nil && [[UIDevice currentDevice]systemVersion].floatValue > self.maxOSVersion.floatValue) {
        return NO;
    }
    
    return YES;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    IndexFilter* ret = [[[self class] alloc] init];
    ret.os = [self.os copyWithZone:zone];
    ret.start = [self.start copyWithZone:zone];
    ret.duration = [self.duration copyWithZone:zone];
    ret.openCities = [self.openCities copyWithZone:zone];
    ret.closeCities = [self.closeCities copyWithZone:zone];
    ret.minApiLevel = [self.minApiLevel copyWithZone:zone];
    ret.maxApiLevel = [self.maxApiLevel copyWithZone:zone];
    ret.minVersion = [self.minVersion copyWithZone:zone];
    ret.maxVersion = [self.maxVersion copyWithZone:zone];
    ret.minOSVersion = [self.minOSVersion copyWithZone:zone];
    ret.maxOSVersion = [self.maxOSVersion copyWithZone:zone];
    ret.minZip = [self.minZip copyWithZone:zone];
    ret.maxZip = [self.maxZip copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    IndexFilter* ret = [[[self class] alloc] init];
    ret.os = [self.os mutableCopyWithZone:zone];
    ret.start = [self.start copyWithZone:zone];
    ret.duration = [self.duration copyWithZone:zone];
    ret.openCities = [self.openCities mutableCopyWithZone:zone];
    ret.closeCities = [self.closeCities mutableCopyWithZone:zone];
    ret.minApiLevel = [self.minApiLevel copyWithZone:zone];
    ret.maxApiLevel = [self.maxApiLevel copyWithZone:zone];
    ret.minVersion = [self.minVersion copyWithZone:zone];
    ret.maxVersion = [self.maxVersion copyWithZone:zone];
    ret.minOSVersion = [self.minOSVersion copyWithZone:zone];
    ret.maxOSVersion = [self.maxOSVersion copyWithZone:zone];
    ret.minZip = [self.minZip copyWithZone:zone];
    ret.maxZip = [self.maxZip copyWithZone:zone];
    
    return ret;
}


#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.os = [aDecoder decodeObjectForKey:@"os"];
        self.start = [aDecoder decodeObjectForKey:@"start"];
        self.duration = [aDecoder decodeObjectForKey:@"duration"];
        self.openCities = [aDecoder decodeObjectForKey:@"openCities"];
        self.closeCities = [aDecoder decodeObjectForKey:@"closeCities"];
        self.minApiLevel = [aDecoder decodeObjectForKey:@"minApiLevel"];
        self.maxApiLevel = [aDecoder decodeObjectForKey:@"maxApiLevel"];
        self.minVersion = [aDecoder decodeObjectForKey:@"minVersion"];
        self.maxVersion = [aDecoder decodeObjectForKey:@"maxVersion"];
        self.minOSVersion = [aDecoder decodeObjectForKey:@"minOSVersion"];
        self.maxOSVersion = [aDecoder decodeObjectForKey:@"maxOSVersion"];
        self.minZip = [aDecoder decodeObjectForKey:@"minZip"];
        self.maxZip = [aDecoder decodeObjectForKey:@"maxZip"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.os forKey:@"os"];
    [aCoder encodeObject:self.start forKey:@"start"];
    [aCoder encodeObject:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.openCities forKey:@"openCities"];
    [aCoder encodeObject:self.closeCities forKey:@"closeCities"];
    [aCoder encodeObject:self.minApiLevel forKey:@"minApiLevel"];
    [aCoder encodeObject:self.maxApiLevel forKey:@"maxApiLevel"];
    [aCoder encodeObject:self.minVersion forKey:@"minVersion"];
    [aCoder encodeObject:self.maxVersion forKey:@"maxVersion"];
    [aCoder encodeObject:self.minOSVersion forKey:@"minOSVersion"];
    [aCoder encodeObject:self.maxOSVersion forKey:@"maxOSVersion"];
    [aCoder encodeObject:self.minZip forKey:@"minZip"];
    [aCoder encodeObject:self.maxZip forKey:@"maxZip"];
}
@end
