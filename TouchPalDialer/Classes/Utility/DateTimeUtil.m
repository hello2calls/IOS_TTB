//
//  DateTimeUtil.m
//  TPVoIP
//
//  Created by lingmei xie on 13-6-21.
//  Copyright (c) 2013年 lingmei xie. All rights reserved.
//

#import "DateTimeUtil.h"

@implementation DateTimeUtil

+ (NSString *)durationString:(NSInteger)duration seperator:(NSString *)str
{
    int hours = duration/3600;
    int minutes = (duration%3600)/60;
    int second = (duration%3600)%60;
    NSString *timeString = @"";
    if (hours != 0) {
        timeString = [NSString stringWithFormat:@"%@%@",[self timeFormat:hours],str];
    }
    timeString = [NSString stringWithFormat:@"%@%@%@%@",timeString,[self timeFormat:minutes],str,[self timeFormat:second]];
    return timeString;
}

+ (NSString *)durationHistoryString:(NSInteger)duration
{
    int minutes = duration/60;
    int second = duration%60;
    NSString *timeString = @"";
    timeString = [NSString stringWithFormat:@"%d'%@\"",minutes,[self timeFormat:second]];
    return timeString;

}

+ (NSString *)durationMinute:(NSInteger)duration
{
    int  minutes = ceilf(duration/60.0);
    return [NSString stringWithFormat:@"%d'",minutes];
}

+ (NSString *)timeFormat:(NSInteger)time
{
    if (time<10) {
        return [NSString stringWithFormat:@"0%d",time];
    }else {
        return [NSString stringWithFormat:@"%d",time];
    }
}

+ (NSString *)getLocalShortTimeString:(NSTimeInterval)intervalFrom1970
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:intervalFrom1970];
    NSDateFormatter *formatter	=  [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}

+ (NSString *)dateString:(NSTimeInterval)time
{
    NSString *dateString = nil;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    // now
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    int nowSecond = [comps second];
    int nowMinute = [comps minute];
    int nowHour = [comps hour];
    
    NSDateFormatter *formatter	=  [[NSDateFormatter alloc] init];
    NSTimeInterval nowSinceToday0Clock = (nowHour * 60 + nowMinute) * 60 + nowSecond;
    NSTimeInterval nowSince1970 = [now timeIntervalSince1970];
    NSTimeInterval delta = nowSince1970 - time;
    int onedaysecond = 24*60*60;
    if (delta < nowSinceToday0Clock) {
        dateString = [self getLocalShortTimeString:time];
    }else if(delta < (nowSinceToday0Clock + onedaysecond)){
        dateString = @"昨天";
    }else {
        [formatter setDateFormat:@"MM/dd"];
        dateString = [formatter stringFromDate:date];
    }
    return dateString;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (NSTimeInterval) currentTimestampInSecond {
    return [[NSDate date] timeIntervalSince1970];
}

+ (long long) currentTimestampInMillis {
    return (long long) (1000 * [DateTimeUtil currentTimestampInSecond]);
}

+ (NSString *) stringTimestampInMillis {
    long long tt = [DateTimeUtil currentTimestampInMillis];
    return [@(tt) stringValue];
}

/**
 *  resolve string to NSDate with timezone set to Asia/Shanghai timezone
 *
 *  @param format     format string
 *  @param dateString input string
 *
 *  @return a NSDate instance
 */
+ (NSDate *) dateByFormat:(NSString *)format fromString:(NSString *)dateString {
    if (!format || !dateString) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:dateString];
    NSTimeInterval interval = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    return localDate;

}
+ (NSDate *) getDateFromCommercialSkinInTimeZoneByFormat:(NSString *)format fromString:(NSString *)dateString {
    if (!format || !dateString) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:dateString];
    NSTimeInterval interval = [[NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"] secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];;
    return localDate;
}

+ (NSString *)dateStringByFormat:(NSString *)format fromDate:(NSDate *)date {
    if (!format || !date) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSDateComponents *) dateComponentsFromTime:(NSTimeInterval)time {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:time];
    return [DateTimeUtil dateComponentsFromDate:date];
}

+ (NSDateComponents *) dateComponentsFromDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekOfYearCalendarUnit;
    return [calendar components:unitFlags fromDate:date];
}

+ (NSTimeInterval) timeElapsedInDate:(NSDate *)date {
    NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
    int nowSecond = [comps second];
    int nowMinute = [comps minute];
    int nowHour = [comps hour];
    return (NSTimeInterval)(HOUR_IN_SECOND * nowHour + MINUTE_IN_SECOND * nowMinute + nowSecond);
}

+ (NSTimeInterval) timeElapsedInToday {
    return [DateTimeUtil timeElapsedInDate:[NSDate date]];
}

+ (BOOL) isInSameWeekOfDate:(NSDate *)date andDate:(NSDate *)anotherDate {
    if (!date || !anotherDate) {
        return NO;
    }
    NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
    NSDateComponents *anotherComps = [DateTimeUtil dateComponentsFromDate:anotherDate];
    return comps.weekOfYear == anotherComps.weekOfYear;
}

+ (NSString *) weekdayStringFromDate:(NSDate *)date {
    if (!date) {
        return nil;
    }
    NSDateComponents *comps = [DateTimeUtil dateComponentsFromDate:date];
    NSString *key = nil;
    
    // sunday is the first day as zero(0)
    switch (comps.weekday - 1) {
        case 0: {
            key = @"Sunday";
            break;
        }
        case 1: {
            key = @"Monday";
            break;
        }
        case 2: {
            key = @"Tuesday";
            break;
        }
        case 3: {
            key = @"Wednesday";
            break;
        }
        case 4: {
            key = @"Thursday";
            break;
        }
        case 5: {
            key = @"Friday";
            break;
        }
        case 6: {
            key = @"Saturday";
            break;
        }
        default:
            break;
    }
    if (key) {
        key = NSLocalizedString(key, @"周几");
    }
    return key;
}

@end
