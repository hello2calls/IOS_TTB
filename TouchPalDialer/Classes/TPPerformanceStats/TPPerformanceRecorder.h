//
//  TPPerformanceRecorder.h
//  TouchPalDialer
//
//  Created by siyi on 16/8/17.
//
//

#ifndef TPPerformanceRecorder_h
#define TPPerformanceRecorder_h

#import <Foundation/Foundation.h>



#define PERFORMANCE_ACTION_START @"start"
#define PERFORMANCE_ACTION_END @"end"

@interface TPPerformanceRecorder : NSObject

/**
 *  recording the time for a point relative to the main function starting
 *
 *  @param recordTime  absolute time in seconds
 *  @param path  usage path
 *  @param durationName  duration name as usage key
 *  @param action  PERFORMANCE_ACTION_START or PERFORMANCE_ACTION_END
 */
+ (void) recordWithTime:(double)recordTime forPath:(NSString *)path inDuration:(NSString *)durationName byAction:(NSString *)action;

/**
 *  recording the spent time in a duration
 *
 *  @param timeInterval time spent in seconds
 *  @param path         usage path
 *  @param durationName     duration name as usage key
 */
+ (void) recordWithTimeInterval:(double)timeInterval forPath:(NSString *)path inDuration:(NSString *)durationName;
@end


#endif /* TPPerformanceRecorder_h */
