//
//  TodayWidgetUtil.m
//  TouchPalDialer
//
//  Created by game3108 on 15/6/9.
//
//

#import "TodayWidgetUtil.h"
#import "TPDialerColor.h"

#include "def.h"
#include "Option.h"
#include "Configs.h"
#include "IPhoneNumber.h"
#include "IRules.h"
#include "ICityGroup.h"
#include <list>
#include <fcntl.h>

using namespace orlando;

static FILE *fd;
static Option *option;

@interface TodayWidgetUtil()

@end

@implementation TodayWidgetUtil

+ (void)initialize
{
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"numberAttr.img"];
    fd = fopen([filePath UTF8String],"r");
    option = OptionManager::getInst()->getOption();
    option ->initAttrImage((void *)fd);
}

+ (NSString *)getAttr:(NSString *)number{
    if (!number) {
        return @"";
    }
    IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
    string tempt = inumber->getAttr(1);
    NSString *attr = [NSString stringWithUTF8String:tempt.c_str()];
    attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return attr;
}

//号码归一化
+ (NSString *)getNormalizedNumber:(NSString *)number
{
    if (!number) {
        return @"";
    }
    number = [self digitNumber:number];
    IPhoneNumber *inumber = PhoneNumberFactory::Create((string)[number UTF8String],false);
    string temp=inumber->getNormalizedNumber();
    return [NSString stringWithUTF8String:temp.c_str()];
}

+ (NSString *)digitNumber:(NSString *)number{
    NSMutableString* result = [[NSMutableString alloc] initWithString:number];
    NSInteger len = [result length];
    NSRange range = NSMakeRange(0, 1);
    for (NSInteger i = len-1; i>=0;i--) {
        char tmp =[result characterAtIndex:i];
        if (!((tmp>='0' && tmp<='9') || tmp == '+' || tmp == '*' || tmp == '#')) {
            range.location = i;
            [result deleteCharactersInRange:range];
        }
    }
    return result;
}

+ (NSString *)requestNumberInfo:(NSString *)number andToken:(NSString *)token{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ws2.cootekservice.com/yellowpage/info2?survey=true&guess=true&need_slots=true&phone=%@&_v=1&_token=%@",number,token]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
    NSHTTPURLResponse *urlResponse=[[NSHTTPURLResponse alloc] init];
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    NSInteger status=[urlResponse statusCode];
    if ( status != 200 ){
        return nil;
    }
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

+ (NSString *)readDataFromNSUserDefaults:(NSString *)key
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.cootek.Contacts"];
    NSString *value = [shared valueForKey:key];
    
    return value;
}

+ (void)writeDefaultKeyToDefaults:(id)object andKey:(NSString *)key{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.cootek.Contacts"];
    [shared setObject:object forKey:key];
    [shared synchronize];
}

+ (NSDictionary *)getDictionaryFromJsonString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    return returnData;
}

+ (NSString *)getClassfyType:(NSString *)type{
    if ( [type isEqualToString:@"house agent"] ){
        return @"房产中介";
    }else if ( [type isEqualToString:@"insurance"] ){
        return @"保险电话";
    }else if ( [type isEqualToString:@"financial products"] ){
        return @"金融产品";
    }else if ( [type isEqualToString:@"headhunting"] ){
        return @"猎头电话";
    }else if ( [type isEqualToString:@"promote sales"] ){
        return @"推销电话";
    }else if ( [type isEqualToString:@"repair"] ){
        return @"修理电话";
    }else if ( [type isEqualToString:@"book hotel/airline"] ){
        return @"预定电话";
    }else if ( [type isEqualToString:@"public services"] ){
        return @"公共服务";
    }else if ( [type isEqualToString:@"fraud"] ){
        return @"诈骗电话";
    }else if ( [type isEqualToString:@"crank"] ){
        return @"骚扰电话";
    }else if ( [type isEqualToString:@"express"] ){
        return @"快递外卖";
    }else{
        return nil;
    }
}

+ (NSString *)getNumberFromPasteboard:(NSString *)string {
    NSString *numStr = [string stringByReplacingOccurrencesOfString:@"[^0-9+]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [string length])];
    NSRange range = [numStr rangeOfString:@"+"];//判断字符串是否包含
    if ( range.length >0 ){
        if ( [numStr hasPrefix:@"+"] ){
            NSString *tempt = [numStr stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [numStr length])];
            numStr = [NSString stringWithFormat:@"+%@",tempt];
        }else{
            numStr = [numStr stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [numStr length])];
        }
    }
    return numStr;
}

+ (NSString *)getNormalizePhoneNumber:(NSString *)number{
   
    return [self getNormalizedNumber:number];
}

+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)getColor:(NSString *)colorString
{
    TPDialerColor *tpDialerColor =[[TPDialerColor alloc] initWithString:colorString];
    UIColor *color =  [UIColor colorWithRed:tpDialerColor.R green:tpDialerColor.G blue:tpDialerColor.B alpha:tpDialerColor.alpha];
    return color;
}

+ (void)callNumber:(NSString *)number{
    NSString *numberString = [NSString stringWithFormat:@"tel://%@",number];
    numberString = [numberString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *phoneNumberUrl = [NSURL URLWithString:numberString];
    [[UIApplication sharedApplication] openURL:phoneNumberUrl];
}

+ (BOOL) getIfFreeCall:(NSString *)number{
    if ( [number hasPrefix:@"+86"] && number.length >= 12 && number.length <= 14)
        return [[self readDataFromNSUserDefaults:@"isVoipOn"] boolValue];
    return NO;
}



@end
