//
//  TPDrawString.h
//  TouchPalDialer
//
//  Created by lingmei xie on 13-1-4.
//
//

#import <Foundation/Foundation.h>

@protocol TPDrawRichDelegate
-(CGSize)drawElementRect:(CGRect)rect;
-(CGFloat)minWidthOfContent;
@property(nonatomic,assign)BOOL isAlwaysShow;

@end

@interface TPDrawRichDefault : NSObject<TPDrawRichDelegate>

@end

@interface TPDrawRichText : TPDrawRichDefault
@property(nonatomic,copy) NSString *number;
-(id)initWithText:(NSString *)str font:(UIFont *)font color:(UIColor *)color;
-(id)initWithText:(NSString *)str font:(UIFont *)font color:(UIColor *)color bgColor:(UIColor *)bgColor;
@end
@interface TPDrawRichImage : TPDrawRichDefault
-(id)initWithImage:(UIImage *)image;
-(CGFloat)minWidthOfContent;
@end

@interface TPRichLabel : UILabel<TPDrawRichDelegate>
@property(nonatomic,retain)NSArray *elements;
-(id)initWithFrame:(CGRect)frame;
@end

@interface TPRichLabelUtils : NSObject
+(NSArray *)createDefaultElements:(NSString *)name
                        textColor:(UIColor *)color
                             font:(UIFont *)font;
+(NSArray *)createNumberHighlightElements:(NSString *)name
                          textColor:(UIColor *)color
                        httextColor:(UIColor *)htColor
                               font:(UIFont *)font
                          highlight:(NSRange)range;
+(NSArray *)createHighlightElements:(NSString *)name
                          textColor:(UIColor *)color
                        httextColor:(UIColor *)htColor
                               font:(UIFont *)font
                          highlight:(NSArray *)hts;
@end