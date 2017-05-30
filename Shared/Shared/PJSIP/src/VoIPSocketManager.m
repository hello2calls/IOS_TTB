//
//  VoIPSocketManager.m
//  BiBi
//
//  Created by lugan on 3/9/16.
//  Copyright © 2016 cootek. All rights reserved.
//

#import "VoIPSocketManager.h"


@interface SocketInfo : NSObject {
    
}


@property (nonatomic) CFSocketNativeHandle fd;
@property (nonatomic) CFReadStreamRef      readStream;
@property (nonatomic) CFWriteStreamRef     writeStream;
@property (nonatomic) NSInputStream       *inputStream;
@property (nonatomic) NSOutputStream      *outputStream;

@end

@implementation SocketInfo

@end

@interface VoIPSocketManager() {
    NSMutableDictionary *_socketInfoDic;
}

@end


@implementation VoIPSocketManager


- (instancetype)init{
    if (self = [super init]) {
        _socketInfoDic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)isEnableSystem {
   return ([[[UIDevice currentDevice] systemVersion] floatValue] < 10 &&
           [[[UIDevice currentDevice] systemVersion] floatValue] >=7);
}

- (void)onSocketCreated:(int)fd{
    cootek_log(@"VoIPSocketManager onSocketCreated fd=[%d]", fd);
    if (fd < 0) {
        return;
    }
    if (![self isEnableSystem]) {
        return;
    }
    NSNumber* numFd = [NSNumber numberWithInt:fd];
    if ([_socketInfoDic objectForKey:numFd] != nil) {
        return;
    }
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocket(NULL, fd, &readStream, &writeStream);
    bool readProp = CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
    bool writeProp = CFWriteStreamSetProperty(writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP);
    cootek_log(@"onSocketCreated: readProp = [%d], writeProp = [%d]", readProp, writeProp);
    
    NSInputStream *inputStream = (__bridge NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge NSOutputStream *)writeStream;
//    [inputStream setDelegate:self];
    BOOL inputProp = [inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
//    [outputStream setDelegate:self];
    BOOL outputProp = [outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
    cootek_log(@"onSocketCreated: inputProp = [%d], outputProp = [%d]", inputProp, outputProp);
    
    SocketInfo* info = [[SocketInfo alloc] init];
    info.fd = fd;
    info.inputStream = inputStream;
    info.outputStream = outputStream;
    info.readStream = readStream;
    info.writeStream = writeStream;
    
    [_socketInfoDic setObject:info forKey:numFd];
    
}

- (void)onSocketClosed:(int)fd{
    cootek_log(@"VoIPSocketManager onSocketClosed fd=[%d]", fd);
    
    if (fd < 0) {
        return;
    }
    if (![self isEnableSystem]) {
        return;
    }
    
    NSNumber* numFd = [NSNumber numberWithInt:fd];
    SocketInfo* info = [_socketInfoDic objectForKey:numFd];
    if (info == nil) {
        return;
    }
    
    CFWriteStreamClose(info.writeStream);
    CFReadStreamClose(info.readStream);
    CFRelease(info.writeStream);
    CFRelease(info.readStream);
    
    [info.outputStream close];
    [info.inputStream close];
    
    [_socketInfoDic removeObjectForKey:numFd];
}
/*
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    cootek_log(@"VoIPSocketManager NSStreamDelegate in Thread %@  eventCode=[%d]", [NSThread currentThread], (int)eventCode);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
            
        case NSStreamEventHasBytesAvailable: {
            uint8_t buf[1500] = {0};
            int numBytesRead = (int)[(NSInputStream *)stream read:buf maxLength:1500];
            cootek_log(@"VoIPSocketManager notify=[%@] recv=[%s] numBytesRead=[%d]", stream, buf, numBytesRead);
            break;
        }
            
        case NSStreamEventErrorOccurred: {
            break;
        }
            
        case NSStreamEventEndEncountered: {
            break;
        }
            
        default:
            break;
    }
}*/

@end
