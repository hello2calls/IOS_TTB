//
//  NonOpSettingCellView.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-20.
//
//

#import "NonOpSettingCellView.h"

@implementation NonOpSettingCellView
+(NonOpSettingCellView*) nonopCellWithData:(NonOpSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    NonOpSettingCellView* view = [[NonOpSettingCellView alloc] initWithData:data forPosition:position];
    [view fillData:data];
    return view;
}

-(id) initWithData:(NonOpSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    self = [super initWithData:data forPosition:position cellStyle:[NonOpSettingCellView styleForData:data] selectionStyle:UITableViewCellSelectionStyleNone accessoryType:UITableViewCellAccessoryNone];
    return self;
}

+(UITableViewCellStyle) styleForData:(NonOpSettingItemModel*) data {
    if(data.subtitle != nil && data.subtitle.length > 0) {
        return UITableViewCellStyleSubtitle;
    }
    if(data.additionalInfo != nil && data.additionalInfo.length > 0) {
        return UITableViewCellStyleValue1;
    }
    
    return UITableViewCellStyleDefault;
}

-(void) fillData:(SettingItemModel*) data {
    [super fillData:data];
    NonOpSettingItemModel* m = (NonOpSettingItemModel*)data;
    if(m.additionalInfo != nil && m.additionalInfo.length > 0) {
        self.detailTextLabel.text = NSLocalizedString(m.additionalInfo, @"");
    }
}

@end
