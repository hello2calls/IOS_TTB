//
//  CallCommercialManager.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/12.
//
//

#import <Foundation/Foundation.h>
#import "CallCommercialModel.h"
#import "Ad.pb.h"
#import "AdShowtimeManager.h"


@interface CallCommercialManager : NSObject

+ (CallCommercialManager *)instance;

- (void)prepareCommercialFor:(NSString *)number withBlock:(void(^)(void))doneBlock;

- (udp_response_tData *)getCommercialModel;

- (void)onShow;

- (void)onClick;

- (void)preCallADDisappearWithCloseType:(ADCloseType)closeTyep;

- (void) prepareCommercialForTu:(NSString *)tu;
- (id) getCommercialForTu:(NSString *)tu;
- (void) removeCommercialForTu:(NSString *)tu shouldDeleteFile:(BOOL)shouldDelete;

@end
