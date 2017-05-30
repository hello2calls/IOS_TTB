//
//  AntiNormalItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "AntiNormalItem.h"

@implementation AntiNormalItem

- (instancetype)init{
    
    if (self = [super init]) {
        _title = nil;
        _subtitle = nil;
        _vcClass = nil;
        _clickHandle = nil;
        _height = 60;
    }
    return self;
    
}

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle vcClass:(NSString *)vcClass attributedSubtitle:(NSAttributedString *)attributedSubtitle clickHandle:(HandleBlock)handle{
    
    if (self = [super init]) {
        _title = title;
        _subtitle = subtitle;
        _vcClass = vcClass;
        _clickHandle = handle;
        _height = 60;
        _attributedSubtitle = attributedSubtitle;
    }
    return self;
    
}

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle vcClass:(NSString *)vcClass clickHandle:(HandleBlock)handle{
    
    return [[self alloc] initWithTitle:title subtitle:subtitle vcClass:vcClass attributedSubtitle:nil clickHandle:handle];
    
}

+ (instancetype)itemWithTitle:(NSString *)title attributedSubtitle:(NSAttributedString *)attributedSubtitle vcClass:(NSString *)vcClass clickHandle:(HandleBlock)handle{
    
    return [[self alloc] initWithTitle:title subtitle:nil vcClass:vcClass attributedSubtitle:attributedSubtitle clickHandle:handle];
    
}

@end
