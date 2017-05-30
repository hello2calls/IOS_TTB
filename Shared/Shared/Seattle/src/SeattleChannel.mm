//
//  SeattleChannel.mm
//  TestSeattle
//
//  Created by Elfe Xu on 13-1-27.
//  Copyright (c) 2013年 Elfe. All rights reserved.
//

#import "IChannel.h"
#import "SeattleChannel.h"
#import "CStringUtils.h"
#import "NetworkUtility.h"
#import "GZipUtils.h"
#import "CooTekServerDef.h"
#import "NSString+MD5.h"
#import <Usage_iOS/GTMBase64.h>
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "ASIHTTPRequest.h"
#import "FunctionUtility.h"
#import "CTKAESCryptor.h"
#import "CTKRSACryptor.h"
#import "NoahManager.h"
#import "DialerUsageRecord.h"
#import "IndexConstant.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"
#import "UsageConst.h"
@interface HttpSender(){
    HttpResponse *response_;
    __strong ASIHTTPRequest *request_;
    double timeoutSetting_;
    
    NSString *_lastUrl;
    NSString *_lastCookie;
    NSString *_lastBody;
    BOOL _lastIfPost;
    HttpRequest *_lastRequest;
}
@end

#define HTTP_RESULT_SUCCESS 200
#define HTTP_RESULT_TIMEOUT 408
#define HTTP_CLIENT_ERROR_MIN 400
#define HTTP_CLIENT_ERROR_MAX 499
#define HTTP_SERVER_ERROR_MIN 500
#define HTTP_SERVER_ERROR_MAX 599

#define DEFAULT_TIMEOUT_IN_SECONDS 30
#define DEFAULT_GZIP_THRESHHOLD 64

#define SECURE_TYPE_ZERO 0
#define SECURE_TYPE_ONE 1
#define SECURE_TYPE_TWO 2
#define SECURE_TYPE_THREE 3
#define SECURE_TYPE_FOUR 4 // security level 3.1

#define DYNAMIC_SERVICE @"DYNAMIC_SERVICE"
#define OPT_DYNAMIC_SERVICE @"OPT_DYNAMIC_SERVICE"
#define STATIC_SERVICE @"STATIC_SERVICE"
#define TOUCHLIFE_SERVICE @"TOUCHLIFE_SERVICE"


class SeattleHttpChannel : public IChannel {
public:
    BOOL useHttps;
public:
    SeattleHttpChannel(BOOL useHttps) {
        this->useHttps = useHttps;
    }
    
    virtual RequestSendResult send(IRequest* request, IResponse* response) const {
        HttpSender *sender = [[HttpSender alloc] initWithRequest:(HttpRequest *)request
                                                        response:(HttpResponse *)response
                                                         useHttps:useHttps
                               ];
        [sender sendRequest];
        TPNUMERIC status = ((HttpResponse *)response)->get_status_code();
        switch (status) {
            case HTTP_RESULT_SUCCESS:
                response->set_valid(YES);
                return kSuccess;
            case HTTP_RESULT_TIMEOUT:
                return kNeedRetry;
            default:
                if (status >= HTTP_CLIENT_ERROR_MIN && status <= HTTP_CLIENT_ERROR_MAX) {
                    response->set_valid(YES);
                    return kSuccess;
                }else if (status >= HTTP_SERVER_ERROR_MIN && status <= HTTP_SERVER_ERROR_MAX) {
                    response->set_valid(YES);
                    return kNeedRetryLater;
                } else {
                    return kUnrecoverableFailure;
                }
        }
    }
};

class SecureChannel : public IChannel {
public:
    int secureType;
public:
    SecureChannel(int secureType) {
        this->secureType = secureType;
    }
    
    virtual RequestSendResult send(IRequest* request, IResponse* response) const {
        HttpSender *sender = [[HttpSender alloc] initWithRequest:(SecureHttpRequest *)request
                                                         response:(SecureHttpResponse *)response
                                                       secureType:secureType
                               ];
        [sender sendRequest];
        TPNUMERIC status = ((SecureHttpResponse *)response)->get_status_code();
        switch (status) {
            case HTTP_RESULT_SUCCESS:
                response->set_valid(YES);
                return kSuccess;
            case HTTP_RESULT_TIMEOUT:
                return kNeedRetry;
            default:
                if (status >= HTTP_CLIENT_ERROR_MIN && status <= HTTP_CLIENT_ERROR_MAX) {
                    response->set_valid(YES);
                    return kSuccess;
                }else if (status > HTTP_SERVER_ERROR_MIN && status <= HTTP_SERVER_ERROR_MAX) {
                    response->set_valid(YES);
                    return kNeedRetryLater;
                } else {
                    return kUnrecoverableFailure;
                }
        }
    }
};


SeattleChannelManager::SeattleChannelManager() {
    httpChannel_ = new SeattleHttpChannel(false);
    httpsChannel_ = new SeattleHttpChannel(true);
    secureZeroChannel = new SecureChannel(0);
    secureOneChannel = new SecureChannel(1);
    secureTwoChannel = new SecureChannel(2);
    secureThreeChannel = new SecureChannel(3);
}


@implementation HttpSender
{
    CTKAESCryptBot *_cryptBot;
    BOOL _haveTriedSecure4;
}

- (id)initWithRequest:(HttpRequest *)request response:(HttpResponse *)response useHttps:(BOOL)useHttps {
    self = [super init];
    if (self) {
        response_ = response;
        _cryptBot = [[CTKAESCryptBot alloc]initWithRandomKey];
        _haveTriedSecure4 = NO;
        
        NSString *format = @"http://%@%@";
        TPNUMERIC port = request->get_port();
        
        if (useHttps) {
            format = @"https://%@%@";
            port = 443;
        }
        NSString *api = CStringUtils::cstr2nsstr(request->get_api().c_str());
        NSString *host = CStringUtils::cstr2nsstr(request->get_host().c_str());
        
        NSString *url = [HttpSender getUrlStringByFormat:format host:host port:port api:api];
        
        NSString *body = CStringUtils::cstr2nsstr(request->get_message_string().c_str());
        NSString *cookie = CStringUtils::cstr2nsstr(request->get_cookie().c_str());
        BOOL isPost = (request->get_method() == kPost);
        timeoutSetting_ = DEFAULT_TIMEOUT_IN_SECONDS;
        
        if (!isPost) {
            url = [NSString stringWithFormat:@"%@%@", url, body];
            body = @"";
        }
        if (ENABLE_AD_DEBUG) {
            if ([api rangeOfString:@"/ad/voip"].location != NSNotFound) {
                url = [url stringByAppendingString:@"&debug=1"];
                cootek_log(@"ad-voip, url: %@", url);
            }
        }
        [UserDefaultsManager setObject:url forKey:USER_POPUP_API];
        request_ = [self generateRequest:url cookie:cookie body:body isPost:isPost request:request];
    }
    return self;
}

- (id)initWithRequest:(SecureHttpRequest *)request response:(SecureHttpResponse *)response secureType:(int)secureType {
    self = [super init];
    if (self) {
        response_ = response;
        _cryptBot = [[CTKAESCryptBot alloc]initWithRandomKey];
        _haveTriedSecure4 = NO;
        
        NSString *format = @"http://%@%@";
        TPNUMERIC port = request->get_port();
        
        BOOL signForTouchLife = NO;
        NSString *host = CStringUtils::cstr2nsstr(request->get_host().c_str());
        NSString *api = CStringUtils::cstr2nsstr(request->get_api().c_str());
        if (secureType == SECURE_TYPE_THREE) {
            format = USE_DEBUG_SERVER ? @"http://%@%@" : @"https://%@%@";
            port = 443;
        }
        if ([host isEqual:TOUCHLIFE_SERVICE] || (USE_DEBUG_SERVER && [api hasPrefix:@"/account/info"])) {
            signForTouchLife = YES;
        }
        NSMutableString *url = [[HttpSender getUrlStringByFormat:format host:host port:port api:api] mutableCopy];
        NSString *body = CStringUtils::cstr2nsstr(request->get_message_string().c_str());
        NSString *cookie = CStringUtils::cstr2nsstr(request->get_cookie().c_str());
        BOOL isPost = (request->get_method() == kPost);
        BOOL needSign = (secureType == SECURE_TYPE_ONE ||secureType == SECURE_TYPE_TWO);
        NSString *token = @"";
        NSArray *strs = [cookie componentsSeparatedByString:@";"];
        NSMutableString *signString = [NSMutableString string];
        if (isPost) {
            [signString appendString:@"POST"];
        } else {
            [signString appendString:@"GET"];
        }
        if (signForTouchLife) {
            [signString appendString:@"&"];
            [signString appendString:api];
        } else {
            [signString appendString:url];
        }
        for (NSString *str in strs) {
            if ([str hasPrefix:@"auth_token="]) {
                token = [str substringWithRange:NSMakeRange(@"auth_token=".length, str.length - @"auth_token=".length)];
            }
        }
        timeoutSetting_ = DEFAULT_TIMEOUT_IN_SECONDS;
        if(![api isEqualToString:@"/auth/login"])
        {
            [url appendString:@"?"];
            NSMutableString *prefixStr = [NSMutableString stringWithString:@"_token="];
            [prefixStr appendString:token];
            [prefixStr appendString:@"&_ts="];
            NSDate *date = [NSDate date];
            long timeInLong = [date timeIntervalSince1970];
            NSLog(@"test time:%ld", timeInLong);
            [prefixStr appendString:[NSString stringWithFormat:@"%d",timeInLong]];
            [prefixStr appendString:@"&_v="];
            NSNumber *version = [NSNumber numberWithLongLong:request->get_version()];
            [prefixStr appendString:[NSString stringWithFormat:@"%@",version]];
            [url appendString:prefixStr];
        
            if (needSign) {
                [signString appendString:@"&"];
                [signString appendString:prefixStr];
                if (!signForTouchLife) {
                    [signString appendString:@"&"];
                    [signString appendString:body];
                }
                NSString *secret = [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
                if (secret != nil){
                    [signString appendString:@"&"];
                    [signString appendString:secret];
                }
                //NSLog(@"test sign11:%@", signString);
                NSString *md5SignStr = [signString md5_base64];
                [url appendString:@"&_sign="];
                [url appendString:[md5SignStr substringToIndex:md5SignStr.length-2]];
                cootek_log(@"SeattleChannel.mm url: %@, signString prepared to be singed: %@", url, signString);
            }
        }
        
        if (!isPost) {
            if ([body hasPrefix:@"?"]) {
                body = [body stringByReplacingOccurrencesOfString:@"?" withString:@"&"];
            }
            url = [NSMutableString stringWithFormat:@"%@%@",url,body];
            body = @"";
        }
        [UserDefaultsManager setObject:url forKey:USER_POPUP_API];
        request_ = [self generateRequest:url cookie:cookie body:body isPost:isPost request:request];
    }
    return self;
}

- (BOOL)createSecure4Request
{
    NSURLComponents *newUrl = [NSURLComponents componentsWithString:_lastUrl];
    NSMutableString *newQuery = [[NSMutableString alloc] init];
    NSString *newBody = @"";
    
    if (newUrl.query) {
        NSString *encryptedQuery = [_cryptBot aes128ECBEncryptGTMBase64String:newUrl.query];
        if (!encryptedQuery) {
            return NO;
        }
        [newQuery appendString:@"_query="];
        [newQuery appendString:encryptedQuery];
    }
    if (_lastBody.length != 0) {
        newBody = [_cryptBot aes128ECBEncryptGTMBase64String:_lastBody];
        if (!newBody) {
            return NO;
        }
    }
    
    NSString * encryptedAESKey = [_cryptBot getEncryptedAESKey];
    if (!encryptedAESKey) {
        return NO;
    }
    if (newQuery.length > 0) {
        [newQuery appendString:@"&"];
    }
    [newQuery appendString:@"_rand="];
    [newQuery appendString:encryptedAESKey];
    newUrl.query = newQuery;
    newUrl.scheme = @"http";
    newUrl.port = @80;
    cootek_log(@"modified url is %@", newUrl.URL.absoluteString);

    request_ = [self generateRequest:newUrl.URL.absoluteString cookie:_lastCookie body:newBody isPost:_lastIfPost request:_lastRequest];
    _haveTriedSecure4 = YES;
    return YES;
}

- (ASIHTTPRequest *) generateRequest:(NSString *)url cookie:(NSString *)cookie body:(NSString *)body isPost:(BOOL)isPost request:(HttpRequest*) request{
    _lastUrl = url;
    _lastCookie = cookie;
    _lastBody = body;
    _lastIfPost = isPost;
    _lastRequest = request;
    
    //        request_ = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
    //                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
    //                                             timeoutInterval:timeoutSetting_];
    ASIHTTPRequest *requestNow = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    if ([cookie length] > 0) {
        //            [request_ addValue:cookie forHTTPHeaderField:@"Cookie"];
        [requestNow addRequestHeader:@"Cookie" value:cookie];
    }
    if ([[requestNow.url absoluteString] rangeOfString:@"ad/voip"].length>0) {
        cootek_log(@"%@",[FunctionUtility getWebViewUserAgent]);
        [requestNow addRequestHeader:@"User-Agent" value:[FunctionUtility getWebViewUserAgent]];
    }
    NSLog(@"request = %@, cookie = %@ body = %@ ", url, cookie, body);
    
    if (ENABLE_STATISTIC_NETWORK_INFO) {
        NSString *info = [NSString stringWithFormat:@"request = %@, cookie = %@ body = %@ ", url, cookie, body];
        [DialerUsageRecord recordpath:PATH_NETWORK_INFO kvs:Pair(INFO_REQUEST, info), nil];
    }
    
    if(isPost) {
        //            [request_ setHTTPMethod:@"POST"];
        [requestNow setRequestMethod:@"POST"];
        NSMutableData *postBody = [[NSMutableData alloc] initWithCapacity:1];
        [postBody appendData:[body dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion:YES]];
        
        if (postBody.length > DEFAULT_GZIP_THRESHHOLD && request->allow_zip()) {
            //                [request_ addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
            //                [request_ setHTTPBody:[postBody gzipDeflate]];
            [requestNow addRequestHeader:@"Content-Encoding" value:@"gzip"];
            [requestNow appendPostData:[postBody gzipDeflate]];
        } else {
            //                [request_ setHTTPBody:postBody];
            [requestNow appendPostData:postBody];
        }
    } else {
        //            [request_ setHTTPMethod:@"GET"];
        [requestNow setRequestMethod:@"GET"];
    }
    
    //        [request_ addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    //        [request_ setTimeoutInterval:timeoutSetting_];
    [requestNow addRequestHeader:@"Accept-Encoding" value:@"gzip"];
    [requestNow setTimeOutSeconds:timeoutSetting_];
    
    return requestNow;
}


+ (NSString *) getUrlStringByFormat:(NSString *)format host:(NSString *) host port:(TPNUMERIC) port api:(NSString *)api {
    //first, we set values under the release condition.
    BOOL isHttps = [format rangeOfString:@"https"].location != NSNotFound;
    if ([host isEqualToString:DYNAMIC_SERVICE]) {
        host = COOTEK_DYNAMIC_SERVICE_HOST;
    }
    if ([host isEqualToString:OPT_DYNAMIC_SERVICE]) {
        host = COOTEK_OPT_DYNAMIC_SERVICE_HOST;
    }
    if ([host isEqualToString:STATIC_SERVICE]) {
        host = COOTEK_STATIC_SERVICE_HOST;
    }
    if ([host isEqualToString:TOUCHLIFE_SERVICE]) {
        host = COOTEK_DYNAMIC_LIFE_SERVICE;
    }
    
    //then, we check for debugging settings
    if (USE_DEBUG_SERVER) {
        if (!NOAH_LOCAL_DEBUG){
            host = @"docker-ws2.cootekservice.com";
        } else {
            host = VOIP_DEDUG_SERVER_HOST;
            port = isHttps? VOIP_DEBUG_HTTPS_PORT: VOIP_DEBUG_HTTP_PORT;
        }
        
        //customize your settings by checking your `api`
        
        if (ENABLE_YP_DEBUG && [api rangeOfString:@"/yellowpage_v3/ad_reward"].location != NSNotFound) {
            host = YP_DEBUG_SERVER_HOST;
            port = isHttps? YP_DEBUG_HTTPS_PORT: YP_DEBUG_HTTP_PORT;
        }
    }
    if (ENABLE_AD_DEBUG && [api rangeOfString:@"/ad/voip"].location != NSNotFound) {
        host = AD_DEBUG_SERVER_HOST;
        port = isHttps? AD_DEBUG_HTTPS_PORT: AD_DEBUG_HTTP_PORT;
    }
    if (!api) {
        api = @"";
    }
    NSString *hostAndPort = [NSString stringWithFormat:@"%@:%d", host, port];
    NSString *url = [NSString stringWithFormat:format, hostAndPort, api];
    cootek_log(@"SeattleChannel getUrlStringByFormat] url:%@, host:%@, port:%@, api:%@, hostAndPort:%@",
               url, host, @(port).description, api, hostAndPort);
    return url;
}

- (void)sendRequest {
    [self sendRequestPrivate];
}


- (BOOL)ifNeedRerequest:(NSInteger)status{
    if ( status != HTTP_RESULT_SUCCESS && status != HTTP_RESULT_TIMEOUT && status != HTTP_SERVER_ERROR_MIN )
        return YES;
    return NO;
}

- (NSInteger) requestByProxy:(NSInteger)originStatus{
    NSArray *proxyArray = (NSArray *)[UserDefaultsManager objectForKey:SEATTLE_PROXY_DICTIONARY];
    if ( proxyArray == nil  || [proxyArray count] == 0 )
        return originStatus;
    NSInteger status;
    for ( NSString *urlString in proxyArray ){
        ASIHTTPRequest *requestNow = [self generateRequest:_lastUrl cookie:_lastCookie body:_lastBody isPost:_lastIfPost request:_lastRequest];
        [requestNow setProxyHost:urlString];
        [requestNow setProxyPort:8080];
        [requestNow startSynchronous];
        status = [requestNow responseStatusCode];
        if ( ![self ifNeedRerequest:status] ){
            request_ = requestNow;
            break;
        }
    }
    return status;
}


- (void)sendRequestPrivate{
    
//    NSData* returnData = [NetworkUtility sendSafeSynchronousRequest:request_ returningResponse:&urlResponse error:nil];

    [request_ startSynchronous];

    
    int status=[request_ responseStatusCode];

    if ( [self ifNeedRerequest:status] ){
        status = [self requestByProxy:status];
    }
    
    NSData* returnData = [request_ responseData];
    if (_haveTriedSecure4) {
        returnData = [_cryptBot aes128ECBDecryptWithData:[GTMBase64 webSafeDecodeData:returnData]];
    }
    
    response_->set_status_code(status);
    
    NSString *responseString=[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"api = %@, status = %d, header = %@, response string = %@", CStringUtils::cstr2nsstr(_lastRequest->get_api().c_str()),
          status, [request_ responseHeaders], responseString);
    if (responseString.length>0 &&
        ([responseString rangeOfString:@"4003"].length>0||[responseString rangeOfString:@"4001"].length>0)){
        NSString *token = [SeattleFeatureExecutor getToken];
        NSString *info = [NSString stringWithFormat:@"api = %@, status = %d, header = %@, response string = %@, token = %@", CStringUtils::cstr2nsstr(_lastRequest->get_api().c_str()),
                          status, [request_ responseHeaders], responseString,token];
        cootek_log(@"Request message info %@ ",info);
        [DialerUsageRecord recordpath:PATH_RELOGIN kvs:Pair(API_ERROR_LOGOUT_INFO, info), nil];
    }
    
    if(ENABLE_STATISTIC_NETWORK_INFO) {
        NSString *info = [NSString stringWithFormat:@"api = %@, status = %d, header = %@, response string = %@", CStringUtils::cstr2nsstr(_lastRequest->get_api().c_str()),
                          status, [request_ responseHeaders], responseString];
        [DialerUsageRecord recordpath:PATH_NETWORK_INFO kvs:Pair(INFO_RESPONSE, info), nil];
    }
    
    if ([responseString length]>0 &&
        (status == HTTP_RESULT_SUCCESS||
         (status >= HTTP_CLIENT_ERROR_MIN && status <= HTTP_CLIENT_ERROR_MAX)))
    {
        response_->set_message_string(CStringUtils::nsstr2cstr(responseString));
        NSDictionary *headers = [request_ responseHeaders];
        NSString *cookie = [headers objectForKey:@"Set-Cookie"];
        if ([cookie length] > 0) {
            response_->set_cookie(CStringUtils::nsstr2cstr(cookie));
        }
    }
    else
    {
        if ([request_.url.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame && !_haveTriedSecure4) {
            if ([request_.url.path isEqualToString:@"/auth/login"] && [self createSecure4Request]) {
                return [self sendRequestPrivate];
            }
        }
        response_->set_status_code(HTTP_RESULT_TIMEOUT);
    }
    [UserDefaultsManager setIntValue:status forKey:USER_POPUP_RESULT];
    [UserDefaultsManager setObject:responseString forKey:USER_POPUP_RESPONSE];
}

@end
