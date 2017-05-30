//
//  NetworkUtil.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-21.
//
//

#ifndef TouchPalDialer_NetworkUtil_h
#define TouchPalDialer_NetworkUtil_h

@interface NetworkUtil : NSObject

//+ (void) executeWithUrl:(NSString*)url;
+ (void) executeWithUrlRequest:(NSURLRequest*)request success:(void(^)(NSData*))resultSuccess failure:(void(^)(NSData*))resultFailure;
@end

#endif
