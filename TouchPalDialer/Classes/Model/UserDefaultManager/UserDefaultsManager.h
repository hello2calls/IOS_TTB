//
//  UserDefaultsManager.h
//  TouchPalDialer
//
//  Created by 亮秀 李 on 12/3/12.
//
//

#import <Foundation/Foundation.h>
#import "UserDefaultKeys.h"

#define CRUCIAL_USER_DEFAULTS_NAME      @"crucial.com.cootek.Contacts"
#define WELCOME_ASSISTANT_BUTTON_STATUS @"welcome_assistant_button_status"

#define CRUCIAL_VERSION (1)
#define KEY_CRUCIAL_VERSION @"crucial_version"

@interface UserDefaultsManager :NSObject

//for one time shown tip
+ (BOOL)isKeyFlagged:(NSString *)key;
+ (void)setFlagKey:(NSString *)key;

//for boolValue
+ (BOOL)boolValueForKey:(NSString *)key;
+ (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
+ (void)setBoolValue:(BOOL)value forKey:(NSString *)key;

//for intValue
+ (int)intValueForKey:(NSString *)key;
+ (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue;
+ (void)setIntValue:(int)value forKey:(NSString *)key;

//for floatValue
+ (float)floatValueForKey:(NSString *)key;
+ (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue;
+ (void)setFloatValue:(float)value forKey:(NSString *)key;

//for double
+ (double)doubleValueForKey:(NSString *)key;
+ (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;
+ (void)setDoubleValue:(double)value forKey:(NSString *)key;

//for string
+ (NSString *)stringForKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

//for date
+ (NSDate *)dateForKey:(NSString *)key;
+ (NSDate *)dateForKey:(NSString *)key defaultValue:(NSDate *)defaultValue;

//for array
+ (NSArray *)arrayForKey:(NSString *)key;
+ (NSArray *)arrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;

//for dictionary
+ (NSDictionary *)dictionaryForKey:(NSString *)key;
+ (NSDictionary *)dictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;

//for id<NSCoding>
+ (id<NSCoding>)objectForKey:(NSString *)key;
+ (id<NSCoding>)objectForKey:(NSString *)key defaultValue:(id<NSCoding>)defaultValue;
+ (void)setObject:(id<NSCoding>)value forKey:(NSString *)key;

//synchronize
+ (void)synchronize;

//removeKey
+ (void)removeObjectForKey:(NSString *)key;
@end
