//
//  NormalSettingItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "SettingItem.h"

typedef void(^HandleBlock)();

@interface NormalSettingItem : SettingItem

@property (nonatomic,copy)   NSString *badgeTitle;


+ (NormalSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle badgeTitle:(NSString *)badgeTitle vcClass:(NSString *)vcClass;

+ (NormalSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle badgeTitle:(NSString *)badgeTitle handleBlock:(HandleBlock)handle;

@end
