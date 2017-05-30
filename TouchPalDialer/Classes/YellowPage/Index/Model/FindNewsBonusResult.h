//
//  FindNewsBonusResult.h
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YPFeedsBonusType) {
    YP_FEEDS_BONUS_TRAFFIC = 1,
    YP_FEEDS_BONUS_MINUTES = 2,
    YP_FEEDS_BONUS_FREE_MINUTES = 3,
};


typedef NS_ENUM(NSUInteger, YPRedPacketType) {
    YP_RED_PACKET_FEEDS_LIST = 1,
    YP_RED_PACKET_FEEDS_DETAIL = 2,
    YP_RED_PACKET_FEEDS_SHARE = 3,
    YP_RED_PACKET_FEEDS_ALL = 4,
};

typedef NS_ENUM(NSUInteger, YPRedPacketRequestType) {
    YP_RED_PACKET_REQUEST_QUERY = 1,
    YP_RED_PACKET_REQUEST_ACQUIRE = 2,
};

@interface FindNewsBonusResult : NSObject

@property(nonatomic, assign, getter=getBonusType, setter=setBonusType:)YPFeedsBonusType type;
@property(nonatomic, strong, getter=getRewardType, setter=setRewardType:)NSString* rewardType;
@property(nonatomic, strong, getter=getBonusAmount, setter=setBonusAmount:)NSString* amount;
@property(nonatomic, strong, getter=getBonusResult, setter=setBonusResult:)NSDictionary* result;
@property(nonatomic, strong, getter=getBonusId, setter=setBonusId:)NSString* bonusId;
@property(nonatomic, strong, getter=getS, setter=setS:)NSString* s;
@property(nonatomic, strong, getter=getTimestamp, setter=setTimestamp:)NSNumber* timestamp;
@property(nonatomic, strong, getter=getResultCode, setter=setResultCode:)NSNumber* resultCode;
@property(nonatomic, strong, getter=getEventName, setter=setEventName:)NSString* eventName;


- (NSString*)getBonusString;
- (BOOL) checkBonus;

@end
