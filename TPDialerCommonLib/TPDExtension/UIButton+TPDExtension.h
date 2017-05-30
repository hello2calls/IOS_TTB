//
//  UIButton+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (TPDExtension)
@property (nonatomic,strong) UIView* tpd_icon;
@property (nonatomic,strong) UILabel* tpd_text1;
@property (nonatomic,strong) UILabel* tpd_text2;
@property (nonatomic,strong) NSArray* tpd_subviews;

@property (nonatomic,copy) void (^tpd_whenClicked)(id sender);


/**
 *  垂直方向布局的四种button
 */
+ (UIButton *)tpd_buttonStyleVerticalImageLabel:(NSArray *)arr withBlock:(void (^)(id sender))block;

+ (UIButton *)tpd_buttonStyleVerticalLabel2:(NSArray *)arr withBlock:(void (^)(id sender))block;

// 以上button，如果要改变其中元素间距，用这个：
-(UIButton*)tpd_withOffset:(NSArray*)offsets;

+(UIButton*)tpd_buttonStyleCommon;

-(UIButton*)tpd_withBlock:(void (^)(id sender))block;

@end
