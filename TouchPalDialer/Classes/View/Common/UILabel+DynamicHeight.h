//
//  UILabel+DynamicHeight.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/9/6.
//
//

#import <UIKit/UIKit.h>

@interface UILabel (DynamicHeight)

- (CGSize)sizeOfMultiLineLabel;

- (void) adjustSizeByFillContent;

- (void) adjustSizeByFixedWidth;
- (void) adjustSizeByFixedHeight;

@end
