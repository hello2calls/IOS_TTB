//
//  AdvancedSyncCalllog.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-3-13.
//
//

#import <Foundation/Foundation.h>

@interface AdvancedSyncCalllog : NSObject

+ (BOOL)copySystemCalllogToTPDialer:(NSString *)filePath;
+ (BOOL)isAccessCallHistoryDB;

@end
