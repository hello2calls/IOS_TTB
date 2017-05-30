//
//  BaseDialerCell.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseCommonCell.h"
#import "AppSettingsModel.h"
#import "PhoneNumber.h"

#import "TouchPalDialerAppDelegate.h"
#import "UIView+WithSkin.h"
#import "TPDialerResourceManager.h"

@implementation BaseCommonCell
@synthesize currentData;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
           }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshWithEditingState:(BOOL)isediting{
    
}
- (void)accessoryButtonClicked:(id)sender{
    cootek_log(@"accessoryButtonClicked *********** go to detail");
}
- (void)goToDetail{
}

- (void)setDataToCell{

}
- (id)selfSkinChange:(NSString *)style{
    cootek_log(@"selfSkinChange = %@",style);
    NSNumber *toTop = [NSNumber numberWithBool:YES];
    return toTop;
}
- (BOOL)isShowNumberAttr{
    return NO;
}

- (void)setLongGestureMode:(BOOL)inLongGesture
{
    // do nothing
}
- (BOOL)supportLongGestureMode
{
    return NO;
}
@end
