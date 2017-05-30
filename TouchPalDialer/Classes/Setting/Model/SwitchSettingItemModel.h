//
//  SwitchSettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingItemModel.h"
#import "AppSettingsModel.h"

@interface SwitchSettingItemModel : SettingItemModel

@property (nonatomic, copy) NSString* settingKey;
@property (nonatomic, copy) NSArray* followingSettingKeys;
@property (nonatomic, copy) NSString* closeAlertStr;
@property (nonatomic, assign) BOOL isReverse;
@property (nonatomic, retain) AppSettingsModel* settings;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, copy) void(^actionBlock)(BOOL isOn);
@property (nonatomic, copy) void(^preActionBlock)();

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings;

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                        itemWithSubtitle:(NSString*) subtitle
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings;

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings
                                  action:(void(^)(BOOL))block;

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                        itemWithSubtitle:(NSString*) subtitle
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings
                                  action:(void(^)(BOOL))block;

+(SwitchSettingItemModel*) itemWithTitle:(NSString*) title
                        itemWithSubtitle:(NSString*) subtitle
                              settingKey:(NSString*) settingKey
                              inSettings:(AppSettingsModel*)settings
                                  action:(void(^)(BOOL))block
                               preAction:(void(^)())preBlock;

- (BOOL)canSwitch;

@end
