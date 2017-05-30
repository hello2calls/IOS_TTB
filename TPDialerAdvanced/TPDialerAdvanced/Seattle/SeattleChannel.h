//
//  SeattleChannel.h
//  TestSeattle
//
//  Created by Elfe Xu on 13-1-27.
//  Copyright (c) 2013年 Elfe. All rights reserved.
//

//#define IS_GZIP_COMPRESS  YES
#import "tp_http_data.h"
#import "Reachability.h"


class SeattleChannelManager : public IChannelManager {
public:
    SeattleChannelManager();
    virtual ~SeattleChannelManager() {
        delete httpsChannel_;
        delete httpChannel_;
    }
    
    virtual const IChannel* get_channel(ChannelType type) {
        switch (type) {
            case kHttpChannel:
                return httpChannel_;
            case kHttpsChannel:
                return httpsChannel_;
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
};

@interface HttpSender : NSObject
- (id)initWithRequest:(HttpRequest *)request response:(HttpResponse *)response useHttps:(BOOL)useHttps;
- (void)sendRequest;
@end
