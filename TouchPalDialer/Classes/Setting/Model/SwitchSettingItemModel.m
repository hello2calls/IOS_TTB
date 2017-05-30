//
//  SwitchSettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SwitchSettingItemModel.h"

@implementation SwitchSettingItemModel

@synthesize isReverse;
@synthesize settingKey;
@synthesize settings;
@synthesize actionBlock;
@synthesize preActionBlock;

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title settingKey:(NSString*) settingKey inSettings:(AppSettingsModel*)settings {
    return [self itemWithTitle:title
              itemWithSubtitle:nil
                    settingKey:settingKey
                    inSettings:settings
                        action:nil
                     preAction:nil];
}
+(SwitchSettingItemModel *)itemWithTitle:(NSString *)title settingKey:(NSString *)settingKey inSettings:(AppSettingsModel *)settings action:(void (^)(BOOL))block {
    return [self itemWithTitle:title
              itemWithSubtitle:nil
                    settingKey:settingKey
                    inSettings:settings
                        action:block
                     preAction:nil];
}

+(SwitchSettingItemModel *)itemWithTitle:(NSString *)title itemWithSubtitle:(NSString *)subtitle settingKey:(NSString *)settingKey inSettings:(AppSettingsModel *)settings {
    return [self itemWithTitle:title
              itemWithSubtitle:subtitle
                    settingKey:settingKey
                    inSettings:settings
                        action:nil
                     preAction:nil];
}

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                        itemWithSubtitle:(NSString*) subtitle
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings
                                  action:(void(^)(BOOL))block{
    return [self itemWithTitle:title
              itemWithSubtitle:subtitle
                    settingKey:settingKey
                    inSettings:settings
                        action:nil
                     preAction:nil];
}

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                        itemWithSubtitle:(NSString*) subtitle
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings
                                  action:(void(^)(BOOL))block
                               preAction:(void(^)())preBlock{
    SwitchSettingItemModel* item = [[SwitchSettingItemModel alloc] init];
    item.title = title;
    item.subtitle = subtitle;
    item.settingKey = settingKey;
    item.isReverse = NO;
    item.settings = settings;
    item.actionBlock = block;
    item.preActionBlock = preBlock;
    return item;
}

-(BOOL) on {
    BOOL anotherCondition = YES;
    if (_followingSettingKeys != nil) {
        for (NSString *key in _followingSettingKeys) {
            anotherCondition &= [[settings settingValueForKey:key] boolValue];
        }
    }
    BOOL v = [[settings settingValueForKey:settingKey] boolValue];
    return isReverse ? !v && anotherCondition : v && anotherCondition;
}

- (BOOL)canSwitch {
    if (_followingSettingKeys == nil) {
        return YES;
    } else {
        BOOL can = YES;
        for (NSString *key in _followingSettingKeys) {
            can &= [[settings settingValueForKey:key] boolValue];
        }
        return can;
    }
}

-(void) setOn:(BOOL)value {
    [settings setSettingValue:[NSNumber numberWithBool:isReverse ? (!value) : value]
                             forKey:settingKey];
    if (self.actionBlock) {
        actionBlock(value);
    }

}

@end
