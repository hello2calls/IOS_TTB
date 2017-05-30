//
//  TPAdControlRequestParams.m
//  TouchPalDialer
//
//  Created by siyi on 16/6/22.
//
//

#import "TPAdControlRequestParams.h"
#import "DateTimeUtil.h"
#import "Reachability.h"
#import "FunctionUtility.h"

@implementation TPAdControlRequestParams

- (instancetype) init {
    self = [super init];
    if (self) {
        // required, automatically
        _time = (long long) ([DateTimeUtil currentTimestampInMillis] / 1000);
        _productType = PRODUCT_TYPE_DIALER;
        
        ClientNetworkType type = [Reachability network];
        _networkType = [self getNetworkTypeString:type];
        if (type > network_none) {
            _ipAddress = [FunctionUtility getIpAddress];
        } else {
            _ipAddress = @"";
        }
        //
        _feedsId = DSP_FEEDS_NULL;
        
        // optional
        _os = OS_IOS;
        _debug = NO;
    }
    return self;
}

- (NSString *) getNetworkTypeString:(ClientNetworkType)type {
    NSString *typeString = TP_DSP_NETWORK_UNKNOWN;
    switch (type) {
        case network_2g: {
            typeString = TP_DSP_NETWORK_2G;
            break;
        }
        case network_3g: {
            typeString = TP_DSP_NETWORK_3G;
            break;
        }
        case network_4g: {
            typeString = TP_DSP_NETWORK_4G;
            break;
        }
        case network_wifi: {
            typeString = TP_DSP_NETWORK_WIFI;
            break;
        }
        default: {
            typeString = TP_DSP_NETWORK_UNKNOWN;
            break;
        }
    }
    return typeString;
}

@end
