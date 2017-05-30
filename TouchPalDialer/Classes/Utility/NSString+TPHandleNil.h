//
//  NSString+TPHandleNil.h
//  TouchPalDialer
//
//  Created by Chen Lu on 11/24/12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (TPHandleNil)

+(NSString *) nilToEmpty:(NSString *)aString;

+(NSString *) nilToEmptyTrimmed:(NSString *)aString;

+ (BOOL) isNilOrEmpty: (NSString *) str;
@end
