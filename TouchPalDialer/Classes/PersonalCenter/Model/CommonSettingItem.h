//
//  CommonSettingItem.h
//  TouchPalDialer
//
//  Created by ALEX on 16/8/3.
//
//

#import "SettingItem.h"

@interface CommonSettingItem : SettingItem

@property (nonatomic,copy) NSString *rightTitle;
@property (nonatomic,strong) UIColor *rightTitleColor;

+ (CommonSettingItem *)itemWithTitle:(NSString *)title subTitle:(NSString *)subTitle rightTitle:(NSString *)rightTitle  handle:(HandleBlock)handle;

@end
