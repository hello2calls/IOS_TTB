//
//  TodayWidgetUtil.h
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TodayWidgetUtil : NSObject
+(NSString *)getAttr:(NSString *)phone;
+(NSString *)getNumberFromPasteboard:(NSString*) string;
+(NSString *)getNormalizedNumber:(NSString *)number;
+(NSString *)digitNumber:(NSString *)number;
+(NSString *)requestNumberInfo:(NSString *)number andToken:(NSString *)token;
+(NSString *)readDataFromNSUserDefaults:(NSString *)key;
+ (void)writeDefaultKeyToDefaults:(id)object andKey:(NSString *)key;
+(NSDictionary *)getDictionaryFromJsonString:(NSString *)string;
+(NSString *)getClassfyType:(NSString *)type;
+(NSString *)getNormalizePhoneNumber:(NSString *)inputStr;
+(UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)rect;
+(UIColor *)getColor:(NSString *)colorString;
+(void)callNumber:(NSString *)number;
+(BOOL) getIfFreeCall:(NSString *)number;
@end
