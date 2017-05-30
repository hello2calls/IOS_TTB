//
//  VoipAccountInfo.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-6.
//
//

#import <Foundation/Foundation.h>

@interface VoipAccountInfo : NSObject
@property (nonatomic, assign)long timeStamp;
@property (nonatomic, assign) NSInteger balance;
@property (nonatomic, assign) NSInteger bonusToday;
@property (nonatomic, assign)long deadLine;
@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *invitationCode;
@property (nonatomic, assign) NSInteger invitationUsedCount;
@property (nonatomic, copy) NSString *invitationReceived;
@property (nonatomic, copy) NSString *qualification;
@property (nonatomic, assign) NSInteger queueNumber;
@property (nonatomic, assign) NSInteger shareTime;
@property (nonatomic, assign) NSInteger temporaryTime;
@property (nonatomic, assign) NSInteger registerTime;

@end
