//
//  InputNumberPasteUtility.h
//  TouchPalDialer
//
//  Created by Chen Lu on 2/6/13.
//
//

#import <Foundation/Foundation.h>

@interface InputNumberPasteUtility : NSObject

+ (NSString *)appendPasteboardString;
+ (NSString *)getPasteboardString;

@end
