//
//  SettingsModelCreator.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import <Foundation/Foundation.h>
#import "SettingPageModel.h"
#import "AppSettingsModel.h"


@interface SettingsCreator : NSObject

+(SettingsCreator*) creator;
-(id) initWithAppSettings:(AppSettingsModel*) settings;
-(SettingPageModel*) modelForPage:(SettingPageType) settingPageType;

@end
