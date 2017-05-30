//
//  AdStatManager.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/18.
//
//

#import "AdStatManager.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"
#import "UpdateService.h"
#import "TouchPalVersionInfo.h"
#import "IndexConstant.h"
#import "FileUtils.h"
#define AD_COMMIT_STAT_INTERVAL (10)
#define MAX_TIMES (10)
#define TIMER_INTERVAL (600)
#define COMMIT_COMMERCIAL_LIST @"commitCommercialList.plist"
#define EDURL_LIST  @"edurl.plist"

@interface AdStatManager () {
    dispatch_queue_t _queue;
    int _sendUrlRetry;
    int _commitRetry;
}
@end

@implementation AdStatManager

AdStatManager *sInstance = nil;

+ (void)initialize
{
    if (self == [AdStatManager class]) {
        sInstance = [[AdStatManager alloc] init];
    }
}


+ (AdStatManager *)instance {
    return sInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
          _queue = dispatch_queue_create("com.cootek.smartdialer.ad.stat",NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self
                              selector:@selector(checkIfshouldSendExistParamInList)
                               name:N_REACHABILITY_NETWORK_CHANE
                               object:nil];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                          target:self
                                                        selector:@selector(checkIfshouldSendExistParamInList)
                                                        userInfo:nil
                                                         repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [timer fire];

    }
    return self;
}


- (NSString *)genenrateUUID {
    return [FunctionUtility generateUUID];
}

- (void)commitCommericalStat:(NSString *)tu pst:(NSString *)preuuid st:(NSString *)uuid {
    if(!ENABLE_COMMERICAL_PREPARE) {
        return;
    }
    if (!preuuid) {
       preuuid = @"";
    }
    if(!uuid) {
        uuid = @"";
    }
    cootek_log(@"PrepareThread commitCommericalStat =(%@,%@)",preuuid,uuid);
    NSDictionary *param = @{@"tu":tu,@"st":uuid,@"pst":preuuid};
    dispatch_async(_queue, ^() {
        _commitRetry = 0;
        [self addCommitCommercialWithParam:param];
        [self commitCommericalStat:param];
    });
}

- (void)commitCommericalStat:(NSDictionary *)param {
    cootek_log(@"PrepareThread commitCommericalStat retyr=%d",_commitRetry);
    if (![self commitCommercialStatSend:param]) {
        if ([Reachability network]==network_none) {
            return;
        }
        if(_commitRetry < MAX_TIMES) {
            _commitRetry ++ ;
            [self performSelector:@selector(commitCommericalStat:)
                       withObject:param
                       afterDelay:AD_COMMIT_STAT_INTERVAL * _commitRetry];
        }
    } else {
        [self removeCommitCommercialWithParam:param];
    }
}


-(void)addCommitCommercialWithParam:(NSDictionary *)paramDic {
    NSString *commitCommercialPath = [FileUtils getNewFileInCommonFileWithPathComponent:COMMIT_COMMERCIAL_LIST];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:commitCommercialPath];
    if (array==nil) {
        array = [NSMutableArray array];
    }
    if (![array containsObject:paramDic]) {
        [array addObject:paramDic];
        [array writeToFile:commitCommercialPath atomically:YES];
    }
}


- (void)addEdurlWithParam:(NSObject *)paramObj{
    NSString *commitCommercialPath = [FileUtils getNewFileInCommonFileWithPathComponent:EDURL_LIST];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:commitCommercialPath];
    if (array==nil) {
        array = [NSMutableArray array];
    }
    if (![array containsObject:paramObj]) {
        [array addObject:paramObj];
        [array writeToFile:commitCommercialPath atomically:YES];
    }
}

-(void)removeCommitCommercialWithParam:(NSDictionary *)paramDic {
    NSString *commitCommercialPath = [FileUtils getNewFileInCommonFileWithPathComponent:COMMIT_COMMERCIAL_LIST];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:commitCommercialPath];
    if ([array containsObject:paramDic]) {
        [array removeObject:paramDic];
    }
    [array writeToFile:commitCommercialPath atomically:YES];
}

-(void)removeEdurlWithParam:(NSObject *)paramObj {
    NSString *commitCommercialPath = [FileUtils getNewFileInCommonFileWithPathComponent:EDURL_LIST];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:commitCommercialPath];
    if ([array containsObject:paramObj]) {
        [array removeObject:paramObj];
    }
    [array writeToFile:commitCommercialPath atomically:YES];
}

- (void)checkIfshouldSendExistParamInList {
    dispatch_async(_queue, ^() {
    NSString *commitCommercialPath = [FileUtils getNewFileInCommonFileWithPathComponent:COMMIT_COMMERCIAL_LIST];
    NSMutableArray *commitArray = [NSMutableArray arrayWithContentsOfFile:commitCommercialPath];
    if (commitArray.count > 0) {
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSDictionary *param in commitArray) {
                _commitRetry = 0;
                if (![self commitCommercialStatSend:param]) {
                } else {
                    [newArray addObject:param];
                }
            
        }
        [commitArray removeObjectsInArray:newArray];
        [commitArray writeToFile:commitCommercialPath atomically:YES];
    }
        
    NSString *edurlPath = [FileUtils getNewFileInCommonFileWithPathComponent:EDURL_LIST];
    NSMutableArray *edurlArray = [NSMutableArray arrayWithContentsOfFile:edurlPath];
    if (edurlArray.count > 0) {
        NSMutableArray *newArray = [NSMutableArray array];
        
        for (NSString *edurl in edurlArray) {
            _sendUrlRetry=0;
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:edurl]];
            NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] init];
            [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
            if ([urlResponse statusCode] != 200) {
            } else {
                [newArray addObject:edurl];
            }
            
        }
        [edurlArray removeObjectsInArray:newArray];
        [edurlArray writeToFile:edurlPath atomically:YES];
    }
    });
}

- (BOOL)commitCommercialStatSend:(NSDictionary *)params {
    NSString* token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    [dic setObject:COOTEK_APP_NAME forKey:@"ch"];
    [dic setObject:CURRENT_TOUCHPAL_VERSION forKey:@"v"];
    [dic setObject:@(2) forKey:@"product"];
    [dic setObject:@(6) forKey:@"type"];
    [dic setObject:[FunctionUtility networkType].uppercaseString  forKey:@"nt"];
    [dic setObject:token forKey:@"token"];
    NSString* url = nil;
    if (ENABLE_AD_DEBUG) {
        url = @"http://183.136.223.35:8885/ad/sspstat";
    } else {
        url = YP_SSP_URL;
    }
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:dic]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] init];
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    if ([urlResponse statusCode] == 200) {
        NSDictionary *reponse = [NSJSONSerialization JSONObjectWithData:result options:(NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers) error:nil];
        BOOL success = [[reponse objectForKey:@"success"] boolValue];
        return success;
    }
    return NO;
}

- (void)sendUrl:(NSString *)url {
    _sendUrlRetry = 0;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    dispatch_async(_queue, ^() {
        [self addEdurlWithParam:url];
        [self sendUrlRequest:request];
    });

}

- (void)sendUrlRequest:(NSURLRequest *)request {
    NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] init];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    if ([urlResponse statusCode] != 200) {
        if ([Reachability network]==network_none) {
            return;
        }
        if(_sendUrlRetry < MAX_TIMES) {
            _sendUrlRetry ++;
            [self performSelector:@selector(sendUrlRequest:)
                       withObject:request
                       afterDelay:AD_COMMIT_STAT_INTERVAL * _sendUrlRetry];
        }
    } else {
         [self removeEdurlWithParam:request.URL.absoluteString];
    }
}

@end
