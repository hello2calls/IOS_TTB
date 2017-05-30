//
//  MenuView.h
//  旋转动画(手机银行首页)
//
//  Created by H L on 2016/12/7.
//  Copyright © 2016年 李校松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
typedef NS_ENUM(NSInteger , FTT_RoundviewType) {
    FTT_RoundviewTypeSystem = 0,
    FTT_RoundviewTypeCustom ,
};
@protocol TPDMenuDelegate <NSObject>
- (void)MenuAction:(NSInteger)index;
@end

typedef void(^JumpBlock)(NSInteger num , NSString *name);

@interface MenuView : UIView
// 点击按钮触发事件
@property (nonatomic , copy) JumpBlock back ;
// 按钮风格
@property (nonatomic , assign) FTT_RoundviewType Type;
// 按钮的宽度
@property (nonatomic , assign) CGFloat BtnWitch;
// 视图的宽度
@property (nonatomic , assign) CGFloat Witch;
// 按钮的背景颜色
@property (nonatomic , strong) UIColor *BtnBackgroudColor ;
// 展示
@property (nonatomic , strong) UIView   *maskView;

- (void)show ;
/**
 *  创建按钮
 *
 *  @param type        按钮的风格
 *  @param BtnWitch    按钮的宽度
 *  @param sizeWith    字体是否自动适应按钮的宽度
 *  @param msak        是否允许剪切
 *  @param radius      圆角的大小
 *  @param image       图片数组
 *  @param titileArray 名字数组
 *  @param titleColor  字体的颜色
 */
- (void)BtnType:(FTT_RoundviewType)type BtnWitch:(CGFloat)BtnWitch  adjustsFontSizesTowidth:(BOOL)sizeWith  msaksToBounds:(BOOL)msak conrenrRadius:(CGFloat)radius image:(NSMutableArray *)image TitileArray:(NSMutableArray *)titileArray titileColor:(UIColor *)titleColor;

- (void)loadView;
- (void)hello;

+ (MenuView *)MenuInitialWithArray:(NSArray *)array Delegate:(id)viewDelegate BlockArray:(NSArray *)blockArray changeStatusBlock:(void (^)(BOOL isShow))statusChange;
+ (UIWindow *)tpd_topWindow;


@end
