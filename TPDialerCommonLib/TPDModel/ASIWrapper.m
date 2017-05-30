//
//  ASIWrapper.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/14.
//
//

#import "ASIWrapper.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TPDLib.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface ASIWrapper()
@property (nonatomic) double lastCalledDate;
@end

@implementation ASIWrapper

+(ASIWrapper*)defaultWrapperObject{
    ASIWrapper* ret = [[ASIWrapper alloc] init];
    
    ret.cache = nil;
    ret.cacheTimeInSecond = -1; //默认不cache
    ret.params = [NSMutableDictionary dictionary];
    ret.success = NO;
    ret.obligeUsingMultiform = NO;
    
    return ret;
    
    
}

-(void)resolve{
    self.responseStruct = [[self.cache tpd_JSONValue] valueForKey:self.responseStructKey];
}


+(BOOL)hitInCache:(ASIWrapper*)wrapper{
    
    NSArray* arr = [ASIWrapper searchWithSQL:[NSString stringWithFormat:@"select * from ASIWrapper where pathStr=\'%@\' and params = \'%@\' and method = \'%@\'", wrapper.pathStr, [wrapper.params tpd_JSONRepresentation], wrapper.method]];
    if (arr.count > 0) {
        ASIWrapper* tmp = [arr firstObject];
        if ([[NSDate date] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:tmp.lastCalledDate ] ] < wrapper.cacheTimeInSecond) {
            wrapper.cache = tmp.cache;
            wrapper.success = YES;
            return YES;
        }
    }
    return NO;
}

// 只有在请求成功时才调用
+(void)updateCache:(ASIWrapper*)wrapper{
    [ASIWrapper deleteWithWhere:[NSString stringWithFormat:@"pathStr=\'%@\' and params = \'%@\' and method = \'%@\'", wrapper.pathStr, [wrapper.params tpd_JSONRepresentation], wrapper.method]];
    wrapper.lastCalledDate = [[NSDate date] timeIntervalSince1970];
    [wrapper saveToDB];
}


+ (NSString *) createParamString:(NSDictionary*)params
{
    if (params==nil) {
        return @"";
    }
    NSString *result = @"";
    for (NSString* key in params.allKeys) {
        result = [result stringByAppendingFormat:@"%@=%@&", key, [params valueForKey:key]];
    }
    if ([result length] >= 2){
        result = [result substringToIndex:[result length] - 1];
        result = [@"?" stringByAppendingString:result];
    }
    return [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
}

+(NSData*)downloadFile:(NSString*)url{
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
    wrapper.pathStr = url;
    wrapper.method = @"GET";
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:wrapper.pathStr]];
    [request setAllowCompressedResponse:YES]; //默认是YES
    [request setTimeOutSeconds:20];
    [request startSynchronous];
    
    NSError* error = [request error];
    if (!error) {
        wrapper.binary = [request responseData];
        return wrapper.binary;
    }
    
    return nil;
}

- (ASIWrapper *)refresh {
    if (!self.isDataFromCache) return self;
    self.cacheTimeInSecond = -1;
    if ([self.method isEqualToString:@"GET"]) {
        [ASIWrapper getRequest:self];
    }
    return self;
}

+(void)getRequest:(ASIWrapper*)wrapper{
    wrapper.method = @"GET";
    
    if ([ASIWrapper hitInCache:wrapper]) {
        // 命中，wrapper中信息已更新可直接返回
        [wrapper resolve];
        wrapper.isDataFromCache = YES;
        return;
    }else{
        NSString* urlFullPath = [NSString stringWithFormat:@"%@%@",wrapper.pathStr, [ASIWrapper createParamString:wrapper.params]];;

        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
        [request setAllowCompressedResponse:YES]; //默认是YES
        [request setTimeOutSeconds:20];
        [request startSynchronous];
        
        NSError* error = [request error];
        if (!error) {
            NSDictionary *dic = [[request responseString] tpd_JSONValue];
            // dic != nil是为了预防404
            if (dic != nil) {
                wrapper.success = YES;
                wrapper.cache =[request responseString];
                [wrapper resolve];
                wrapper.isDataFromCache = NO;
                // 请求成功则更新cache
                [ASIWrapper updateCache:wrapper];
            }
            else{
                
                wrapper.success = NO;
            }
            
        }else{
            wrapper.success = NO;
            wrapper.errInfo = [ASIWrapper resolveError:error];
        }
    }
    
    
    return;
    
}

+(void)postRequest:(ASIWrapper*)wrapper{
    [self request:wrapper method:@"POST"];
}

//NSData* d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpeg"]];
//[ASIWrapper nameCardPost:d];
+(ASIWrapper*)nameCardPost:(NSData*)fileContent{
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
    
    wrapper.params = @{
                       @"PIN":@"hui.huang",
                       @"user":@"hui.huang@cootek.cn",
                       @"pass":@"3XPFEBKB73BMYMN6",
                       @"json":@"1",
                       @"lang":@"15",
                       @"size":@(fileContent.length),
                       };
    wrapper.method = @"POST";
    
    NSString* paramStr = [ASIWrapper createParamString:wrapper.params];
    wrapper.pathStr = [NSString stringWithFormat:@"http://bcr1.intsig.net/BCRService/BCR_VCF2%@",paramStr];

    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:wrapper.pathStr]];
    
    [request setPostBody:[fileContent mutableCopy]];
    
    [request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:20];
    [request startSynchronous];
    
    NSError* error = [request error];
    if (!error) {
        NSDictionary *dic = [[request responseString] tpd_JSONValue];
        if (dic != nil) {
            wrapper.success = YES;
            wrapper.cache =[request responseString];
            wrapper.isDataFromCache = NO;
        }
        else{
            
            wrapper.success = NO;
            wrapper.errInfo = [request responseString];
        }
        
    }else{
        wrapper.success = NO;
        wrapper.errInfo = [ASIWrapper resolveError:error];
    }
    
}

// warning: 不适用与GET请求
+(void)request:(ASIWrapper*)wrapper method:(NSString *)method{
    wrapper.method = method;
    
    NSString* urlFullPath = wrapper.pathStr;
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlFullPath]];
    
    if (wrapper.obligeUsingMultiform) {
        
        for (NSString* key in wrapper.params.allKeys) {
            id value = wrapper.params[key];
            if ([value isKindOfClass:[NSData class]]) {
                [request addData:value forKey:key];
            }else{
                [request addPostValue:value forKey:key];
            }
        }
        [request setPostFormat:ASIMultipartFormDataPostFormat];
    }else{
        NSString *parameterString = [wrapper.params tpd_JSONRepresentation];
        NSMutableData *parameterData = [[parameterString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        [request setPostBody:parameterData];
        
    }
    
    
    [request setAllowCompressedResponse:YES];
    [request setTimeOutSeconds:20];
    [request startSynchronous];
    
    NSError* error = [request error];
    if (!error) {
        NSDictionary *dic = [[request responseString] tpd_JSONValue];
        if (dic != nil &&[[dic valueForKey:@"status"] integerValue] == 0) {

        }
        else{

            wrapper.success = NO;
        }
        
    }else{
        wrapper.success = NO;
        wrapper.errInfo = [ASIWrapper resolveError:error];
    }
    
}

+(NSString*)resolveError:(NSError*)error{
    
    switch (error.code) {
        case ASIConnectionFailureErrorType:
            
            break;
        case ASIRequestTimedOutErrorType:
            
            break;
        default:
            
            break;
    }
    return @"";
}



#pragma mark - 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}
+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}
+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
@end


