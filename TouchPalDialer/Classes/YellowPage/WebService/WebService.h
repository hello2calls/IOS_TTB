//
//  WebService.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-23.
//
//

#ifndef TouchPalDialer_WebService_h
#define TouchPalDialer_WebService_h


@class NSURLConnection;
@class NSURLResponse;
@class NSURLRequest;
@class NSURLErrorDomain;
@class HttpRequest;
@class HttpResponse;

@protocol ConnectionDelegate <NSObject>
@optional
- (void)connection:(HttpRequest *)request didFailWithError:(HttpResponse *)response;
@end

@protocol ConnectionDataDelegate <ConnectionDelegate>
@optional
- (void)connection:(HttpRequest *)request didReceiveResponse:(HttpResponse *)response;
- (void)connectionDidFinishLoading:(HttpRequest *)request;
@end

@protocol ConnectionDowloadDelegate <ConnectionDelegate>
@optional
- (void)connection:(HttpRequest *)request didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes;
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL;
@end

@interface WebService : NSObject
- (void) abort:(Request *)request;
- (void) asyncExec:(Request *)request delegate:(id)delegate;
- (HttpResponse* ) syncExec:(Request *)request;
@end
#endif
