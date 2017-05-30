//
//  UITableViewCell+TPDExtension.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/19.
//
//

#import <UIKit/UIKit.h>
#import "TPDCategoryMacro.h"
#import "TPDExtension.h"

@interface UITableViewCell (TPDExtension)
@property (nonatomic,strong) UIView* tpd_img1;
@property (nonatomic,strong) UILabel* tpd_label1;
@property (nonatomic,strong) UILabel* tpd_label2;
@property (nonatomic,strong) UIView* tpd_img2;
@property (nonatomic,strong) UIView* tpd_img3;
@property (nonatomic,strong) UIButton* tpd_container;
@property (nonatomic,copy) double (^tpd_getHeight)();
@property (nonatomic,copy) void (^tpd_action)(id sender);
+(UITableViewCell*)tpd_tableViewCellStyle1:(NSArray*)controlArr action:(void(^)(id sender))block;

// 带reuseId的版本
+(UITableViewCell*)tpd_tableViewCellStyle1:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;

// 左侧一个image，紧接着右边两个垂直排布的label
+(UITableViewCell*)tpd_tableViewCellStyleImageLabel2:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;
-(UITableViewCell*)tpd_tableViewCellStyleImageLabel2:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;

// 垂直排列布局：上面一个label，中间一个大image，底下再一个label, 使用于头条新闻
+(UITableViewCell*)tpd_tableViewCellStyleLabelImageLabel:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;
-(UITableViewCell*)tpd_tableViewCellStyleLabelImageLabel:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;

// 垂直排列布局：上面一个label，中间三个image，底下再一个label， 使用于头条新闻
+(UITableViewCell*)tpd_tableViewCellStyleLabelImage3Label:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;
-(UITableViewCell*)tpd_tableViewCellStyleLabelImage3Label:(NSArray*)controlArr action:(void(^)(id sender))block reuseId:(NSString*)reuseId;



-(UIView*)tpd_withSeperateLine;
-(UIView*)tpd_seperateLineWithEdgeInsets:(UIEdgeInsets)edgeInsets;
-(UIView*)tpd_withFullSeperateLine;
@end

