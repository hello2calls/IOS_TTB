//
//  DefaultJumpLoginController.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/6.
//
//

#import "DefaultLoginController.h"

@interface DefaultJumpLoginController : DefaultLoginController
@property (nonatomic, copy)NSString *destination;
@property (nonatomic, copy)UIViewController *(^yourDestination)(void);
@end
