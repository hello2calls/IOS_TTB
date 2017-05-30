//
//  SettingModel.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/25.
//
//

#import "SettingItem.h"

@implementation SettingItem
- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle vcClass:(NSString *)vcClass handle:(HandleBlock)handle{
    if (self = [super init]) {
        _title    = title;
        _subTitle = subtitle;
        _vcClass  = vcClass;
        _handle   = handle;
        _redDotHidden = YES;
    }
    return self;
}
@end
