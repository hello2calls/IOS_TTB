//
//  VoipFeedbackInfo.h
//  TouchPalDialer
//
//  Created by game3108 on 15/4/15.
//
//

#import <Foundation/Foundation.h>

@interface VoipFeedbackInfo : NSObject
@property (nonatomic, assign) NSInteger reasonId;
@property (nonatomic, strong) NSString *callerNumber;
@property (nonatomic, strong) NSString *calleeNumber;
@property (nonatomic, strong) NSString *netType;
@property (nonatomic, assign) NSInteger callType;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) BOOL shouldUpload;
@end
