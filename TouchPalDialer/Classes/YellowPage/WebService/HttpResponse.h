//
//  HttpResponse.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-24.
//
//

#ifndef TouchPalDialer_HttpResponse_h
#define TouchPalDialer_HttpResponse_h

typedef enum {
    HttpRequestSuccess = 0,
    HttpRequestFailed = 1,
    HttpRequestRetry = 2
} HttpRequestStatus;

@class NSURLResponse;

@interface HttpResponse : NSObject

@property(nonatomic, assign)HttpRequestStatus requestStatus;
@property(nonatomic, assign)NSInteger httpStatus;
@property(nonatomic, retain)NSDictionary* headers;
@property(nonatomic, retain)NSData* body;

@end
#endif
