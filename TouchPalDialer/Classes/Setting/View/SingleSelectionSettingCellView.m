//
//  SingleSelectionSettingCellView.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-20.
//
//

#import "SingleSelectionSettingCellView.h"

@implementation SingleSelectionSettingCellView
+(SingleSelectionSettingCellView*) singleSelectionCellWithData:(SingleSelectionSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    SingleSelectionSettingCellView* view = [[SingleSelectionSettingCellView alloc] initWithData:data forPosition:position];
    
    [view fillData:data];
    return view;
}


-(id) initWithData:(SingleSelectionSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    self = [super initWithData:data forPosition:position cellStyle:[DefaultSettingCellView styleForData:data] selectionStyle:UITableViewCellSelectionStyleBlue accessoryType:UITableViewCellAccessoryNone];
    return self;
}

-(void) fillData:(SettingItemModel *)data {
    [super fillData:data];
    SingleSelectionSettingItemModel* m = (SingleSelectionSettingItemModel*)data;
    if(m.isChecked) {
        self.checkMarkLabel.hidden = NO;
    } else {
        self.checkMarkLabel.hidden = YES;

    }
}
@end
