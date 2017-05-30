//
//  AntiSwitchItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "AntiSwitchItem.h"

@implementation AntiSwitchItem

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle settingKey:(NSString *)settingKey willSwitchHandle:(SwitchHandle)switchHandle{

    AntiSwitchItem *item = [self itemWithTitle:title subtitle:subtitle vcClass:nil clickHandle:nil];
    item.switchHandle = switchHandle;
    item.settingKey = settingKey;
    return item;
    
}
 
@end
