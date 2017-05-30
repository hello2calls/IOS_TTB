//
//  DownloadFile.m
//  WebViewLoadDemo
//
//  Created by Liangxiu on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkDataDownloader.h"
#import "TPDialerResourceManager.h"
#import <ZipArchive/ZipArchive.h>
#import "UserDefaultsManager.h"
#import "Reachability.h"
#import "UserDefaultKeys.h"
#import "CootekNotifications.h"
#import "SeattleExecutorHelper.h"
#import "AppSettingsModel.h"
#import "consts.h"

#define KEY_ENTER_FOREGROUND_AUTO_UPDATE_CITY_JOB_ID @"KEY_ENTER_FOREGROUND_AUTO_UPDATE_CITY_JOB_ID"

@implementation  NetworkDownloaderJob
@synthesize identity;
@synthesize size;
@synthesize factor;
@synthesize url;
@synthesize targetPath;
@synthesize tmpTargetPath;
@synthesize downloadType;
@synthesize errorMessage;

-(BOOL) readyForDownload {
    return YES;
}

-(BOOL) prepare {
    return YES;
}

-(void) successDown{
    cootek_log(@"successDown id =%@",self.identity);
}
@end


@interface NetworkDataDownloaderWrapper (){
    CGFloat totalFileSize_;
    CGFloat completePercent_;
    NSInteger index_;
    NSMutableArray *downloaders_;
}
-(void)download:(NSInteger)index;
@end
@implementation NetworkDataDownloaderWrapper

@synthesize wapperID = wapperID_;
@synthesize downloaders = downloaders_;
@synthesize downloadStatus = downloadStatus_;
@synthesize downloadPercent = downloadPercent_;

-(id)initWithJobs:(NSArray*) jobs wrapperID:(NSString *)idStr{
    self = [super init];
    if(self != nil) {
        NSMutableArray *downloader = [[NSMutableArray alloc] initWithCapacity:[jobs count]];
        self.downloaders = downloader;
        
        wapperID_ = [idStr copy];
        [self resetStatus];
        for (NetworkDownloaderJob *job in jobs) {
            NetworkDataDownloader *downloader = [NetworkDataDownloadManager downloaderForJob:job];
            if(downloader.downloadStatus == NetworkDataDownloadPaused
               || downloader.downloadStatus == NetworkDataDownloadNotStarted){
                NetworkDataDownloader *downloader = [NetworkDataDownloadManager downloaderForJob:job];
                totalFileSize_ = totalFileSize_ + job.size;
                downloader.delegate = self;
                [downloaders_ addObject:downloader];
            }
        }
        for (NetworkDownloaderJob *job in jobs) {
            if (totalFileSize_ > 0) {
                job.factor = (job.size/totalFileSize_);
            }else{
                job.factor = 1.0;
            }
        }
    }
    return self;
}
-(void)willChangeDownPercent:(CGFloat)percent{
    downloadPercent_ = completePercent_ + percent;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_DOWNLOAD_DATA_PROGRESS object:self userInfo:nil];
}
-(void)completePercent:(CGFloat )factor{
   int count = [downloaders_ count];
   if (count > 1) {
        completePercent_ = factor + completePercent_;
   }
}
-(void)willChangeDownStatus:(NetworkDataDownloadStatus)status{
    switch (status) {
        case NetworkDataDownloadStarting:
            downloadStatus_ = NetworkDataDownloadStarting;
            break;
        case NetworkDataDownloadDownloading:
            downloadStatus_ = NetworkDataDownloadDownloading;
            break;
        case NetworkDataDownloadRetrying:
            downloadStatus_ = NetworkDataDownloadRetrying;
            break;
        case NetworkDataDownloadPaused:
            downloadStatus_ = NetworkDataDownloadPaused;
            break;
        case NetworkDataDownloadStoped:{
            downloadStatus_ = NetworkDataDownloadStoped;
            [self stopDownload];
            break;
        }
        case NetworkDataDownloadFailed:{
            downloadStatus_ = NetworkDataDownloadFailed;
            [self downloadFailed];
            break;
        }
        case NetworkDataDownloadCompleted:{
            index_ = index_ +1;
            [self download:index_];
            break;
        }
        default:
            break;
    }
}

-(void)download:(NSInteger)index{
    @synchronized(self) {
        if(downloadStatus_ == NetworkDataDownloadCompleted) {
            //Already completed. Notify the UI.
            return;
        }
        if(downloadStatus_ == NetworkDataDownloadFailed) {
            cootek_log(@"Retry downloading");
            [self resetStatus];
        }
        if (index < [downloaders_ count]) {
            NetworkDataDownloader *downloader = [downloaders_
                                                 objectAtIndex:index];
           BOOL isStart = [downloader download];
           if (!isStart) {
               index_ ++;
               [self download:index_];
           }
        }else{
            downloadStatus_ = NetworkDataDownloadCompleted;
            [self downloadCompleted];
        }
    }
}

#pragma NetworkDataDownloaderDelegate
-(void)downloadFailed{
    @synchronized(self) {
        if ([NetworkDataDownloadWrapperManager downloaderForWrappID:wapperID_]) {
            NetworkDataDownloader *downloader = [downloaders_ objectAtIndex:[downloaders_ count]-1];
            if(![wapperID_ isEqualToString:KEY_ENTER_FOREGROUND_AUTO_UPDATE_CITY_JOB_ID]){
                if (downloader.job.errorMessage) {
                    UIAlertView *alert = [[UIAlertView alloc] init];
                    [alert setMessage:downloader.job.errorMessage];
                    [alert addButtonWithTitle:NSLocalizedString(@"Ok",@"")];
                    [alert show];
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_DOWNLOAD_DATA_FAIL object:self userInfo:nil];
                }

            }
            [NetworkDataDownloadWrapperManager removeDownloaderForIdentity:wapperID_];
        }
    }
}
-(void)downloadCompleted{
    @synchronized(self) {
        if ([NetworkDataDownloadWrapperManager downloaderForWrappID:wapperID_]) {
            if(![wapperID_ isEqualToString:KEY_ENTER_FOREGROUND_AUTO_UPDATE_CITY_JOB_ID]){
                [[NSNotificationCenter defaultCenter] postNotificationName:N_DOWNLOAD_DATA_SUCCESS object:self userInfo:nil];
            }else{
               [UserDefaultsManager setObject:@NO forKey:KEY_IS_YELLOW_CITY_UPDATE_IN_PROCESS];
            }
            [NetworkDataDownloadWrapperManager removeDownloaderForIdentity:wapperID_];
        }
    }
}
-(BOOL)download{
    @synchronized(self) {
        if(downloadStatus_ == NetworkDataDownloadCompleted) {
            //Already completed. Notify the UI.
            return NO;
        }
        if(downloadStatus_ == NetworkDataDownloadFailed) {
            cootek_log(@"Retry downloading");
            [self resetStatus];
        }
        if(downloadStatus_ != NetworkDataDownloadNotStarted) {
            cootek_log(@"cannot download as the status is not NotStarted.");
            return NO;
        }
        [self download:index_];
        return YES;
    }
}
-(void)downloadPaused{
    if(downloadStatus_ == NetworkDataDownloadNotStarted
       ||downloadStatus_ == NetworkDataDownloadCompleted
       ||downloadStatus_ == NetworkDataDownloadFailed
       ||downloadStatus_ == NetworkDataDownloadStoped){
        return;
    }
    @synchronized(self) {
        if (index_ < [downloaders_ count]) {
            NetworkDataDownloader *downloader = [downloaders_ objectAtIndex:index_];
            [downloader downloadPaused];
        }
    }
}
-(BOOL)downloadResume{
    if (downloadStatus_ != NetworkDataDownloadPaused) {
        return NO;
    }
    @synchronized(self) {
        if (index_ < [downloaders_ count]) {
            NetworkDataDownloader *downloader = [downloaders_ objectAtIndex:index_];
            BOOL isResume = [downloader downloadResume];
            if (!isResume) {
                index_ = index_ +1;
                [self download:index_];
            }
        }
    }
    return YES;
}
-(void)cancelDownload{
    if(downloadStatus_ != NetworkDataDownloadDownloading
       && downloadStatus_ != NetworkDataDownloadStarting){
        return;
    }
    @synchronized(self) {
        if ([NetworkDataDownloadWrapperManager downloaderForWrappID:wapperID_]) {
            for (NetworkDataDownloader *downloader in downloaders_) {
                [downloader cancelDownload];
            }
            [self resetStatus];
            [NetworkDataDownloadWrapperManager removeDownloaderForIdentity:wapperID_];
        }
    }
}
-(void)stopDownload{
    if(downloadStatus_ != NetworkDataDownloadDownloading){
        return;
    }
    @synchronized(self) {
        if ([NetworkDataDownloadWrapperManager downloaderForWrappID:wapperID_]) {
            CGFloat tmpPercent = downloadPercent_;
            [self resetStatus];
            downloadPercent_ = tmpPercent;
            downloadStatus_ = NetworkDataDownloadStoped;
            for (NetworkDataDownloader *downloader in downloaders_) {
                [downloader stopDownload];
            }
            [NetworkDataDownloadWrapperManager removeDownloaderForIdentity:wapperID_];
        }
    }
}

-(void)resetStatus{
    index_ = 0;
    completePercent_ = 0.0;
    totalFileSize_ = 0.0;
    downloadPercent_ = 0.0;
    downloadStatus_ = NetworkDataDownloadNotStarted;
}
@end

@interface NetworkDataDownloader() {
    NetworkDownloaderJob* job_;
    NetworkDataDownloadStatus downloadStatus_;
    CGFloat totalFileSize_;
    long long downloadedSize_;
    CGFloat downloadPercent_;
    NSInteger failedCount_;
    
    NSFileHandle __strong *fileHandler_;
    NSURLConnection *connection_;
}
- (void) retryDownload;
- (void) closeFileHandle;
- (void) closeConnect;
- (void) removeTmpFiles;
@end
@implementation NetworkDataDownloader
@synthesize delegate;
@synthesize job = job_;
@synthesize downloadStatus = downloadStatus_;
@synthesize downloadPercent = downloadPercent_;
@synthesize downloadedSize = downloadedSize_;

- (id) initWithJob:(NetworkDownloaderJob *)job {
    self = [super init];
    if(self != nil) {
        job_ = job;
    }
    return self;
}
- (void)resetStatus {
    @synchronized(self) {
        downloadedSize_ = 0;
        totalFileSize_ = 0;
        downloadPercent_ = 0;
        failedCount_ = 0;
        [self closeConnect];
        [self closeFileHandle];
 
        downloadStatus_ = NetworkDataDownloadNotStarted;
    }
}
- (void) closeFileHandle{
    if(fileHandler_ != nil) {
        [fileHandler_ closeFile];
        fileHandler_ = nil;
    }
}
- (void) closeConnect{
    if(connection_ != nil) {
        [connection_ cancel];
        connection_ = nil;
    }
}
- (void) removeTmpFiles{
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:job_.tmpTargetPath]) {
        [fileManager removeItemAtPath:job_.tmpTargetPath error:&err];
    }
    if ([fileManager fileExistsAtPath:job_.targetPath]) {
        [fileManager removeItemAtPath:job_.targetPath error:&err];
    }
}
-(void) prepareAndDownload {
    if([self.job prepare]) {
        [self performSelectorOnMainThread:@selector(downloadPrivate) withObject:nil waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(downloadFailed) withObject:nil waitUntilDone:NO];
    }
}

-(void) downloadPrivate {
    NSURL* url = [NSURL URLWithString:self.job.url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err = nil;
    BOOL result = YES;
    job_.tmpTargetPath = [NSString stringWithFormat:@"%@.tmp",job_.targetPath];

    if(![fm fileExistsAtPath:[self.job.tmpTargetPath stringByDeletingLastPathComponent]]){
        result =  [fm createDirectoryAtPath:[self.job.tmpTargetPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&err];
        if(!result) {
            cootek_log(@"create target path hit error %@", err);
            [self downloadFailed];
            return;
        }
    }
    if ([fm fileExistsAtPath:job_.tmpTargetPath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:job_.tmpTargetPath
                                                            error:&error];
        if (!error && fileDictionary)
            downloadedSize_ = [fileDictionary fileSize];
    } else {
        [fm createFileAtPath:job_.tmpTargetPath contents:nil attributes:nil];
    }
    if(downloadedSize_ > 0){
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%lld-", downloadedSize_];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    downloadStatus_ = NetworkDataDownloadStarting;
    [delegate willChangeDownStatus:downloadStatus_];
    
    
}

- (void)retryDownload{
    @synchronized(self){
        downloadStatus_ = NetworkDataDownloadRetrying;
        [delegate willChangeDownStatus:downloadStatus_];
        if(connection_!=nil){
            [self closeConnect];
            NSURL* url = [NSURL URLWithString:self.job.url];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                               timeoutInterval:60];
            if(downloadedSize_ > 0){
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%lld-", downloadedSize_];
                [request setValue:requestRange forHTTPHeaderField:@"Range"];
            }
            connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        }
    }
}
-(void)downloadPaused{
    @synchronized(self){
        downloadStatus_ = NetworkDataDownloadPaused;
        [delegate willChangeDownStatus:downloadStatus_];
        [self closeConnect];
    }
}
-(BOOL)downloadResume{
    if(downloadStatus_ != NetworkDataDownloadPaused) {
        return NO;
    }
    if ([NetworkDataDownloadManager downloaderForJobIdentity:self.job.identity]) {
        NSURL* url = [NSURL URLWithString:self.job.url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:60];
        if(downloadedSize_ > 0){
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%lld-", downloadedSize_];
            [request setValue:requestRange forHTTPHeaderField:@"Range"];
        }
        connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        return YES;
    }else{
        self.delegate = nil;
        return  NO;
    }
}
- (void)downloadCompleted
{
    @synchronized(self) {
        downloadedSize_ = totalFileSize_;
        downloadPercent_ = 1;
        
        downloadStatus_ = NetworkDataDownloadCompleted;
        [delegate completePercent:job_.factor];
        [job_ successDown];
        [delegate willChangeDownStatus:downloadStatus_];
        
        [self resetStatus];
        [NetworkDataDownloadManager removeDownloaderForIdentity:job_.identity];
   
    }
}
- (void)downloadFailed
{
    @synchronized(self) {
        
        downloadedSize_ = 0;
        downloadPercent_ = 0;

        downloadStatus_ = NetworkDataDownloadFailed;
        [delegate willChangeDownStatus:downloadStatus_];
        
        [self resetStatus];
        [NetworkDataDownloadManager removeDownloaderForIdentity:job_.identity];
    }
}


-(BOOL)download{
    @synchronized(self) {
        if (![NetworkDataDownloadManager downloaderForJobIdentity:self.job.identity]){
            return NO;
        }
        if(downloadStatus_ == NetworkDataDownloadCompleted) {
            //Already completed. Notify the UI.
            return NO;
        }
         if(downloadStatus_ != NetworkDataDownloadNotStarted) {
            cootek_log(@"cannot download as the status is not NotStarted.");
            return NO;
        }
      
        if(downloadStatus_ == NetworkDataDownloadFailed) {
            cootek_log(@"Retry downloading");
            [self resetStatus];
        }
        if(![self.job readyForDownload]) {
            [self performSelectorInBackground:@selector(prepareAndDownload) withObject:nil];
        } else {
            [self downloadPrivate];
        }
        return YES;
    }
}

-(void)cancelDownload{
    if(downloadStatus_ != NetworkDataDownloadDownloading
       && downloadStatus_ != NetworkDataDownloadStarting){
        return;
    }
    @synchronized(self) {
       
        [self resetStatus];
        [self removeTmpFiles];
        [NetworkDataDownloadManager removeDownloaderForIdentity:job_.identity];
    }
}
-(void)stopDownload{
    if(downloadStatus_ != NetworkDataDownloadDownloading){
        return;
    }
    @synchronized(self) {
        CGFloat tmpPercent = downloadPercent_;
        downloadPercent_ = tmpPercent;
        downloadStatus_ = NetworkDataDownloadStoped;
        [delegate willChangeDownStatus:downloadStatus_];
        [self resetStatus];
    }
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
 
    return request;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    @synchronized(self) {
        if(downloadStatus_ != NetworkDataDownloadStarting
           && downloadStatus_ !=NetworkDataDownloadRetrying
           && downloadStatus_ !=NetworkDataDownloadPaused) {
            cootek_log(@"Not in starting status. Ignore the response.");
            return;
        }
        fileHandler_ = [NSFileHandle fileHandleForWritingAtPath:job_.tmpTargetPath];
        NSHTTPURLResponse *tmpResponse = (NSHTTPURLResponse *)response;
        int status=[tmpResponse statusCode];
        if (status >= REQUEST_SUCCESS && status <= REQUEST_SUCCESS_MAX) {
            totalFileSize_ = response.expectedContentLength;
            cootek_log(@"Totole Size zz = %f",totalFileSize_);
            downloadStatus_ = NetworkDataDownloadDownloading;
            [delegate willChangeDownStatus:downloadStatus_];
            if(downloadedSize_ < 0){
                downloadedSize_ =0;
            }
            [fileHandler_ seekToFileOffset:downloadedSize_];
        }else{
            [self downloadFailed];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @synchronized(self) {
        if(downloadStatus_ != NetworkDataDownloadDownloading) {
            cootek_log(@"Not in downloading status. Ignore the data.");
            return;
        }
        
        downloadedSize_+=[data length];
        if(totalFileSize_ > 0) {
            downloadPercent_ = downloadedSize_/totalFileSize_;
        } else {
            downloadPercent_ = 0;
        }
        @try {
            [fileHandler_ writeData:data];
            [fileHandler_ synchronizeFile];
            [delegate willChangeDownPercent:downloadPercent_*job_.factor];
        }
        @catch (NSException *exception) {
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(self) {
        cootek_log(@"error = %@",error);
        if(failedCount_++>2){
            [self downloadFailed];
        }else{
            [self retryDownload];
        }
   }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    @synchronized(self) {
        if(downloadStatus_ != NetworkDataDownloadDownloading) {
            cootek_log(@"Not in downloading status. Skip the didFinishLoading call.");
            return;
        }
        [self closeFileHandle];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
            //rename
            NSError *err = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            cootek_log(@"targetPath = %@ tmpTargetPath=%@",job_.targetPath,job_.tmpTargetPath);
            [fileManager moveItemAtPath:job_.tmpTargetPath toPath:job_.targetPath error:&err];
            if(!err){
                if([self.job.targetPath rangeOfString:@".zip"].length>0){
                    BOOL result = YES;
                    ZipArchive *zipArchive = [[ZipArchive alloc] init];
                    result = [zipArchive UnzipOpenFile:self.job.targetPath Password:@""];
                    if(result) {
                        result = [zipArchive UnzipFileTo:[self.job.targetPath stringByDeletingLastPathComponent]  overWrite:YES];
                    }
                    if(result) {
                        result = [zipArchive UnzipCloseFile];
                    }
                    if(!result) {
                        cootek_log(@"unzip downloading file failed.");
                        [self removeTmpFiles];
                        dispatch_async(dispatch_get_main_queue(), ^(){[self downloadFailed];});
                        return;
                    }
                }
                [self removeTmpFiles];
                dispatch_async(dispatch_get_main_queue(), ^(){[self downloadCompleted];});
            }else{
                cootek_log(@"copy file error = %@",err);
                [self removeTmpFiles];
                dispatch_async(dispatch_get_main_queue(), ^(){[self downloadFailed];});
            }
        });
    }
}

-(void)dealloc{
    [self resetStatus];
}
@end

@implementation  NetworkDataDownloadManager

static NSMutableDictionary* downloaders;

+ (void) initialize {
    @synchronized(self) {    
        // need if (...) to make sure the static initialize only been executed once
        // http://www.friday.com/bbum/2009/09/06/iniailize-can-be-executed-multiple-times-load-not-so-much/
        if (self == [NetworkDataDownloadManager class]) {
            downloaders = [[NSMutableDictionary alloc] init];
        }
    }
}

+(NetworkDataDownloader*) downloaderForIdentity:(NSString*) identity {
    if(identity == nil || [identity length] == 0) {
        return nil;
    }
    
    @synchronized(self) {
        return [downloaders objectForKey:identity];
    }
}
+(BOOL) downloaderForJobIdentity:(NSString *)identity{
    NetworkDataDownloader* downloader = nil;
    @synchronized(self) {
        downloader = [downloaders objectForKey:identity];
        if(downloader) {
            return YES;
        }
    }
    return NO;
}
+(NetworkDataDownloader*) downloaderForJob:(NetworkDownloaderJob *)job;
{
    NetworkDataDownloader* downloader = nil;
    @synchronized(self) {
        downloader = [downloaders objectForKey:job.identity];
        if(downloader == nil) {
            downloader = [[NetworkDataDownloader alloc] initWithJob:job];
            if(downloader != nil) {
                [downloaders setObject:downloader forKey:job.identity];
            }
        }
    }
    
    return downloader;
}

+(void) removeDownloaderForIdentity:(NSString*) identity {
    if(identity == nil || [identity length] == 0) {
        return;
    }
    
    @synchronized(self) {
        [downloaders removeObjectForKey:identity];
    }
}

+(NSInteger) countForDownloadingItems:(NetworkDataDownloaderType)downloadType {
    @synchronized(self) {
        NSInteger i = 0;
        for(NetworkDataDownloader* downloader in [downloaders allValues]) {
            if(downloader.job.downloadType == downloadType) {
                if (downloader.downloadStatus == NetworkDataDownloadDownloading || downloader.downloadStatus == NetworkDataDownloadStarting) {
                    i++;
                }
            }
        }
        return i;
    }
}
@end

@implementation NetworkDataDownloadWrapperManager
static NSMutableDictionary* downloaderWrappers;

+ (void) initialize {
    @synchronized(self) {
        if (self == [NetworkDataDownloadWrapperManager class]) {
            downloaderWrappers = [[NSMutableDictionary alloc] init];
        }
    }
}

+(NSArray *)identities
{
    @synchronized(self) {
        return [NSArray arrayWithArray:[downloaderWrappers allKeys]];
    }
}

+(BOOL) downloaderForWrappID:(NSString *)identity{
    NetworkDataDownloaderWrapper* downloader = nil;
    @synchronized(self) {
        downloader = [downloaderWrappers objectForKey:identity];
        if(downloader) {
            return YES;
        }
    }
    return NO;
}
+(NetworkDataDownloaderWrapper*) downloaderForJobs:(NSArray*)jobs identity:(NSString *)identity{
    NetworkDataDownloaderWrapper* downloaderWrapper = nil;
    @synchronized(self) {
        downloaderWrapper = [downloaderWrappers objectForKey:identity];
        if(downloaderWrapper == nil) {
            downloaderWrapper = [[NetworkDataDownloaderWrapper alloc] initWithJobs:jobs wrapperID:identity];
            if(downloaderWrapper != nil) {
                [downloaderWrappers setObject:downloaderWrapper forKey:identity];
            }
        }
    }
    return downloaderWrapper;
}

+(NetworkDataDownloaderWrapper*) downloaderForJob:(NetworkDownloaderJob*) job{
    NetworkDataDownloaderWrapper* downloaderWrapper = nil;
    @synchronized(self) {
        downloaderWrapper = [downloaderWrappers objectForKey:job.identity];
        if(downloaderWrapper == nil) {
            NSArray *jobs = [NSArray arrayWithObject:job];
            downloaderWrapper = [[NetworkDataDownloaderWrapper alloc] initWithJobs:jobs wrapperID:job.identity];
            if(downloaderWrapper != nil) {
                [downloaderWrappers setObject:downloaderWrapper forKey:job.identity];
            }
        }
    }
    return downloaderWrapper;
}
+(void) removeDownloaderForIdentity:(NSString*) identity {
    if(identity == nil || [identity length] == 0) {
        return;
    }
    
    @synchronized(self) {
        NetworkDataDownloaderWrapper *wrapper = [downloaderWrappers objectForKey:identity];
        NSArray *downloaders = [wrapper downloaders];
        for (NetworkDataDownloader *dowloader in downloaders) {
            dowloader.delegate = nil;
        }
        [downloaderWrappers removeObjectForKey:identity];
    }
}
+(NetworkDataDownloaderWrapper*) downloaderForIdentity:(NSString*) identity {
    if(identity == nil || [identity length] == 0) {
        return nil;
    }
    
    @synchronized(self) {
        return [downloaderWrappers objectForKey:identity];
    }
}
@end