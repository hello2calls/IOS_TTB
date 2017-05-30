//
//  UIImage+Mask.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-4-19.
//
//

#import "UIImage+Mask.h"

@implementation UIImage (Mask)

+ (UIImage *)squareImageWithColor:(UIColor *)color length:(CGFloat)length
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(length, length), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, length, length));
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)maskedImage:(UIImage *)image withMask:(UIImage *)imageMask fillColor:(UIColor *)fillColor
{
    CGImageRef maskRef = [imageMask CGImage];
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, YES);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
    CGContextTranslateCTM(context, 0.0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect myRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGContextFillRect(context, myRect);
    CGContextDrawImage(context, myRect, masked);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(mask);
    CGImageRelease(masked);
    return result;
}


@end
