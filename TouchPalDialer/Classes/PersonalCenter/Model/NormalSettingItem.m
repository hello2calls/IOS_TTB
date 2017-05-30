//
//  NormalSettingItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "NormalSettingItem.h"

@implementation NormalSettingItem

+ (NormalSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle badgeTitle:(NSString *)badgeTitle handleBlock:(HandleBlock)handle;{
    NormalSettingItem *settingModel = [[self alloc] initWithTitle:title subTitle:subTitle vcClass:nil handle:handle];
    settingModel.badgeTitle = badgeTitle;
    return settingModel;
}

+ (NormalSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle badgeTitle:(NSString *)badgeTitle vcClass:(NSString *)vcClass{
    NormalSettingItem *settingModel = [[self alloc] initWithTitle:title subTitle:subTitle vcClass:vcClass handle:nil];
    settingModel.badgeTitle = badgeTitle;
    return settingModel;
}

@end
