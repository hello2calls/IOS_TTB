//
//  TimerTicker.h
//  TouchPalDialer
//
//  Created by game3108 on 14-10-31.
//
//

#import <Foundation/Foundation.h>

@protocol TimerTickerDelegate <NSObject>
-(void) onTimerStop;
-(void) onTimerTicker:(NSInteger) ticker;
@end

@interface TimerTicker : NSObject
@property(nonatomic, assign) NSInteger time_ticker;
@property(nonatomic) id<TimerTickerDelegate> delegate;
@property(nonatomic) NSString* keyValue;
@property(nonatomic, assign) BOOL upStop;
@property(nonatomic, assign) BOOL downStop;
- (dispatch_source_t)timeTickerDown;
- (dispatch_source_t)timeTickerUp;
@end
