//
//  UIImage+Mask.h
//  TouchPalDialer
//
//  Created by Leon Lu on 13-4-19.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Mask)

+ (UIImage *)squareImageWithColor:(UIColor *)color length:(CGFloat)length;
+ (UIImage *)maskedImage:(UIImage *)image withMask:(UIImage *)imageMask fillColor:(UIColor *)fillColor;

@end
