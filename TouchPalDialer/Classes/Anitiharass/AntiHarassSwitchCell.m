//
//  AntiHarassSwitchCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/10.
//
//

#import "AntiHarassSwitchCell.h"
#import "AppSettingsModel.h"

@interface AntiHarassSwitchCell ()

@property (nonatomic,weak) UISwitch *switchView;
@property (nonatomic,weak) UIButton *switchDetectButton;

@end

@implementation AntiHarassSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self buildUI];
        
    }
    return self;
}

- (void)buildUI{
    
    ((UIView *)[self valueForKey:@"_arrowLabel"]).hidden = YES;
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.userInteractionEnabled = NO;
    self.switchView = switchView;
    [self addSubview:switchView];
    
    UIButton *switchDetectButton = [[UIButton alloc] init];
    switchDetectButton.backgroundColor = [UIColor clearColor];
    self.switchDetectButton = switchDetectButton;
    [switchDetectButton addTarget:self action:@selector(switchViewWillChanged) forControlEvents:UIControlEventTouchDown];
    [self addSubview:switchDetectButton];
}

- (void)setItem:(AntiNormalItem *)item{
    
    [super setItem:item];

    NSString *key = ((AntiSwitchItem *)item).settingKey;
    self.switchView.on = [[[AppSettingsModel appSettings] settingValueForKey:key] boolValue];
    
}

- (void)switchViewWillChanged{

    AntiSwitchItem *item = (AntiSwitchItem *)self.item;
    if (item.switchHandle) {
        item.switchHandle(!self.switchView.on);
    }
    
}

- (void)layoutSubviews{

    [super layoutSubviews];
    
    self.switchView.tp_x = self.tp_width - self.switchView.tp_width - kSettingCellArrowPadding;
    self.switchView.tp_y = (self.tp_height - self.switchView.tp_height) / 2;
    
    self.switchDetectButton.frame = self.switchView.frame;
}
@end
