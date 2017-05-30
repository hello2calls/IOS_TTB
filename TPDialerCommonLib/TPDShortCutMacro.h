//
//  TPDShortCutMacro.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/20.
//
//

#ifndef TPDShortCutMacro_h
#define TPDShortCutMacro_h

#define WEAK(object) __weak __typeof(object) weak##object = object;
#define STRONG(object) __strong __typeof(object) strong##object = object;
#define EXEC_BLOCK(block, ...) block(__VA_ARGS__);


#pragma mark - 存取userdefault
#define VALUE_IN_DEFAULT(key) \
[[NSUserDefaults standardUserDefaults] objectForKey:key]

#define SET_VALUE_IN_DEFAULT(value, key) \
[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];

#define RESET_VALUE_IN_DEFAULT(key) \
[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];\
[[NSUserDefaults standardUserDefaults] synchronize];

#define CURRENT_VERSION \
[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define CURRENT_BUILD \
[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]


#define FIRST_TIME_RUN_IN_VERSION(key, block)\
NSString* firstTimeKey = [NSString stringWithFormat:@"%@-%@", CURRENT_VERSION, key];\
NSObject* o = VALUE_IN_DEFAULT(firstTimeKey);\
if (o == nil) {\
block();\
}\
SET_VALUE_IN_DEFAULT(@"exists", firstTimeKey)\


#endif /* TPDShortCutMacro_h */
