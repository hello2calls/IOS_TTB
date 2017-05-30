//
//  UIColor+String.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/5.
//
//

#import "NSString+Color.h"
#import "TPDialerColor.h"

@implementation NSString (Color)

- (UIColor *)color {
    TPDialerColor *tpColor = [[TPDialerColor alloc] initWithString:self];
    return [UIColor colorWithRed:tpColor.R green:tpColor.G blue:tpColor.B alpha:tpColor.alpha];
}


@end
