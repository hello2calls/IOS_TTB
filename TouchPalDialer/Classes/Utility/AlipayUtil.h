//
//  AlipayUtil.h
//  TouchPalDialer
//
//  Created by Chen Lu on 8/7/12.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AlipayUtil : NSObject

+(BOOL) isAlipayNeedInstall;

+(NSString*) extractAlipayPhoneNumber:(NSString *)rawNumber;

+(NSString*) extractAlipayPhoneNumber:(NSString *)rawNumber matchesOneOf:(NSArray*) storedNumbers;

+(NSURL *) urlWithAlipayPhoneNumber:(NSString*) number name:(NSString*) name;

+(BOOL) checkAndInstallAlipayWithName:(NSString*) name;

+(void) jumpToAlipayWithAlipayPhoneNumber:(NSString*)number name:(NSString*) name;

@end
