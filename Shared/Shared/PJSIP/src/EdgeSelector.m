//
//  EdgeSelector.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-3.
//
//

#import "EdgeSelector.h"
#import "UserDefaultsManager.h"
#import "Reachability.h"
#import "STUNClient.h"
#import "PJSIPManager.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"
#import "Reachability.h"
#import "SIPConst.h"
#import "PJCore.h"
#include <pjsua-lib/pjsua.h>
#import <arpa/inet.h>

#define SOCKET_READ_TIME_OUT 2.0
#define MAX_LATENCY 0.8
#define MAX_LENTENCY_2G 5.0
#define SOCKET_READ_TIME_OUT_2G 5.0
#define EXPECTED_RESULT 3
#define UDP_SEND_COUNT_2G 3
#define UDP_SEND_COUNT 5
#define EXPECTED_RESULT_2G 1
#define TEST_INTERVAL_2G 1.5
#define TEST_INTERVAL 0.1
#define TEST_EDGE_TIME_OUT_2G 3.5
#define TEST_EDGE_TIME_OUT 2

#define STUN_HEADER_LENGTH 20
#define MAPPED_ADDRESS_LENGTH 8
#define TLV_LENGTH 4



@interface EdgeSelectPara ()

@property (nonatomic, readonly) int backCount;
@property (nonatomic, readonly) int averLatency;
@property (nonatomic, readonly) int variance;

+ (id)edgeSelectPara:(IPAddress *)edge;

- (void)onReceiveWithSendingDate:(NSDate *)date;

@end

@implementation IPAddress

+ (IPAddress *)edgeDataWith:(NSString *)host port:(int)port {
    IPAddress *data = [[IPAddress alloc] init];
    data.host = host;
    data.port = port;
    return data;
}

- (id)copy {
    IPAddress *data = [[IPAddress alloc] init];
    data.host = self.host;
    data.port = self.port;
    return data;
}

@end

@implementation EdgeSelectPara {
    NSTimeInterval _startTime;
    int _sumLatency;
    int _averLatency;
    NSMutableArray *_durations;
}

+ (id)edgeSelectPara:(IPAddress *)edge {
    
    EdgeSelectPara *para = [[EdgeSelectPara alloc] init];
    para.postBoys = edge;
    return para;
}

- (id)init {
    self = [super init];
    if (self) {
        _startTime = [[NSDate date] timeIntervalSince1970];
        _sumLatency = 0;
        _backCount = 0;
        _averLatency = 0;
        _durations = [NSMutableArray array];
    }
    return self;
}

- (id)copy {
    EdgeSelectPara *data = [[EdgeSelectPara alloc] init];
    data.edge = [_edge copy];
    data.postBoys = [_postBoys copy];
    data.source = [_source copy];
    data.postKids = [_postKids copy];
    return data;
}

- (void)onReceiveWithSendingDate:(NSDate *)date {
    _backCount ++;
    int latency = 1000*([[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970]);
    _sumLatency += latency;
    [_durations addObject:@(latency)];
}

- (int)variance {
    int sum = 0;
    for (NSNumber *number in _durations) {
        int duration = [number integerValue];
        sum += (duration - _averLatency) * (duration - _averLatency);
    }
    return sum/_backCount;
}

- (void)setSourceMap:(IPAddress *)map {
    if (map == nil || [map.host isEqualToString:@"0.0.0.0"])  {
        return;
    }
    _source = map;
}

- (void)setEdge:(IPAddress *)edge {
    if (edge == nil || [edge.host isEqualToString:@"0.0.0.0"]) {
        _edge = _postBoys;
        _edge.port = DEFAULT_SIP_PORT;
    } else {
        _edge = edge;
    }
}

- (void)setPostKids:(IPAddress *)postKids{
    if (postKids == nil || [postKids.host isEqualToString:@"0.0.0.0"])  {
        return;
    }
    _postKids = postKids;
}

- (int)averLatency {
    if (_backCount == 0) {
        return 9999;
    }
    if (_averLatency > 0) {
        return _averLatency;
    }
    _averLatency = (_sumLatency/_backCount);
    return _averLatency;
}

@end

@interface EdgeSelector() {
    NSArray<IPAddress *> *hostUrlArray;
    int _failedSendCount;
    int _totalSendCount;
    int _successSendCount;
    int _oneEdgeSendCount;
    BOOL _is2GNetwork;
    dispatch_queue_t _queue;
    NSThread *_thread;
    BOOL _isInit;
    pj_timer_entry _entry;
}

@property (nonatomic, strong)GCDAsyncUdpSocket *socket;
@property (nonatomic, strong)NSMutableDictionary *currentEdges;
@property (nonatomic, strong)NSMutableDictionary *sendDates;
@property (nonatomic, strong)NSArray<IPAddress *>* testEdge;
@property (nonatomic, copy)void(^block)(EdgeSelectPara *);
@property (nonatomic,assign) BOOL failedNeedChooseEdge;

@end

@implementation EdgeSelector

static NSArray *sRankResults = nil;

+ (NSString *)postKidsRank:(NSString *)address {
    if (sRankResults == nil) {
        return nil;
    }
    NSMutableString *poskids = [NSMutableString string];
    for (EdgeSelectPara *para in sRankResults) {
        if (para.postKids != nil) {
            NSString *str = [NSString stringWithFormat:@"%@:%d;",para.postKids.host,para.postKids.port];
            if ([para.postKids.host isEqualToString:address]) {
                [poskids insertString:str atIndex:0];
            } else if([poskids rangeOfString:para.postKids.host].length != para.postKids.host.length){
                [poskids appendFormat:str];
            }
        }
    }
    cootek_log(@"postKidsRank = %@",poskids);
    return poskids;
}

+ (void)setRandResult:(NSArray *)resuts {
    if ([resuts count] == 0) {
        return;
    }
    if (sRankResults) {
        sRankResults = nil;
    }
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[resuts count]];
    for (EdgeSelectPara *para in resuts) {
        [tmp addObject:[para copy]];
    }
    sRankResults = [NSArray arrayWithArray:tmp];

}

-(id)initWithEdge:(NSArray<IPAddress *> *)edges initPJ:(BOOL)status{
    self = [super init];
    if (self != nil) {
        self.testEdge = edges;
        _isInit = status;
        _thread = [NSThread currentThread];
        
        if (edges != nil) {
            hostUrlArray = [NSArray arrayWithArray:edges];
        } else {
            hostUrlArray = [self edgeList];
        }
        [self startSocket];
    }
    return self;
}

- (NSArray *)edgeList {
    if (USE_DEBUG_SERVER) {
        return [NSArray arrayWithObject:[IPAddress edgeDataWith:DEBUG_POSTBOY_IP
                                                           port:DEBUG_EDGE_TURN_PORT]];
    } else if(ENABLE_EDGE_TEST){
        return [NSArray arrayWithObject:[IPAddress edgeDataWith:TEST_EDGE_IP
                                                           port:TEST_TURN_PORT]];
    } else {
        NSArray *list = (NSArray *)[UserDefaultsManager objectForKey:VOIP_POSTBOY_SERVERS];
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[list count]];
        for (NSDictionary *dic in list) {
            [tmp addObject: [IPAddress edgeDataWith:[dic objectForKey:@"address"]
                                              port:[[dic objectForKey:@"port"] integerValue]]];
        }
        return tmp;
    }
}

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block
    enableSchedule:(BOOL)enable
{
    [self selectEdge:block
           needRetry:NO
      enableSchedule:enable
      enable2GSelect:NO];
}

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block
    enable2GSelect:(BOOL)enable
{
    [self selectEdge:block
           needRetry:NO
      enableSchedule:YES
      enable2GSelect:enable];
}

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block
         needRetry:(BOOL)retry
{
    [self selectEdge:block
           needRetry:retry
      enableSchedule:YES
      enable2GSelect:NO];
}

- (void)selectEdge:(void(^)(EdgeSelectPara *edge))block
         needRetry:(BOOL)retry
    enableSchedule:(BOOL)enable
    enable2GSelect:(BOOL)is2G
{
    self.failedNeedChooseEdge = retry;
    self.block = block;
    self.currentEdges = [NSMutableDictionary dictionary];
    _failedSendCount = 0;
    _is2GNetwork = [[Reachability shareReachability] networkStatus] < network_3g ;
    cootek_log(@"begin sending udp packets with network 2G network? %d", _is2GNetwork);
    _oneEdgeSendCount = (_is2GNetwork || is2G) ? UDP_SEND_COUNT_2G : UDP_SEND_COUNT;
    _totalSendCount = _oneEdgeSendCount * [hostUrlArray count];
    cootek_log(@"send total=%d,one=%d",_totalSendCount,_oneEdgeSendCount);
    double delay = _is2GNetwork ? TEST_INTERVAL_2G : TEST_INTERVAL;
    self.sendDates = [NSMutableDictionary dictionaryWithCapacity:_totalSendCount];
    
    for (int i = 0; i < _oneEdgeSendCount; i ++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * i * NSEC_PER_SEC)),_queue, ^{
            [self sendUdpSocketToServersForIndex:i andHosts:hostUrlArray];
        });
    }
    [self onScheduleTimout:_is2GNetwork ? TEST_EDGE_TIME_OUT_2G : TEST_EDGE_TIME_OUT
            enableSchedule:enable];
}


- (void)onScheduleTimout:(double)delay enableSchedule:(BOOL)enable {
    cootek_log(@"EdgeSelector onScheduleTimout =%f",delay);
    if (_isInit && enable) {
        SEL methord = @selector(parseBestEdgeCheck);
        NSMethodSignature * sig  = [[self class] instanceMethodSignatureForSelector:methord];
        NSInvocation * invocatin = [NSInvocation invocationWithMethodSignature:sig];
        [invocatin setTarget:self];
        [invocatin setSelector:methord];
        [invocatin retainArguments];
        [self schedulePJTimer:delay * 1000 invocation:invocatin];
    } else {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),_queue, ^{
            cootek_log(@"EdgeSelector onScheduleTimout not in PJCore");
            [self parseBestEdgeCheck];
        });
    }
}

- (void)startSocket {
    cootek_log(@"startSocket = %@,size=%d", _thread.name,hostUrlArray.count);
    _queue = dispatch_queue_create("com.cootek.smartdialer.select.edge",NULL);
    if (self.socket == nil) {
        self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                    delegateQueue:_queue];
        NSError *error = nil;
        [_socket bindToPort:1033 error:&error];
        [_socket beginReceiving:&error];
    }
}

- (void)sendUdpSocketToServersForIndex:(int)i andHosts:(NSArray *)hosts {
    cootek_log(@"sending data to edge for the round: %d", i);
    for (IPAddress *host in hosts) {
        if (i == 0) {
            [_currentEdges setObject:[EdgeSelectPara edgeSelectPara:host]
                              forKey:host.host];
        }
        NSData *stunData = [self constructData];
        NSData *transctionId = [stunData subdataWithRange:NSMakeRange(4, 16)];
        [self.sendDates setObject:[NSDate date] forKey:transctionId];
        [_socket sendData:stunData toHost:host.host port:host.port withTimeout:2 tag:i];
    }
}

- (void)parseBestEdgeCheck {
    
    if (self.sendDates == nil) {
        return;
    }
    cootek_log(@"parseBestEdgeCheck handler pak count= %d",_successSendCount+_failedSendCount);
    if (_thread != [NSThread currentThread]) {
        [self performSelector:@selector(parseBestEdgeCheck)
                     onThread:_thread
                   withObject:nil
                waitUntilDone:NO];
        if (_isInit) {
            pjsua_wakeup();
        }
        return;
    }
    self.sendDates = nil;
    int min_fialcount = 1000;
    NSDictionary *resultEdgs = [NSDictionary dictionaryWithDictionary:_currentEdges];
    cootek_log(@"edge select test result:");
    for (EdgeSelectPara *para in [resultEdgs allValues]) {
        cootek_log(@"(address=%@,map=%@,edge=%@,kids=%@)\n",
                   para.postBoys.host,para.source.host,para.edge.host,para.postKids.host);
        if ((_oneEdgeSendCount - para.backCount) < min_fialcount) {
            min_fialcount = (_oneEdgeSendCount - para.backCount);
        }
    }
    cootek_log(@"edge select min fialed count = %d",min_fialcount);
    NSMutableArray *paraArray = [NSMutableArray array];
    for (EdgeSelectPara *para in [resultEdgs allValues]) {
        if ((_oneEdgeSendCount - para.backCount) == min_fialcount) {
            [paraArray addObject:para];
        }
    }
    NSArray *results = [paraArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EdgeSelectPara *para1 = (EdgeSelectPara *)obj1;
        EdgeSelectPara *para2 = (EdgeSelectPara *)obj2;
        if (para1.averLatency < para2.averLatency) {
            return NSOrderedAscending;
        } else if (para1.averLatency == para2.averLatency) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    if (self.testEdge == nil) {
        [EdgeSelector setRandResult:results];
    }
    EdgeSelectPara *best = nil;
    if ([results count] > 0 && min_fialcount < _oneEdgeSendCount) {
        double min_latency = ((EdgeSelectPara *)[paraArray objectAtIndex:0]).averLatency;
        double min_variance = 10000000;
        for(int i=0; i<[results count]; i++) {
            EdgeSelectPara *para = [results objectAtIndex:i];
            cootek_log(@"edge kids result(edge=%@:%d,kids=%@:%d)\n",
                       para.edge.host,para.edge.port,para.postKids.host,para.postKids.port);
            if ((para.averLatency - min_latency) < 20 && para.variance < min_variance) {
                min_variance = para.variance;
                best = para;
            }
        }
    }

   if (best != nil) {
        cootek_log(@"edge select best edge:%@:%d,source=%@ kids=%@\n",
                   best.edge.host,best.edge.port,best.source.host,best.postKids.host);
        [self notifyEdgeSuccess:best];
   } else if(self.failedNeedChooseEdge) {
       cootek_log(@"edge select failed all...,then retry all");
       void(^tmp)(EdgeSelectPara *) = [self.block copy];
       [self clear];
       hostUrlArray = [self edgeList];
       [self startSocket];
       [self selectEdge:tmp needRetry:NO];
   } else {
        cootek_log(@"edge select failed all...");
        [self notifyEdgeFailTotally];
    }
    
}

- (void)notifyEdgeSuccess:(EdgeSelectPara *)edge {
    if (self.block) {
        self.block(edge);
    }
    [self clear];
}

- (void)clear {
    self.testEdge = nil;
    self.block = nil;
    self.currentEdges = nil;
    [self.socket close];
    self.socket = nil;
    
    if (_entry.id == PJ_TRUE) {
        cootek_log(@"cancel timer ......");
        pjsua_cancel_timer(&_entry);
        _entry.id = PJ_FALSE;
    }
    if (_queue != NULL) {
        _queue = NULL;
    }
}

- (void)notifyEdgeFailTotally {
    if (self.block) {
        self.block(nil);
    }
    [self clear];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    _failedSendCount ++;
    if (_failedSendCount + _successSendCount == _totalSendCount) {
        cootek_log(@"all send have receive,parse best");
        [self parseBestEdgeCheck];
    }
}

/**
 * Called when the socket has received the requested datagram.
 **/


- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    
    _successSendCount ++;
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    if([data length] >= 20 && [self.sendDates count] > 0){
        NSData *transctionId = [data subdataWithRange:NSMakeRange(4, 16)];
        if ([transctionId length] > 0) {
            NSDate *date = [self.sendDates objectForKey:transctionId];
            if (date != nil) {
                [((EdgeSelectPara *)[_currentEdges objectForKey:host]) onReceiveWithSendingDate:date];
            }
        }
        if ([data length] >=28) {
            Byte *tmp = (Byte *)[data bytes];
            IPAddress *map = [self getAddress:tmp desired:0x0001 offsetBtye:0];
            IPAddress *edge = [self getAddress:tmp desired:0x0002 offsetBtye:12];
            IPAddress *kids = [self getAddress:tmp desired:0x0003 offsetBtye:24];
            
            [((EdgeSelectPara *)[_currentEdges objectForKey:host]) setSourceMap:map];
            [((EdgeSelectPara *)[_currentEdges objectForKey:host]) setEdge:edge];
            [((EdgeSelectPara *)[_currentEdges objectForKey:host]) setPostKids:kids];
        }
    }
    if (_failedSendCount + _successSendCount == (_totalSendCount * 4/5)) {
        cootek_log(@"all send have receive,parse best");
        [self parseBestEdgeCheck];
    }
}

- (NSData *)constructData {
    NSData *msgTypeBindingRequest = [NSData dataWithBytes:"\x00\x0e" length:2]; // STUN binding request. A Binding request has class=0b00 (request) and
    // method=0b000000000001 (Binding)
    NSData *bodyLength = [NSData dataWithBytes:"\x00\x00" length:2]; // we have/need no attributes, so message body length is zero
    NSData *transactionIdBindingRequest = [self createNRundomBytes:16]; //  The transaction ID used to uniquely identify STUN transactions.
    NSData *postkindVers = [NSData dataWithBytes:"\x10\x00" length:2];
    // create final request
    
    NSMutableData *stunRequest = [NSMutableData data];
    [stunRequest appendData:msgTypeBindingRequest];
    [stunRequest appendData:bodyLength];
    [stunRequest appendData:transactionIdBindingRequest];
    [stunRequest appendData:postkindVers];
    return stunRequest;
}

- (NSData *)createNRundomBytes:(int)n {
    NSMutableData* theData = [NSMutableData dataWithCapacity:n];
    for( unsigned int i = 0 ; i < n ; ++i ){
        u_int32_t randomBits = arc4random();
        [theData appendBytes:(void*)&randomBits length:1];
    }
    return theData;
}

/*
 * Get the response address attribute if present.
 */
- (IPAddress *)getAddress:(Byte[] )request desired:(int) desiredType offsetBtye:(int)countByte
{
    int length = (int) (((request[2] << 8) & 0xff00) | (request[3] & 0xff));
    int offset = STUN_HEADER_LENGTH + countByte;
    while (length > 0) {
        int type = (int) (((request[offset ] << 8) & 0xff00) | (request[offset + 1] & 0xff));
        int attributeLength = (int) (((request[offset + 2] << 8) & 0xff00) | (request[offset + 3] & 0xff));
        
        if (type != desiredType) {
            
            offset += (TLV_LENGTH + attributeLength);
            length -= (TLV_LENGTH + attributeLength);
            continue;
        }
        
        if (attributeLength != MAPPED_ADDRESS_LENGTH) {
            return nil;
        }
        int port = (int) (((request[offset + 6] << 8) & 0xff00) | (request[offset + 7] & 0xff));
        Byte address[4];
        address[0] = request[offset + 8];
        address[1] = request[offset + 9];
        address[2] = request[offset + 10];
        address[3] = request[offset + 11];
        NSString *ip = [NSString stringWithFormat:@"%u.%u.%u.%u",address[0],address[1],address[2],address[3]];
        return [IPAddress edgeDataWith:ip port:port];
    }
    return nil;
}

void onPJTimer(pj_timer_heap_t *timer_heap, pj_timer_entry *entry){
    cootek_log(@"Edge onPJTimer reponse ......");
    if (entry->user_data != NULL) {
        NSInvocation *object = (NSInvocation *)CFBridgingRelease(entry->user_data);
        [object invoke];
    }
    entry->id = PJ_FALSE;
}

- (void)schedulePJTimer:(int)delay invocation:(NSInvocation *)invocation {
    pj_status_t status;
    pj_time_val time;
    
    pj_timer_entry_init(&_entry,1,(void *)CFBridgingRetain(invocation),&onPJTimer);
    
    time.sec = 0;
    time.msec = delay;
    pj_time_val_normalize(&time);
    status = pjsua_schedule_timer(&_entry, &time);
    if (status == PJ_SUCCESS) {
        _entry.id = PJ_TRUE;
        cootek_log(@"Edge schedulePJTimer success ......");
    }
}
@end
