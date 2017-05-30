//
//  NonOpSettingCellView.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-20.
//
//

#import "DefaultSettingCellView.h"
#import "NonOpSettingItemModel.h"

@interface NonOpSettingCellView : DefaultSettingCellView
+(NonOpSettingCellView*) nonopCellWithData:(NonOpSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;
-(id) initWithData:(NonOpSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;
@end
