//
//  PhoneConvertUtil.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import <Foundation/Foundation.h>

@interface PhoneConvertUtil : NSObject

+ (NSString*) LongToNSString :(long long) phoneLong;
+ (long long) NSStringToLong:(NSString*) phone;

+ (NSString*) LongToNSStringIOS10Anti :(long long) phoneLong;
@end
