//
//  QueryCallerUtil.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import "LocalCallerUtil.h"
#import "Reachability.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "CalleridUpdateInfo.h"
#import "TouchPalVersionInfo.h"
#import "FileUtils.h"
#import <AFNetworkOperation/AFHTTPRequestOperation.h>

@implementation LocalCallerUtil

+ (void)copyDBIfNotExist {
    [[NSFileManager defaultManager] removeItemAtPath:[FileUtils getAbsoluteFilePath:[self getNameDBName]] error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:[FileUtils getAbsoluteFilePath:[self getTagDBName]] error:NULL];
    if (![FileUtils checkFileExist:[self getNameDBName]]) {
        [FileUtils copyFile:[self getNameDBName]];
    }
    if (![FileUtils checkFileExist:[self getTagDBName]]) {
        [FileUtils copyFile:[self getTagDBName]];
    }
}

+ (NSString *)getNameDBName {
    return @"1000.db";
}

+ (NSString *)getTagDBName {
    return @"1100.db";
}

+ (NSString *)getNameUpDBName {
    return @"1000_up.db";
}

+ (NSString *)getCheckFileName {
    if (USE_DEBUG_SERVER) {
        return @"packagelist_test";
    }
    return @"packagelist";
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



@end
