//
//  Header.h
//  TouchPalDialer
//
//  Created by siyi on 16/2/22.
//
//

#ifndef Header_h
#define Header_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HangupCommercialModel.h"
#import "TimerTickerManager.h"
#import "TimerTicker.h"
#import "LaunchCommercialManager.h"
#import "TPEntryViewController.h"

#define DEFAULT_FETCH_TIMEOUT_MSEC (500)
#define DEFAULT_DISPLAY_TIMEOUT_MSEC (3000)

typedef void (^LaunchADCallback)();

@interface LaunchADController : TPEntryViewController <TimerTickerDelegate, LaunchCommercialDelegate>

- (instancetype) initWithADModel:(HangupCommercialModel *) model uuid:(NSString *)uuid viewDidAppearCallback:(LaunchADCallback) callback;
- (void) finish;

+ (HangupCommercialModel *)getPlistModel;
+ (void) asyncGetLaunchADWithUuid:(NSString *)uuid preUuid:(NSString *)preUuid;
@property (nonatomic) HangupCommercialModel *adModel;
@property (nonatomic, assign) long long displayTime;
@property (nonatomic, assign) long long expireTimestamp;

@end

#endif /* Header_h */
