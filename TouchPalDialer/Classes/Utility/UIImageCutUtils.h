//
//  UIImageCutUtils.h
//  TouchPalDialer
//
//  Created by Alice on 12-1-4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImageCutUtils : UIImage{

}
- (UIImage *) croppedToMaxImageSize:(CGSize)size ;
- (UIImage *) scaleToSize:(CGSize)size;
- (UIImage *) croppedImageWithRect:(CGRect)rect ;

@end
