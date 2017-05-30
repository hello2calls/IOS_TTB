//
//  ActionDriver.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/8.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//



@protocol ActionDriverDelegate <NSObject>

@required
//加载完本地的配置文件
- (void)endLoadLocalFile:(BOOL) result;

//加载完更新后的配置文件
- (void)endLoadRemoteFile:(BOOL) result;

//当客户端接收到新的通知之后
- (BOOL)receiveNewUpdateNotification;

//配置文件和相关文件存放位置
- (NSString *)storagePath;

@optional
//配置文件名称
- (NSString *)configFileName;

//测试专用，填写测试服务器地址
- (NSString *)serverURL;

//Action的通用接口
- (void)showActionConfirmDialog:(NSString *)toastId and:(NSString *) confirmText;
- (void)close:(NSString *)toastId;

//changelocalsettingsaction的接口
- (BOOL)changeBoolSetting:(NSString *)key Value:(BOOL)value OnlyDefault:(BOOL)onlyDefault;
- (BOOL)changeIntSetting:(NSString *)key Value:(int)value OnlyDefault:(BOOL)onlyDefault;
- (BOOL)changeStringSetting:(NSString *)key Value:(NSString *)value OnlyDefault:(BOOL)onlyDefault;
- (BOOL)changeLongSetting:(NSString *)key Value:(long)value OnlyDefault:(BOOL)onlyDefault;

//launchwebviewaction的接口
- (BOOL)openUrl:(NSString *) url WebTitle:(NSString *)webTitle RequestToken:(BOOL)requestToken;

//launchlocalpageaction的接口
- (BOOL)lauchLocalController:(NSString *)localPageName;

@end