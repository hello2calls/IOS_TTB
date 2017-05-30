#import <Foundation/Foundation.h>

typedef enum {
    HVT_BATCH    = 0,  //启动时发送
    HVT_REALTIME = 1   //实时发送
} HVTReportPolicy;     //发送模式

#define HVT_AUTO      @"auto"    //自动跟踪
#define HVT_MANUAL    @"manual"  //手动跟踪

typedef enum {
    HVT_START      = 0,   //开始
    HVT_HEART_BEAT = 1,   //心跳
    HVT_END        = 2,   //结束
    HVT_PAUSE      = 3,   //暂停
    HVT_RESUME     = 4,   //继续
    HVT_ACTION     = 5,   //用户行为
} HVTSendFlag;            //操作模式

typedef NSInteger (^hvtProgressCallBack)(void);    //获取进度回调
typedef void (^hvtStateCallBack)(NSInteger);       //返回状态回调

@interface HVTAgentSDK : NSObject

+ (void)initWithReportPolicy:(HVTReportPolicy)reportPolicy;
+ (void)initWithReportPolicy:(HVTReportPolicy)reportPolicy unTracked:(NSArray<NSString *> *)unTracked;

+ (void)setServerUrl:(NSString *)url;

+ (instancetype)create:(NSString *)platformId;
+ (instancetype)create:(NSString *)platformId settings:(NSDictionary *)settings;

- (BOOL)initVideo:(NSDictionary *)trackType;
- (BOOL)initVideo:(NSDictionary *)trackType options:(NSDictionary *)options;

- (BOOL)send:(HVTSendFlag)flag;
- (BOOL)send:(HVTSendFlag)flag options:(NSDictionary *)options;
- (BOOL)send:(HVTSendFlag)flag options:(NSDictionary *)options callback:(hvtStateCallBack)callback;

- (BOOL)autoTrack:(HVTSendFlag)flag;
- (BOOL)autoTrack:(HVTSendFlag)flag options:(NSDictionary *)options;
- (BOOL)autoTrack:(HVTSendFlag)flag options:(NSDictionary *)options callback:(hvtStateCallBack)callback;

- (BOOL)send:(HVTSendFlag)flag actionName:(NSString *)actionName params:(NSDictionary *)params;
- (BOOL)send:(HVTSendFlag)flag actionName:(NSString *)actionName params:(NSDictionary *)params callback:(hvtStateCallBack)callback;

- (BOOL)set:(NSDictionary *)options;

//取自动跟踪播放时长
- (NSInteger)getAutoSpend;

//禁用启用
- (BOOL)disable;
- (BOOL)enable;
+ (void)disable;
+ (void)enable;

//销毁实例
- (void)destroy;

@end