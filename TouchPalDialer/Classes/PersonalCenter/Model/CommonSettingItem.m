//
//  CommonSettingItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/3.
//
//

#import "CommonSettingItem.h"

@implementation CommonSettingItem

+ (CommonSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle rightTitle:(NSString *)rightTitle  handle:(HandleBlock)handle{
    return [[self alloc] initWithTitle:title subTitle:subTitle rightTitle:rightTitle vcClass:nil handle:handle];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle rightTitle:(NSString *)rightTitle vcClass:(NSString *)vcClass handle:(HandleBlock)handle{
    if (self = [super initWithTitle:title subTitle:subtitle vcClass:vcClass handle:handle]) {
        _rightTitle = rightTitle;
        _rightTitleColor = nil;
    }
    return self;
}

@end
