//
//  NoahpushLoginController.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/22.
//
//

#import "NoahpushLoginController.h"
#import "PersonalCenterUtility.h"
#import "NoahManager.h"

@implementation NoahpushLoginController

- (void)jumpSomeWhereAfterLogin:(BOOL)animate {
    ExtensionStaticToast *estToast = [PersonalCenterUtility getPersonalMarketExtensionStaticToast];
    if (estToast) {
        [[NoahManager sharedPSInstance]clicked:estToast.toastId];
        [[NoahManager sharedPSInstance]cleaned:estToast.toastId];
    }
}

- (LoginControllerType)getIdentifyController {
    return NOAH_PUSH;
}

@end
