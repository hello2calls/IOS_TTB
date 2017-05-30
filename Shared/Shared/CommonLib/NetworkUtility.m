//
//  NetworkUtility.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-10.
//
//

#import "NetworkUtility.h"
#import "log.h"

@implementation NetworkUtility

+ (NSData *)sendSafeSynchronousRequest:(NSMutableURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
#if DEBUG
    if ([NSThread isMainThread]) {
        cootek_log(@"ERROR! Execute sendSynchronousRequest in main thread.");
        
//        IMPORTANT: After fix the sync call network bugs, please uncomment the following line,
//        so, the debug mode can always throw exception if we execte network request in main thread.       
        @throw [[NSException alloc] initWithName:@"DEBUG EXCEPTION" reason:@"execute sendSynchronousRequest in main thread." userInfo:nil];
    }
#endif
   
    NSString* userAgent = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserAgent"];
    if (userAgent) {
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    return [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
}
@end
