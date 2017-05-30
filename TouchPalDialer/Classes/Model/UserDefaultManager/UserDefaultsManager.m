//
//  UserDefaultsManager.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 12/3/12.
//
//

#import "UserDefaultsManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "NSKeyedUnarchiver+TPSafe.h"
#import "FunctionUtility.h"
#import "SeattleDefs.h"
#import "TouchPalVersionInfo.h"

static NSUserDefaults *_crucialUserDefaults = nil;
static NSMutableArray *_crucialKeys = nil;

@implementation UserDefaultsManager

+ (void) initialize {
    if ([FunctionUtility systemVersionFloat] >= 7.0) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _crucialUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:CRUCIAL_USER_DEFAULTS_NAME];
            _crucialKeys = [[NSMutableArray alloc] initWithCapacity:1];
            [UserDefaultsManager setCrucialKeys];
        });
    }
}

+ (BOOL)knownTypeObjectMathes:(id)object withDefaultValue:(id)defaultValue
{
    if(defaultValue == nil || object == nil) {
        return YES;
    } else {
        if([defaultValue isKindOfClass:[NSNumber class]]) {
            return [object isKindOfClass:[NSNumber class]];
        }
        if([defaultValue isKindOfClass:[NSDate class]]) {
            return [object isKindOfClass:[NSDate class]];
        }
        if([defaultValue isKindOfClass:[NSString class]]) {
            return [object isKindOfClass:[NSString class]];
        }
        if([defaultValue isKindOfClass:[NSArray class]]) {
            return [object isKindOfClass:[NSArray class]];
        }
        if([defaultValue isKindOfClass:[NSDictionary class]]) {
            return [object isKindOfClass:[NSDictionary class]];
        }
        if([defaultValue isKindOfClass:[NSData class]]) {
            return [object isKindOfClass:[NSData class]];
        }
        return YES;
    }
}

//For one time show up tip
+ (BOOL)isKeyFlagged:(NSString *)key{
    return [UserDefaultsManager boolValueForKey:key defaultValue:NO];
}
+ (void)setFlagKey:(NSString *)key{
    [UserDefaultsManager setBoolValue:YES forKey:key];
}

//For BOOL
+ (BOOL)boolValueForKey:(NSString *)key{
    return [UserDefaultsManager boolValueForKey:key defaultValue:NO];
}
+ (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue{
    id value = [UserDefaultsManager objectForKey:key defaultValue:[NSNumber numberWithBool:defaultValue]];
    return [value boolValue];
}
+ (void)setBoolValue:(BOOL)value forKey:(NSString *)key{
    [UserDefaultsManager setObject:[NSNumber numberWithBool:value] forKey:key];
}

//For int
+ (int)intValueForKey:(NSString *)key{
    return [UserDefaultsManager intValueForKey:key defaultValue:0];
}
+ (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue{
    id value = [UserDefaultsManager objectForKey:key defaultValue:[NSNumber numberWithInt:defaultValue]];
    return [value intValue];
}
+ (void)setIntValue:(int)value forKey:(NSString *)key{
    [UserDefaultsManager setObject:[NSNumber numberWithInt:value] forKey:key];
}

//For float
+ (float)floatValueForKey:(NSString *)key{
    return [UserDefaultsManager floatValueForKey:key defaultValue:0.0];
}
+ (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue{
    id value = [UserDefaultsManager objectForKey:key defaultValue:[NSNumber numberWithFloat:defaultValue]];
    return [value floatValue];
}
+ (void)setFloatValue:(float)value forKey:(NSString *)key{
    [UserDefaultsManager setObject:[NSNumber numberWithFloat:value] forKey:key];
}

//For double
+ (double)doubleValueForKey:(NSString *)key{
    return [UserDefaultsManager doubleValueForKey:key defaultValue:0.0];
}
+ (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue{
    id value = [UserDefaultsManager objectForKey:key defaultValue:[NSNumber numberWithDouble:defaultValue]];
    return [value doubleValue];
}
+ (void)setDoubleValue:(double)value forKey:(NSString *)key{
    [UserDefaultsManager setObject:[NSNumber numberWithDouble:value] forKey:key];
}

//For NSString
+ (NSString *)stringForKey:(NSString *)key{
    NSString *nonNilString = @"r9yfuwhio";
    NSString *string = [UserDefaultsManager stringForKey:key defaultValue:nonNilString];
    if(string == nonNilString) {
        return nil;
    } else {
        return string;
    }
}
+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue{
    if(defaultValue == nil){return [UserDefaultsManager stringForKey:key];}
    return (NSString *)[UserDefaultsManager objectForKey:key defaultValue:defaultValue];
}

//For NSDate
+ (NSDate *)dateForKey:(NSString *)key{
    NSDate *nonNilDate = [NSDate date];
    NSDate *dateBack = [UserDefaultsManager dateForKey:key defaultValue:nonNilDate];
    if(nonNilDate == dateBack) {
        return nil;
    } else {
        return dateBack;
    }
}

+ (NSDate *)dateForKey:(NSString *)key defaultValue:(NSDate *)defaultValue{
    if(defaultValue==nil){return [UserDefaultsManager dateForKey:key];}
    return (NSDate *)[UserDefaultsManager objectForKey:key defaultValue:defaultValue];
}

//For NSArray
+ (NSArray *)arrayForKey:(NSString *)key{
    NSArray *nonNilArray = [NSArray array];
    NSArray *array = [UserDefaultsManager arrayForKey:key defaultValue:nonNilArray];
    if(array == nonNilArray){
        return nil;
    }else{
        return array;
    }
}

+ (NSArray *)arrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue{
    if(defaultValue==nil){return [UserDefaultsManager arrayForKey:key];}
    return (NSArray *)[UserDefaultsManager objectForKey:key defaultValue:defaultValue];
}

//For NSDictionary
+ (NSDictionary *)dictionaryForKey:(NSString *)key{
    NSDictionary *nonNilDic = [NSDictionary dictionary];
    NSDictionary *dicBack = [UserDefaultsManager dictionaryForKey:key defaultValue:nonNilDic];
    if(nonNilDic == dicBack){
        return nil;
    } else {
        return dicBack;
    }
}
+ (NSDictionary *)dictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue{
    if(defaultValue==nil){return [UserDefaultsManager dictionaryForKey:key];}
    return (NSDictionary *)[UserDefaultsManager objectForKey:key defaultValue:defaultValue];
}

//For NSObject
+ (id<NSCoding>)objectForKey:(NSString *)key{
    return [UserDefaultsManager objectForKey:key defaultValue:nil];
}
+ (id<NSCoding>)objectForKey:(NSString *)key defaultValue:(id)defaultValue{
    NSUserDefaults *userDefaults = [UserDefaultsManager getUserDefaultsByKey:key];
    id obj = [userDefaults objectForKey:key];
    
    if(obj == nil) {
        return defaultValue;
    }
    
    if([obj isKindOfClass:[NSData class]] && ![defaultValue isKindOfClass:[NSData class]]){
        obj = [NSKeyedUnarchiver safelyUnarchiveObjectWithData:obj];
        if (obj == nil) {
#ifdef DEBUG
            NSString *message =[NSString stringWithFormat:@"unarchive对象失败,Key:%@,defaultValue:%@",key,defaultValue];
            [DefaultUIAlertViewHandler showAlertViewWithTitle:message
                                                      message:nil];
#endif
            obj = defaultValue;
        }
    }
    
    if(![UserDefaultsManager knownTypeObjectMathes:obj withDefaultValue:defaultValue]){
#ifdef DEBUG
        NSString *realtype = NSStringFromClass([obj class]);
        NSString *expectedType = NSStringFromClass([defaultValue class]);
        NSString *message = [NSString stringWithFormat:@"NSUserDefaults中的Key:%@读取类型错误：real:%@, expected:%@",
                                 key,realtype,expectedType];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message
                                                  message:nil];
#endif
        obj = defaultValue;
    }
    return obj;
}

+ (void)setObject:(id<NSCoding>)value forKey:(NSString *)key{
#ifdef DEBUG
    if ([(id)value isKindOfClass:[NSData class]]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"禁止存取NSData" message:nil];
        return;
    }
    id originalValue =[UserDefaultsManager objectForKey:key];
    if(![UserDefaultsManager knownTypeObjectMathes:value withDefaultValue:originalValue]){
        NSString *originalType = NSStringFromClass([originalValue class]);
        NSString *newType = NSStringFromClass([(id)value class]) ;
        NSString *message = [NSString stringWithFormat:@"NSUserDefaults中的Key:%@在设置时类型错误：newType:%@, originalType:%@"
                             ,key,newType,originalType];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message
                                                  message:nil];
    }
#endif
    NSUserDefaults *userDefaults = [UserDefaultsManager getUserDefaultsByKey:key];
    if (value == nil) {
        [userDefaults setObject:nil forKey:key];
        return;
    }
    if([(id)value isKindOfClass:[NSNumber class]] ||
       [(id)value isKindOfClass:[NSString class]] ||
       [(id)value isKindOfClass:[NSDate class]]){
        [userDefaults setObject:value forKey:key];
        [userDefaults synchronize];
    } else {
        [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:key];
    }
    if ( [[UIDevice currentDevice].systemVersion intValue] >= 7){
        [UserDefaultsManager setForGroupUserDefaultsWithSuiteName:@"group.com.cootek.Contacts" object:value forKey:key];
    }
}

+ (void)removeObjectForKey:(NSString *)key{
    NSUserDefaults *userDefaults = [UserDefaultsManager getUserDefaultsByKey:key];
    [userDefaults removeObjectForKey:key];
}

+ (void)synchronize{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_crucialUserDefaults synchronize];
}

+(void)setForGroupUserDefaultsWithSuiteName:(NSString *)name object:(id<NSCoding>)value forKey:(NSString *)key{
    if ([@[ANTIHARASS_IS_UPDATE_IN_WIFI,ANTIHARASS_AUTOUPDATEINWIFI_ON,ANTIHARASS_IS_ON,ANTIHARASS_REMOTE_VERSION,ANTIHARASS_VERSION] containsObject:key]) {
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:name];
         [userDefault setValue :value forKey:key];
         [userDefault synchronize];

    }
}

+ (NSUserDefaults *) getUserDefaultsByKey:(NSString *)key {
    if ([_crucialKeys containsObject:key]) {
        return _crucialUserDefaults;
    }
    return [NSUserDefaults standardUserDefaults];
}

+ (void) setCrucialKeys {
    NSDictionary *crucials = [UserDefaultsManager getCrucials];
    for(NSNumber *version in crucials.allKeys) {
        NSArray *keys = [crucials objectForKey:version];
        if (keys == nil || keys.count == 0) {
            continue;
        }
        [_crucialKeys addObjectsFromArray:[crucials objectForKey:version]];
    }// end for
    
    NSNumber *oldVersion = [_crucialUserDefaults objectForKey:KEY_CRUCIAL_VERSION];
    if (oldVersion == nil) {
        oldVersion = @(0);
    }
    int oldVersionInt = [oldVersion intValue];
    if (oldVersionInt == CRUCIAL_VERSION) {
        return;
    }
    
    BOOL isCrucialNewInstall = (oldVersionInt == 0);
    BOOL isAppInstalled = [[NSUserDefaults standardUserDefaults] stringForKey:FIRST_LAUNCH_VERSION] != nil;
    BOOL isCrucialNewAndAppInstalled = (isCrucialNewInstall && isAppInstalled);
    
    BOOL isCrucialInUpgrade = (oldVersionInt > 0) && (oldVersionInt < CRUCIAL_VERSION);
    
    if (isCrucialInUpgrade || isCrucialNewAndAppInstalled) {
        for(NSNumber *version in crucials.allKeys) {
            NSArray *keys = [crucials objectForKey:version];
            if (keys == nil || keys.count == 0) {
                continue;
            }
            if (oldVersionInt < [version intValue]) {
                [UserDefaultsManager writeCrucialKeys:keys];
            }
            
        }// end for
    }
    
    if (isCrucialInUpgrade || isCrucialNewInstall) {
        [_crucialUserDefaults setInteger:CRUCIAL_VERSION forKey:KEY_CRUCIAL_VERSION];
        [_crucialUserDefaults synchronize];
    }
}

+ (void) writeCrucialKeys:(NSArray *)keys {
    NSUserDefaults *stardardUserDefaults = [NSUserDefaults standardUserDefaults];
    for(NSString *crucialKey in keys) {
        // get value from standard user defaults
        id crucialValue = [stardardUserDefaults objectForKey:crucialKey];
        if (crucialValue != nil) {
            // write the value to the crucial user defaults
            [_crucialUserDefaults setObject:crucialValue forKey:crucialKey];
        }
    }
}

+ (NSDictionary *) getCrucials {
    NSMutableDictionary *mutableCrucials = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    // ------ version 1 -------
    NSArray *commonKeys = @[IS_VOIP_ON, VERSION_JUST_BEFORE_UPGRADE, IS_TOUCHPAL_NEWER, FIRST_LAUNCH_VERSION, ACTIVATE_IDENTIFIER, VOIP_REGISTER_ACCOUNT_NAME, VOIP_REGISTER_SECRET_CODE, SEATTLE_AUTH_LOGIN_ACCESS_TOKEN, VOIP_LAST_MOBILE_POSTKID];
    
    // 添加一般的key
    NSMutableArray *crucialKeys = [[NSMutableArray alloc] initWithArray:commonKeys];
    
    // seattle 需要用到key，在SeattleDefs.h中定义的。
    // 组成C的string数组，末尾的NULL必须有
    char *seattleKeys[] = {KEY_TP_COOKIE, KEY_VOIP_COOKIE, KEY_TELECOM_TOKEN, KEY_TELECOM_TOKEN_EXPIRE_TIME, KEY_TP_SECRET, NULL};
    char *key = NULL;
    int i = 0;
    
    // 添加seattle的key
    while((key = seattleKeys[i]) != NULL) {
        NSString *nsKey = [NSString stringWithUTF8String:key];
        NSString *seattleKey = [NSString stringWithFormat:@"%@_%@", SEATTLE_SETTING_PREFIX, nsKey];
        [crucialKeys addObject:seattleKey];
        i++;
    }
    
    [mutableCrucials setObject:[crucialKeys copy] forKey:@(1)];
    // ------ end: version 1 -------
    
    // ------ version 2 -------
    //
    
    return [mutableCrucials copy];
}

@end
