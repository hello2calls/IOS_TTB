//
//  SwitchSettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/2.
//
//

#import "SwitchSettingCell.h"
#import "DefaultUIAlertViewHandler.h"
#import "AppSettingsModel.h"

@interface SwitchSettingCell ()

@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *subtitleLabel;
@property (nonatomic,weak) UISwitch *switchView;
@property (nonatomic,weak) UIButton *switchDetectBtn;
@end
@implementation SwitchSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self buildUI];
        
    }
    return self;
}

- (void)buildUI{
    
    UILabel *titleLabel         = [[UILabel alloc] init];
    titleLabel.textColor        = [self mainTextColor];
    titleLabel.backgroundColor  = [UIColor clearColor];
    self.titleLabel = titleLabel;
    self.titleLabel.font        = [UIFont systemFontOfSize:17];
    [self addSubview:titleLabel];
    
    UILabel *subtitleLabel      = [[UILabel alloc] init];
    subtitleLabel.backgroundColor  = [UIColor clearColor];
    subtitleLabel.textColor     = [self subTextColor];
    self.subtitleLabel          = subtitleLabel;
    self.subtitleLabel.font     = [UIFont systemFontOfSize:13];
    [self addSubview:subtitleLabel];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    [self addSubview:switchView];
    self.switchView = switchView;
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *switchDetectBtn = [[UIButton alloc] init];
    switchDetectBtn.userInteractionEnabled = NO;
    [switchDetectBtn addTarget:self action:@selector(detectSwitchTouch) forControlEvents:UIControlEventTouchDown];
    self.switchDetectBtn = switchDetectBtn;
    [self addSubview:switchDetectBtn];
}

- (void)setSettingItem:(SettingItem *)settingItem{
    [super setSettingItem:settingItem];
    _titleLabel.text    = self.settingItem.title;
    _subtitleLabel.text = self.settingItem.subTitle;
    _switchView.userInteractionEnabled = ((SwitchSettingItem *)self.settingItem).openAlert == nil && ((SwitchSettingItem *)self.settingItem).closeAlert == nil;
    _switchDetectBtn.userInteractionEnabled = !_switchView.userInteractionEnabled;
    
    NSString *key = ((SwitchSettingItem *)self.settingItem).appModelKey;
    _switchView.on = [[[AppSettingsModel appSettings] settingValueForKey:key] boolValue];
    
    
    [_titleLabel sizeToFit];
    [_subtitleLabel sizeToFit];

}

- (void)detectSwitchTouch{
    __weak typeof(self) weakSelf = self;
    
    if (self.switchView.isOn && ((SwitchSettingItem *)self.settingItem).closeAlert != nil) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:((SwitchSettingItem *)weakSelf.settingItem).closeAlert message:nil cancelTitle:@"取消" okTitle:@"确认" okButtonActionBlock:^ {
            [weakSelf.switchView setOn:!weakSelf.switchView.on animated:YES];
            [weakSelf switchChanged:weakSelf.switchView];
        } cancelActionBlock:^{
            
        }];
    }else if (!self.switchView.isOn && ((SwitchSettingItem *)self.settingItem).openAlert != nil) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:((SwitchSettingItem *)weakSelf.settingItem).openAlert message:nil cancelTitle:@"取消" okTitle:@"确认" okButtonActionBlock:^ {
            [weakSelf.switchView setOn:!weakSelf.switchView.on animated:YES];
            [weakSelf switchChanged:weakSelf.switchView];
        } cancelActionBlock:^{
            
        }];
    }else{
         [weakSelf.switchView setOn:!weakSelf.switchView.on animated:YES];
         [weakSelf switchChanged:weakSelf.switchView];
    }
 

}

- (void)switchChanged:(UISwitch *)swichView{
    
    NSString *key = ((SwitchSettingItem *)self.settingItem).appModelKey;
    if (key != nil) {
         [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:swichView.isOn] forKey:key];
    }
    
    SwitchSettingItem *switchItem = (SwitchSettingItem *)self.settingItem;
    if (switchItem.switchHandle) {
        switchItem.switchHandle(swichView.isOn);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat titleLabelX = kSettingCellFrontPadding;
    CGFloat titleLabelY = (self.bounds.size.height - _titleLabel.tp_height - _subtitleLabel.tp_height) / 2;
    CGFloat titleLabelW = _titleLabel.bounds.size.width;
    CGFloat titleLabelH = _titleLabel.bounds.size.height;
    
    CGFloat subtitleLabelX =  kSettingCellFrontPadding;
    CGFloat subtitleLabelY =  titleLabelY + titleLabelH + 2;
    CGFloat subtitleLabelW = _subtitleLabel.bounds.size.width;
    CGFloat subtitleLabelH = _subtitleLabel.bounds.size.height;
    
    self.titleLabel.frame  =  CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    self.subtitleLabel.frame =  CGRectMake(subtitleLabelX, subtitleLabelY, subtitleLabelW, subtitleLabelH);
    
    self.switchView.center = CGPointMake(self.tp_width - kSettingCellArrowPadding - self.switchView.tp_width / 2 , self.tp_height / 2);
    self.switchDetectBtn.frame = self.switchView.frame;
}


@end
