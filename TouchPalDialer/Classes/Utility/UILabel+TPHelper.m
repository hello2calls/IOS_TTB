//
//  UILabel+TPHelper.m
//  TouchPalDialer
//
//  Created by siyi on 16/3/15.
//
//

#import "UILabel+TPHelper.h"
#import "UILabel+DynamicHeight.h"

@implementation UILabel (TPHelper)

- (instancetype) initWithTitle: (NSString *)title font: (UIFont *)font
             isFillContentSize: (BOOL) fillContent{
    self = [self init];
    if (self) {
        self.text = title;
        self.textAlignment = NSTextAlignmentCenter;
        self.font = font;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.numberOfLines = 0;
        self.backgroundColor = [UIColor clearColor];
        if (fillContent) {
            [self adjustSizeByFillContent];
        }
    }
    return self;
}

- (instancetype) initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize isBold:(BOOL)isBold {
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    if (isBold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return [self initWithTitle:title font:font isFillContentSize:YES];
}

- (instancetype) initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize {
    return [self initWithTitle:title fontSize:fontSize isBold:NO];
}

@end
