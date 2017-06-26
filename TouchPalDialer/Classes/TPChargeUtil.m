//
//  TPChargeUtil.m
//  VoipSDK
//
//  Created by by.huang on 2017/6/14.
//  Copyright © 2017年 by.huang. All rights reserved.
//

#import "TPChargeUtil.h"

#import "GTMBase64.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"


//#define Url_Recharge @"http://121.52.235.231:40708/voip/p2p_recharge"
//#define Url_QueryTime @"http://121.52.235.231:40708/voip/p2p_query_time"
#define Url_Recharge @"http://ws2.cootekservice.com/voip/p2p_recharge"
#define Url_QueryTime @"http://ws2.cootekservice.com/voip/p2p_query_time"

#define ChargeNum @"+8618680686420"


@implementation TPChargeUtil

+(void)queryTime : (NSString *)phoneNum callback : (OnQueryCallback)callback;
{
    NSString *appKey = @"822422015299";
    long timestamp = [[NSDate date]timeIntervalSince1970] * 1000;
    
    NSString *strA = [NSString stringWithFormat:@"{account_name=%@&appkey=%@&channel_code=%@&timestamp=%ld}",phoneNum,appKey,IPHONE_CHANNEL_CODE,timestamp];
    
    NSString *signStr = [NSString stringWithFormat:@"%@&GET&/voip/p2p_query_time&%@",@"4c06bb2404fa4c09a482f7c0e7ce0ac7",strA];
    
    signStr = [GTMBase64 md5_base64:signStr];
    signStr = [signStr substringWithRange:NSMakeRange(0, signStr.length-2)];
    signStr = [self transformBase64:signStr];
    
    NSString *jsonStr = [NSString stringWithFormat:@"account_name=%@&appkey=%@&channel_code=%@&sign=%@&timestamp=%ld",phoneNum,appKey,IPHONE_CHANNEL_CODE,signStr,timestamp];
    
    
    NSString *url = [NSString stringWithFormat:@"%@?%@",Url_QueryTime,jsonStr];
    [self get:url callback:callback];
    
    
}


+(void)charge : (NSString *)phoneNum reward : (int)reward callback : (OnChargeCallback)callback;
{
    NSString *appKey = @"822422015299";
    NSString *channelcode =IPHONE_CHANNEL_CODE;
    NSString *order_number = [self ret32bitString];
    NSString *minute = [NSString stringWithFormat:@"%d",reward];
    long timestamp = [[NSDate date]timeIntervalSince1970] * 1000;
    
    
    NSString *strA = [NSString stringWithFormat:@"{account_name=%@&appkey=%@&channel_code=%@&order_number=%@&reward=%@&timestamp=%ld}",phoneNum,appKey,channelcode,order_number,minute,timestamp];
    
    NSString *signStr = [NSString stringWithFormat:@"%@&POST&/voip/p2p_recharge&%@",@"4c06bb2404fa4c09a482f7c0e7ce0ac7",strA];
    signStr = [GTMBase64 md5_base64:signStr];
    signStr = [signStr substringWithRange:NSMakeRange(0, signStr.length-2)];
    signStr = [self transformBase64:signStr];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    dic[@"account_name"] = phoneNum;
    dic[@"appkey"]= appKey;
    dic[@"channel_code"] = channelcode;
    dic[@"order_number"] =order_number;
    dic[@"reward"] = minute;
    dic[@"timestamp"] = [NSString stringWithFormat:@"%ld",timestamp];
    dic[@"sign"] = signStr;
    
    NSString *jsonStr = [self transformJson:dic];
    [self post:Url_Recharge content:jsonStr callback : callback] ;
}


+(void)get:(NSString *)url callback : (OnQueryCallback)callback
{
    NSURL *requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:requestURL];
    [request addValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"accept"];
    [request addValue:@"keep-alive" forHTTPHeaderField:@"connection"];
    [request addValue:@"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0" forHTTPHeaderField:@"user-agent"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error == nil){
            }
            else{
            }
        });
    }];
    [sessionDataTask resume];
}

+(void)post:(NSString *)url content:(NSString *)jsonStr callback : (OnChargeCallback)callback
{
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(error == nil){
                callback(YES,@"成功");
            }
            else{
                callback(NO,@"失败");
            }
        });
        
    }];
    [sessionDataTask resume];
}



+(NSString *)transformJson : (NSMutableDictionary *)dict
{
    NSData *data=[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+(NSString *)transformBase64 : (NSString *)signStr
{
    signStr = (NSMutableString * )[signStr stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    signStr = (NSMutableString * )[signStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    signStr = (NSMutableString * )[signStr stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return signStr;
}

+(NSString *)ret32bitString

{
    char data[16];
    for (int x=0;x<16;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:16 encoding:NSUTF8StringEncoding];
    
}


@end
