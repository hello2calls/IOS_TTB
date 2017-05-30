//
//  GoDetailSettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "ActionableSettingItemModel.h"
#import "SettingPageModel.h"

@interface GoDetailSettingItemModel : ActionableSettingItemModel

@property (nonatomic, assign) SettingPageType settingPageType;

+(GoDetailSettingItemModel*) itemWithTitle:(NSString*) title PageType:(SettingPageType) pageType;
+(GoDetailSettingItemModel*) itemWithTitle:(NSString*) title subTitle:(NSString*)subTitle PageType:(SettingPageType) pageType;
+(GoDetailSettingItemModel*) itemWithTitle:(NSString*) title subTitle:(NSString*)subTitle withHintType:(int)type withHintCount:(NSInteger)count PageType:(SettingPageType) pageType;

@end
