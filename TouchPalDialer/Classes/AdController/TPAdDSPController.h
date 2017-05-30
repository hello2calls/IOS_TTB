//
//  TPAdDSPController.h
//  TouchPalDialer
//
//  Created by siyi on 16/6/22.
//
//

#ifndef TPAdDSPController_h
#define TPAdDSPController_h


#define AD_CONTROLLER_STRATEGY_FILE @"ad_controller_strategy.plist"

#import <Foundation/Foundation.h>
#import "TPAdControlRequestParams.h"
#import "TPAdControlStrategy.h"

@interface TPAdDSPController : NSObject

+ (instancetype) sharedController;

- (TPAdControlStrategy *) getCachedStrategy:(NSString *)tu;
- (TPAdControlStrategy *) requestForStrategyByParams:(TPAdControlRequestParams *)requestParams;
- (void) asyncRequestForStrategyByParams:(TPAdControlRequestParams *)requestParams
                       completitionBlock:(void (^)(TPAdControlStrategy *strategy))completitionBlock;

@end

#endif /* TPAdDSPController_h */
