//
//  SingleSelectionSettingCellView.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-20.
//
//

#import "DefaultSettingCellView.h"
#import "SingleSelectionSettingItemModel.h"

@interface SingleSelectionSettingCellView : DefaultSettingCellView
+(SingleSelectionSettingCellView*) singleSelectionCellWithData:(SingleSelectionSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;

-(id) initWithData:(SingleSelectionSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;
@end
