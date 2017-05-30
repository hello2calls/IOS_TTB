//
//  CommonUtil.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-2-4.
//
//

#import "CommonUtil.h"

@implementation CommonUtil


+ (BOOL)isValidNormalizedPhoneNumber:(NSString *)number
{
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^((\\+86\\d{7,11})|((400|800)\\d{7})|(1010\\d{4})|(95\\d{3})|(95\\d{6})|(96\\d{3})|(114)|(116114)|(111\\d{2})|(100\\d{2})|(12\\d{3})|(\\d{7,8}))$"                                                                           options:0
                                                                             error:&error];
    NSArray *result = [regex matchesInString:number options:0 range:NSMakeRange(0, number.length)];
    return [result count] > 0;
}

@end
