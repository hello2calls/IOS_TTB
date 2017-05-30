//
//  HttpRequest.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-24.
//
//

#ifndef TouchPalDialer_HttpRequest_h
#define TouchPalDialer_HttpRequest_h

#define HTTP_REQUEST_METHOD_DELETE @"DELETE"
#define HTTP_REQUEST_METHOD_GET @"GET"
#define HTTP_REQUEST_METHOD_POST @"POST"
#define HTTP_REQUEST_METHOD_PUT @"PUT"

typedef enum {
    HttpRequestPriorityLow = 0,
    HttpRequestPriorityNormal = 1,
    HttpRequestPriorityHigh = 2
}RequestPriority;

@interface HttpRequest : NSObject

@property(nonatomic, retain) NSString* url;
@property(nonatomic, retain) NSString* method;
@property(nonatomic, retain) NSDictionary* headers;
@property(nonatomic, retain) NSData* body;
@property(nonatomic, assign) NSInteger timeout;
@property(nonatomic, assign) RequestPriority priority;

- (void) initWithUrl:(NSString* ) url
           andMethod:(NSString* ) method
          andHeaders:(NSDictionary* ) headers
             andBody:(NSData* ) body
          andTimeout:(NSInteger) timeout
         andPriority:(RequestPriority* )priority;

+ (Request* ) httpGetWithUrl:(NSString* ) url;
+ (Request* ) httpPostWithUrl:(NSString* ) url andBody: (NSData* ) body;

@end



#endif
