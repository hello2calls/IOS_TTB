//
//  ImageUtility.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/7/6.
//
//

#import <Foundation/Foundation.h>

@interface ImageUtility : NSObject

+ (UIImage*) gaussianWithImage:(UIImage*)image blur:(CGFloat)blur;
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;
@end
