//
//  NSString+SqlParam.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-4-27.
//
//

#import <Foundation/Foundation.h>

@interface NSString (SqlParam)

+ (NSString *)safeSqlParam:(NSString *)str;

@end
