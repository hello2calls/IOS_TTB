//
//  YellowPageLocationManager.h
//  TouchPalDialer
//
//  Created by tanglin on 15/8/27.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YellowPageLocationManager : NSObject<CLLocationManagerDelegate>

+ (id)instance;

- (void)locate:(BOOL)needCity
checkPermission:(BOOL)permission;

- (void)addCallBackBlock:(void(^)(BOOL isLocation, CLLocationCoordinate2D location))locationBlock;

- (void)requestLocationAuth:(void(^)())block;

@end
