//
//  InviteLoginController.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/4.
//
//

#import <Foundation/Foundation.h>
#import "DefaultLoginController.h"

@interface InviteLoginController : DefaultLoginController
@property (nonatomic,copy) NSString *webTitle;
@property (nonatomic,copy) NSString *shareFrom;
@property (nonatomic,copy) NSString *shareDest; // for sms share
@end
