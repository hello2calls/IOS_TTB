//
//  PrepareAdInterface.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/9.
//
//

#ifndef PrepareAdInterface_h
#define PrepareAdInterface_h

@protocol PrepareAdInterface <NSObject>

- (BOOL)needRequestPrepare;

- (BOOL)deleteAd;

- (BOOL)executePrepareAd;

- (BOOL)saveAd;

- (BOOL)downloadAdResource;

- (BOOL)allResourceDownloaded;

@end

#endif /* PrepareAdInterface_h */

@interface PrepareAdModel : NSObject
@property(nonatomic,assign)int adRetryCount;
@property(nonatomic,assign)int adResourceRetryCount;
@end
