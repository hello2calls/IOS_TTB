//
//  DateTimeUtil.h
//  TPVoIP
//
//  Created by lingmei xie on 13-6-21.
//  Copyright (c) 2013年 lingmei xie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MINUTE_IN_SECOND (60)
#define HOUR_IN_SECOND (60 * MINUTE_IN_SECOND)
#define DAY_IN_SECOND (24 * HOUR_IN_SECOND)

@interface DateTimeUtil : UIView

+ (NSString *)durationString:(NSInteger)duration seperator:(NSString *)str;

+ (NSString *)durationHistoryString:(NSInteger)duration;

+ (NSString *)durationMinute:(NSInteger)duration;

+ (NSString *)dateString:(NSTimeInterval)time;

+ (NSTimeInterval) currentTimestampInSecond; // in seconds
+ (long long) currentTimestampInMillis;
+ (NSString *) stringTimestampInMillis;
+ (NSDate *) dateByFormat:(NSString *)format fromString:(NSString *)dateString;
+ (NSString *) dateStringByFormat:(NSString *)format fromDate:(NSDate *)date;


+ (NSTimeInterval) timeElapsedInDate:(NSDate *)date;
+ (NSTimeInterval) timeElapsedInToday;
+ (NSDateComponents *) dateComponentsFromDate:(NSDate *)date;
+ (NSDateComponents *) dateComponentsFromTime:(NSTimeInterval)time;

+ (BOOL) isInSameWeekOfDate:(NSDate *)date andDate:(NSDate *)anotherDate;

+ (NSString *) weekdayStringFromDate:(NSDate *)date;
+ (NSDate *) getDateFromCommercialSkinInTimeZoneByFormat:(NSString *)format fromString:(NSString *)dateString ;
@end
