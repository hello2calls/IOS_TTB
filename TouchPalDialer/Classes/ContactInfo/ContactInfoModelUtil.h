//
//  ContactInfoModelManager.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import <Foundation/Foundation.h>
#import "ContactInfoModel.h"

@interface ContactInfoModelUtil : NSObject

+ (ContactInfoModel *)getContactInfoModelByPersonId:(NSInteger)personId;
+ (ContactInfoModel *)getContactInfoModelByPhoneNumber:(NSString *)phoneNumber;
+ (NSArray *)getPhoneNumberArrayByPersonId:(NSInteger)personId;
+ (NSArray *)getPhoneNumberArrayByPhoneNumber:(NSString *)phoneNumber;
+ (NSArray *)getSubArrayByPersonId:(NSInteger)personId;
+ (NSArray *)getCallListByPersonId:(NSInteger)personId;
+ (NSArray *)getCallDataListByPersonId:(NSInteger)personId;
+ (NSArray *)getCallListByPhoneNumber:(NSString *)phoneNumber;
+ (NSArray *)getCallDataListtByPhoneNumber:(NSString *)phoneNumber;
+ (NSArray *)getShareArrayByPersonId:(NSInteger)personId;
+ (NSArray *)getShareArrayByPhoneNumber:(NSString *)phoneNumber;
@end
