//
//  LanguageUtil.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/7/1.
//
//

#import <Foundation/Foundation.h>
#import "AppSettingsModel.h"
@interface LanguageUtil : NSObject

+ (NSString*) getCurrentLanguage;
+ (void)setCurrentLanguage:(Language )num;
+ (void) resetToSystemLanguage;

@end
