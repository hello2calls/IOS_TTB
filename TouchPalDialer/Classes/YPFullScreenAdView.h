//
//  YPFullScreenAdView.h
//  TouchPalDialer
//
//  Created by tanglin on 16/2/15.
//
//

#import <UIKit/UIKit.h>
#import "CootekNotifications.h"
typedef void (^btnBlock)(void);

@interface YPFullScreenAdView : UIView
@property(nonatomic,copy)btnBlock closeBlock;
@property(nonatomic,copy)btnBlock sureBlock;
-(instancetype)initWithSelfFrameScale:(CGRect) frame  image1:(UIImage *)image1 andFrame1:(CGRect)frame1 image2:(UIImage *)image2 andFrame2:(CGRect)frame2 ifRemoveSelf:(BOOL)ifRemoveSelf;
-(void)removeSelf;
-(void)sureToBlock;
-(void)addRemoveTap;
@end
