//
//  UIFont+Custom.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/30.
//
//

#import "UIFont+Custom.h"

@implementation UIFont (Custom)

+ (UIFont *)cutomFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"iPhoneIcon3" size:size];
}

- (BOOL)fontContainsCharacter:(unichar )character
{
    NSCharacterSet *characterSet = [self.fontDescriptor objectForKey:UIFontDescriptorCharacterSetAttribute];
    return [characterSet characterIsMember:character];
}
- (BOOL)fontContainsString:(NSString *)stringC
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (!stringC || stringC.length == 0) {
            return NO;
        }
        NSCharacterSet *characterSet = [self.fontDescriptor objectForKey:UIFontDescriptorCharacterSetAttribute];
        for (int i = 0; i < stringC.length; i++) {
            unichar ch = [stringC characterAtIndex:i];
            if (![characterSet characterIsMember:ch]) {
                return NO;
            }
        }
        
        return YES;
    } else {
        return NO;
    }
}
@end
