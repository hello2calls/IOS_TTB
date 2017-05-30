//
//  AdStatManager.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/18.
//
//

#import <Foundation/Foundation.h>

@interface AdStatManager : NSObject

+ (AdStatManager *)instance;

- (void)sendUrl:(NSString *)url;

- (void)commitCommericalStat:(NSString *)tu pst:(NSString *)uuid st:(NSString *)uuid;

- (NSString *)genenrateUUID;

- (void)checkIfshouldSendExistParamInList;
@end
