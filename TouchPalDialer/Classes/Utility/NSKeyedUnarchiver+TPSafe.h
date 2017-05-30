//
//  NSKeyedUnarchiver+TPSafe.h
//  TouchPalDialer
//
//  Created by Chen Lu on 1/14/13.
//
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (TPSafe)

+ (id)safelyUnarchiveObjectWithData:(NSData *)data;
+ (id)safelyUnarchiveObjectWithFile:(NSString *)path;

@end
