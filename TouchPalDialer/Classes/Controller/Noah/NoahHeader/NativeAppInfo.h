//
//  NativeAppInfo.h
//  Presentation_Test
//
//  Created by SongchaoYuan on 14/12/8.
//  Copyright (c) 2014年 SongchaoYuan. All rights reserved.
//

@protocol NativeAppInfoDelegate <NSObject>

@required
//feature相关匹配项
- (NSString *)getStringSetting:(NSString *)key;
- (int)getIntSetting:(NSString *)key;
- (long)getLongSetting:(NSString *)key;
- (BOOL)getBoolSetting:(NSString *)key;

//更新策略
- (int)getInitialQuietDays;
- (int)getInitialMobileQuietDays;

//获取用户的token
- (NSString *)getAuthToken;

@optional
//App首次安装的时间
- (long)getFirstInstallTimestamp;

//extensionstatictoast相关配置
- (BOOL)canExtend:(NSString *)extensionPoint and:(NSString *) extensionConditions;

//guidepointstoast相关配置
- (BOOL)canPointSelfShow:(NSString *)guidePointId and:(NSString *)selfShowConditions;
- (BOOL)canPointHolderShow:(NSString *)guidePointId and:(NSString *)holderShowConditions and:(NSString *)extensionId;
@end