//
//  LaunchCommercialManager.h
//  TouchPalDialer
//
//  Created by siyi on 16/2/22.
//
//

#ifndef LaunchCommercialManager_h
#define LaunchCommercialManager_h

#import <Foundation/Foundation.h>
#import "HangupCommercialModel.h"

#define DIR_ADS @"ads"
#define FILE_LAUNCH_AD @"launch-ad.plist"
#define FILE_LAUNCH_IMG @"launch-ad-img.png"

@protocol LaunchCommercialDelegate <NSObject>

- (void) didFetchAD:(HangupCommercialModel *) lastModel isFresh:(BOOL)isFresh;

@end

@interface LaunchCommercialManager : NSObject
+ (instancetype) instance;
- (void) clearLastModel;
- (void) asyncFetchAD;
- (void) registerDelegate: (id <LaunchCommercialDelegate>) delegate;
- (void) removeDelegate: (id <LaunchCommercialDelegate>) delegate;
- (HangupCommercialModel *) getCachedModel;
- (void) deleteCacheFromDisk;

@property (nonatomic) HangupCommercialModel *lastModel;
@property (nonatomic, readonly) HangupCommercialModel *cachedModel;

@end

#endif /* LaunchCommercialManager_h */
