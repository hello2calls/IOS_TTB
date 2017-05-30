//
//  ZipDataDownloadJob.h
//  TouchPalDialer
//
//  Created by tanglin on 15-4-21.
//
//

#ifndef TouchPalDialer_ZipDataDownloadJob_h
#define TouchPalDialer_ZipDataDownloadJob_h
#import "NetworkDataDownloader.h"

@interface ZipDataDownloadJob : NetworkDownloaderJob

- (id) initWithUrl:(NSString*)requestUrl andPath:(NSString*)path andIdentifier:(NSString*)identifier;
@end
#endif
