//
//  AdShowtimeManager.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/25.
//
//

#import <notify.h>
#import "AdShowtimeManager.h"
#import "AdMessageModel.h"
#import "AdLandingPageManager.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"


@interface AdShowtimeManager () {
    int     _notifyTokenForDidChangeScreenLockStatus;
    NSDate  *_appearTime;
}
@property (nonatomic, assign) BOOL  isScreenLocked;
@property (nonatomic, assign) BOOL  registeredForDarwinNotifications;

@property (nonatomic, strong) AdMessageModel    *ad;
@property (nonatomic, assign) BOOL              isADDidAppear;
@end

@implementation AdShowtimeManager

#pragma mark LifeCycle

- (instancetype)initWithAd:(AdMessageModel *)ad
{
    self = [self init];

    if (self) {
        _ad = ad;
        _isADDidAppear = NO;
        _isScreenLocked = NO;
        _registeredForDarwinNotifications = NO;

        // add UIApplicationDelegate
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

        // add LockScreen Notification
        [self registerForLockScreenNotifications];
    }

    return self;
}

- (void)dealloc
{
    _ad = nil;
    [self unregisterLockScreenNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Public

- (void)adDidAppear
{
    if (!_ad) {
        return;
    }

    if (!_isADDidAppear) {
        _isADDidAppear = YES;
        _appearTime = [NSDate date];
    }
}

- (void)adDidDisappearWithCloseType:(ADCloseType)closeType
{
    if (!_ad) {
        return;
    }

    if (_isADDidAppear) {
        _isADDidAppear = NO;
        long long       tsin = (long long)([_appearTime timeIntervalSince1970] * 1000);
        long long       tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        NSDictionary    *param = @{kADTransformParamSid:_ad.s ? : @"",
                                   kADTransformParamType:kADTransformShowTime,
                                   kADTransformParamTsin:@(tsin),
                                   kADTransformParamTsout:@(tsout),
                                   kADTransformParamTU:_ad.tu ? : @"",
                                   kADTransformParamCloseType:@(closeType)};
        [self transformBackWithParam:param];
        _appearTime = nil;
    }

    if (!((closeType == ADCLOSE_HOME) || (closeType == ADCLOSE_LOCK))) {
        _ad = nil;
        _appearTime = nil;
        [self unregisterLockScreenNotifications];
    }
}

#pragma mark Private

- (void)transformBackWithParam:(NSDictionary *)param
{
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [FunctionUtility visitUrl:kADTransformUrl param:param];
    });
}

#pragma mark UIApplicationDelegate

- (void)applicationDidBecomeActive
{
    [self adDidAppear];
}

- (void)applicationDidEnterBackground
{
    if (!self.isScreenLocked) {
        // Screen is not lock
        [self adDidDisappearWithCloseType:ADCLOSE_HOME];
    }
}

#pragma mark LockScreen Notification

- (void)iphoneDidUnlockScreen
{
    cootek_log(@"AdShowtimeManager iphoneDidUnlockScreen");
}

- (void)iphoneDidLockScreen
{
    cootek_log(@"AdShowtimeManager iphoneDidLockScreen");
    [self adDidDisappearWithCloseType:ADCLOSE_LOCK];
}

- (void)registerForLockScreenNotifications
{
    __weak AdShowtimeManager *weakSelf = self;

    return;
}

- (void)unregisterLockScreenNotifications
{
    if (!self.registeredForDarwinNotifications) {
        return;
    }

    uint32_t result = notify_cancel(_notifyTokenForDidChangeScreenLockStatus);

    self.registeredForDarwinNotifications = !(result == NOTIFY_STATUS_OK);
}

@end
