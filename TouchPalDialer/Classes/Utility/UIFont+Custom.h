//
//  UIFont+Custom.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/8/30.
//
//

#import <Foundation/Foundation.h>

@interface UIFont (Custom)

+ (UIFont *)cutomFontWithSize:(CGFloat)size;

- (BOOL)fontContainsCharacter:(unichar )character;
- (BOOL)fontContainsString:(NSString *)stringC;
@end
