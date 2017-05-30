//
//  TimerTickerManager.m
//  TouchPalDialer
//
//  Created by game3108 on 14-10-31.
//
//

#import "TimerTickerManager.h"
#import "TimerTicker.h"

@implementation TimerTickerManager

static NSMutableDictionary __strong *_timerTickerDic = nil;

+ (void) initialize {
    _timerTickerDic = [NSMutableDictionary dictionaryWithCapacity:3];
}

+ (void) startTimerTickerDown:(id<TimerTickerDelegate>) identifier withTotalTicker:(NSInteger) ticker{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    if ([TimerTickerManager inDictionary:identifier]){
        TimerTicker *object_ticker = [_timerTickerDic objectForKey: class_name];
        object_ticker.delegate = identifier;
    }else{
        TimerTicker *timerTicker = [[TimerTicker alloc] init];
        timerTicker.time_ticker = ticker;
        timerTicker.delegate = identifier;
        timerTicker.keyValue = class_name;
        [timerTicker timeTickerDown];
        [_timerTickerDic setObject:timerTicker forKey:class_name];
    }
}

+ (void) startTimerTickerUp:(id<TimerTickerDelegate>) identifier withTicker:(NSInteger) ticker{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    TimerTicker *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker){
        object_ticker.delegate = identifier;
        object_ticker.upStop = NO;
        object_ticker.time_ticker = ticker;
        cootek_log(@"timeticker reuse ticker");
    } else {
        TimerTicker *timerTicker = [[TimerTicker alloc] init];
        timerTicker.time_ticker = ticker;
        timerTicker.delegate = identifier;
        timerTicker.keyValue = class_name;
        [timerTicker timeTickerUp];
        [_timerTickerDic setObject:timerTicker forKey:class_name];
        cootek_log(@"timeticker new ticker");
    }
}

+ (BOOL) inDictionary:(id<TimerTickerDelegate>) identifier{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        return YES;
    }else{
        return NO;
    }
}

+ (NSInteger) getTimerTicker:(id<TimerTickerDelegate>) identifier{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        return ((TimerTicker *) object_ticker).time_ticker;
    }else{
        return -1;
    }
}

+ (void) setDelegate:(id<TimerTickerDelegate>) identifier{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        ((TimerTicker *) object_ticker).delegate = identifier;
    }
}

+ (void) removeDelegate:(id<TimerTickerDelegate>) identifier{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        ((TimerTicker *) object_ticker).delegate = nil;
        cootek_log(@"timeticker set delegate nil");
    }
}

+ (void) removeDelegateAndTimer:(id<TimerTickerDelegate>) identifier {
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        ((TimerTicker *) object_ticker).delegate = nil;
        [_timerTickerDic removeObjectForKey:class_name];
        cootek_log(@"timeticker set delegate nil");
    }
}

+ (void) removeTimerTickerByKey:(NSString *) keyValue{
    [_timerTickerDic removeObjectForKey:keyValue];
}

+ (void) setTimerTickerUpStop:(id<TimerTickerDelegate>) identifier{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        ((TimerTicker *) object_ticker).upStop = YES;
        cootek_log(@"timeticker set stop yes");
    }
}

+ (void) setTimerTickerDownStop:(id<TimerTickerDelegate>) identifier{
    NSString *class_name = [NSString stringWithUTF8String:object_getClassName(identifier)];
    NSObject *object_ticker = [_timerTickerDic objectForKey: class_name];
    if (object_ticker != nil) {
        ((TimerTicker *) object_ticker).downStop = YES;
    }
}

@end