//
//  NonOpSettingItemModel.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-18.
//
//

#import "SettingItemModel.h"

@interface NonOpSettingItemModel : SettingItemModel

@property (nonatomic, copy) NSString* additionalInfo;

+(NonOpSettingItemModel*) itemWithTitle:(NSString*) title  subTitle:(NSString *)subTitle additionalInfo:(NSString*) additionalInfo;
@end
