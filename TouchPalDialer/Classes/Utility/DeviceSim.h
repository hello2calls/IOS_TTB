//
//  DeviceSim.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-2-25.
//
//

#import <Foundation/Foundation.h>

@interface DeviceSim : NSObject

+ (DeviceSim *)sim;

// carrier name
- (NSString*)carrierName;
// mcc
- (NSString*)mobileCountryCode;
// mnc
- (NSString*)mobileNetworkCode;
// mccmnc
- (NSString*)mccMnc;

@end
