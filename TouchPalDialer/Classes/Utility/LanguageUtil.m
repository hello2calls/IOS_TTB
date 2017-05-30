//
//  LanguageUtil.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/7/1.
//
//

#import "LanguageUtil.h"

@implementation LanguageUtil

+ (NSString *)getCurrentLanguage {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    return preferredLang;
}
+ (void)setCurrentLanguage:(Language)num{

    NSString *lanStr = nil;
    switch (num) {
        case LanguageStandard:
            [self resetToSystemLanguage];
            return;
        case ChineseSimplified:
            lanStr = @"zh_CN";
            break;
        case ChineseTraditional:
            lanStr = @"zh_TW";
            break;
        case English:
            lanStr = @"en-CN";
            break;
        default:
            break;
    }
    if (lanStr && lanStr.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:lanStr,  nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)resetToSystemLanguage {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
