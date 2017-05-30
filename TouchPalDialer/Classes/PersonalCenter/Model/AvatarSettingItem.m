//
//  AvatarSettingItem.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "AvatarSettingItem.h"

@implementation AvatarSettingItem

+ (AvatarSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle avatarImage:(UIImage *)avatarImage handleBlock:(HandleBlock)handle{
    AvatarSettingItem *settingModel = [[self alloc] initWithTitle:title subTitle:subTitle vcClass:nil handle:handle];
    settingModel.avatarImage = avatarImage;
    return settingModel;
}

+ (AvatarSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle avatarImage:(UIImage *)avatarImage vcClass:(NSString *)vcClass{
    AvatarSettingItem *settingModel = [[self alloc] initWithTitle:title subTitle:subTitle vcClass:vcClass handle:nil];
    settingModel.avatarImage = avatarImage;
    return settingModel;
}

@end
