//
//  PersonalCenterGuideViewWithBaozai.h
//  TouchPalDialer
//
//  Created by wen on 16/1/4.
//
//

#import <UIKit/UIKit.h>
#import "CootekNotifications.h"
typedef void (^btnBlock)(void);

@interface GuideViewWithBaozai : UIView
@property(nonatomic,copy)btnBlock closeBlock;
@property(nonatomic,copy)btnBlock sureBlock;
-(instancetype)initWithSelfFrame:(CGRect) frame  image1:(UIImage *)image1 andFrame1:(CGRect)frame1 image2:(UIImage *)image2 andFrame2:(CGRect)frame2 image3:(UIImage *)image3 andFrame3:(CGRect)frame3 ifRemoveSelf:(BOOL)ifRemoveSelf;
-(void)removeSelf;
-(void)sureToBlock;
-(void)addRemoveTap;
@end
