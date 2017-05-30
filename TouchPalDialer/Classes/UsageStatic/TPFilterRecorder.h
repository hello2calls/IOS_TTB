//
//  TPFilterRecorder.h
//  TouchPalDialer
//
//  Created by siyi on 16/11/3.
//
//

#ifndef TPFilterRecorder_h
#define TPFilterRecorder_h

#import <Foundation/Foundation.h>
#import "UsageRecordDataKV.h"

@interface TPFilterRecorder : NSObject
+ (void) recordpath:(NSString *)path kvarray:(NSArray*)kvarray;
+ (void) recordpath:(NSString *)path kvs:(UsageRecordDataKV *)kv,... NS_REQUIRES_NIL_TERMINATION;

+ (void) sendFilterPath:(NSString *)path;
+ (void) clearFilterPath:(NSString *)path;
@end

#endif /* TPFilterRecorder_h */
