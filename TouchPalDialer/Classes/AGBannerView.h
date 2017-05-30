//
//  AGBannerView.h
//  CCMTClient
//
//  Created by LH on 16/4/28.
//  Copyright © 2016年 CCMT. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "GlobalDefine.h"
@interface AGBannerView : UIView

/**
 *  图片点击block
 *
 *  @param NSInteger 输入点击索引
 */
typedef void(^imageCLick)(NSInteger index);


@property (nonatomic, assign)    NSTimeInterval          rollingInterval;

/**
 *  初始化图片广告位
 *
 *  @param imageArray 广告位图片数组
 *
 *  @return 广告位实例对象
 */
- (instancetype)initWithImageArray:(NSArray *)imageArray clickHandler:(imageCLick)clickHandler;


/**
 *  更新图片数组
 *
 *  @param imageArray 广告位图片
 */
- (void)updateBannerByArray:(NSArray *)imageArray clickHandler:(imageCLick)clickHandler;


/**
 *  开始滚动
 *
 *  @param time 时间间隔
 */
- (void)scrollViewAutoScrolllByTime:(int)time;

//暂停
- (void)distantScroll;
//滚动
- (void)continueScroll;

@end
