//
//  PJEventSource.h
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/12.
//
//

#import <Foundation/Foundation.h>
#import "PJThread.h"

@interface PJEventSource : NSObject

- (void)addEventSourceToRunloop;

- (void) removeEventRunRoop;

- (id)initEventSource:(PJThread *)thread;

@end
