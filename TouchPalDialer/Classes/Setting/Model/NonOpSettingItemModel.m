//
//  NonOpSettingItemModel.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "NonOpSettingItemModel.h"

@implementation NonOpSettingItemModel

+(NonOpSettingItemModel*) itemWithTitle:(NSString*) title  subTitle:(NSString *)subTitle additionalInfo:(NSString*) additionalInfo {
    NonOpSettingItemModel* item = [[NonOpSettingItemModel alloc] init];
    item.title = title;
    item.subtitle = subTitle;
    item.additionalInfo = additionalInfo;
    
    return item;
}

@end
