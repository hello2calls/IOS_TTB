//
//  FindRedPacketManager.h
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import <Foundation/Foundation.h>
#import "FindNewsBonusResult.h"

@interface FeedsRedPacketManager : NSObject


- (void) queryFeedsRedPacketByType:(YPRedPacketType)type withBlock:(void (^)(FindNewsBonusResult *))block;
- (void) acquireFeedsRedPacketByType:(YPRedPacketType)type withQueryResult:(FindNewsBonusResult *)queryResult withBlock:(void (^)(FindNewsBonusResult *))block;

+ (void) checkRedPacket;
+ (void) showRedPacketGuaji;
+ (void) showRedPacket: (UIView *) iconView withType:(YPRedPacketType)type withQueryResult:(FindNewsBonusResult *)queryResult withLoginBlock:(void(^)(void))block;
+ (void) openRedPacket: (UIView *) iconView withType:(YPRedPacketType)type withResult:(FindNewsBonusResult *)result;
@end
