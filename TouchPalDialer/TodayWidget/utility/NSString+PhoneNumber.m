//
//  NSString+FormatPhoneNumber.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-10-31.
//
//

#import "NSString+PhoneNumber.h"

#define STR_SPACE       @" "
#define STR_MIDDLE_LINE @"-"

@implementation NSString (FormatPhoneNumber)

-(NSString *)formatPhoneNumberByDigitNumber:(NSString *)digitNumber{
    if (self.length <= 7) {return self;}
    if ([self rangeOfString:@"^[0-9+]{1}[0-9*#+\\ \\-,;]*" options:NSRegularExpressionSearch].length == 0) {
        return self;
    }
    if ((self.length >4 && [self hasPrefix:@"00"] && ![self hasPrefix:@"0086"]) || ([self rangeOfString:@","].length > 0 || [self rangeOfString:@";"].length > 0)){
        return self;
    }else{
        return [self normalizedChina:[NSMutableString stringWithString:digitNumber]];
    }
}
-(NSString *)formatPhoneNumber{
    if (self.length <= 7) {return self;}
    if ([self rangeOfString:@"^[0-9+]{1}[0-9*#+\\ \\-,;]*" options:NSRegularExpressionSearch].length == 0) {
        return self;
    }
    if ((self.length >4 && [self hasPrefix:@"00"] && ![self hasPrefix:@"0086"])
        || ([self rangeOfString:@","].length > 0 || [self rangeOfString:@";"].length > 0)) {
        return self;
    }else{
        return [self normalizedChina:[NSMutableString stringWithString:[self digitNumber]]];
    }
}
-(NSString *)digitNumber{
    NSMutableString* result = [[NSMutableString alloc] initWithString:self];
    NSInteger len = [result length];
    NSRange range = NSMakeRange(0, 1);
    for (NSInteger i= len-1; i>=0;i--) {
        char tmp =[result characterAtIndex:i];
        if (!((tmp>='0' && tmp<='9') || tmp == '+' || tmp == '*' || tmp == '#')) {
            range.location = i;
            [result deleteCharactersInRange:range];
        }
    }
    //cootek_log(@"%@", result);
    return result;
}

-(int)numberFlag:(NSString *)number{
    NSArray *moblieNumberPrefixs = [NSArray arrayWithObjects:@"13",@"15",@"18",@"14",@"16",nil];
    NSArray *areas = [NSArray arrayWithObjects:@"10",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",nil];
    int flag = 0;
    if ([number hasPrefix:@"1"]) {
        NSString *str = [number substringToIndex:2];
        if ([moblieNumberPrefixs containsObject:str]) {
            flag = 1;
        }
    }else if ([number hasPrefix:@"400"] || [number hasPrefix:@"800"]){
        flag = 8;
    }else if ([number hasPrefix:@"0"]){
        flag = 128;
        if ([number hasPrefix:@"0086"]) {
            flag = flag + 512;
            NSRange range = NSMakeRange(4,2);
            NSString *str = [number substringWithRange:range];
            if ([areas containsObject:str]) {
                flag = flag + 64;
            }else if ([moblieNumberPrefixs containsObject:str]){
                flag = flag + 4;
            }
        }else{
            NSRange range = NSMakeRange(1,2);
            NSString *str = [number substringWithRange:range];
            if ([areas containsObject:str]) {
                flag = flag + 16;
            }
        }
    }else if ([number hasPrefix:@"+86"]){
        flag = flag + 256;
        NSRange range = NSMakeRange(3,2);
        NSString *str = [number substringWithRange:range];
        if ([areas containsObject:str]) {
            flag = flag + 32;
        }else if ([moblieNumberPrefixs containsObject:str]){
            flag = flag + 2;
        }
    }
    return flag;
}
-(NSString *)normalizedChina:(NSMutableString *)tmp{
    NSInteger len = [tmp length];
    if (len < 5) {return self;}
    int flag = [self numberFlag:tmp];
    switch (flag){
        case 1://130
        {
            if (len <9 || len>11) break;
            if (len <= 7) {[tmp insertString:STR_MIDDLE_LINE atIndex:3];}
            else {
                [tmp insertString:STR_MIDDLE_LINE atIndex:7];
                [tmp insertString:STR_MIDDLE_LINE atIndex:3];
            }
            return tmp;
            break;
        }
        case 258://+86130
        {
            if (len > 6) {
              if(len > 11 && len < 15){
                    [tmp insertString:STR_MIDDLE_LINE atIndex:10];
                    [tmp insertString:STR_MIDDLE_LINE atIndex:6];
                }
                [tmp insertString:STR_SPACE atIndex:3];
                return tmp;
            }
            break;
        }
        case 644://0086152
        {
            if (len > 7){
                if (len > 12 && len < 16){
                    [tmp insertString:STR_MIDDLE_LINE atIndex:11];
                    [tmp insertString:STR_MIDDLE_LINE atIndex:7];
                }
                [tmp insertString:STR_SPACE atIndex:4];
                [tmp insertString:STR_SPACE atIndex:2];
                return tmp;
            }
            break;
        }
        case 8://400
        {
            if (len <9 || len >  11) break;
            if (len == 9 || len == 10) {
                [tmp insertString:STR_MIDDLE_LINE atIndex:6];
            }
            [tmp insertString:STR_MIDDLE_LINE atIndex:3];
            return tmp;
            break;
        }
        case 144:{//021
            if (len > 11) break;
            [tmp insertString:STR_MIDDLE_LINE atIndex:3];
            return tmp;
            break;
        }
        case 128:{//0835
            if (len > 12) break;
            [tmp insertString:STR_MIDDLE_LINE atIndex:4];
            return tmp;
            break;
        }
        case 288://+8621
        {
            if (len > 13) break;
            if (len >5 ){
                [tmp insertString:STR_SPACE atIndex:3];
                if (len > 11) {
                    [tmp insertString:STR_MIDDLE_LINE atIndex:6];
                }
                return tmp;
            }
            break;
        }
        case 256://+86835
        {
            if (len > 14) break;
            if (len > 6) {
                [tmp insertString:STR_SPACE atIndex:3];
                if (len > 11) {
                    [tmp insertString:STR_MIDDLE_LINE atIndex:7];
                }
                return tmp;
            }
            break;
        }
        case 704://008621
        {
            if (len > 6) {
                if (len ==13 || len ==14) {
                    [tmp insertString:STR_MIDDLE_LINE atIndex:6];
                }
                [tmp insertString:STR_SPACE atIndex:4];
                [tmp insertString:STR_SPACE atIndex:2];
                return tmp;
            }
            break;
        }
        case 640://0086835
        {
            if (len > 7){
                if (len ==15 || len ==14) {
                    [tmp insertString:STR_MIDDLE_LINE atIndex:7];
                }
                [tmp insertString:STR_SPACE atIndex:4];
                [tmp insertString:STR_SPACE atIndex:2];
                return tmp;
            }
            break;
        }
        default:
            break;
    }
    return self;
}
@end
@implementation NSString (SearchPhoneNumber)
-(NSRange)rangeOfStringInNumbers:(NSString *)aString digitNumber:(NSString *)digitNumber{
    NSRange range = [digitNumber rangeOfString:aString];
    if (range.length > 0) {
        NSRange displayRange = NSMakeRange(0, 0);
        NSInteger len = [self length];
        int numberCount = 0;
        BOOL isLocationFound = NO;
        for (int i=0; i<len; i++) {
            char tmp =[self characterAtIndex:i];
            if ((tmp>='0' && tmp<='9') || tmp == '+'||tmp == '#'||tmp == '*') {
                numberCount++;
            }
            if(!isLocationFound) {
                if (numberCount == (range.location +1)) {
                    displayRange.location = i;
                    numberCount = 1;
                    isLocationFound = YES;
                    if(range.length == 1) {
                        displayRange.length = 1;
                        break;
                    }
                }
            }else {
                if (numberCount == range.length) {
                    displayRange.length = i-displayRange.location+1;
                    break;
                }
            }
        }
        return displayRange;
    }
    return range;
}
@end