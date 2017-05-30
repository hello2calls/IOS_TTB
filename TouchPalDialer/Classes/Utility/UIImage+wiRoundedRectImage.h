//
//  UIImage+wiRoundedRectImage.h
//  TouchPalDialer
//
//  Created by tanglin on 16/2/25.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (wiRoundedRectImage)
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;
@end
