//
//  UILabel+TPHelper.h
//  TouchPalDialer
//
//  Created by siyi on 16/3/15.
//
//

#ifndef UILabel_TPHelper_h
#define UILabel_TPHelper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UILabel (TPHelper)

- (instancetype) initWithTitle:(NSString *)title font:(UIFont *)font isFillContentSize: (BOOL) fillContent;
- (instancetype) initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize isBold:(BOOL)isBold;
- (instancetype) initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize;

@end

#endif /* UILabel_TPHelper_h */
