//
//  YellowPageLocationManager.m
//  TouchPalDialer
//
//  Created by tanglin on 15/8/27.
//
//

#import "YellowPageLocationManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "LocalStorage.h"
#import "UserDefaultKeys.h"
#import "UpdateService.h"
#import "TouchPalVersionInfo.h"
#import "IndexConstant.h"
#import "SeattleFeatureExecutor.h"
#import "NetworkUtility.h"
#import "CootekWebHandler.h"
#import "UserDefaultsManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalVersionInfo.h"
#import "EditVoipViewController.h"
#import "SeattleFeatureExecutor.h"
#import "TPShareController.h"
#import "DialerUsageRecord.h"
#import "VoipShareView.h"
#import "LoginController.h"
#import "FreeCallLoginController.h"
#import "FunctionUtility.h"
#import "TPShareController.h"
#import "TPDialerResourceManager.h"
#import <TAESDK/TaeWebViewUISettings.h>
#import "DefaultUIAlertViewHandler.h"
#import "LoginController.h"
#import "CallFlowPacketLoginController.h"
#import "FlowEditViewController.h"
#import "FlowInputNameView.h"
#import "Reachability.h"
#import "HandlerWebViewController.h"
#import "VoipShareAllView.h"
#import "AlipayController.h"
#import "ScheduleInternetVisit.h"
#import "VoipFeedbackInfo.h"
#import "LocalStorage.h"
#import "TaskBonusManager.h"
#import "RootScrollViewController.h"
#import "MarketLoginController.h"
#import "IndexConstant.h"
#import "ScanRootViewController.h"
#import "TouchLifeShareMgr.h"
#import "YellowPageLocationManager.h"

#define LOCATION_PERMISSION_CHECK_INTERVAL 10*60*60
@interface YellowPageLocationManager(){
    CLLocationManager* locationManager_;
    NSMutableArray* blockList;
    BOOL isLocating;
    BOOL isNeedCity;
    BOOL checkPermission;
    int count;
    int lastCheckTime;
}
@property(nonatomic,copy) void(^blockCallLocate)();
@end


@implementation YellowPageLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;//精度设定
        locationManager_.delegate = self;
        isLocating = NO;
        blockList = [NSMutableArray new];
        checkPermission = NO;
        count = 0;
        lastCheckTime = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

+ (id) instance
{
    static YellowPageLocationManager * _ypLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ypLocationManager = [[YellowPageLocationManager alloc] init];
    });
    return _ypLocationManager;
}

- (void)onAppDidBackground
{
    if (locationManager_ != nil) {
        [locationManager_ stopUpdatingLocation];
        isLocating = NO;
    }
}

-(void) locate:(BOOL)needCity checkPermission:(BOOL)permission
{
    isNeedCity = needCity | isNeedCity;
    checkPermission = permission | checkPermission;
    if (isLocating) {
        return;
    }

    isLocating = YES;
    checkPermission = permission;
    if ([locationManager_ respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager_ requestWhenInUseAuthorization];
    }

    [locationManager_ startUpdatingLocation];
}

- (void) addCallBackBlock:(void(^)(BOOL isLocation, CLLocationCoordinate2D location))locationBlock
{
    if (locationBlock) {
        [blockList addObject:locationBlock];
    }
}

#pragma Location
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    if(!isLocating) {
        return;
    }

    if (count < 3 && [error code] != kCLErrorDenied) {
        count++;
        return;
    }

    count = 0;
    isLocating = NO;
    [locationManager_ stopUpdatingLocation];

    NSString *time = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION_CACHE_TIME];
    if (time.length > 0) {
        long long lTime = time.longLongValue;
        long long now = [[NSDate date]timeIntervalSince1970] *1000;
        if (now - lTime > 24 * 60 * 60 * 1000) {
            [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION andValue:@""];
            [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", now]];
        }
    } else {
        long long now = [[NSDate date]timeIntervalSince1970] *1000;
        [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION andValue:@""];
        [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", now]];
    }


    NSString *errorString;
    for (void(^block)(BOOL isLocation, CLLocationCoordinate2D location) in blockList) {
        CLLocationCoordinate2D location = {-1,-1};
        block(NO, location);
    }
    [self blockClear];

    NSLog(@"Error: %@",[error localizedDescription]);

    switch([error code]) {
        case kCLErrorDenied:
        {
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"fail"), Pair(@"reason",@"kCLErrorDenied"), nil];
            if (checkPermission) {
                if (lastCheckTime + LOCATION_PERMISSION_CHECK_INTERVAL < [[NSDate date] timeIntervalSince1970]) {
                    lastCheckTime = [[NSDate date] timeIntervalSince1970];
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Location Service Disabled", @"")
                                                                   message:NSLocalizedString(@"To re-enable, please go to Settings and turn on Location Service for this app.", @"")
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                    [alert show];
                }
                checkPermission = NO;
            }

        }
            break;
        case kCLErrorLocationUnknown:
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"fail"), Pair(@"reason",@"kCLErrorLocationUnknown"), nil];
            break;
        default:
            errorString = @"An unknown error has occurred";
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"fail"), Pair(@"reason",@"kCLErrorLocationUnknown"), nil];
            break;
    }
}

- (void) blockClear
{
    blockList = [NSMutableArray new];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if (isLocating) {
        count = 0;
        isLocating = NO;
        [locationManager_ stopUpdatingLocation];
    } else {
        return;
    }

    if (newLocation != nil) {
        cootek_log(@"longitude = %.8f\nlatitude = %.8f", newLocation.coordinate.longitude,newLocation.coordinate.latitude);
        if (!isNeedCity) {
            [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"suc"), Pair(@"isNeedCity",@"NO"), Pair(@"lat", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude])), Pair(@"lng", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude])), nil];
        }
    } else {
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"fail"), Pair(@"reason", @"newLocation:nil"), nil];
        return;
    }

    NSTimeInterval time = [[NSDate date]timeIntervalSince1970]*1000;
    long long longSeconds = time;
    CLLocationCoordinate2D currentLocation_ = newLocation.coordinate;
    [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION andValue:[NSString stringWithFormat:@"[%@,%@]", @(currentLocation_.latitude),@(currentLocation_.longitude)]];
    [LocalStorage setItemForKey:NATIVE_PARAM_LOCATION_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", longSeconds]];


    if (isNeedCity) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];

        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];

        if ([language hasPrefix:@"zh"]) {
            [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
            {

                 if (error == nil && [placemarks count] > 0)
                 {
                     CLPlacemark *placemark = [placemarks lastObject];

                     // strAdd -> take bydefault value nil
                     NSString *strAdd = nil;

                     if ([placemark.subThoroughfare length] != 0)
                         strAdd = placemark.subThoroughfare;

                     if ([placemark.thoroughfare length] != 0)
                     {
                         // strAdd -> store value of current location
                         if ([strAdd length] != 0)
                             strAdd = [NSString stringWithFormat:@"%@%@",[placemark thoroughfare],strAdd];
                         else
                         {
                             // strAdd -> store only this value,which is not null
                             strAdd = placemark.thoroughfare;
                         }
                     }

                     if ([placemark.subLocality length] > 0)
                     {
                         // strAdd -> store value of current location
                         if ([strAdd length] != 0)
                             strAdd = [NSString stringWithFormat:@"%@%@",[placemark subLocality],strAdd];
                         else
                         {
                             // strAdd -> store only this value,which is not null
                             strAdd = placemark.subLocality;
                         }
                     }

                     NSString* city = placemark.administrativeArea;
                     if (city && city.length > 0) {
                         NSArray *array = [city componentsSeparatedByString:@"市"];
                         city = [array objectAtIndex:0];
                         NSString* subCity = [city substringToIndex:2];
                         city = [[UpdateService instance] getSelectedCity:subCity];
                     }

                     if (!city || city.length == 0) {
                         city = placemark.locality;
                         NSArray *array = [city componentsSeparatedByString:@"市"];
                         city = [array objectAtIndex:0];
                         NSString* subCity = [city substringToIndex:2];
                         city = [[UpdateService instance] getSelectedCity:subCity];
                         if (city.length <= 0) {
                             city = [array objectAtIndex:0];
                         }
                     }


                     if ((city && city.length > 0)) {

                         //如果定位成功，并且获取到城市，保存到当前定位城市中，并且保存相应的js需要调用的值。
                         [LocalStorage setItemForKey:QUERY_PARAM_LOC_CITY andValue:city];
                         [LocalStorage setItemForKey:NATIVE_PARAM_CITY andValue:city];
                         [LocalStorage setItemForKey:NATIVE_PARAM_CITY_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", longSeconds]];


                         if ([city length] > 0)
                         {
                             // strAdd -> store value of current location
                             if ([strAdd length] != 0)
                                 strAdd = [NSString stringWithFormat:@"%@市%@",city,strAdd];
                             else
                             {
                                 // strAdd -> store only this value,which is not null
                                 strAdd = city;
                             }
                         }

                         [LocalStorage setItemForKey:NATIVE_PARAM_ADDR andValue:strAdd];
                         [LocalStorage setItemForKey:NATIVE_PARAM_ADDR_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", longSeconds]];

                         for (void(^block)(BOOL isLocation, CLLocationCoordinate2D location) in blockList) {
                             block(YES, newLocation.coordinate);
                         }
                         [self blockClear];
                         [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"suc"), Pair(@"isNeedCity",@"YES"), Pair(@"lat", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude])), Pair(@"lng", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude])), nil];

                         return;
                     }

                 }
                 [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"fail"), Pair(@"isNeedCity",@"YES"), Pair(@"reason",@"geocodingFail"), Pair(@"lat", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude])), Pair(@"lng", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude])), nil];

                 for (void(^block)(BOOL isLocation, CLLocationCoordinate2D location) in blockList) {
                     block(NO, newLocation.coordinate);
                 }
                 [self blockClear];
            }];

            // 非中文语言环境
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

                NSString* url = @"";

                if (USE_DEBUG_SERVER) {
                    url = [NSString stringWithFormat:@"%@%@",YP_DEBUG_SERVER, GEOCODING_REQUEST_PATH];
                } else {
                    url = [NSString stringWithFormat:@"%@%@",TOUCHLIFE_SITE, GEOCODING_REQUEST_PATH];
                }

                NSString* parseUrl = [NSString stringWithFormat:@"%@?_token=%@&location=%f,%f&coordtype=wgs84ll",url, [SeattleFeatureExecutor getToken], currentLocation_.latitude,currentLocation_.longitude];

                parseUrl = [parseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                NSURL *urlRequest=[NSURL URLWithString:parseUrl];
                NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];

                [httpIndexRequest setHTTPMethod:@"GET"];
                NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
                NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
                NSInteger status=[response_url statusCode];
                NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
                cootek_log(@"Location to GEO -->  url : %@ , status : %d, response: %@",parseUrl, status, responseString);
                if (status != 404 && [responseString length]>0) {
                    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error =nil;
                    NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];

                    NSNumber* resultCode = [returnData objectForKey:@"result_code"];
                    if (resultCode.intValue == 2000) {
                        NSTimeInterval time = [[NSDate date]timeIntervalSince1970]*1000;
                        long long longSeconds = time;
                        NSString* resString = [returnData objectForKey:@"result"];


                        NSData *data = [resString dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *error =nil;
                        NSMutableDictionary *res= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
                        NSNumber* status = [res objectForKey:@"status"];
                        if (status.intValue == 0) {
                            NSDictionary* result = [res objectForKey:@"result"];
                            NSString* address = [result objectForKey:@"formatted_address"];
                            NSString* city = [[result objectForKey:@"addressComponent"] objectForKey:@"city"];
                            NSArray *array = [city componentsSeparatedByString:@"市"];
                            city = [array objectAtIndex:0];
                            [LocalStorage setItemForKey:NATIVE_PARAM_ADDR andValue:address];
                            [LocalStorage setItemForKey:NATIVE_PARAM_ADDR_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", longSeconds]];

                            city = [[UpdateService instance] getSelectedCity:city];
                            if (city.length <= 0) {
                                city = [array objectAtIndex:0];
                            }

                            if ((city && city.length > 0)) {
                                //如果定位成功，并且获取到城市，保存到当前定位城市中，并且保存相应的js需要调用的值。
                                [LocalStorage setItemForKey:QUERY_PARAM_LOC_CITY andValue:city];
                                [LocalStorage setItemForKey:NATIVE_PARAM_CITY andValue:city];
                                [LocalStorage setItemForKey:NATIVE_PARAM_CITY_CACHE_TIME andValue:[NSString stringWithFormat:@"%lld", longSeconds]];
                                for (void(^block)(BOOL isLocation, CLLocationCoordinate2D location) in blockList) {
                                    block(YES, newLocation.coordinate);
                                }
                                [self blockClear];
                                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"suc"), Pair(@"isNeedCity",@"YES"), Pair(@"lat", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude])), Pair(@"lng", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude])), nil];
                                return;
                            }
                        }
                    }
                }

                // failed
                for (void(^block)(BOOL isLocation, CLLocationCoordinate2D location) in blockList) {
                    block(NO, newLocation.coordinate);
                }
                [self blockClear];

                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_GPS kvs:Pair(@"result",@"fail"), Pair(@"isNeedCity",@"YES"), Pair(@"reason",@"geocodingFail"),Pair(@"lat", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.latitude])), Pair(@"lng", ([NSString stringWithFormat:@"%.8f", newLocation.coordinate.longitude])), nil];

            });
        }
    } else {
        for (void(^block)(BOOL isLocation, CLLocationCoordinate2D location) in blockList) {
            block(YES, newLocation.coordinate);
        }
        [self blockClear];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self locate:YES checkPermission:NO];
    if(self.blockCallLocate && status != kCLAuthorizationStatusNotDetermined) {
        self.blockCallLocate();
        self.blockCallLocate = nil;
    }
}

- (void)requestLocationAuth:(void(^)())block {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        if ([locationManager_ respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            self.blockCallLocate = block;
            [locationManager_ requestWhenInUseAuthorization];
        } else {
            if (block) {
                block();
            }
        }
    } else {
        if (block) {
            block();
        }
    }
}

- (void) dealloc {
    if (locationManager_ != nil) {
        locationManager_.delegate = nil;
        locationManager_ = nil;
    }
}

@end
