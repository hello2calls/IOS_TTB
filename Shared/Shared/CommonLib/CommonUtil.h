//
//  CommonUtil.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-2-4.
//
//

#import <Foundation/Foundation.h>

// [TODO] Elfe This is a temp class to put functions shared by both TPDialer and CIS.
// In the future, need to dup code from two projects to the CommonLib,
// and the code in this file should be put into approapriate pleaces
@interface CommonUtil : NSObject

+ (BOOL)isValidNormalizedPhoneNumber:(NSString *)number;

@end
