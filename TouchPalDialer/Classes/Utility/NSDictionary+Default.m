//
//  NSDictionary+Default.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//
#import "NSDictionary+Default.h"
#import "NSKeyedUnarchiver+TPSafe.h"

@implementation NSDictionary (Default)

- (id) objectForKey:(NSString *)key withDefaultValue: (id) defaultValue
{
    id obj = [self objectForKey:key];
    
    if(obj == nil) {
        return defaultValue;
    }
    return obj;
}

- (BOOL) objectForKey:(NSString*)key withDefaultBoolValue: (BOOL)defaultBoolValue
{
    id obj = [self objectForKey:key];
    
    if(obj == nil) {
        return defaultBoolValue;
    }
    return [(NSNumber*)obj boolValue];
}

- (NSString*) stringForKey:(NSString *)key
{
    id value = [self objectForKey:key];
    if (![value isKindOfClass:[NSString class]]) {
        value = [value stringValue];
    }
    return (NSString*)value;
}
@end
