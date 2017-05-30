//
//  TPDContactInfoManager.h
//  TouchPalDialer
//
//  Created by ALEX on 16/9/21.
//
//

#import <Foundation/Foundation.h>
#import "TPWebShareController.h"

@interface TPDContactInfoManager : NSObject
+ (instancetype)instance;
- (void)showContactInfoByPersonId:(NSInteger)personId inNav:(UINavigationController *)nav;
- (void)showContactInfoByPhoneNumber:(NSString *)phoneNumber;
- (NSInteger)getPersonId;
@end

