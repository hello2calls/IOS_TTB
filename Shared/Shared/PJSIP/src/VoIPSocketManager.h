//
//  VoIPSocketManager.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/12/22.
//
//

#import <Foundation/Foundation.h>

@interface VoIPSocketManager : NSObject

- (void)onSocketClosed:(int)fd;

- (void)onSocketCreated:(int)fd;

@end
