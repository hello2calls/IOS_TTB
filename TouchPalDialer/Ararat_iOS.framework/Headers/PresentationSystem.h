//
//  PresentationSystem.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/11/25.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentHistoryManager.h"
#import "ActionDriver.h"
#import "NativeAppInfo.h"
#import "PresentStatistic.h"
#import "Presentations.h"

#define serverUrl @"ws2.cootekservice.com"

#if DEBUG
#define noah_log(...) NSLog(__VA_ARGS__)
#define noah_log_function NSLog(@"%s", __PRETTY_FUNCTION__)
#else
#define noah_log(...)
#define noah_log_function
#endif

@class Presentations;
@class ToolbarToast;
@class DummyToast;
@class ExtensionStaticToast;
@class BackgroundImageToast;
@class FreecallHangupToast;
@class GuidePointsToast;
@class Notification;
@interface NetworkState : NSObject
@property (nonatomic, assign) BOOL wifiConnected;
@property (nonatomic, assign) BOOL mobileConnected;

-(id)initWithWifiConnected:(BOOL)wifi andMobileConnected:(BOOL)mobile;

@end

@interface PresentationSystem : NSObject

@property (nonatomic, weak) id<NativeAppInfoDelegate> nativeAppInfoDelegate;
@property (nonatomic, weak) id<ActionDriverDelegate> actionDriverDelegate;
@property (nonatomic, weak) id<PresentStatisticDelegate> statisticDelegate;

#pragma mark - Inner Function Call
+ (id)sharedInstance;
- (NetworkState *)getNetworkState;
- (BOOL)meetNetworkWithWifi:(BOOL) wifiConnected Mobile:(BOOL) mobileConnected IfNeeded:(NSInteger) needConnection;
- (PresentHistoryManager *)getHistoryManager;
- (NSString *)storagePath;
- (NSString *)getDomainName;
- (void)setNewPresentations:(Presentations *)presents;
- (Presentations *)getPresentations;
- (NSString *)getLocale;
- (PresentToast *)getToastByFeatureId:(NSString *)fid;
- (void)clicked:(NSString *)fid and:(BOOL)afterConfirm;
- (void)setNewCleanType:(int)type;
- (void)actionPerformed:(int)actionType and:(NSArray *)stringArray;
- (void)clickException:(PresentToast *)pt;
- (NSString *)getAuthToken;
- (void)saveData;
- (NSDictionary *)initialPresentationConfig;

#pragma mark - Client Function Call
//noah调用相关
- (void)presentationInitialize;//初始化
- (void)presentationUpdate;//定时更新
- (NSString *)initialPresentationFile;//初始配置的路径
- (void)clearAllPresentations;//清空所有的推送
- (void)startNotificationRegistration;//对应黄页的startApp,注册APNs通道
- (void)processReceivedNotification:(NSDictionary *)userInfo;//didReceiveRemoteNotification处理通知
- (void)registerDevice:(NSString *)deviceToken;//注册push token, 可以删除旧有的xinge_device_token

//toasts获取
- (ToolbarToast *)getToolbarToast;
- (DummyToast *)getDummyToast;
- (NSArray *)getExtensionStaticToastAndKeyName:(NSString *)key;
- (BackgroundImageToast *)getBackgroundImageToast;
- (FreecallHangupToast *)getFreecallHangupToast;
- (int)getGuidePointNumber:(NSString *)guidePointId;
- (int)getGuidePointType:(NSString *)guidePointId;
- (void)getGuidePointClicked:(NSString *)guidePointId;
- (void)getGuidePointShown:(NSString *)guidePointId;

//事件调用
- (void)shown:(NSString *)fid;
- (void)closed:(NSString *)fid;
- (void)cleaned:(NSString *)fid;
- (void)clicked:(NSString *)fid;//click不对应confirm
- (void)actionPerformed:(NSString *)fid;//click对应confirm

//launchwebviewaction相关
- (void)webPageOpenedWithUrl:(NSString *)url;
- (void)webPageLoadedWithUrl:(NSString *)url;

//autodownloadurl和imageurl获取地址
- (NSString *)getPresentImagePath:(NSString *)toastId;
- (NSString *)getDownloadFilePath:(NSString *)toastId;

//有需求的话可以调
- (void)setNotShowAgainWithToastId:(NSString *)toastId and:(BOOL)notShowAgain;
- (BOOL)isToastExistWithToastId:(NSString *)toastId;
- (int)getPresentTimesWithToastId:(NSString *)toastId;

@end


