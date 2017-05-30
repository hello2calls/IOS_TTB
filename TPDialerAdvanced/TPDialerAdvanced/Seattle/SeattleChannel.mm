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

@interface HttpSender(){
    HttpResponse *response_;
    NSMutableURLRequest *request_;
    volatile BOOL isReturnData_;
    double timeoutSetting_;
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

class SeattleHttpChannel : public IChannel {
public:
    BOOL useHttps;
public:
    SeattleHttpChannel(BOOL useHttps) {
        this->useHttps = useHttps;
    }
    
    virtual RequestSendResult send(IRequest* request, IResponse* response) const {
        HttpSender *sender = [[[HttpSender alloc] initWithRequest:(HttpRequest *)request
                                                        response:(HttpResponse *)response
                                                         useHttps:useHttps
                               ] autorelease];
        [sender sendRequest];
        TPNUMERIC status = ((HttpResponse *)response)->get_status_code();
        switch (status) {
            case HTTP_RESULT_SUCCESS:
                response->set_valid(YES);
                return kSuccess;
            case HTTP_RESULT_TIMEOUT:
                return kNeedRetry;
            default:
                if (status >= HTTP_SERVER_ERROR_MIN && status <= HTTP_SERVER_ERROR_MAX) {
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
}

@implementation HttpSender

- (id)initWithRequest:(HttpRequest *)request response:(HttpResponse *)response useHttps:(BOOL)useHttps {
    self = [super init];
    if (self) {
        response_ = response;
        
        NSString *format = format = @"http://%@%@";
        TPNUMERIC port = request->get_port();
        
        if (useHttps) {
            format = @"https://%@%@";
            port = 443;
        }         
        
        NSString *url = [NSString stringWithFormat:format,
                         [HttpSender hostUrlForUrl:CStringUtils::cstr2nsstr(request->get_host().c_str())
                                              port:port],
                                      CStringUtils::cstr2nsstr(request->get_api().c_str())
                         ];
        
        NSString *body = CStringUtils::cstr2nsstr(request->get_message_string().c_str());
        NSString *cookie = CStringUtils::cstr2nsstr(request->get_cookie().c_str());
        BOOL isPost = (request->get_method() == kPost);
        timeoutSetting_ = DEFAULT_TIMEOUT_IN_SECONDS;
        
        if (!isPost) {
            url = [NSString stringWithFormat:@"%@%@", url, body];
            body = @"";
        }
        
        request_ = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                 timeoutInterval:timeoutSetting_] autorelease];
        
        if ([cookie length] > 0) {
            [request_ addValue:cookie forHTTPHeaderField:@"Cookie"];
        }
        
       cootek_log(@"request = %@, cookie = %@ body = %@ ", url, cookie, body);
        
        if(isPost) {
            [request_ setHTTPMethod:@"POST"];
            NSMutableData *postBody = [[[NSMutableData alloc] initWithCapacity:1] autorelease];
            [postBody appendData:[body dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion:YES]];
            
            if (postBody.length > DEFAULT_GZIP_THRESHHOLD && request->allow_zip()) {
                [request_ addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
                [request_ setHTTPBody:[postBody gzipDeflate]];
            } else {
                [request_ setHTTPBody:postBody];
            }
        } else {
            [request_ setHTTPMethod:@"GET"];
        }
        
        [request_ addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [request_ setTimeoutInterval:timeoutSetting_];
    }
    return self;
}

+ (NSString *)hostUrlForUrl:(NSString *)url port:(TPNUMERIC)port {
    BOOL useTestForDynamic = NO;
    BOOL useTestForStatic = NO;
    
    if ([url rangeOfString:COOTEK_DYNAMIC_SERVICE_HOST].length > 0 && useTestForDynamic) {
        return @"58.32.229.109:8081";        
    }
    
    if ([url rangeOfString:COOTEK_STATIC_SERVICE_HOST].length > 0 && useTestForStatic) {
        return COOTEK_STATIC_SERVICE_HOST_TEST;
    }
    
    return [NSString stringWithFormat:@"%@:%d", url, (NSInteger)port];
}

- (void)sendRequest {
    NSDate *timeDate =[NSDate date];
	NSInteger intervalTime = 0;
	[NSThread detachNewThreadSelector:@selector(sendRequestPrivate) toTarget:self withObject:nil];
	while (isReturnData_ == NO && intervalTime < timeoutSetting_) {
		intervalTime = [[NSDate date] timeIntervalSinceDate:timeDate];
		sleep(1);
	}
	if (isReturnData_ == NO) {
		response_->set_status_code(HTTP_RESULT_TIMEOUT);
		[NSURLConnection canHandleRequest:request_];
	}
}

- (void)sendRequestPrivate{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSHTTPURLResponse *urlResponse=[[[NSHTTPURLResponse alloc] init] autorelease];
    
    NSData* returnData = [NetworkUtility sendSafeSynchronousRequest:request_ returningResponse:&urlResponse error:nil];
	int status=[urlResponse statusCode];
    
	response_->set_status_code(status);
    
	NSString *responseString=[[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    
    cootek_log(@"status = %d, header = %@, response string = %@", status, [urlResponse allHeaderFields], responseString);
    
    if (status == HTTP_RESULT_SUCCESS) {
		if ([responseString length]>0)
        {
            response_->set_message_string(CStringUtils::nsstr2cstr(responseString));
		}
        
        NSDictionary *headers = [urlResponse allHeaderFields];
        NSString *cookie = [headers objectForKey:@"Set-Cookie"];
        if ([cookie length] > 0) {
            response_->set_cookie(CStringUtils::nsstr2cstr(cookie));
        }
	}
    
	isReturnData_ = YES;
	[pool release];
}

- (void)dealloc{
	[super dealloc];
}
@end
