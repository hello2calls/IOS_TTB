//
//  SSPStat.m
//  TouchPalDialer
//
//  Created by tanglin on 16/6/14.
//
//

#import "SSPStat.h"
#import "IndexConstant.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"
#import "LocalStorage.h"
#import "UpdateService.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"
#import "NSString+MD5.h"
#import "NSDataEx.h"
#import "NetworkUtil.h"
#import "CTUrl.h"
#import <Usage_iOS/GTMBase64.h>

SSPStat *ssps_instance_ = nil;
@implementation SSPStat

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mSCached = [NSMutableDictionary new];
    }
    return self;
}

+ (void)initialize
{
    ssps_instance_ = [SSPStat new];
}

+ (instancetype) instance
{
    return ssps_instance_;
}

- (void) saveSWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andS:(NSString*)s
{
    NSString* key = [NSString stringWithFormat:@"%d%d",sspid, tu];
    [_mSCached setObject:s forKey:key];
}

- (NSString *) getSWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu
{
    NSString* key = [NSString stringWithFormat:@"%d%d",sspid, tu];
    return [_mSCached objectForKey:key];
}

- (NSString *)generateRequestUrl:(NSInteger)sspid :(NSInteger)tu :(NSInteger)adn :(NSString*)placementId :(NSString *)ftu
{
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = YP_DEBUG_SSP_URL;
    } else {
        url = YP_SSP_URL;
    }
   
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    NSString* s = [[NSString stringWithFormat:@"%@%@%d%d",time, token, tu, sspid] MD5Hash];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:@"1" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",sspid] forKey:@"sspid"];
    [params setObject:[NSString stringWithFormat:@"%@",placementId ? placementId : @""] forKey:@"placement_id"];
    [params setObject:@"2" forKey:@"product"];
    [params setObject:s forKey:@"s"];
    [params setObject:[NSString stringWithFormat:@"%d", tu] forKey:@"tu"];
    [params setObject:token forKey:@"token"];
    [params setObject:[NSString stringWithFormat:@"%d", adn] forKey:@"adn"];
    [params setObject:time forKey:@"prt"];
    [params setObject:[DialerUsageRecord getClientNetWorkType] forKey:@"nt"];
    [params setObject:[FunctionUtility getIpAddress] forKey:@"ip"];
    [params setObject:CURRENT_TOUCHPAL_VERSION forKey:@"v"];
    [params setObject:COOTEK_APP_NAME forKey:@"ch"];
    if (ftu) {
        [params setObject:ftu forKey:@"ftu"];
    }
    
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    return url;
}

- (NSString *)generateFilledUrl:(NSInteger)sspid :(NSInteger)tu :(NSInteger)adn :(NSString*)s andFtu:(NSString *)ftu
{
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = YP_DEBUG_SSP_URL;
    } else {
        url = YP_SSP_URL;
    }
    
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:@"2" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",sspid] forKey:@"sspid"];
    [params setObject:@"2" forKey:@"product"];
    if (s) {
        [params setObject:s forKey:@"s"];
    }
    if (ftu) {
        [params setObject:ftu forKey:@"ftu"];
    }
    [params setObject:[NSString stringWithFormat:@"%d", tu] forKey:@"tu"];
    [params setObject:token forKey:@"token"];
    [params setObject:[NSString stringWithFormat:@"%d", adn] forKey:@"adn"];
    [params setObject:time forKey:@"prt"];
    
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    return url;
}

- (NSString *)generateEdUrl:(NSInteger)sspid :(NSInteger)tu :(NSInteger)rank :(NSInteger)expid  :(NSString*)title :(NSString*)desc :(NSString*)s :(NSString*)ftu
{
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = YP_DEBUG_SSP_URL;
    } else {
        url = YP_SSP_URL;
    }
   
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
 
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    NSData* titleNs =[GTMBase64 encodeData:[title dataUsingEncoding:NSUTF8StringEncoding]];
    NSData* descNs = [GTMBase64 encodeData:[desc dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* titleBase64 = [[NSString alloc] initWithData:titleNs encoding:NSUTF8StringEncoding];
    NSString* descBase64 = [[NSString alloc] initWithData:descNs encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:@"3" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",sspid] forKey:@"sspid"];
    [params setObject:@"2" forKey:@"product"];
    if (s) {
        [params setObject:s forKey:@"s"];
    }
    [params setObject:[NSString stringWithFormat:@"%d", tu] forKey:@"tu"];
    [params setObject:token forKey:@"token"];
    [params setObject:time forKey:@"prt"];
    [params setObject:[NSString stringWithFormat:@"%d", rank] forKey:@"rank"];
    [params setObject:[NSString stringWithFormat:@"%d", expid] forKey:@"expid"];
    
    if (titleBase64.length > 0) {
        [params setObject:titleBase64 forKey:@"title"];
    }
    
    if (descBase64.length > 0) {
        [params setObject:descBase64 forKey:@"desc"];
    }
    
    if (ftu) {
        [params setObject:ftu forKey:@"ftu"];
    }
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    return url;
}


- (NSString *)generateClickUrl:(NSInteger)sspid :(NSInteger)tu :(NSInteger)rank :(NSString*)s :(NSString* )ftu
{
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = YP_DEBUG_SSP_URL;
    } else {
        url = YP_SSP_URL;
    }
    
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:@"4" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",sspid] forKey:@"sspid"];
    [params setObject:@"2" forKey:@"product"];
    if (s) {
        [params setObject:s forKey:@"s"];
    }
    if (ftu) {
        [params setObject:ftu forKey:@"ftu"];
    }
    [params setObject:[NSString stringWithFormat:@"%d", tu] forKey:@"tu"];
    [params setObject:token forKey:@"token"];
    [params setObject:time forKey:@"prt"];
    [params setObject:[NSString stringWithFormat:@"%d", rank] forKey:@"rank"];
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    return url;
}

+ (NSURLRequest *)urlRequest:(NSString *)url
{
    NSString *parseUrl = [CTUrl encodeRequestUrl:url];
    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc]initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    return httpRequest;
}


- (NSString *) requestWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn andPlacementId:(NSString*)placementId
{
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = YP_DEBUG_SSP_URL;
    } else {
        url = YP_SSP_URL;
    }
    
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    NSString* s = [[NSString stringWithFormat:@"%@%@%d%d",time, token, tu, sspid] MD5Hash];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:@"1" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",sspid] forKey:@"sspid"];
    [params setObject:[NSString stringWithFormat:@"%@",placementId ? placementId : @""] forKey:@"placement_id"];
    [params setObject:@"2" forKey:@"product"];
    [params setObject:s forKey:@"s"];
    [params setObject:[NSString stringWithFormat:@"%d", tu] forKey:@"tu"];
    [params setObject:token forKey:@"token"];
    [params setObject:[NSString stringWithFormat:@"%d", adn] forKey:@"adn"];
    [params setObject:time forKey:@"prt"];
    [params setObject:[DialerUsageRecord getClientNetWorkType] forKey:@"nt"];
    [params setObject:[FunctionUtility getIpAddress] forKey:@"ip"];
    [params setObject:CURRENT_TOUCHPAL_VERSION forKey:@"v"];
    [params setObject:COOTEK_APP_NAME forKey:@"ch"];
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
    
    return s;
}

- (NSString *) requestWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn andPlacementId:(NSString*)placementId andFtu:(NSInteger)ftu
{
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = YP_DEBUG_SSP_URL;
    } else {
        url = YP_SSP_URL;
    }
    
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    NSString* s = [[NSString stringWithFormat:@"%@%@%d%d",time, token, tu, sspid] MD5Hash];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:@"1" forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%d",sspid] forKey:@"sspid"];
    [params setObject:[NSString stringWithFormat:@"%@",placementId ? placementId : @""] forKey:@"placement_id"];
    [params setObject:@"2" forKey:@"product"];
    [params setObject:s forKey:@"s"];
    [params setObject:[NSString stringWithFormat:@"%d", tu] forKey:@"tu"];
    [params setObject:token forKey:@"token"];
    [params setObject:[NSString stringWithFormat:@"%d", adn] forKey:@"adn"];
    [params setObject:time forKey:@"prt"];
    [params setObject:[DialerUsageRecord getClientNetWorkType] forKey:@"nt"];
    [params setObject:[FunctionUtility getIpAddress] forKey:@"ip"];
    [params setObject:CURRENT_TOUCHPAL_VERSION forKey:@"v"];
    [params setObject:COOTEK_APP_NAME forKey:@"ch"];
    [params setObject:[NSString stringWithFormat:@"%d", ftu] forKey:@"ftu"];
    
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
    
    return s;
}

- (void) filledWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn
{
    NSString* url = [self generateFilledUrl:sspid :tu :adn :nil andFtu:nil];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
}

- (void) filledWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andADN:(NSInteger)adn andS:(NSString*)s andFtu:(NSInteger) ftu
{
    NSString* url = [self generateFilledUrl:sspid :tu :adn :s andFtu:[NSString stringWithFormat:@"%d", ftu]];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
}

- (void) edWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank andExpId:(NSInteger)expid andTitle:(NSString*)title andDesc:(NSString*)desc andS:(NSString*)s andFtu:(NSInteger)ftu
{
    NSString* url = [self generateEdUrl:sspid :tu :rank :expid :title :desc :s :[NSString stringWithFormat:@"%d", ftu]];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
}

- (void) edWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank andExpId:(NSInteger)expid andTitle:(NSString*)title andDesc:(NSString*)desc
{
    NSString* url = [self generateEdUrl:sspid :tu :rank :expid :title :desc :nil :nil];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
}

- (void) clickWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank andS:(NSString*)s andFtu:(NSInteger)ftu
{
    NSString* url = [self generateClickUrl:sspid :tu :rank :s :[NSString stringWithFormat:@"%d", ftu]];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
}

- (void) clickWithSSPid:(NSInteger)sspid andTu:(NSInteger)tu andRank:(NSInteger)rank
{
    NSString* url = [self generateClickUrl:sspid :tu :rank :nil :nil];
    
    [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:^(NSData *sucess) {
    } failure:^(NSData *errorResult) {
        [NetworkUtil executeWithUrlRequest:[SSPStat urlRequest:url] success:nil failure:nil];
    }];
}


@end
