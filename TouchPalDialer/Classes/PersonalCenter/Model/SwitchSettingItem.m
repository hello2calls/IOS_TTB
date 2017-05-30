//
//  SwitchSettingItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/2.
//
//

#import "SwitchSettingItem.h"

@implementation SwitchSettingItem

+ (SwitchSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle appModelKey:(NSString *)key  switchHandle:(SwitchHandle)switchHandle{
    
    return [[self alloc] initWithTitle:title subTitle:subTitle vcClass:nil handle:nil closeAlert:nil openAlert:nil appModelKey:key switchHandle:switchHandle];

}

+ (SwitchSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle openAlert:(NSString *)alert  appModelKey:(NSString *)key switchHandle:(SwitchHandle)switchHandle {
    
    return [[self alloc] initWithTitle:title subTitle:subTitle vcClass:nil handle:nil closeAlert:nil openAlert:alert appModelKey:key switchHandle:switchHandle];

}

+ (SwitchSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle appModelKey:(NSString *)key closeAlert:(NSString *)alert switchHandle:(SwitchHandle)switchHandle{

    return [[self alloc] initWithTitle:title subTitle:subTitle vcClass:nil handle:nil closeAlert:alert openAlert:nil appModelKey:key switchHandle:switchHandle];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subtitle vcClass:(NSString *)vcClass handle:(HandleBlock)handle closeAlert:(NSString *)closeAlert openAlert:(NSString *)openAlert appModelKey:(NSString *)key switchHandle:(SwitchHandle)switchHandle{
    if (self = [super initWithTitle:title subTitle:subtitle vcClass:vcClass handle:handle]) {
        _openAlert = openAlert;
        _closeAlert = closeAlert;
        _appModelKey = key;
        _switchHandle = switchHandle;
        self.hiddenArrow = YES;
    }
    return self;
}
@end
