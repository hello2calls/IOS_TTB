//
//  FeedsRedPacketLoginController.m
//  TouchPalDialer
//
//  Created by lin tang on 16/8/25.
//
//

#import "FeedsRedPacketLoginController.h"
#import "FeedsRedPacketManager.h"

@implementation FeedsRedPacketLoginController

- (void)jumpSomeWhereAfterLogin:(BOOL)animate {
    
}

- (void)doSomeThingAfterLoginSuccess {
    if (self.afterLoginBlock) {
        self.afterLoginBlock();
    }
}

-(NSDictionary *)preInfo {
    return @{@"text":@"绑定手机号，看天天头条天天领红包"};
}
@end
