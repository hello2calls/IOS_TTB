//
//  AntiSwitchItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "AntiNormalItem.h"

typedef void(^SwitchHandle)(BOOL on);


@interface AntiSwitchItem : AntiNormalItem

@property (nonatomic,copy) SwitchHandle switchHandle;
@property (nonatomic,copy) NSString *settingKey;

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle settingKey:(NSString *)settingKey willSwitchHandle:(SwitchHandle)switchHandle;

@end
