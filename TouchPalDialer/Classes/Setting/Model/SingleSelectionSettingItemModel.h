//
//  SingleSelectionSettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "ActionableSettingItemModel.h"
#import "AppSettingsModel.h"

@interface SingleSelectionSettingItemModel : ActionableSettingItemModel

@property (nonatomic, copy) void(^settingChangedBlock)(void);
@property (nonatomic, copy) NSString* settingKey;
@property (nonatomic, retain) id expectedValue;
@property (nonatomic, retain) AppSettingsModel* settings;

+(SingleSelectionSettingItemModel*) itemWithTitle:(NSString*) title settingKey:(NSString*) settingKey forExpectedValue:(id)value inSettings:(AppSettingsModel*)settings;

-(BOOL) isChecked;
@end
