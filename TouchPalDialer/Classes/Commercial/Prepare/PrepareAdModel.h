//
//  PrepareAdModel.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/9/12.
//
//

#import <Foundation/Foundation.h>

@class PrepareAdModel;

@interface PrepareAdItem : NSObject <NSCoding,NSCopying>

@property(nonatomic,assign)long expired;
@property(nonatomic,copy)NSString *htmlPath;
@property(nonatomic,copy)NSString *adPath;
@property(nonatomic,assign)int wtime;
@property(nonatomic,assign)BOOL idws;
@property(nonatomic,assign)BOOL dispaly;
@property(nonatomic,copy)NSString *uuid;
@property(nonatomic,copy)NSString *fullHtmlPath;

- (BOOL)isItemExpired;

+ (PrepareAdItem *)adItems:(NSString *)htmlPath
                    adPath:(NSString *)adPath
                   request:(NSString *)uuid
                   expired:(long)expired
                      idws:(BOOL)idws
                     wtime:(int)wtime;

@end

@protocol PrepareAdInterface

@optional

- (BOOL)needRequestPrepare;

- (BOOL)deleteAd;

- (BOOL)executePrepareAd;

- (BOOL)saveAd;

- (BOOL)downloadAdResource;

- (BOOL)allResourceDownloaded;

- (PrepareAdItem *)prepareItem;

- (void)didShowPrepareAd;

@end

@protocol PrepareAdDelegate 

@optional

- (void)needStartPrepare:(PrepareAdModel *)model afterDelay:(int)second;

@end

@interface PrepareAdModel : NSObject <PrepareAdInterface> 

@property(nonatomic,assign)int adRetryCount;
@property(nonatomic,assign)int launchCount;
@property(nonatomic,assign)int adResourceRetryCount;
@property(nonatomic,readonly,getter = _tu)NSString *tu;
@property(nonatomic,readonly,getter = _delegate)id<PrepareAdDelegate> delegate;

- (PrepareAdModel *)initWithTu:(NSString *)tu delegate:(id<PrepareAdDelegate>) delegate;

@end


