//
//  ContactInfoUtil.h
//  TouchPalDialer
//
//  Created by game3108 on 15/7/20.
//
//

#import <Foundation/Foundation.h>
#import "ContactInfoCellModel.h"
#import "CallLogDataModel.h"

@interface ContactInfoUtil : NSObject
+ (UIImage *)getBgImageByPersonId:(NSInteger)personId;
+ (UIImage *)getPhotoImageByPersonId:(NSInteger)personId;
+ (UIImage *)getPhotoImageByPhoneNumber:(NSString *)phoneNumber;

+ (NSString *)getDateStr:(NSInteger)callTime;
+ (NSString *)getDateTimeFormat:(NSInteger)callTime;
+ (NSString *)getTimeStr:(NSInteger)callTime;
+ (NSString *)getTimeFormat:(NSInteger)callTime;

+ (void) chooseContactPhotoByPersonId:(NSInteger)personId;
+ (void) chooseEditDeleteActionByPersonId:(NSInteger)personId;
+ (void) chooseAddActionByNumber:(NSString *)number;

+ (void) editGestureAction:(NSInteger)personId;
+ (void) shareByPersonId:(NSInteger)personId;
+ (void) favPersonByPeronId:(NSInteger)personId;
+ (void) copyByPhoneNumber:(NSString *)phoneNumber;
+ (void) shareByPhoneNumber:(NSString *)phoneNumber;

+ (void) shareMessageByModel:(ContactInfoCellModel *)model;
+ (void) makePhoneCallByPersonId:(NSInteger)personId andModel:(ContactInfoCellModel *)model;
+ (void) makePhoneCallByPhoneNumber:(NSString *)phoneNumber;
+ (void) showFacetimeByPersonId:(NSInteger)personId;
+ (void) sendEmailByModel:(ContactInfoCellModel *)model;
+ (void) selectGroupByPersonId:(NSInteger)personId;
+ (void) editNoteByPersonId:(NSInteger)personId;
+ (void) openUrl:(ContactInfoCellModel *)model;
+ (void) smsInviteByPersonId:(NSInteger)personId;
+ (void) smsInviteByPhone:(NSString *)phone;


+ (void) deleteCallLog:(CallLogDataModel *)model;
+ (void) clearCallLogByPersonId:(NSInteger)personId;
+ (void) clearCallLogByPhoneNumber:(NSString *)number;

+ (void) makeCall:(CallLogDataModel *)model;

+ (NSString *) shareNameByPersonID:(NSInteger)personId;
+ (NSString *) shareNumberEmailsByPersonID:(NSInteger)personId;
@end
