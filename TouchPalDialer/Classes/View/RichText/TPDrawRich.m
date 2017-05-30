//
//  TPDrawString.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-1-4.
//
//

#import "TPDrawRich.h"

@implementation TPDrawRichDefault
@synthesize isAlwaysShow;
-(CGSize)drawElementRect:(CGRect)rect{
    return CGSizeZero;
}
-(CGFloat)minWidthOfContent{
    return 0.0;
}
@end
@interface TPDrawRichText(){
    NSString *str_;
    UIColor __strong *textColor_;
    UIColor __strong *bgColor_;
    UIFont __strong *textFont_;
    NSTextAlignment textAligment_;
}
@end
@implementation TPDrawRichText
-(CGSize)drawElementRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize size = CGSizeZero;
    if (bgColor_) {
        rect.size.width = [self minWidthOfContent];
        CGContextSetFillColorWithColor(context, bgColor_.CGColor);
        CGContextFillRect (context, rect);
    }
    if (self.isAlwaysShow) {
        rect.size.width = [self minWidthOfContent];
    }
    CGContextSetFillColorWithColor(context, textColor_.CGColor);
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//    paragraphStyle.alignment = textAligment_;
//    NSDictionary *tdic;
//    if (textColor_){
//        tdic = @{NSFontAttributeName:textFont_, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:textColor_};
//    }else{
//        tdic = @{NSFontAttributeName:textFont_, NSParagraphStyleAttributeName:paragraphStyle};
//    }
//    
//    size = [str_ sizeWithAttributes:tdic];
//    [str_ drawInRect:rect withAttributes:tdic];
    //cootek_log(@"textFont_fontName:%@",textFont_.fontName);
    NSRange dotRange = [str_ rangeOfString:@"·"];
    if ( dotRange.location !=  NSNotFound ){
        NSString *outStr = [str_ stringByReplacingOccurrencesOfString:@"·" withString:@"•"];
        size = [outStr drawInRect:rect withFont:textFont_ lineBreakMode:NSLineBreakByTruncatingTail alignment:textAligment_];
    }else{
        size = [str_ drawInRect:rect withFont:textFont_ lineBreakMode:NSLineBreakByTruncatingTail alignment:textAligment_];
    }
    return size;
}
-(CGFloat)minWidthOfContent{
//    NSDictionary *tdic = @{NSFontAttributeName:textFont_};
//    return [str_ boundingRectWithSize:CGSizeZero
//                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                     attributes:tdic
//                                        context:nil].size.width;
    
    return [str_ sizeWithFont:textFont_].width;
}
-(id)initWithText:(NSString *)str font:(UIFont *)font color:(UIColor *)color{
    return [self initWithText:str font:font color:color bgColor:nil];
}
-(id)initWithText:(NSString *)str font:(UIFont *)font color:(UIColor *)color bgColor:(UIColor *)bgColor{
    self = [super init];
    if (self) {
        str_ = [str copy];
        self.number =  [str copy];
        textColor_ = color;
        textFont_ = font;
        textAligment_ = NSTextAlignmentLeft;
        bgColor_ = bgColor;
    }
    return self;
}
@end
@interface TPDrawRichImage(){
    UIImage __strong *image_;
}
@end
@implementation TPDrawRichImage
-(CGSize)drawElementRect:(CGRect)rect{
    rect.size =image_.size;
    [image_ drawInRect:rect];
    return rect.size;
}
-(id)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        image_ = image;
    }
    return self;
}
-(CGFloat)minWidthOfContent{
    return image_.size.width;
}
@end

@interface TPRichLabel(){
    NSArray __strong *elements_;
}
@end

@implementation TPRichLabel
@synthesize isAlwaysShow;
@synthesize elements = elements_;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)setElements:(NSArray *)elements{
    elements_ = elements;
    [self.layer setNeedsDisplay];
}
-(CGSize)drawElementRect:(CGRect)rect{
    CGSize size = {0,0};
    rect.size.width = rect.size.width - [self minWidthOfContent];
    for (id<TPDrawRichDelegate> element in elements_) {
        rect.origin.x = rect.origin.x + size.width;
        rect.size.width = rect.size.width - size.width;
        if (rect.size.width > 0 || element.isAlwaysShow) {
            size = [element drawElementRect:rect];
        }
    }
    return rect.size;
}

-(CGFloat)minWidthOfContent{
    CGFloat width = 0.0;
    for (int i=0; i<[elements_ count];i++) {
        id<TPDrawRichDelegate> element = [elements_ objectAtIndex:i];
        if (element.isAlwaysShow) {
            CGFloat tmpWidth = [element minWidthOfContent];
            width = width+tmpWidth;
        }
    }
    return width;
}
-(void)drawRect:(CGRect)rect{
    // the raw parameter rect's origin may be negative! weired...
    // set the origin to be zero
    rect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self drawElementRect:rect];
}
@end

@implementation TPRichLabelUtils
+(NSArray *)createDefaultElements:(NSString *)name
                        textColor:(UIColor *)color
                             font:(UIFont *)font{
    TPDrawRichText *element = [[TPDrawRichText alloc] initWithText:name font:font color:color];
    NSArray *elements =[NSArray arrayWithObject:element];
    return elements;
}
+(NSArray *)createNumberHighlightElements:(NSString *)name
                                textColor:(UIColor *)color
                              httextColor:(UIColor *)htColor
                                     font:(UIFont *)font
                                highlight:(NSRange)range{
    NSMutableArray *elements = [NSMutableArray arrayWithCapacity:1];
    NSRange rangeHt = range;
    if (rangeHt.location > 0) {
        NSRange rangeNormal = {0,range.location};
        NSString *strNormal = [name substringWithRange:rangeNormal];
        TPDrawRichText *elementNormal = [[TPDrawRichText alloc] initWithText:strNormal font:font color:color];
        [elements addObject:elementNormal];
    }

    NSString *str = [name substringWithRange:rangeHt];
    TPDrawRichText *elementHt = [[TPDrawRichText alloc] initWithText:str font:font color:htColor];
    [elements addObject:elementHt];
    
    if (range.location + range.length < [name length] ) {
        NSRange rangeNormal = {range.location + range.length ,[name length]-(range.location + range.length)};
        NSString *strNormal = [name substringWithRange:rangeNormal];
        TPDrawRichText *elementNormal = [[TPDrawRichText alloc] initWithText:strNormal font:font color:color];
        [elements addObject:elementNormal];
    }

    return elements;

}
+(NSArray *)rangeArray:(NSArray *)hts{
    NSMutableArray *hits = [NSMutableArray arrayWithCapacity:1];
    for (int i=0; i<[hts count]; i=i+2) {
        NSRange rangeHt = {[[hts objectAtIndex:i] integerValue],[[hts objectAtIndex:i+1] integerValue]};
        [hits addObject:[NSValue valueWithRange:rangeHt]];
    }
    return [hits sortedArrayUsingFunction:compareNSRange context:nil];
}
NSInteger compareNSRange(id obj1, id obj2, void *context) {
	int obj1_location = [obj1 rangeValue].location;
	int obj2_location = [obj2 rangeValue].location;
    
	if (obj1_location > obj2_location) {
		return NSOrderedDescending;
	}else if (obj1_location == obj2_location) {
		return NSOrderedSame;
	} else {
		return NSOrderedAscending;
	}
}
+(NSArray *)createHighlightElements:(NSString *)name
                          textColor:(UIColor *)color
                        httextColor:(UIColor *)htColor
                               font:(UIFont *)font
                          highlight:(NSArray *)hts{
    NSMutableArray *elements = [NSMutableArray arrayWithCapacity:1];
    NSRange preRange = {0,0};
    NSArray *hits = [self rangeArray:hts];
    for (int i=0; i<[hits count]; i++) {
        NSRange rangeHt = [[hits objectAtIndex:i] rangeValue];
        if (preRange.location + preRange.length < rangeHt.location) {
            NSRange rangeNormal = {preRange.location + preRange.length,rangeHt.location-(preRange.location + preRange.length)};
            NSString *strNormal = [name substringWithRange:rangeNormal];
            TPDrawRichText *elementNormal = [[TPDrawRichText alloc] initWithText:strNormal font:font color:color];
            [elements addObject:elementNormal];
        }
        NSString *str = [name substringWithRange:rangeHt];
        TPDrawRichText *elementHt = [[TPDrawRichText alloc] initWithText:str font:font color:htColor];
        [elements addObject:elementHt];
     
        preRange = rangeHt;
    }
    if (preRange.location + preRange.length < [name length] ) {
        NSRange rangeNormal = {preRange.location + preRange.length ,[name length]-(preRange.location + preRange.length)};
        NSString *strNormal = [name substringWithRange:rangeNormal];
        TPDrawRichText *elementNormal = [[TPDrawRichText alloc] initWithText:strNormal font:font color:color];
        [elements addObject:elementNormal];
    }
    return elements;
}
@end