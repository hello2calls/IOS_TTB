//
//  SeattleChannel.h
//  TestSeattle
//
//  Created by Elfe Xu on 13-1-27.
//  Copyright (c) 2013年 Elfe. All rights reserved.
//

//#define IS_GZIP_COMPRESS  YES
#import "secure_http_data.h"
#import "http_data.h"
#import "Reachability.h"


class SeattleChannelManager : public IChannelManager {
public:
    SeattleChannelManager();
    virtual ~SeattleChannelManager() {
        delete httpsChannel_;
        delete httpChannel_;
        delete secureZeroChannel;
        delete secureOneChannel;
        delete secureTwoChannel;
        delete secureThreeChannel;
    }
    
    virtual const IChannel* get_channel(ChannelType type) {
        switch (type) {
            case kHttpChannel:
                return httpChannel_;
            case kHttpsChannel:
                return httpsChannel_;
            case kSecureZeroChannel:
                return secureZeroChannel;
            case kSecureOneChannel:
                return secureOneChannel;
            case kSecureTwoChannel:
                return secureTwoChannel;
            case kSecureThreeChannel:
                return secureThreeChannel;
            default:
                return nil;
        }
    }
    
    virtual void destroy_channel(ChannelType type) {
        // do nothing
    }
    
    virtual NetworkType get_network_type() {
        switch ([[Reachability shareReachability] currentReachabilityStatus]) {
            case NotReachable:
                return kNetworkNotAvailable;
            case ReachableViaWiFi:
                return kNetworkWifi;
            case ReachableViaWWAN:
                return kNetworkMobile;
        }
        
        return kNetworkUnknown;
    }
    
private:
    IChannel* httpChannel_;
    IChannel* httpsChannel_;
    IChannel* secureZeroChannel;
    IChannel* secureOneChannel;
    IChannel* secureTwoChannel;
    IChannel* secureThreeChannel;
};

@interface HttpSender : NSObject
- (id)initWithRequest:(HttpRequest *)request response:(HttpResponse *)response useHttps:(BOOL)useHttps;
- (id)initWithRequest:(SecureHttpRequest *)request response:(SecureHttpResponse *)response secureType:(int)secureType;
- (void)sendRequest;
@end
