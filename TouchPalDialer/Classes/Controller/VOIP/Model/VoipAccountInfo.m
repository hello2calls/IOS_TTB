//
//  VoipAccountInfo.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-6.
//
//

#import "VoipAccountInfo.h"

@implementation VoipAccountInfo
- (void)dealloc {
    self.accountName = nil;
    self.userType = nil;
    self.invitationCode = nil;
    self.invitationReceived = nil;
    self.qualification = nil;
}
@end
