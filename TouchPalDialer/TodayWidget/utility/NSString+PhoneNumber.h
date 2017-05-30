//
//  NSString+FormatPhoneNumber.h
//  TouchPalDialer
//
//  Created by lingmei xie on 12-10-31.
//
//

#import <Foundation/Foundation.h>

@interface NSString (FormatPhoneNumber)
-(NSString *)formatPhoneNumber;
-(NSString *)formatPhoneNumberByDigitNumber:(NSString *)digitNumber;
-(NSString *)digitNumber;
@end

@interface NSString (SearchPhoneNumber)
-(NSRange)rangeOfStringInNumbers:(NSString *)aString digitNumber:(NSString *)digitNumber;
@end