//
//  FindNewsBonusResult.m
//  TouchPalDialer
//
//  Created by lin tang on 16/8/22.
//
//

#import "FindNewsBonusResult.h"

@implementation FindNewsBonusResult

- (NSString*)getBonusString
{
    NSString* bonusStr = @"";
    switch (self.type) {
        case YP_FEEDS_BONUS_TRAFFIC:
            bonusStr = @"M免费流量";
            break;
        case YP_FEEDS_BONUS_MINUTES:
            bonusStr = @"分钟免费时长";
            break;
        case YP_FEEDS_BONUS_FREE_MINUTES:
            bonusStr =@"分钟永久时长";
            break;
        default:
            break;
    }
    return bonusStr;
}

- (BOOL) checkBonus
{
    if (self.resultCode.integerValue == 2000) {
        return YES;
    }
    return NO;
}


@end
