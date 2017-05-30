//
//  FeedsRedPacketLoginController.h
//  TouchPalDialer
//
//  Created by lin tang on 16/8/25.
//
//

#import "DefaultLoginController.h"
#import "FindNewsBonusResult.h"

@interface FeedsRedPacketLoginController : DefaultLoginController

@property(nonatomic, assign)YPRedPacketType type;
@property(nonatomic, strong) void(^afterLoginBlock)();
@end
