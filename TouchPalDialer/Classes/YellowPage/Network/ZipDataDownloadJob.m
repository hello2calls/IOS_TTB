//
//  ZipDataDownloadJob.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-21.
//
//

#import <Foundation/Foundation.h>
#import "ZipDataDownloadJob.h"
#import "NetworkDataDownloader.h"


@implementation ZipDataDownloadJob

- (id) initWithUrl:(NSString*)requestUrl andPath:(NSString*)path andIdentifier:(NSString *)identifier
{
    self = [super init];
    
    if(self) {
        self.downloadType = NetworkDataDownloaderYellowpage;
        self.size = 0.0;
        self.url = requestUrl;
        self.targetPath = path;
        self.identity = identifier;
        self.errorMessage = nil;
    }
    return self;
    
}

@end