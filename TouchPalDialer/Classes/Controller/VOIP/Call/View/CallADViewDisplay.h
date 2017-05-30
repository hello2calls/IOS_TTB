//
//  CallADViewDisplay.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/7.
//
//

#import <Foundation/Foundation.h>
@class AdMessageModel;
@interface CallADViewDisplay : NSObject
@property (nonatomic,assign) CGFloat adAlpha;
@property (nonatomic,retain)UIImageView *adView;
- (id)initWithHostView:(UIView *)view andDisplayArea:(CGRect)frame;

- (void)loadAD:(AdMessageModel *)model image:(UIImage *)image;
- (void)showADWithImage:(UIImage *)image;
- (void)hideAD;
@end
