//
//  UIImageCutUtils.m
//  TouchPalDialer
//
//  Created by Alice on 12-1-4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageCutUtils.h"

@implementation UIImageCutUtils

// 裁剪图片
- (UIImage *)croppedImageWithRect:(CGRect)rect {
	CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);  
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));  
	
    UIGraphicsBeginImageContext(smallBounds.size);  
    CGContextRef context = UIGraphicsGetCurrentContext();  
    CGContextDrawImage(context, smallBounds, subImageRef);  
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];  
    UIGraphicsEndImageContext();
	
//    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
//    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(subImageRef);
    return smallImage;
}
// 缩放图片拉伸缩放
- (UIImage*)scaleToSize:(CGSize)size {
	
    CGFloat newWidth = size.width;
    CGFloat newHeight = size.height;
	
    float width  = self.size.width;
    float height = self.size.height;
    if (width == 0 || height == 0)  return self;
	
    if (width != newWidth || height != newHeight) {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
		
        UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resized;
    }

    return self;
}


// 缩放尺寸，并最大适应原图居中显示
-(UIImage *)croppedToMaxImageSize:(CGSize)size {	
    if (size.width == 0 || size.height == 0) {
        return self;
    }
	
    float newWidth=0;//self.size.width;
    float newHeight=0;//self.size.height;
	
    if(size.height > size.width) {
		if(self.size.height > self.size.width) {
			if((self.size.width  / self.size.height) >= (size.width / size.height)) {
                newWidth = self.size.width * (size.height / self.size.height);
                newHeight = self.size.height * (size.height / self.size.height);
			} else {
                newWidth = self.size.width * (size.width / self.size.width);
                newHeight = self.size.height * (size.width / self.size.width);
				
			}
		} else {
            newWidth = self.size.width * (size.height / self.size.height);
            newHeight = self.size.height * (size.height / self.size.height);
			
		}    
	} else {
		if(self.size.width > self.size.height) {
			if((self.size.height / self.size.width) >= (size.height / size.width)) {
                newWidth = self.size.width * (size.width / self.size.width);
                newHeight = self.size.height * (size.width / self.size.width);
			} else {
                newWidth = self.size.width * (size.height / self.size.height);
                newHeight = self.size.height * (size.height / self.size.height);
				
			}
		} else {
            newHeight = self.size.height * (size.width / self.size.width);
            newWidth = self.size.width * (size.width / self.size.width);
		}    
	}	
    UIImage *maxImage = nil;
    if (newWidth == self.size.width && newHeight == self.size.height) {
        maxImage = self;
    }
    else{
        maxImage = [self scaleToSize:CGSizeMake(newWidth, newHeight)];
    }	
    float x = newWidth/2 - size.width/2;
    float y = newHeight/2 - size.height/2; 
    if (x == 0 && y == 0) {
        return maxImage;
    }
    // 顶点开始
	//return  [self croppedImageWithRect:CGRectMake(0,0, size.width, size.height)];
    // 居中	
    return  [self croppedImageWithRect:CGRectMake(x , y,size.width, size.height)];	
}
@end
