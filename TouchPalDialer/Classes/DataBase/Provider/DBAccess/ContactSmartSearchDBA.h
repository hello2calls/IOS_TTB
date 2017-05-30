//
//  ContactSmartSearchDBA.h
//  TouchPalDialer
//
//  Created by hengfengtian on 15/11/24.
//
//

#import <Foundation/Foundation.h>

@interface ContactSmartSearchDBA : NSObject

+ (void)increaseContactClickedTimes: (NSString*)query personId:(NSInteger)personId hitType:(NSInteger)hitType;

+ (void)queryAndInitContactClickedTimes;

@end
