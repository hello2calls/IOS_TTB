//
//  DefaultJumpLoginController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/6.
//
//

#import "DefaultJumpLoginController.h"
#import "TouchPalDialerAppDelegate.h"
#import "MyWalletViewController.h"

@implementation DefaultJumpLoginController

- (void)jumpSomeWhereAfterLogin:(BOOL)animate {
    Class dest = NSClassFromString(_destination);
    if (dest) {
        [[TouchPalDialerAppDelegate naviController] pushViewController:[[dest alloc] init] animated:animate];
    } else if (_yourDestination) {
        [[TouchPalDialerAppDelegate naviController] pushViewController:_yourDestination() animated:animate];
    }
}

- (LoginControllerType)getIdentifyController {
    if ([_destination isEqual:NSStringFromClass([MyWalletViewController class])]) {
        return PERSOANL_WALLET;
    }
    if ([self.origin isEqualToString:@"personal_center_backfee"]) {
        return PERSONAL_BACK_FEE;
    }
    
    return DEFAULT_CONTROLLER;
}

@end
