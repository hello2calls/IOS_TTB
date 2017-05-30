//
//  DefaultSettingCellView.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "CootekTableViewCell.h"
#import "SettingItemModel.h"

@interface DefaultSettingCellView : CootekTableViewCell

+(DefaultSettingCellView*) defaultCellWithData:(SettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;
+(DefaultSettingCellView*) defaultCellWithData:(SettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position selectionStyle:(UITableViewCellSelectionStyle)style accessoryType:(UITableViewCellAccessoryType) accessoryType;

-(id)initWithData:(SettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position cellStyle:(UITableViewCellStyle)cellStyle selectionStyle:(UITableViewCellSelectionStyle)selectionStyle accessoryType:(UITableViewCellAccessoryType) accessoryType;

+(UITableViewCellStyle) styleForData:(SettingItemModel*) data;
+(NSString*) reuseIdentifierForData:(SettingItemModel*) data inPosition:(RoundedCellBackgroundViewPosition)position;
-(void) fillData:(SettingItemModel*) data;

@end
