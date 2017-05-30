//
//  TimeTrickerManager.h
//  TouchPalDialer
//
//  Created by game3108 on 14-10-31.
//
//

#import <Foundation/Foundation.h>
#import "TimerTicker.h"

@interface TimerTickerManager : NSObject
+ (void) startTimerTickerDown:(id<TimerTickerDelegate>) identifier withTotalTicker:(NSInteger) ticker;
+ (void) startTimerTickerUp:(id<TimerTickerDelegate>) identifier withTicker:(NSInteger) ticker;
+ (NSInteger) getTimerTicker:(id<TimerTickerDelegate>) identifier;
+ (void) setDelegate:(id<TimerTickerDelegate>) identifier;
+ (void) removeDelegate:(id<TimerTickerDelegate>) identifier;
+ (void) removeTimerTickerByKey:(NSString *) keyValue;
+ (void) removeDelegateAndTimer:(id<TimerTickerDelegate>) identifier;
+ (void) setTimerTickerUpStop:(id<TimerTickerDelegate>) identifier;
+ (void) setTimerTickerDownStop:(id<TimerTickerDelegate>) identifier;

@end
