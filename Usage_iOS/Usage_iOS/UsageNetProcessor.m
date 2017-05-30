
//
//  NetProcessor.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-28.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import "UsageNetProcessor.h"
#import <AFNetworkOperation/AFNetworking.h>
#import <AFNetworkOperation/AFGZipUtils.h>
#import "EncodeUtil.h"

NSString * const HTTP = @"http://";
NSString * const HTTPS = @"https://";
NSString * const APPEND = @"/statistic/usage?type=";
NSString * const AUTHTOKEN_APPEND = @"auth_token=\"";
NSString * const SERVER_TIMESTAMEP_ARG = @"&send_time=";
@implementation UsageNetProcessor
{
    NSMutableArray *mUsages;
    NSString *mType;
    NSString *mURL;
    int mRetryTimes;
    AFHTTPClient *httpClient;
    NSString *appending;
    NSDictionary *parameters;
    BOOL mUseEncrypt;
}

- (id)initWithUsages:(NSMutableArray *)usages
                type:(NSString *)type
       andUseEncrypt:(BOOL)useEncrypt {
    if (self = [super init]) {
        mUsages = usages;
        mURL = [[UsageRecorder sAssist] getServerAddress];
        mType = type;
        mRetryTimes = [[UsageRecorder sAssist] getRetryTimes];
        mUseEncrypt = useEncrypt;
    }
    return self;
}

- (void)sendWithBlock:(void(^)(NSMutableArray *saveArray, BOOL res, NSString *type))block {
    if ([mUsages count] == 0) {
        block(mUsages, YES, mType);
        return;
    }
    if ([[UsageRecorder sAssist] getToken] == nil) {
        [[UsageRecorder sAssist] tokenInvalid: TOKEN_NEED_UPDATE];
        return;
    }
    NSString *baseURL = [[UsageRecorder sAssist] useHttps]?HTTPS:HTTP;
    NSRange range = [mURL rangeOfString:@"/"];
    if (range.location == -1 || range.length == 0) {
        baseURL = [baseURL stringByAppendingString:mURL];
        baseURL = [baseURL stringByAppendingString:@":"];
        baseURL = [baseURL stringByAppendingString:[[UsageRecorder sAssist] useHttps]?
                        [NSString stringWithFormat:@"%d", [[UsageRecorder sAssist] getHttpsPort]]:
                        [NSString stringWithFormat:@"%d", [[UsageRecorder sAssist] getHttpPort]]];
        appending = [APPEND stringByAppendingString:mType];
    } else {
        NSString *str1 = [mURL substringToIndex:range.location];
        NSString *str2 = [mURL substringFromIndex:range.location];
        baseURL = [baseURL stringByAppendingString:str1];
        baseURL = [baseURL stringByAppendingString:@":"];
        baseURL = [baseURL stringByAppendingString:[[UsageRecorder sAssist] useHttps]?
                        [NSString stringWithFormat:@"%d", [[UsageRecorder sAssist] getHttpsPort]]:
                        [NSString stringWithFormat:@"%d", [[UsageRecorder sAssist] getHttpPort]]];
        appending = [str2 stringByAppendingString:[APPEND stringByAppendingString:mType]];
    }
    NSString *newAppending = [appending stringByAppendingString:[NSString stringWithFormat:@"%@%lld",SERVER_TIMESTAMEP_ARG,(long long)[[UsageSettings getInst] getCurrentTime]]];
    appending = newAppending;
    
    //To generete the baseURL.
    NSURL *url = [NSURL URLWithString:baseURL];
    #ifdef DEBUG
    NSLog(@"URL: %@", [baseURL stringByAppendingString:appending]);
    #endif
    
    
    NSString *token = [[NSString alloc] initWithFormat:@"%@%@\"" ,AUTHTOKEN_APPEND,[[UsageRecorder sAssist] getToken]];
    httpClient = [AFHTTPClient clientWithBaseURL:url];
    [httpClient setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
    [httpClient setDefaultHeader:@"Cookie"
                           value:token];
    [httpClient setDefaultHeader:@"Content-Encoding" value:@"gzip"];
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:mUsages
                                                    options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"body string : %@", [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
    if (mUseEncrypt) {
        NSData *key = [EncodeUtil generateKey];
        parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[EncodeUtil encryptRSA:key], @"data_key", [EncodeUtil encryptAESWithData:bodyData andKey:key], @"data_encode",nil];
    } else {
        parameters = [[NSDictionary alloc] initWithObjectsAndKeys:mUsages, @"data", nil];
    }
    httpClient.parameterEncoding = AFGzipParameterEncoding;
    if ([[UsageRecorder sAssist] useHttps]) {
        httpClient.allowsInvalidSSLCertificate = YES;
    }
    
    #ifdef DEBUG
    NSData *param = [NSJSONSerialization dataWithJSONObject:parameters
                                                    options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"Body: %@", [[NSString alloc] initWithData:param encoding:NSUTF8StringEncoding]);
    #endif
    [self executeRequest:0 withBlock:block];
}

- (void)executeRequest:(int)alreadyRetry withBlock:(void(^)(NSMutableArray *saveArray, BOOL res, NSString *type))block{
    //执行POST请求
    [httpClient postPath:appending parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSData *data = (NSData *) responseObject;
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (!data) {
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
        NSNumber *errorCode = (NSNumber *)[dict objectForKey:@"error_code"];
        #ifdef DEBUG
        NSLog(@"errorcode: %d", [errorCode intValue]);
        #endif
        switch ([errorCode intValue]) {
            case 0:
                #ifdef DEBUG
                NSLog(@"Upload succeed");
                #endif
                block(mUsages, YES, mType);
                break;
            case 1000:
                #ifdef DEBUG
                NSLog(@"Input error.");
                #endif
                block(mUsages, YES, mType);
                break;
            case 1001:
                #ifdef DEBUG
                NSLog(@"Token have no working.");
                #endif
                block(mUsages, NO, mType);
                [[UsageRecorder sAssist] tokenInvalid: TOKEN_NOWORKING];
                break;
            case 1002:
                #ifdef DEBUG
                NSLog(@"Token need update.");
                #endif
                block(mUsages, NO, mType);
                [[UsageRecorder sAssist] tokenInvalid: TOKEN_NEED_UPDATE];
                break;
            case 1003:
                #ifdef DEBUG
                NSLog(@"Need history.");
                #endif
                block(mUsages, NO, mType);
                break;
            case 1004:
                #ifdef DEBUG
                NSLog(@"Try again later.");
                #endif
                block(mUsages, NO, mType);
                break;
            default:
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        #ifdef DEBUG
        NSLog(@"error : %@",[error description]);
        #endif
        if (alreadyRetry < mRetryTimes) {
            [self executeRequest:alreadyRetry+1 withBlock:block];
            #ifdef DEBUG
            NSLog(@"retry : %d",alreadyRetry);
            #endif
        } else {
            block(mUsages, NO, mType);
        }
    }];
}
@end