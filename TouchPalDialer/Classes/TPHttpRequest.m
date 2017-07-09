//
//  TouchpalHttpRequest.m
//  demo
//
//  Created by by.huang on 2017/2/6.
//  Copyright © 2017年 by.huang. All rights reserved.
//

#import "TPHttpRequest.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "NSString+MD5.h"
#import "SeattleFeatureExecutor.h"

@implementation TPHttpRequest

SINGLETON_IMPLEMENTION(TPHttpRequest)

-(void)get:(NSString *)url parameters:(NSMutableDictionary *)parameters success:(SuccessCallback)success fail:(FailCallback)fail
{
    NSURL *requestURL = [NSURL URLWithString:[self generateUrlWithoutAuthToken:url params : parameters]];
    NSURLRequest *request =[NSURLRequest requestWithURL:requestURL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id responseObj = data;
            if(error == nil){
                success(responseObj);
            }
            else{
                fail(responseObj,error);
            }
        });
    }];
    [sessionDataTask resume];
}

-(void)post:(NSString *)url content:(NSString *)jsonStr success:(SuccessCallback)success fail:(FailCallback)fail
{
    NSString *auth_token = [SeattleFeatureExecutor getToken];
    if(IS_NS_STRING_EMPTY(auth_token)){
        //        url = [self generateUrlWithoutAuthToken:url];
    }
    else{
        url = [self generateUrl:url token:auth_token];
    }
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id responseObj = data;
            if(error == nil){
                success(responseObj);
            }
            else{
                fail(responseObj,error);
            }
        });

    }];
    [sessionDataTask resume];
}


-(NSString *)generateUrlWithoutAuthToken : (NSString *)prefixUrl params:(NSMutableDictionary *)parameters
{
    NSString *lac = @"0";
    NSString *cid = @"0";
    NSString *base_id = @"0";
    NSString *auth_token = [SeattleFeatureExecutor getToken];
    NSString *channel_code = [parameters objectForKey:@"_channel_code"];
    NSString *new_account = [parameters objectForKey:@"_new_account"];
    NSString *temp =[NSString stringWithFormat:@"?lac=%@&cid=%@&base_id=%@&auth_token=%@&_channel_code=%@&_new_account=%@",lac,cid,base_id,auth_token,channel_code,new_account];
    
    NSString *result =  [prefixUrl stringByAppendingString:temp];
    result = [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
    
}

-(NSString *)generateUrl : (NSString *)prefixUrl
                   token : (NSString *)token
{
    NSDate *date = [NSDate date];
    NSString *ts =[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    NSString *v = @"1";
    NSString *sign = [self getSignStr:YES url:prefixUrl];
    NSString *temp =[NSString stringWithFormat:@"?_token=%@&_ts=%@&_v=%@&_sign=%@&_appid=%d",token,ts,v,sign,20];
    return [prefixUrl stringByAppendingString:temp];
}


-(NSString *)getSignStr : (Boolean)isPost url : (NSString *)url
{
    NSDate *date = [NSDate date];
    NSString *ts =[NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];

    
    NSMutableString *signString = [NSMutableString string];
    if (isPost) {
        [signString appendString:@"POST"];
    } else {
        [signString appendString:@"GET"];
    }
    [signString appendString:url];
    [signString appendString:@"&"];
    
    NSMutableString *prefixStr = [NSMutableString stringWithString:@"_token="];
    [prefixStr appendString:[SeattleFeatureExecutor getToken]];
    [prefixStr appendString:@"&_ts="];
    [prefixStr appendString:[NSString stringWithFormat:@"%@",ts]];
    [prefixStr appendString:@"&_v="];
    [prefixStr appendString:[NSString stringWithFormat:@"%d",1]];
    
    [signString appendString:prefixStr];
    if ( [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]] ){
        [signString appendString:@"&"];
        [signString appendString:[FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]]];
    }
    return [signString md5_base64];
}


@end
