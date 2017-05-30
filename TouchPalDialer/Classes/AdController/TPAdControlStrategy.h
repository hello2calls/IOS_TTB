//
//  TPAdControlStrategy.h
//  TouchPalDialer
//
//  Created by siyi on 16/6/22.
//
//

#ifndef TPAdControlStrategy_h
#define TPAdControlStrategy_h


/*
 // e.g. raw strategy data returned by the control server
 
 {
 "expid": 0,
 "ad_platform": [
 "da_vinci",
 "tencent_gdt_sdk",
 "admob_voip_sdk"
 ],
 "data_id": [
 {
 "ad_platform_id": 1,
 "placement_id": ""
 },
 {
 "ad_platform_id": 101
 },
 {
 "ad_platform_id": 102
 }
 ],
 "data": [
 {
 "ad_platform": "da_vinci"
 },
 {
 "ad_platform": "tencent_gdt_sdk"
 },
 {
 "ad_platform": "admob_voip_sdk"
 }
 ],
 "tu": 1,
 "source": "hangup_tu",
 "s": "c75aae3d548f7fbe",
 "ad_platform_id": [
 1,
 101,
 102
 ],
 "enable_platform_list": [
 1,
 101,
 102
 ],
 "error_code": 0
 }
 
 */


/**
 *  TP自定义的各个DSP的编号
 */
#define TP_AD_PLATFORM_ID @"ad_platform_id"

/**
 *  placement_id means the `adUnitTag`， 指的是DSP后台配置的广告的标志。
 */
#define TP_AD_PLACEMENT_ID @"placement_id"
#define TP_AD_STYLE @"style"

#define TP_AD_STYLE_LARGE        @"large"
#define TP_AD_STYLE_SMALL        @"small"
#define TP_AD_STYLE_MULTI        @"multi"


#import <Foundation/Foundation.h>

@interface TPAdControlStrategy : NSObject

- (instancetype) initWithRawString:(NSString *)rawMessage;

@property (nonatomic, strong) NSString *tu;
@property (nonatomic, strong) NSArray<NSNumber *> *effectivePlatformIds; /*  */
@property (nonatomic, strong) NSArray<NSNumber *> *platformIdsForNextRequst; /* for next requst */
@property (nonatomic, assign) long expId; /* used by the ssp statistics */
@property (nonatomic, strong) NSString *s; /* unique id for quering */
@property (nonatomic, strong) NSArray *dataId; /* contains placement_id */

@property (nonatomic, strong) NSString *rawMessageString;


@end


#endif /* TPAdControlStrategy_h */
