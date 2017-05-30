//
//  AdInfoModelManager.h
//  TouchPalDialer
//
//  Created by tanglin on 16/2/1.
//
//

#import <Foundation/Foundation.h>
#import "BannerItem.h"
#import "SubBannerItem.h"
#import "FindNewsItem.h"
#import "WebViewControllerDelegate.h"

@class AdInfoModel;
@interface AdInfoModelManager : NSObject<WebViewControllerDelegate>
@property(nonatomic, strong) AdInfoModel* model;

+ (void)initWithAd:(AdInfoModel *)ad webController:(UIViewController *)controller;
@end

@interface AdInfoModel : NSObject
@property(nonatomic, strong) NSString* s;
@property(nonatomic, strong) NSString* tu;
@property(nonatomic, strong) NSString* adId;
@property(nonatomic, strong) NSString* ctId;

- (instancetype) initWithS:(NSString *)s andTu:(NSString *)tu andAdid:(NSString *)adid;
- (instancetype) initWithS:(NSString *)s andTu:(NSString *)tu andCtid:(NSString *)ctid;
@end
