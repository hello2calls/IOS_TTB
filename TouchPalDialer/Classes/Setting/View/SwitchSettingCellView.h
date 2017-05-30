//
//  SwitchSettingCellView.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "DefaultSettingCellView.h"
#import "SwitchSettingItemModel.h"

@interface SwitchSettingCellView : DefaultSettingCellView
@property (nonatomic, copy) void(^actionBlock)(void) ;
@property (nonatomic, copy) NSString *closeAlertStr;
@property (nonatomic, copy) NSString *openAlertStr;
+(SwitchSettingCellView*) switchCellWithData:(SwitchSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;
-(id) initWithData:(SwitchSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position;
-(void)setSwitchOn:(BOOL)on;
-(UISwitch*)getSwitch;
@end
