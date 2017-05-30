//
//  MarketLoginController.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/7.
//
//

#import <Foundation/Foundation.h>
#import "DefaultLoginController.h"

@interface MarketLoginController : DefaultLoginController

@property (nonatomic, copy)NSString *url;

@property (nonatomic, copy)NSString *title;

+ (NSString *) getActivityCenterUrlString;

@end
