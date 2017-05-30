//
//  VoipCommercialPresent.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/7/29.
//
//

#import <Foundation/Foundation.h>
#import "HangupCommercialModel.h"
#import "AdShowtimeManager.h"
#import "AdLandingPageManager.h"
#import "HandlerWebViewController.h"
#define CALL_TYPE_P2P @"P2P"
#define CALL_TYPE_C2P @"C2P"
#define CALL_TYPE_C2C @"C2C"

// for debugging
#define CALL_TYPE_BACK_CALL @"BACK_CALL"

@protocol HangupCommercialManagerDelegate <NSObject>
- (void)callingCommercialDataDidLoad:(AdMessageModel *)ad image:(UIImage *)image;
@end


@interface HangupCommercialManager : NSObject
@property(nonatomic,retain)HangupCommercialModel *commercialModel;
@property(nonatomic,assign)NSInteger adCount;
@property(nonatomic,retain)NSMutableArray *observerList;
@property (nonatomic, assign) NSTimeInterval lastWebAdRequestTime;

+ (HangupCommercialManager *)instance;

- (void)setAdLandingPageManager:(AdLandingPageManager*)AdLandingPageManager
                      ifCallIng:(BOOL)ifCalling;

- (void)asyncAskCommercialWithCallingNumber:(NSString *)number
                                andCallType:(NSString *)callType
                                         tu:(NSString *)tu
                                       uuid:(NSString *)uuid;

- (NSDictionary *)asyncCommercialAd:(NSString *)tu param:(NSDictionary *)param;

- (UIImage *)getImage;

- (NSString *)getClickText;

- (NSString *)getJumpTitle;

- (NSString *)getJumpUrl;

- (void)handleClickWithCloseBlock:(void(^)(void))closeBlock;

- (void)tellClick;

- (void)tellShow:(BOOL)realShow;

- (void)didShowAD:(AdMessageModel *)ad show:(BOOL)realShow;

- (void)didClickAD:(AdMessageModel *)ad;

- (void)hangupADDisappearWithCloseType:(ADCloseType)closeTyep;

- (void)callingADDisappearWithCloseType:(ADCloseType)closeTyep;

- (void)callingViewADDidLoad:(AdMessageModel *)ad;

- (NSString *)getGuideText;

- (void)finishPresent;

- (void)addADObserver:(id<HangupCommercialManagerDelegate>)observer;

- (void)removeADObserver:(id<HangupCommercialManagerDelegate>)observer;

- (BOOL)isDirectAD;

- (void)showDirectAD;

-(BOOL)checkIfResourceReady;

- (void)asyncVisitUrl:(NSString *)url;

- (NSArray *)getNotReadyAdResources;

- (NSString *)commericalRequestCK:(NSString *)tu;

@end
