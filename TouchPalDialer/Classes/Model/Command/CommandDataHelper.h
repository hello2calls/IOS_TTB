//
//  CommandDataHelper.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-13.
//
//

#import <Foundation/Foundation.h>

@interface CommandDataHelper : NSObject
+ (NSString *)displayNameFromData:(id)data;
+ (NSString *)phoneNumberFromData:(id)data;
+ (NSString *)defaultPhoneNumberFromData:(id)data;
+ (NSInteger)personIdFromData:(id)data;
@end
