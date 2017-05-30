//
//  SingleSelectionSettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SingleSelectionSettingItemModel.h"
#import "BasicUtil.h"

@implementation SingleSelectionSettingItemModel

@synthesize settingKey;
@synthesize expectedValue;
@synthesize settings;
@synthesize settingChangedBlock;


+(SingleSelectionSettingItemModel*) itemWithTitle:(NSString*) title settingKey:(NSString*) settingKey forExpectedValue:(id)value inSettings:(AppSettingsModel*)settings {
    SingleSelectionSettingItemModel* item = [[SingleSelectionSettingItemModel alloc] init];
    item.title = title;
    item.settingKey = settingKey;
    item.expectedValue = value;
    item.settings = settings;
    return item;
}

-(BOOL) isChecked {
    return [BasicUtil object:expectedValue equalTo:[settings settingValueForKey:settingKey]];
}

-(void) executeAction:(UIViewController *)vc {
     [settings setSettingValue:self.expectedValue forKey:self.settingKey];
    if (settingChangedBlock) {
        settingChangedBlock();
    }
}

@end
