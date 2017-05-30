//
//  SwitchSettingCellView.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-19.
//
//

#import "SwitchSettingCellView.h"
#import "DefaultUIAlertViewHandler.h"

@interface SwitchSettingCellView() {
    UISwitch *sw_;
    UIButton *_swButton;
}

@property(nonatomic, assign) SwitchSettingItemModel* swithData;

@end

@implementation SwitchSettingCellView

@synthesize swithData;

+(SwitchSettingCellView*) switchCellWithData:(SwitchSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    SwitchSettingCellView* view = [[SwitchSettingCellView alloc] initWithData:data forPosition:position];
    view.selectionStyle = UITableViewCellSelectionStyleNone;
    [view fillData:data];
    
    return view;
}

-(id) initWithData:(SwitchSettingItemModel*) data forPosition:(RoundedCellBackgroundViewPosition)position {
    self = [super initWithData:data forPosition:position cellStyle:[DefaultSettingCellView styleForData:data] selectionStyle:UITableViewCellSelectionStyleNone accessoryType:UITableViewCellAccessoryNone];
    if(self) {
        sw_ = [[UISwitch alloc] initWithFrame:CGRectZero];
        sw_.userInteractionEnabled = NO;
        
        UIButton *swButton = [[UIButton alloc]initWithFrame:CGRectMake(sw_.frame.origin.x, sw_.frame.origin.y, sw_.frame.size.width, sw_.frame.size.height)];
        [swButton addTarget:self action:@selector(onSwitchClick) forControlEvents:UIControlEventTouchUpInside];
        _swButton = swButton;
        [swButton addSubview:sw_];
        
        [self addSubview:swButton];
    }
    return self;
}

-(void) fillData:(SettingItemModel *)data {
    [super fillData:data];
    self.swithData = (SwitchSettingItemModel*) data;
    sw_.on = self.swithData.on;
}

- (void)onSwitchClick{
    if (!self.swithData.canSwitch) {
        return;
    }
    if (self.swithData.preActionBlock){
        swithData.preActionBlock();
        return;
    }
    BOOL isOn = sw_.isOn;
    if ( isOn ){
        if ( _closeAlertStr != nil ){
            [DefaultUIAlertViewHandler showAlertViewWithTitle:_closeAlertStr message:nil cancelTitle:@"取消" okTitle:@"确认" okButtonActionBlock:^(){
                [sw_ setOn:!sw_.isOn animated:YES];
                [self onSwitchChanged:sw_];
            }];
        }else{
            [sw_ setOn:!sw_.isOn animated:YES];
            [self onSwitchChanged:sw_];
        }
    }else{
        if ( _openAlertStr != nil ){
            [DefaultUIAlertViewHandler showAlertViewWithTitle:_openAlertStr message:nil cancelTitle:@"取消" okTitle:@"确认" okButtonActionBlock:^(){
                [sw_ setOn:!sw_.isOn animated:YES];
                [self onSwitchChanged:sw_];
            }];
        }else{
            [sw_ setOn:!sw_.isOn animated:YES];
            [self onSwitchChanged:sw_];
        }
    }
}

-(void)setSwitchOn:(BOOL)on{
    if ( on == sw_.on )
        return;
    [sw_ setOn:on animated:YES];
    [self onSwitchChanged:sw_];
}

- (void)onSwitchChanged:(UIControl*)sender{
    UISwitch* sw = (UISwitch*) sender;
    self.swithData.on = sw.on;
    if (_actionBlock){
        _actionBlock();
    }
}

-(UISwitch*)getSwitch{
    return sw_;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (_swButton != nil) {
        CGFloat swButtonW = sw_.tp_width;
        CGFloat swButtonH = sw_.tp_height;
        CGFloat swButtonX = self.tp_width - swButtonW - 16;
        CGFloat swButtonY = (self.tp_height - swButtonH) / 2;
        _swButton.frame = CGRectMake(swButtonX, swButtonY, swButtonW, swButtonH);
    }
}
@end
