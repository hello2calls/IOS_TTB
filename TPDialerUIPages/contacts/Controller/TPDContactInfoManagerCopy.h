//
//  TPDContactInfoManagerCopy.h
//  TouchPalDialer
//
//  Created by H L on 2016/11/16.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "TPWebShareController.h"

@interface TPDContactInfoManagerCopy : NSObject
+ (instancetype)instance;
- (void)showContactInfoByPersonId:(NSInteger)personId inNav:(UINavigationController *)nav;
- (void)showContactInfoByPhoneNumber:(NSString *)phoneNumber;
- (NSInteger)getPersonId;
@end
