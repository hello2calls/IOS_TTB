//
//  ShowAlertViewManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/2/4.
//
//

#import <Foundation/Foundation.h>
#import "ShowAlertViewInfo.h"

#define VOIP_INFO_TYPE 1
#define FLOW_INFO_TYPE 2

@interface ShowAlertViewManager : NSObject
+(instancetype)instance;
- (void)addInfo:(ShowAlertViewInfo*)info;
- (void)showAlertView:(NSInteger)alertType;
- (void)checkAlertView;
@end
