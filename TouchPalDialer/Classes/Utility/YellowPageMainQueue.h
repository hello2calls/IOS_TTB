//
//  YellowPageMainQueue.h
//  TouchPalDialer
//
//  Created by tanglin on 15/9/2.
//
//

#import <Foundation/Foundation.h>
#import "YPNavigationTask.h"

@interface YellowPageMainQueue : NSObject

+ (id)instance;
- (void) addTask:(YPNavigationTask* )task;
- (void) removeFirstTask;
@end
