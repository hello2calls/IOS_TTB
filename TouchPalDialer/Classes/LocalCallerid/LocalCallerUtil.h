//
//  QueryCallerUtil.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworkOperation/AFHTTPRequestOperation.h>
#define ONLINE_FILE_PATH @"http://dialer.cdn.cootekservice.com/android/default/callerid/v5420/default"

@interface LocalCallerUtil : NSObject

+ (void)copyDBIfNotExist;
+ (NSString*) getNameDBName;
+ (NSString*) getNameUpDBName;
+ (NSString*) getTagDBName;
+ (NSString*) getCheckFileName;
+ (void) downloadFileFrom:(NSString*)url to:(NSString*)filePath withSuccessBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success withFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
