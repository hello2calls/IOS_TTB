//
//  TimerTicker.m
//  TouchPalDialer
//
//  Created by game3108 on 14-10-31.
//
//

#import "TimerTicker.h"
#import "TimerTickerManager.h"

@implementation TimerTicker

- (dispatch_source_t)timeTickerDown
{
    _downStop = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, _time_ticker);
    dispatch_source_set_event_handler(timer, ^{
        if(_time_ticker <= 0 || _downStop ) {
            dispatch_source_cancel(timer);
            [self removeSelfFromTimerTickerManager];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_delegate){
                    [_delegate onTimerStop];
                }
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_delegate){
                    [_delegate onTimerTicker:_time_ticker];
                }
            });
            _time_ticker--;
            //cootek_log(@"!!!!!!!!!%d",_time_ticker);
        }
    });
    dispatch_resume(timer);
    return timer;
}

- (dispatch_source_t)timeTickerUp {
    _upStop = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.1*NSEC_PER_SEC, _time_ticker);
    dispatch_source_set_event_handler(timer, ^{
        if (_upStop){
            [self removeSelfFromTimerTickerManager];
            dispatch_source_cancel(timer);
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_delegate){
                    [_delegate onTimerStop];
                }
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_delegate){
                    [_delegate onTimerTicker:_time_ticker];
                }
            });
            _time_ticker++;
        }
    });
    dispatch_resume(timer);
    return timer;
}

- (void) removeSelfFromTimerTickerManager{
    [TimerTickerManager removeTimerTickerByKey:_keyValue];
}

@end
