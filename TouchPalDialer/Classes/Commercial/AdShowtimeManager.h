//
//  AdShowtimeManager.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/25.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, ADCloseType) {
    ADCLOSE_UNKNOW             = 0,// 未知行为
    ADCLOSE_BUTTEN_CLICKAD     = 1,// 点击广告按钮
    ADCLOSE_BUTTEN_REDIALER    = 2,// 点击回拨按钮
    ADCLOSE_BUTTEN_CLOSE       = 3,// 点击关闭按钮
    ADCLOSE_BUTTEN_COMPLAIN    = 4,// 点击吐槽按钮
    ADCLOSE_HOME               = 5,// HOME键返回
    ADCLOSE_SWITCH_WINDOW      = 6,// 切换窗口
    ADCLOSE_BACK               = 7,// 回退(仅限android)
    ADCLOSE_LOCK               = 8,// 锁屏
    ADCLOSE_TIMEOUT            = 9,// 超时自动关闭
    ADCLOSE_BUTTON_FREE_CALL   = 10,// 拨号前-点击免费电话
    ADCLOSE_BUTTON_NORMAL_CALL = 11,// 拨号前-点击普通电话
    ADCLOSE_BUTTON_CANCEL      = 12,// 拨号前-点击取消按钮
    ADCLOSE_DIRECT             = 13,// 自动打开的广告
};

// 广告时间回传管理
@class AdMessageModel;
@interface AdShowtimeManager : NSObject
- (instancetype)initWithAd:(AdMessageModel *)ad;

- (void)adDidAppear;
- (void)adDidDisappearWithCloseType:(ADCloseType)closeType;
@end
