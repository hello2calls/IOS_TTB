//
//  UIImage+TPDExtension.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/7.
//
//

#import "UIImage+TPDExtension.h"

@implementation UIImage (TPDExtension)
+ (UIImage *)tpd_imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)tpd_imageWithColor:(UIColor *)color
{
    return [self tpd_imageWithColor:color size:CGSizeMake(60, 30)];
}
@end
