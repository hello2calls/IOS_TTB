//
//  AntiharassUtil.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/8.
//
//

#import "AntiharassUtil.h"
#import "UserDefaultsManager.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "DialerUsageRecord.h"

@implementation AntiharassUtil

+ (NSString *)getAntiharassName:(AntiharassType)type{
    NSInteger cityCode = 0;
    switch (type) {
        case BEIJING:
            cityCode = 1000;
            break;
        case SHANGHAI:
            cityCode = 2100;
            break;
        case GUANGZHOU:
            cityCode = 2000;
            break;
        case SHENZHEN:
            cityCode = 75500;
            break;
        case CHENGDU:
            cityCode = 2800;
            break;
        case CHONGQING:
            cityCode = 2300;
            break;
        case TIANJIN:
            cityCode = 2200;
            break;
        case NANJING:
            cityCode = 2500;
            break;
        case WUHAN:
            cityCode = 2700;
            break;
        case XIAN:
            cityCode = 2900;
            break;
        case ZHENZHOU:
            cityCode = 37100;
            break;
        case OTHER:
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"antiharass_ios_%d",cityCode];
}

+ (NSString *)getDBName:(AntiharassType)type{
    return [NSString stringWithFormat:@"%@.db",[self getAntiharassName:type]];
}

+ (NSString *)getZipName:(AntiharassType)type{
    return [NSString stringWithFormat:@"%@.zip",[self getAntiharassName:type]];
}

+ (NSString *)getStringName:(AntiharassType)type{
    NSString *cityName = @"";
    switch (type) {
        case BEIJING:
            cityName = @"北京";
            break;
        case SHANGHAI:
            cityName = @"上海";
            break;
        case GUANGZHOU:
            cityName = @"广州";
            break;
        case SHENZHEN:
            cityName = @"深圳";
            break;
        case CHENGDU:
            cityName = @"成都";
            break;
        case CHONGQING:
            cityName = @"重庆";
            break;
        case TIANJIN:
            cityName = @"天津";
            break;
        case NANJING:
            cityName = @"南京";
            break;
        case WUHAN:
            cityName = @"武汉";
            break;
        case XIAN:
            cityName = @"西安";
            break;
        case ZHENZHOU:
            cityName = @"郑州";
            break;
        case OTHER:
            cityName = @"其他城市";
            break;
        default:
            break;
    }
    return cityName;
}

+ (NSString *)getVersionFileName{
    return @"antiharass_version";
}

+ (NSString *)translateVersionToString:(NSString *)version{
    if ( version.length == 8 ){
        NSString *year = [version substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [version substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [version substringWithRange:NSMakeRange(6, 2)];
        return [NSString stringWithFormat:@"%@.%@.%@",year,month,day];
    }
    return version;
}

+ (BOOL) ifDBTypeChanged{
    NSInteger dbType = [UserDefaultsManager intValueForKey:ANTIHARASS_DATABASE_TYPE defaultValue:0];
    NSInteger nowType = [UserDefaultsManager intValueForKey:ANTIHARASS_TYPE defaultValue:0];
    if ( dbType == nowType )
        return NO;
    return YES;
}

+ (void)downloadFileFrom:(NSString *)urlString to:(NSString *)filePath withSuccessBlock:(void (^)(AFHTTPRequestOperation *, id))success withFailure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, responseObject);
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    [operation start];

}

+ (void)showGuidePage{
    CommonWebViewController *controller = [[CommonWebViewController alloc] init];
    controller.url_string = [UIDevice currentDevice].systemVersion.floatValue >= 10 ? GUIDE_PATH_IOS10 : GUIDE_PATH;
    controller.header_title = @"使用必读";
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
    [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_PAGE_SHOW_TIME, @(1)), nil];
}

@end
