//
//  SnowGenerator.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/4/16.
//
//

#import <Foundation/Foundation.h>

@interface SnowGenerator : NSObject
- (id)initWithHolderView:(UIView *)view;
- (void)startSnow;
- (void)stopSnow;
- (UIImage *)noahPushBg;
@end
