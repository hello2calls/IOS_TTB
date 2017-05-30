//
//  DeviceSim.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-2-25.
//
//

#import "DeviceSim.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface DeviceSim () {
    CTTelephonyNetworkInfo *networkInfo_;
	CTCarrier *carrier_;
}
@end

@implementation DeviceSim

+ (DeviceSim *)sim
{
    return [[DeviceSim alloc] init];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		networkInfo_ = [[CTTelephonyNetworkInfo alloc] init];
		carrier_ = networkInfo_.subscriberCellularProvider;
	}
	return self;
}

- (NSString *)mobileCountryCode
{
    if (carrier_ == nil) {
        return @"";
    }
    
    NSString *mcc = carrier_.mobileCountryCode;
    return mcc == nil ? @"" : mcc;
}

- (NSString *)mobileNetworkCode
{
    if (carrier_ == nil) {
        return @"";
    }
    
    NSString *mnc = carrier_.mobileNetworkCode;
    return mnc == nil ? @"" : mnc;
}

- (NSString *)mccMnc
{
    NSString *mcc = [self mobileCountryCode];
    NSString *mnc = [self mobileNetworkCode];
    if ([mcc isEqualToString:@""] || [mnc isEqualToString:@""]) {
        return @"";
    } else {
        return [mcc stringByAppendingString:mnc];
    }
}

- (NSString *)carrierName
{
    return carrier_ == nil ? @"" : carrier_.carrierName;
}

@end
