//
//  PhoneConvertUtil.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import "PhoneConvertUtil.h"

@implementation PhoneConvertUtil

+ (NSString*) shiftString:(NSString*)string withStep:(int)step {
    while (step < 0) {
        step += string.length;
    }
    if (step > string.length) {
        step = step % string.length;
    }
    NSString *head = [string substringWithRange:NSMakeRange(0, step)];
    NSString *tail = [string substringWithRange:NSMakeRange(step, string.length - step)];
    NSString *headReverse = [self reverseString:head];
    NSString *tailReverse = [self reverseString:tail];
    return [self reverseString:([NSString stringWithFormat:@"%@%@", headReverse , tailReverse])];
}

+ (NSString*)reverseString:(NSString*)string{
    NSMutableString *s = [[NSMutableString alloc]init];
    for (NSUInteger i= string.length; i>0; i--) {
        [s appendString:[string substringWithRange:NSMakeRange(i-1, 1)]];
    }
    return s;
}



+ (long long) NSStringToLong:(NSString*) phone {
    NSString *regulaStr = @"\\+8\\d{4,}";

    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regulaStr];
    if (!phone || phone.length == 0 || [regex evaluateWithObject:phone] == NO || phone.length > 16) {
        return 0;
    }
    NSString *head = [phone substringWithRange:NSMakeRange(1, 3)];
    NSMutableString *mutable = [[NSMutableString alloc]init];
    for (int i = 4; i < phone.length; i++) {
        NSString *stringValue = [phone substringWithRange:NSMakeRange(i, 1)];
        [mutable appendString:[NSString stringWithFormat:@"%d", ((stringValue.intValue + i - 4) % 10)]];
    }
    NSString *body = [self shiftString:mutable withStep:3];
    NSString *numberStr = [NSString stringWithFormat:@"%@%@", head, body];
    long long number = numberStr.longLongValue;
    return number;
}

+ (NSString*) LongToNSString :(long long) phoneLong{
    if  (phoneLong == 0 || phoneLong < 10000) {
        return @"";
    }
    NSString *phone = [NSString stringWithFormat:@"%lld", phoneLong];
    NSString *head = [phone substringWithRange:NSMakeRange(0, 3)];
    NSString *body = [phone substringWithRange:NSMakeRange(3, phone.length - 3)];
    
    body = [self shiftString:body withStep:body.length - 3];
    
    NSMutableString *mutable = [[NSMutableString alloc]init];
    for (int i = 0; i < body.length; i++) {
        NSString *stringValue = [body substringWithRange:NSMakeRange(i, 1)];
        [mutable appendString:[NSString stringWithFormat:@"%d", ((stringValue.intValue + 10 - i) % 10)]];
    }
    
    return [NSString stringWithFormat:@"+%@%@", head, mutable];
}

+ (NSString*) LongToNSStringIOS10Anti :(long long) phoneLong{
    if  (phoneLong == 0 || phoneLong < 10000) {
        return @"";
    }
    NSString *phone = [NSString stringWithFormat:@"%lld", phoneLong];
    NSString *head = [phone substringWithRange:NSMakeRange(0, 3)];
    NSString *body = [phone substringWithRange:NSMakeRange(3, phone.length - 3)];
    
    body = [self shiftString:body withStep:body.length - 3];
    
    NSMutableString *mutable = [[NSMutableString alloc]init];
    for (int i = 0; i < body.length; i++) {
        NSString *stringValue = [body substringWithRange:NSMakeRange(i, 1)];
        [mutable appendString:[NSString stringWithFormat:@"%d", ((stringValue.intValue + 10 - i) % 10)]];
    }
    
    return [NSString stringWithFormat:@"%@%@", head, mutable];
}

@end
