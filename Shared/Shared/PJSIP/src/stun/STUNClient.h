//
//  STUNClient.h
//  STUN
//
//  Created by Igor Khomenko on 9/19/12.
//  Copyright (c) 2012 Quickblox. All rights reserved. Check our BAAS quickblox.com
//
//
// This a simple and ad-hoc STUN client (UDP), partially compliant with RFC5389
// it gets the public(reflective) IP and Port of a UDP socket
//
// Documentation http://tools.ietf.org/html/rfc5389#page-10
// Russian tutorial http://svitter.ru/?p=442
//
// From quickblox.com team with love!
//


#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "log.h"


// STUN default port
//#define STUNPort 3478

// The following is a list of some public/free stun servers
// some of them send the trasport address as both MAPPED-ADDRESS and XOR-MAPPED-ADDRESS -
// and others send only MAPPED-ADDRESS
// All list - http://www.tek-tips.com/faqs.cfm?fid=7542
//#define STUNServer @"stunserver.org"

#define publicIPKey @"publicIPKey"
#define publicPortKey @"publicPortKey"
#define publicSocketHostKey @"publicSocketHostKey"
#define publicSocketPortKey @"publicSocketPortKey" // 3478
#define publicHostPortKey @"publicHostPortKey" // 8090
#define isPortRandomization @"isPortRandomization"
#define publicActionKey @"publicActionKey"

#ifdef TEST
#define stun_log 1
#define STUNLog(...) if (stun_log) NSLog(__VA_ARGS__)
#else
#define STUNLog(...)
#endif

typedef NS_ENUM(NSUInteger, StunChangeAction) {
    STUN_CHANGE_ACTION_INIT = 0,
    STUN_CHANGE_ACTION_WIFI_CHANGE = 1,
    STUN_CHANGE_ACTION_CALL = 2,
    STUN_CHANGE_ACTION_NETWORK_CHANGE = 3,
};

@protocol STUNClientDelegate;
@interface STUNClient : NSObject <GCDAsyncUdpSocketDelegate>{
    GCDAsyncUdpSocket *udpSocket;
    id<STUNClientDelegate>delegate;
    
    // binding request
    __strong NSData *msgTypeBindingRequest;
    __strong NSData *bodyLength;
    __strong NSData *magicCookie;
    __strong NSData *transactionIdBindingRequest;
    
    // indication message
    __strong NSData *msgTypeIndicationMessage;
    __strong NSData *transactionIdIndicationMessage;
    
    __strong NSTimer *retentionTimer;
}

@property(nonatomic, retain) NSString *stunServer;
@property(nonatomic, assign) int stunPort;
@property(nonatomic, assign) int hostPort;
@property(nonatomic, assign) int action;
@property(nonatomic, retain) NSDictionary *bundle;

- (id)initWithHost:(NSString *)host port:(int)port hostPort:(int)hostPort bundle:(NSDictionary*)dict action:(StunChangeAction)action;
- (void)requestPublicIPandPortWithUDPSocket:(GCDAsyncUdpSocket *)socket delegate:(id<STUNClientDelegate>)delegate;
- (void)startSendIndicationMessage;
- (void)stopSendIndicationMessage;

@end

@protocol STUNClientDelegate <NSObject>
-(void)didReceivePublicIPandPort:(NSDictionary *) data;
@end
