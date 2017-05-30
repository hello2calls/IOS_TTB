//
//  AvatarSettingItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "SettingItem.h"


@interface AvatarSettingItem : SettingItem
@property (nonatomic,strong) UIImage *avatarImage;
@property (nonatomic,copy) HandleBlock avatarClickHandle;

+ (AvatarSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle avatarImage:(UIImage *)avatarImage handleBlock:(HandleBlock)handle;

+ (AvatarSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle avatarImage:(UIImage *)avatarImage vcClass:(NSString *)vcClass;
@end
