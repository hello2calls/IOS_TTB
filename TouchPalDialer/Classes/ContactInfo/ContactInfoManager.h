//
//  ContactInfoFactory.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/16.
//
//

#import <Foundation/Foundation.h>

#import "TPWebShareController.h"

@interface ContactInfoManager : NSObject
+ (instancetype)instance;
- (void)showContactInfoByPersonId:(NSInteger)personId;
- (void)showContactInfoByPhoneNumber:(NSString *)phoneNumber;
- (NSInteger)getPersonId;
@end
