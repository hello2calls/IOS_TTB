//
//  SwitchSettingItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/2.
//
//

#import "SettingItem.h"

typedef void(^SwitchHandle)(BOOL isSwitchOn);

@interface SwitchSettingItem : SettingItem

@property (nonatomic,copy) SwitchHandle switchHandle;
@property (nonatomic,copy,readonly) NSString *openAlert;
@property (nonatomic,copy,readonly) NSString *closeAlert;
@property (nonatomic,strong,readonly) NSString *appModelKey;

+ (SwitchSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle appModelKey:(NSString *)key  switchHandle:(SwitchHandle)switchHandle;

+ (SwitchSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle openAlert:(NSString *)alert  appModelKey:(NSString *)key switchHandle:(SwitchHandle)switchHandle;

+ (SwitchSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle appModelKey:(NSString *)key closeAlert:(NSString *)alert switchHandle:(SwitchHandle)switchHandle;
@end
