//
//  UpdateService.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-24.
//
//

#import <Foundation/Foundation.h>
#import "UpdateService.h"
#import "ZipDataDownloadJob.h"
#import "CootekNotifications.h"
#import "Reachability.h"
#import "UserDefaultsManager.h"
#import "UserDefaultKeys.h"
#import "NetworkUtility.h"
#import "IndexConstant.h"
#import "SeattleFeatureExecutor.h"
#import <ZipArchive/ZipArchive.h>
#import "FileUtils.h"
#import "SectionBanner.h"
#import "IndexData.h"
#import "UIDataManager.h"
#import "IndexJsonUtils.h"
#import "SectionGroup.h"
#import "ImageUtils.h"
#import "CTUrl.h"
#import "ActivityItem.h"
#import <ZipArchive/ZipArchive.h>
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "LocalStorage.h"
#import "DialerUsageRecord.h"
#import "SectionMiniBanner.h"
#import "SectionFullScreenAd.h"
#import "FullScreenAdItem.h"
#import "FindNewsItem.h"
#import "SectionFindNews.h"
#import "NetworkUtil.h"
#import "SectionAD.h"
#import "YPAdItem.h"
#import "NSString+TPHandleNil.h"

#define WIFI_CHECK_INTERVAL 2*60*60 //2h
#define MOBILE_HIGH_CHECK_INTERVAL 2*60*60*24  //2d
#define MOBILE_LOW_CHECK_INTERVAL 2*60*60*24    //2d

@interface UpdateService()
{
    BOOL running;
}
@property(nonatomic, strong) NSString* updateUrl;
@property(nonatomic, strong) NSString* workSpacePath;
@property(nonatomic, strong) NSString* localTempFile;
@property(nonatomic, strong) NSArray* cityData;

@end


UpdateService *update_instance_ = nil;
@implementation UpdateService

- (id) init
{
    self = [super init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    self.localTempFile = [cacheDirectory stringByAppendingPathComponent:ZIP_DOWNLOAD_TEMP_FILE];

    NSArray *mainPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [mainPath objectAtIndex:0];
    self.workSpacePath = [documentsDirectory stringByAppendingPathComponent:WORKING_SPACE];

    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",self.workSpacePath,ZIP_VERSION_FILE]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self initZipFromLocal];
        });
    }
    return self;
}

+ (id) instance
{
    return update_instance_;

}

+ (void)initialize
{
    update_instance_ = [[UpdateService alloc] init];
}

- (void) initZipFromLocal
{
    NSString *originWorkPath = [[NSBundle mainBundle] pathForResource:@"webpages" ofType:@""];

    [FileUtils mergeContentsOfPath:originWorkPath intoPath:self.workSpacePath keepSrc:YES error:nil];
    [UserDefaultsManager setObject:[self getZipVersion] forKey:ZIP_CURRENT_VERSION];
    self.cityData = [self getCityData];
    [UserDefaultsManager setBoolValue:YES forKey:ZIP_INIT_UNZIP];
}


- (void) run
{
    @synchronized(self) {
        cootek_log(@"updateService  --- run ---");
        if (running) {
            cootek_log(@"updateService  --- running is Yes, return ---");
            return;
        }

        NSString* version = [UserDefaultsManager stringForKey:ZIP_CURRENT_VERSION];
        cootek_log(@"updateService zip current version: %@",version);

        if ([version intValue] <= 0) {
            [self initZipFromLocal];
        }
        if (USE_DEBUG_SERVER) {
            self.updateUrl = [NSString stringWithFormat:YP_ZIP_UPDATE_URL, YP_DEBUG_SERVER, version.intValue];
        } else {
            self.updateUrl = [NSString stringWithFormat:YP_ZIP_UPDATE_URL, SEARCH_SITE, version.intValue];
        }
        cootek_log(@"updateService updateUrl: %@",self.updateUrl);
        running = YES;
        if ([self shouldStartDownload]) {
            cootek_log(@"updateService -- start download ---");
            [self performSelectorInBackground:@selector(startDownload) withObject:nil];
        } else {
            cootek_log(@"updateService -- run finish ---");
            running = NO;
        }
    }
}


-(BOOL) shouldStartDownload
{
    int currentTime = [[NSDate date] timeIntervalSince1970];
    NSInteger lastTime = [UserDefaultsManager intValueForKey:LAST_ZIP_DOWNLOAD_TIME];
    int lastTimeToNow = -1;
    ClientNetworkType type= [Reachability network];
    if (type == network_2g) {
        lastTimeToNow = lastTime + MOBILE_LOW_CHECK_INTERVAL;
    } else if (type >= network_3g
               && [Reachability network] < network_wifi) {
        lastTimeToNow = lastTime + MOBILE_HIGH_CHECK_INTERVAL;
    } else if (type == network_wifi) {
        lastTimeToNow = lastTime + WIFI_CHECK_INTERVAL;
    }

    if (lastTimeToNow == -1 || (currentTime < lastTimeToNow && lastTime > 0)) {
        cootek_log(@"updateService lastTimeToNow: %ld, currentTime:%ld",lastTimeToNow, currentTime);
        return NO;
    }

    BOOL zipDownloadFinish = [UserDefaultsManager boolValueForKey:self.updateUrl defaultValue:NO];

    if (zipDownloadFinish) {
        return NO;
    }

    if (NO_ZIP_UPDATE) {
        return NO;
    }

    return YES;
}

- (void)startDownload
{

    cootek_log([NSString stringWithFormat:@"--- startDownload method in: %@", [NSThread currentThread].name]);
    if ([self checkEtag:self.updateUrl]) {
        cootek_log(@"updateService checkEtag Success start download");

        dispatch_sync(dispatch_get_main_queue(), ^{
            ZipDataDownloadJob *job = [[ZipDataDownloadJob alloc] initWithUrl:self.updateUrl andPath:self.localTempFile andIdentifier:@"zip"];

            NetworkDataDownloaderWrapper *downloader = [NetworkDataDownloadWrapperManager downloaderForJob:job];
            [self addZipDownloaderObserver];

            [downloader download];
        });
    } else {
        cootek_log(@"updateService checkEtag failed download canceled");
        running = NO;
    }
}

- (NSString*) getZipVersion
{
    NSString* zipVersion = [self readFromFile:[NSString stringWithFormat:@"%@/%@",self.workSpacePath,ZIP_VERSION_FILE]];
    return zipVersion;
}

- (NSArray*) getCityData
{
    NSString* citydata = [self readFromFile:[NSString stringWithFormat:@"%@/%@",self.workSpacePath,CITY_DATA_FILE]];

    if (citydata == nil) {
        NSString *originWorkPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"webpages/%@",CITY_DATA_FILE] ofType:@""];
        citydata = [self readFromFile:originWorkPath];
    }

    NSData *data = [citydata dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];

    NSMutableSet* cityArray = [NSMutableSet new];
    for (NSDictionary* cityItem in returnData) {
        NSArray* cities = [cityItem objectForKey:@"value"];
        [cityArray addObjectsFromArray:cities];
    }

    return [cityArray allObjects];
}

- (NSString *) readFromFile:(NSString *)filepath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]){
        NSString *content = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        return content;
    } else {
        return nil;
    }
}

- (BOOL) checkEtag:(NSString *)url
{
    NSURL *urlRequest=[NSURL URLWithString:url];
    NSMutableURLRequest *httpVersionRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    NSString* token = [SeattleFeatureExecutor getToken];
    [httpVersionRequest addValue:token forHTTPHeaderField:@"Cookie"];
    NSString* etag = [UserDefaultsManager stringForKey:ZIP_DOWNLOAD_ETAG];
    [httpVersionRequest addValue:etag forHTTPHeaderField:@"If-None-Match"];
    httpVersionRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;

    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    [NetworkUtility sendSafeSynchronousRequest:httpVersionRequest returningResponse:&response_url error:nil];
    NSInteger status = [response_url statusCode];
    cootek_log(@"updateService url: %@, status:%d",url, status);
    if (status == 200) {
        NSDictionary* headers = [response_url allHeaderFields];
        NSString* etags = [headers objectForKey:@"Etag"];
        NSString* contentLength = [headers objectForKey:@"Content-Length"];
        [UserDefaultsManager setObject:etags forKey:ZIP_DOWNLOAD_ETAG];
        [UserDefaultsManager setIntValue:contentLength.intValue forKey:ZIP_DOWNLOAD_LENGHT];

        if ([[NSFileManager defaultManager] isDeletableFileAtPath:self.localTempFile]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.localTempFile error:nil];
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString* localTempDirectory = [cacheDirectory stringByAppendingPathComponent:ZIP_DOWNLOAD_TEMP_DIRECTORY];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:localTempDirectory]) {
            [[NSFileManager defaultManager] removeItemAtPath:localTempDirectory error:nil];
        }
    } else {
        return NO;
    }

    return YES;
}


- (void)addZipDownloaderObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zipDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zipDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_FAIL
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zipDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_PROGRESS
                                               object:nil];
}

- (void)zipDownloaderStatusChanged:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [self performSelectorInBackground:@selector(zipDownloaderStatusChanged:) withObject:notification];
        return;
    }

    id sender = [notification object];
    if(![sender isKindOfClass:[NetworkDataDownloaderWrapper class]]) {
        running = NO;
        return;
    }

    __weak NetworkDataDownloaderWrapper *downloader = sender;
    if(downloader) {
        [self updateDownloaderStatus:downloader];
    } else {
        running = NO;
    }
}


- (void)updateDownloaderStatus:(NetworkDataDownloaderWrapper *)downloader
{
    switch (downloader.downloadStatus) {
        case NetworkDataDownloadCompleted: {
            [UserDefaultsManager setBoolValue:YES forKey:self.updateUrl];
            [UserDefaultsManager setIntValue:[[NSDate date] timeIntervalSince1970]
             forKey:LAST_ZIP_DOWNLOAD_TIME];
            [self performSelectorInBackground:@selector(deploy) withObject:nil];
            running = NO;
            break;
        }
        case NetworkDataDownloadNotStarted: {
            running = NO;
            break;
        }
        case NetworkDataDownloadFailed: {
            [UserDefaultsManager setIntValue:[[NSDate date] timeIntervalSince1970]
                                      forKey:LAST_ZIP_DOWNLOAD_TIME];
            running = NO;
            break;
        }
        case NetworkDataDownloadStarting: {
            running = NO;
            break;
        }
        case NetworkDataDownloadDownloading: {
            break;
        }
        default: {
            running = NO;
            break;
        }
    }
}

-(void) checkDeployForLocalZip
{
    cootek_log(@"updateService --- checkDeployForLocalZip ---");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* currentVersion = [UserDefaultsManager stringForKey:ZIP_NATIVE_VERSION];
        cootek_log(@"updateService current native version:%@, new native version :%d",currentVersion,[CURRENT_TOUCHPAL_VERSION intValue]);
        if (currentVersion == nil || [CURRENT_TOUCHPAL_VERSION intValue] != [currentVersion intValue]) {
            [UserDefaultsManager setObject:CURRENT_TOUCHPAL_VERSION forKey:ZIP_NATIVE_VERSION];
            NSString *originWorkPath = [[NSBundle mainBundle] pathForResource:@"webpages" ofType:@""];
            NSString* nVersion = [self readFromFile:[NSString stringWithFormat:@"%@/%@",originWorkPath,ZIP_VERSION_FILE]];
            NSString* cVersion = [UserDefaultsManager stringForKey:ZIP_CURRENT_VERSION];
            if ([nVersion intValue] > [cVersion intValue]) {
                [self initZipFromLocal];
            }
        }
    });

}

- (void)requestForIndexData:(NSString *)url
{
    if ([Reachability network] < network_2g) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_FAILED object:nil userInfo:nil];
        });
        return;
    }

    int apiVersion = 3;
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        apiVersion = 4;
    }
    url = [url stringByAppendingFormat:@"?version=%d&_v=3&_token=%@&",
           apiVersion, [SeattleFeatureExecutor getToken]];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    url = [url stringByAppendingFormat:@"_ts=%.0f&",interval];
    url = [url stringByAppendingFormat:@"_sign=%@&", [CTUrl signWithUrl:url andNeedLogin:false andTS:interval]];
    url = [url stringByAppendingFormat:@"addr=%@&geo_city=%@&city=%@&latitude=%@&longtitude=%@&", [UserDefaultsManager objectForKey:NATIVE_PARAM_ADDR defaultValue:@""], [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY], [UserDefaultsManager objectForKey:INDEX_CITY_SELECTED], [LocalStorage getItemWithKey:QUERY_PARAM_LATITUDE], [LocalStorage getItemWithKey:QUERY_PARAM_LONGITUDE]];
    url = [url stringByAppendingFormat:@"app_name=%@&app_version=%@&network=%@", COOTEK_APP_NAME, CURRENT_TOUCHPAL_VERSION,[DialerUsageRecord getClientNetWorkType]];
    
    NSURL *urlRequest = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];

        NSDictionary* newData = [returnData objectForKey:@"result"];
        NSDictionary* cacheData = (NSDictionary*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA];

        IndexData* newIndexFilter = [[IndexData alloc] initWithJson:newData];
        
        NSString* newIndexFilterString = [newIndexFilter.groupArray componentsJoinedByString:@""];
        NSString* cacheIndexFilterString = (NSString*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA_FILTER];

        if ([newData isEqual:cacheData] == NO || [newIndexFilterString isEqual:cacheIndexFilterString] == NO) {

            cootek_log(@"updateService requestForIndexData update");
            [UserDefaultsManager setObject:newData forKey:INDEX_REQUEST_DATA];
            [UserDefaultsManager setObject:newIndexFilterString forKey:INDEX_REQUEST_DATA_FILTER];
            IndexData* newIndex = [[IndexData alloc]initWithJson:newData];
            [self downloadImagesToFilesFromBanner:newIndex];
            [self downloadAdCellImages:newIndex];

            NSArray* activities = (NSMutableArray*)[UserDefaultsManager objectForKey:INDEX_REQUEST_ACTIVITY];
            ActivityItem* selectedActivity = nil;
            for (NSDictionary* item in activities) {
                ActivityItem* activityItem = [[ActivityItem alloc]initWithJson:item];
                if ([activityItem isValid]) {
                    selectedActivity = activityItem;
                    break;
                }
            }
            [UserDefaultsManager setBoolValue:NO forKey:INDEX_HAS_ACTIVITY];
            if (selectedActivity != nil) {
                if ([self downloadImagesToFilesFromActivity:selectedActivity.iconZipLink] == NO) {
                    [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA];
                    [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA_FILTER];
                    [self requestForIndexData:url];
                    return;

                }
            }

            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_SUCCESS object:nil userInfo:nil];
            });
        } else {
            cootek_log(@"updateService requestForIndexData newData == cacheData");
            IndexData* newIndex = [[IndexData alloc]initWithJson:newData];
            if (![self activityImagesIsValid:newIndex]) {
                [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA];
                [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA_FILTER];
                [self requestForIndexData:url];
            } else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_SUCCESS object:nil userInfo:nil];
                });
            }
        }

    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_SERVER_FAILED object:nil userInfo:nil];
        });
    }
}

- (void)requestForIndexFont:(NSString *)url
{
    NSURL *urlRequest=[NSURL URLWithString:[NSString stringWithFormat:@"%@?_token=%@",url,[SeattleFeatureExecutor getToken]]];

    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        NSDictionary* newData = [returnData objectForKey:@"result"];
        NSDictionary* cacheData = (NSDictionary*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA];

        IndexData* newIndexFilter = [[IndexData alloc]initWithJson:newData];
        NSString* newIndexFilterString = [newIndexFilter.groupArray componentsJoinedByString:@""];
        NSString* cacheIndexFilterString = (NSString*)[UserDefaultsManager objectForKey:INDEX_REQUEST_DATA_FILTER];

        if ([newData isEqual:cacheData] == NO || [newIndexFilterString isEqual:cacheIndexFilterString] == NO) {

            cootek_log(@"updateService requestForIndexData update");
            [UserDefaultsManager setObject:newData forKey:INDEX_REQUEST_DATA];
            [UserDefaultsManager setObject:newIndexFilterString forKey:INDEX_REQUEST_DATA_FILTER];
            IndexData* newIndex = [[IndexData alloc]initWithJson:newData];
            if ([self downloadImagesToFilesFromBanner:newIndex] == NO) {
                [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA];
                [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA_FILTER];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_SUCCESS object:nil userInfo:nil];
                });
                return;
            }

            NSArray* activities = (NSMutableArray*)[UserDefaultsManager objectForKey:INDEX_REQUEST_ACTIVITY];
            ActivityItem* selectedActivity = nil;
            for (NSDictionary* item in activities) {
                ActivityItem* activityItem = [[ActivityItem alloc]initWithJson:item];
                if ([activityItem isValid]) {
                    selectedActivity = activityItem;
                    break;
                }
            }
            [UserDefaultsManager setBoolValue:NO forKey:INDEX_HAS_ACTIVITY];
            if (selectedActivity != nil) {
                if ([self downloadImagesToFilesFromActivity:selectedActivity.iconZipLink] == NO) {
                    [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA];
                    [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA_FILTER];
                    [self requestForIndexData:url];
                    return;

                }
            }

            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:N_INDEX_REQUEST_SUCCESS object:nil userInfo:nil];
            });
        } else {
            cootek_log(@"updateService requestForIndexData newData == cacheData");
            IndexData* newIndex = [[IndexData alloc]initWithJson:newData];
            if (![self activityImagesIsValid:newIndex]) {
                [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA];
                [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_DATA_FILTER];
                [self requestForIndexData:url];
            }
        }

    }
}

//-(void) requestNewsData:(NSString *)qId withBlock:(void (^)(NSMutableArray *))block
//{
//    if (!qId) {
//        qId = YP_COUPON_QUERY_INIT_ID;
//    }
//
//    self.queryId = qId;
//    [[AdRequestManager new] generateTasks:nil withBlock:block];
//
//}

- (NSMutableArray *)requestForNews:(NSString *)url
{

    NSString* parseUrl = url;

    parseUrl = [parseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];

    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && responseString && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        
        @synchronized (self) {
            [UIDataManager instance].couponDic = [returnData objectForKey:@"news"];
            
            NSArray* dic = [returnData objectForKey:@"news"];
            if (dic.count > 0) {
                [UIDataManager instance].couponDic = [dic objectAtIndex:0];
                
                NSMutableArray* coupons = [[[UIDataManager instance] couponDic] objectForKey:@"cts"];
                
                if (coupons.count > 0) {
                    IndexData* coupon = [[IndexData alloc]initFindNewsWithJson:[[UIDataManager instance] couponDic]];
                    if (coupon.groupArray.count > 0) {
                        SectionGroup* group = [coupon.groupArray objectAtIndex:0];
                        if ([group isValid]) {
                            SectionFindNews* newFind = [group.sectionArray objectAtIndex:group.current];
                            return [newFind.items mutableCopy];
                        }
                    }
                }
            }
        } // end: @synchronized
    }
    return nil;
}

- (NSMutableArray *)requestForAds:(NSString *)url
{
    
    
    NSString* parseUrl = url;
    
    parseUrl = [parseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && responseString && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
       
        NSArray* ads = [returnData objectForKey:@"ad"];
        
        if (ads.count > 0) {
            [UIDataManager instance].couponDic = [ads objectAtIndex:0];
            
            if ([UIDataManager instance].couponDic.count > 0) {
                NSMutableArray* coupons = [[[UIDataManager instance] couponDic] objectForKey:@"ads"];
                
                if (coupons.count > 0) {
                    IndexData* coupon = [[IndexData alloc]initFindNewsWithJson:[[UIDataManager instance] couponDic]];
                    if (coupon.groupArray.count > 0) {
                        SectionGroup* group = [coupon.groupArray objectAtIndex:0];
                        if ([group isValid]) {
                            SectionFindNews* newFind = [group.sectionArray objectAtIndex:group.current];
                            return [newFind.items mutableCopy];
                        }
                    }
                }
            }
        }
        
        
    }
    return nil;
}

- (void)requestForMiniBannerData:(NSString *)url
{
    NSString* parseUrl = [NSString stringWithFormat:@"%@?_token=%@&geo_city=%@&city=%@&latitude=%@&longitude=%@&addr=%@",url, [SeattleFeatureExecutor getToken], [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY], [UserDefaultsManager stringForKey:INDEX_CITY_SELECTED defaultValue:@""], [LocalStorage getItemWithKey:QUERY_PARAM_LATITUDE], [LocalStorage getItemWithKey:QUERY_PARAM_LONGITUDE],[UserDefaultsManager objectForKey:NATIVE_PARAM_ADDR defaultValue:@""]];

    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    parseUrl = [parseUrl stringByAppendingFormat:@"&version=1&_v=3&_ts=%.0f&",interval];
    parseUrl = [parseUrl stringByAppendingFormat:@"_sign=%@&", [CTUrl signWithUrl:url andNeedLogin:false andTS:interval]];
    parseUrl = [parseUrl stringByAppendingFormat:@"app_name=%@&app_version=%@&network=%@",COOTEK_APP_NAME, CURRENT_TOUCHPAL_VERSION,[DialerUsageRecord getClientNetWorkType]];

    parseUrl = [parseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];

    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && responseString && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];

        NSNumber* resultCode = [returnData objectForKey:@"result_code"] ;
        if ([resultCode longValue] == 2000) {
            NSDictionary* newData = [returnData objectForKey:@"result"];
            IndexData* newIndex = [[IndexData alloc]initWithJson:newData];
            int count = 0;
            while ([self downloadImagesToFilesFromMiniBanner:newIndex] == NO && count < 3) {
                count ++;
            }

            if (count >= 3) {
                return;
            }

            if (![newData isEqualToDictionary:(NSDictionary *)[UserDefaultsManager objectForKey:INDEX_REQUEST_MINI_BANNER]]) {
                [UserDefaultsManager setBoolValue:NO forKey:INDEX_REQUEST_FULL_AD_TAB_CLICK];
                [UserDefaultsManager setBoolValue:NO forKey:INDEX_REQUEST_MINI_BANNER_TAB_CLICK];
                [UserDefaultsManager setObject:newData forKey:INDEX_REQUEST_MINI_BANNER];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_MINI_BANNER_REQUEST_SUCCESS object:nil userInfo:nil];
                });
            }

        }
    }
}

-(BOOL)downloadImagesToFilesFromMiniBanner:(IndexData*)indexData
{
    for (SectionGroup* section in [indexData groupArray]) {
        if ([SECTION_TYPE_MINI_BANNERS isEqualToString:[section sectionType]]) {
            for (SectionMiniBanner* banner in [section sectionArray]) {
                for (BaseItem* item in banner.items) {
                    NSString* url = item.iconLink;
                    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
                    if(!save){
                        cootek_log(@"updateService downloadImagesToFilesFromMiniBanner save failed, url: %@", url);
                        return NO;
                    }
                }

            }
        } else if ([SECTION_TYPE_FULL_SCREEN_ADS isEqualToString:[section sectionType]]) {
            for (SectionFullScreenAd* ad in [section sectionArray]) {
                for (FullScreenAdItem* item in ad.items) {
                    NSString* url = item.iconLink;
                    BOOL save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
                    if(!save){
                        cootek_log(@"updateService downloadImagesToFilesFromMiniBanner save failed, url: %@", url);
                        return NO;
                    }

                    url = item.adImage;
                    save = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
                    if(!save){
                        cootek_log(@"updateService downloadImagesToFilesFromMiniBanner save failed, url: %@", url);
                        return NO;
                    }
                }

            }
        }
    };
    return YES;
}

- (void) requestForWeatherData
{
    NSString *url = [NSString stringWithFormat:@"%@%@", SEARCH_SITE, WEATHER_REQUEST_PATH];
    NSString *parseUrl = [NSString stringWithFormat:@"%@?_token=%@&_city=%@", url, [SeattleFeatureExecutor getToken],[UserDefaultsManager stringForKey:INDEX_CITY_SELECTED defaultValue:@""]];
    parseUrl = [parseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];

    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && responseString && [responseString length] > 0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];

            [UIDataManager instance].weatherData = @"";
        if ([returnData objectForKey:@"result"] && [[returnData objectForKey:@"result"] objectForKey:@"weather"] && [[[returnData objectForKey:@"result"] objectForKey:@"weather"] objectForKey:@"today"]) {
            NSMutableDictionary *todayWeather = [[[returnData objectForKey:@"result"] objectForKey:@"weather"] objectForKey:@"today"];
            NSString *selectedCity = [UserDefaultsManager stringForKey:INDEX_CITY_SELECTED];
            if ([todayWeather objectForKey:@"city"] && [[todayWeather objectForKey:@"city"] isEqualToString:selectedCity]) {
                        if ([todayWeather objectForKey:@"weather"] && [todayWeather objectForKey:@"temperature"]) {
                            NSString *weather = [todayWeather objectForKey:@"weather"];
                            NSString *temperature = [todayWeather objectForKey:@"temperature"];
                            NSString *bannerWeather = [[weather stringByAppendingString:@" "] stringByAppendingString:temperature];
                            [UIDataManager instance].weatherData = bannerWeather;
                        }
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:N_WEATHER_REQUEST_SUCCESS object:nil userInfo:nil];
        });
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:N_WEATHER_REQUEST_SUCCESS object:nil userInfo:nil];
        });
    }
}

-(void) requestForCUrl:(NSString*) url
{
    if (!url || url.length <=0 ) {
        return;
    }
  
    
    NSString *parseUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];

    [httpIndexRequest setHTTPMethod:@"GET"];
    
    [NetworkUtil executeWithUrlRequest:httpIndexRequest success:nil failure:nil];
}


-(void) requestServiceBottomData:(NSString*) url withServiceId:(NSString*)serviceId
{
    NSString* parseUrl = [NSString stringWithFormat:@"%@?service_id=%@&_token=%@",url, serviceId, [SeattleFeatureExecutor getToken]];

    parseUrl = [parseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];

    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    cootek_log(@"updateService requestServiceBottomData url : %@ , status : %d, response: %@",url, status, responseString);
    if (status != 404 && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        [UIDataManager instance].serviceBottomData = [returnData objectForKey:@"result"];
        [UserDefaultsManager setObject:[UIDataManager instance].serviceBottomData forKey:[NSString stringWithFormat:@"%@%@",[UserDefaultsManager stringForKey:INDEX_SERVICE_BOTTOM_PREFIX],serviceId]];
    } else {

        [UIDataManager instance].serviceBottomData = (NSDictionary *)[UserDefaultsManager objectForKey:[NSString stringWithFormat:@"%@%@",[UserDefaultsManager stringForKey:INDEX_SERVICE_BOTTOM_PREFIX],serviceId]];
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:N_COUPON_REQUEST_SUCCESS object:nil userInfo:nil];
    });
}

- (BOOL) activityImagesIsValid:(IndexData*) data
{
    for (SectionGroup* section in [data groupArray]) {
        if ([SECTION_TYPE_BANNER isEqualToString:[section sectionType]]) {
            for (SectionBanner* banner in [section sectionArray]) {
                NSString* url = ((BaseItem *)[banner.items objectAtIndex:0]).iconLink;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *cacheDirectory = [paths objectAtIndex:0];
                NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:[CTUrl encodeUrl:url] ];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
                    cootek_log(@"updateService activityImagesIsValid false, file not exist: %@", localFilePath);
                    return NO;
                }
            }
        }
    };

    NSArray* activities = (NSMutableArray*)[UserDefaultsManager objectForKey:INDEX_REQUEST_ACTIVITY];
    ActivityItem* selectedActivity = nil;
    for (NSDictionary* item in activities) {
        ActivityItem* activityItem = [[ActivityItem alloc]initWithJson:item];
        if ([activityItem isValid]) {
            selectedActivity = activityItem;
            break;
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:INDEX_ZIP_FILENAME];
    if (selectedActivity && ![[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        cootek_log(@"updateService activityImagesIsValid false, file not exist: %@, selected activity: %@", localFilePath, selectedActivity.iconPicLink);
        return NO;
    }

    return YES;
}

-(BOOL)downloadImagesToFilesFromBanner:(IndexData*)indexData
{
    int freshFileCount = 0;
    int downloadedFreshFileCount = 0;
    for (SectionGroup* section in [indexData groupArray]) {
        if ([SECTION_TYPE_BANNER isEqualToString:[section sectionType]]) {
            for (SectionBanner* banner in [section sectionArray]) {
                if (banner.items.count == 0) {
                    continue;
                }
                NSString* url = ((BaseItem *)[banner.items objectAtIndex:0]).iconLink;
                NSString *fileName = [CTUrl encodeUrl:url];
                BOOL isCached = [self isCachedFile:fileName];
                BOOL save = [ImageUtils saveImageToFile:fileName withUrl:url];
                if (!isCached) {
                    freshFileCount += 1;
                    if (save) {
                        downloadedFreshFileCount += 1;
                    }
                }
                if(!save){
                    cootek_log(@"updateService downloadImagesToFilesFromBanner save failed, url: %@", url);
                    return NO;
                }
            }
        }
    };
    if (freshFileCount > 0
        && freshFileCount == downloadedFreshFileCount) {
        [UserDefaultsManager setBoolValue:YES forKey:INDEX_REQUEST_DOWNLOADED_NEW_BANNER];
        [UserDefaultsManager setBoolValue:NO  forKey:INDEX_REQUEST_ANIMATED_NEW_BANNER];
    }
    return YES;
}

- (BOOL) isCachedFile:(NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        return YES;
    }
    return NO;
}

-(BOOL)downloadImagesToFilesFromActivity:(NSString*)url
{
    NSURL *urlRequest=[NSURL URLWithString:url];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:urlRequest
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                timeoutInterval:10];
    NSHTTPURLResponse *urlResponse = nil;
    NSData *zipData = [NetworkUtility sendSafeSynchronousRequest:httpRequest
                                                 returningResponse:&urlResponse
                                                             error:nil];
    cootek_log(@"updateService downloadImagesToFilesFromActivity url: %@, status: %d", url, [urlResponse statusCode]);
    if ([urlResponse statusCode] == 200) {
        [UserDefaultsManager setObject:nil forKey:INDEX_REQUEST_ACTIVITY];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *localFilePath = [cacheDirectory stringByAppendingPathComponent:INDEX_ZIP_FILENAME];
        NSString *unzipFilePath = [cacheDirectory stringByAppendingPathComponent:INDEX_UNZIP_FILEPATH];
        BOOL save = [zipData writeToFile:localFilePath atomically:YES];
        if (save == NO) {
            cootek_log(@"updateService downloadImagesToFilesFromActivity downloadImagesToFilesFromActivity failed, localFilePath: %@", localFilePath);
            return NO;
        }
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        [zipArchive UnzipOpenFile:localFilePath];
        [zipArchive UnzipFileTo:unzipFilePath overWrite:YES];
        [zipArchive UnzipCloseFile];
        [UserDefaultsManager setBoolValue:YES forKey:INDEX_HAS_ACTIVITY];
        return YES;
    } else {
        return NO;
    }
}


- (NSDictionary *)requestUrlWithDicResult:(NSString *)url
{
    
NSString* parseUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    NSMutableDictionary *returnData = nil;
    if (status != 404 && responseString && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    }
    
    return returnData;
}

- (void) deploy
{
   cootek_log([NSString stringWithFormat:@"--- deploy start, zip version: %@ ----",[UserDefaultsManager stringForKey:ZIP_CURRENT_VERSION]]);

    cootek_log(@"updateService deploy start");

    BOOL result = NO;

    NSArray *opaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [opaths objectAtIndex:0];
    NSString* srcDirectory = [[[cacheDirectory
                                stringByAppendingPathComponent:
                                ZIP_DOWNLOAD_TEMP_DIRECTORY]
                               stringByAppendingString:@"/"]
                              stringByAppendingString:WORKING_SPACE];

    result = [FileUtils mergeContentsOfPath:srcDirectory intoPath:self.workSpacePath keepSrc:YES error:nil];

    if (result) {
        NSString* nVersion = [self getZipVersion];
        cootek_log(@"UpdateService deploy success, zip version:%@",nVersion);
        [UserDefaultsManager setObject:nVersion forKey:ZIP_CURRENT_VERSION];
    } else {
        cootek_log(@"UpdateService deploy failed, current zip version:%@",[self getZipVersion]);
    }

    self.cityData = [self getCityData];

//    [IndexJsonUtils clearClickHiddenInfo];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:N_ZIP_DEPLOY_SUCCESS object:nil userInfo:nil];
    });

    [UserDefaultsManager removeObjectForKey:self.updateUrl];

}

- (NSString*) getSelectedCity:(NSString*) city
{
    NSString* newCity = @"";
    cootek_log(@"updateService getSelectedCity city:%@", city);
    if (!city || city.length == 0) {
        return @"";
    }

    if (self.cityData == nil || self.cityData.count <= 0) {
        self.cityData = [self getCityData];
    }

    for (NSString* c in self.cityData) {
        NSRange range = [c rangeOfString:[city lowercaseString]];
        if (range.length > 0) {
            newCity = [c lowercaseString];
            break;
        }
    }

    return newCity;
}

- (NSString*) getWebSearchPath
{
    return self.workSpacePath;
}

+ (NSString *)generateParamsWithDictionary:(NSDictionary *)parasDic
{
    NSString* paramStr = @"";

    BOOL hasKey = NO;
    for (NSString* key in parasDic) {
        paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [parasDic objectForKey:key]]];
        hasKey = YES;
    }
    
    if (hasKey) {
        paramStr = [paramStr substringToIndex:paramStr.length - 1];
    }
    
    return paramStr;
}

+ (NSString *) createNormalParams
{
    NSString* url = @"";
    url = [url stringByAppendingFormat:@"_v=3&_token=%@&",[SeattleFeatureExecutor getToken]];
    return url;
}

#pragma mark Download Resource
- (BOOL) downloadAdCellImages:(IndexData*)indexData
{
    for (SectionGroup* section in [indexData groupArray]) {
        if ([SECTION_TYPE_V6_SECTIONS isEqualToString:[section sectionType]]
            || [SECTION_TYPE_PROFIT_CENTER isEqualToString:[section sectionType]]) {
            for (SectionAD* adSection in [section sectionArray]) {
                for (YPAdItem* item in adSection.items) {
                    NSString* url = item.iconLink;
                    if ([NSString isNilOrEmpty:url]
                        || [url rangeOfString:@"http"].location == NSNotFound) {
                        continue;
                    }
                    BOOL saveSuccess = [ImageUtils saveImageToFile:[CTUrl encodeUrl:url] withUrl:url];
                    cootek_log(@"updateService downloadAdCellImages, url: %@, saved= %d",
                               url, saveSuccess);
                    if(!saveSuccess){
                        cootek_log(@"updateService downloadAdCellImages save failed, url: %@", url);
                        return NO;
                    }
                }
            }
        }
    };
    return YES;
}
@end
