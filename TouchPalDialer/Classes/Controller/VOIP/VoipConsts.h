//
//  VoipConsts.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-12.
//
//

#import <Foundation/Foundation.h>
#define WIDTH_ADAPT TPScreenWidth()/360.0
#define HEIGHT_ADAPT TPScreenHeight()/640.0
#define EDGE_SERVER_CONFIG_URL @"http://dialer.cdn.cootekservice.com/android/default/control/udp_list.json"
//#define VOIP_CONFIG_URL @"http://voip-c2c.oss.aliyuncs.com/test/bad_voipconfig"
#define VOIP_CONFIG_URL @"http://voip-c2c.oss.aliyuncs.com/voipconfig"
#define PROXY_SERVER_CONFIG_URL @"http://cootek-dialer-download.oss.aliyuncs.com/android/default/ws2proxy/ws2_ip_table"
#define PROXY_SERVER_VERSION_URL @"http://cootek-dialer-download.oss.aliyuncs.com/android/default/ws2proxy/version"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define iOS7_0 @"7.0"