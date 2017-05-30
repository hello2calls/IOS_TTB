//
//  NotVerifyWithoutCodeViewController.h
//  TouchPalDialer
//
//  Created by game3108 on 14-10-24.
//
//

#import "CootekViewController.h"
#import "CommonHeaderBar.h"

@interface CommnonLoginViewController : CootekViewController <CommonHeaderBarProtocol>

+ (CommnonLoginViewController *)loginWithPreInfo:(NSDictionary *)info successNetBlock:(void(^)(void))netBlock successUIBlock:(void(^)(void))uiBlock;
+ (CommnonLoginViewController *)loginWithPreInfo:(NSDictionary *)info successNetBlock:(void(^)(void))netBlock successUIBlock:(void(^)(void))uiBlock failedNetBlock:(void(^)(void))failedNetBlock failedUIBlock:(void(^)(void))failedUIBlock;
- (void)setRegisterNumber:(NSString*)number;
@end

