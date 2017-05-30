//
//  DownloadFile.h
//  WebViewLoadDemo
//
//  Created by Liangxiu on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NetworkDataDownloadNotStarted,
    NetworkDataDownloadStarting,
    NetworkDataDownloadStoped,
    NetworkDataDownloadPaused,
    NetworkDataDownloadRetrying,
    NetworkDataDownloadDownloading,
    NetworkDataDownloadCompleted,
    NetworkDataDownloadFailed,
}NetworkDataDownloadStatus;

typedef enum {
    NetworkDataDownloaderYellowpage,
    NetworkDataDownloaderSkin,
}NetworkDataDownloaderType;

typedef void (^DownloadBlock) (NSInteger result);

@protocol NetworkDataDownloaderDelegate
@property (readonly) NetworkDataDownloadStatus downloadStatus;
@property (readonly) CGFloat downloadPercent;
-(void)resetStatus;
-(void)downloadFailed;
-(BOOL)download;
-(void)cancelDownload;
-(void)stopDownload;
-(void)downloadCompleted;
-(void)downloadPaused;
-(BOOL)downloadResume;
@end

@protocol WrapperDownloaderDelegate
@property (readonly) NetworkDataDownloadStatus downloadStatus;
@property (readonly) CGFloat downloadPercent;
-(void)willChangeDownPercent:(CGFloat)percent;
-(void)willChangeDownStatus:(NetworkDataDownloadStatus)status;
-(void)completePercent:(CGFloat )factor;
@end

@interface NetworkDownloaderJob : NSObject
@property (nonatomic, retain) NSString* identity;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* targetPath;
@property (nonatomic, retain) NSString* tmpTargetPath;
@property (nonatomic) NetworkDataDownloaderType downloadType;
@property (nonatomic, retain) NSString* errorMessage;
@property (nonatomic, assign) CGFloat size ;
@property (nonatomic, assign) CGFloat factor;
-(BOOL) readyForDownload;
-(BOOL) prepare;
-(void) successDown;
@end

@interface NetworkDataDownloader : NSObject<NSURLConnectionDataDelegate,NetworkDataDownloaderDelegate>
@property (readonly,strong) NetworkDownloaderJob* job;
@property (readonly) long long downloadedSize;
@property (assign) id<WrapperDownloaderDelegate> delegate;
-(id) initWithJob:(NetworkDownloaderJob*) job;
@end

@interface NetworkDataDownloaderWrapper : NSObject<NetworkDataDownloaderDelegate,WrapperDownloaderDelegate>
@property (nonatomic, copy) NSString *skinID;
@property (readonly,copy) NSString* wapperID;
@property (nonatomic,retain) NSArray *downloaders;
@property (nonatomic, copy) DownloadBlock downloadBlock;
-(id)initWithJobs:(NSArray*) jobs wrapperID:(NSString *)idStr;
@end

@interface NetworkDataDownloadManager : NSObject
+(BOOL) downloaderForJobIdentity:(NSString *)identity;
+(NetworkDataDownloader*) downloaderForIdentity:(NSString*) identity;
+(NetworkDataDownloader*) downloaderForJob:(NetworkDownloaderJob*) job;
+(void) removeDownloaderForIdentity:(NSString*) identity;
+(NSInteger) countForDownloadingItems:(NetworkDataDownloaderType)downloadType;
@end

@interface NetworkDataDownloadWrapperManager : NSObject
+(NetworkDataDownloaderWrapper*) downloaderForJobs:(NSArray*)jobs identity:(NSString *)identity;
+(NetworkDataDownloaderWrapper*) downloaderForJob:(NetworkDownloaderJob*) job;
+(NetworkDataDownloaderWrapper*) downloaderForIdentity:(NSString*) identity;
+(void) removeDownloaderForIdentity:(NSString*) identity;
+(BOOL) downloaderForWrappID:(NSString *)identity;
+(NSArray *)identities;
@end
