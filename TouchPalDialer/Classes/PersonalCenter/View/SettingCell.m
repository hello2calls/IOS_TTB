//
//  SettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "SettingCell.h"
#import "TPDialerResourceManager.h"
#import "NormalSettingCell.h"
#import "AvatarSettingCell.h"
#import "UnbindSettingCell.h"
#import "IconSettingCell.h"
#import "SwitchSettingCell.h"
#import "CommonSettingCell.h"
#import "AboatUsLogoCell.h"
#import "AntiHarassLogoCell.h"

@interface SettingCell ()

@property (nonatomic,weak) UILabel *arrowLabel;
@property (nonatomic,weak) UIView  *topSplitLine;
@property (nonatomic,weak) UIView  *bottomSplitLine;

@end

@implementation SettingCell

#pragma mark - setter / getter

- (void)setSettingItem:(SettingItem *)settingItem{
    
    _settingItem = settingItem;
    if (_settingItem.hiddenArrow) {
        _arrowLabel.hidden = YES;
    }else{
        _arrowLabel.hidden = NO;
    }
    
}

- (void)setHiddenArrow:(BOOL)hiddenArrow{
    
    _hiddenArrow = hiddenArrow;
    _arrowLabel.hidden = _hiddenArrow;
    
}

- (void)setSeparateLineType:(SettingCellSeparateLineType)separateLineType{
    
    _separateLineType = separateLineType;
    if (_separateLineType == SettingCellSeparateLineTypeHeader) {
        _topSplitLine.tp_x = 0;
        _bottomSplitLine.tp_x = kSettingCellFrontPadding;
    }else if(_separateLineType == SettingCellSeparateLineTypeFooter) {
        _topSplitLine.tp_x = kSettingCellFrontPadding;
        _bottomSplitLine.tp_x = 0;
    }else if(_separateLineType == SettingCellSeparateLineTypeSingle) {
        _topSplitLine.tp_x = 0;
        _bottomSplitLine.tp_x = 0;
    }else{
        _topSplitLine.tp_x = kSettingCellFrontPadding;
        _bottomSplitLine.tp_x = kSettingCellFrontPadding;
    }
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setup];

    }
    return self;
    
}

- (UIColor *)mainTextColor{
    
    return [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"defaultCellMainText_color"];
    
}

- (UIColor *)subTextColor{
    
    return [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_infoText_color"];
    
}


- (void)setup{
    
    UILabel *arrowLabel         = [[UILabel alloc] init];
    arrowLabel.textColor        = [self subTextColor];
    arrowLabel.backgroundColor  = [UIColor clearColor];
    self.arrowLabel = arrowLabel;
    self.arrowLabel.font        = [UIFont fontWithName:@"iPhoneIcon1" size:14];
    self.arrowLabel.text        = @"q";
    [arrowLabel sizeToFit];
    [self addSubview:arrowLabel];
    
    UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"baseContactCell_downSeparateLine_color"];
//    baseContactCell_downSeparateLine_color generalSettingCell_Background_ht_color
    UIView *topSplitLine        = [[UIView alloc] init];
    topSplitLine.backgroundColor   = lineColor;
    self.topSplitLine           = topSplitLine;
    [self addSubview:topSplitLine];
    
    UIView *bottomSplitLine     = [[UIView alloc] init];
    bottomSplitLine.backgroundColor   = lineColor;
    self.bottomSplitLine        = bottomSplitLine;
    [self addSubview:bottomSplitLine];
    
    self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_color"];
    //important! make sure that the contentView's background is transparent
    self.contentView.backgroundColor = [UIColor clearColor];
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] > 7)) {
        self.contentView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_color"];
    }
    UIView *htBackgroundView = [[UIView alloc] init];
    UIColor *selectedBgColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_ht_color"];
    
    htBackgroundView.backgroundColor = selectedBgColor;
    htBackgroundView.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"generalSettingCell_Background_ht_color"].CGColor;
    htBackgroundView.layer.borderWidth = 0.5;
    
    self.selectedBackgroundView = htBackgroundView;
    
    UILabel *checkMarkLabel     = [[UILabel alloc] init];
    self.checkMarkLabel         = checkMarkLabel;
    checkMarkLabel.font         = [UIFont fontWithName:@"iPhoneIcon2" size:20];;
    checkMarkLabel.backgroundColor = [UIColor clearColor];
    checkMarkLabel.textColor    = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_light_blue_500"];
    checkMarkLabel.hidden       = YES;
    checkMarkLabel.text         = @"v";
    [checkMarkLabel sizeToFit];
    [self addSubview:checkMarkLabel];

}

- (void)setHiddenSeparateLine:(BOOL)hiddenSeparateLine{

    _hiddenSeparateLine = hiddenSeparateLine;
 
    _bottomSplitLine.hidden = _hiddenSeparateLine;
    _topSplitLine.hidden    = _hiddenSeparateLine;
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView settingItem:(SettingItem *)settingItem{
    
    SettingCell *cell = nil;
    if ([settingItem isMemberOfClass:[SettingItem class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
        if (!cell) {
            cell = [[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"SettingCell"];
        }
    }
    
    if ([settingItem isMemberOfClass:[NormalSettingItem class]]) {
        NormalSettingCell *normalSettingCell = [tableView dequeueReusableCellWithIdentifier:@"NormalSettingCell"];
        if (!normalSettingCell) {
            normalSettingCell = [[NormalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"NormalSettingCell"];
        }
        normalSettingCell.settingItem = settingItem;
        cell = normalSettingCell;
    }
    
    if ([settingItem isMemberOfClass:[AvatarSettingItem class]]) {
        AvatarSettingCell *avatarSettingCell = [tableView dequeueReusableCellWithIdentifier:@"AvatarSettingCell"];
        if (!avatarSettingCell) {
            avatarSettingCell = [[AvatarSettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"AvatarSettingCell"];
        }
        avatarSettingCell.settingItem = settingItem;
        cell = avatarSettingCell;
    }
    
    if ([settingItem isMemberOfClass:[UnbindSettingItem class]]) {
        UnbindSettingCell *unbindSettingCell = [tableView dequeueReusableCellWithIdentifier:@"UnbindSettingCell"];
        if (!unbindSettingCell) {
            unbindSettingCell = [[UnbindSettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"UnbindSettingCell"];
        }
        unbindSettingCell.settingItem = settingItem;
        cell = unbindSettingCell;
    }
    
    if ([settingItem isMemberOfClass:[IconSettingItem class]]) {
        IconSettingCell *iconSettingCell = [tableView dequeueReusableCellWithIdentifier:@"IconSettingCell"];
        if (!iconSettingCell) {
            iconSettingCell = [[IconSettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"IconSettingCell"];
        }
        iconSettingCell.settingItem = settingItem;
        cell = iconSettingCell;
    }
    
    if ([settingItem isMemberOfClass:[SwitchSettingItem class]]) {
        SwitchSettingCell *switchSettingCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchSettingCell"];
        if (!switchSettingCell) {
            switchSettingCell = [[SwitchSettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"SwitchSettingCell"];
        }
        switchSettingCell.settingItem = settingItem;
        cell = switchSettingCell;
    }
    
    if ([settingItem isMemberOfClass:[CommonSettingItem class]]) {
         CommonSettingCell*commonSettingCell = [tableView dequeueReusableCellWithIdentifier:@"CommonSettingCell"];
        if (!commonSettingCell) {
            commonSettingCell = [[CommonSettingCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"CommonSettingCell"];
        }
        commonSettingCell.settingItem = settingItem;
        cell = commonSettingCell;
    }
 
    if ([settingItem isMemberOfClass:[AboatUsLogoItem class]]) {
        AboatUsLogoCell *aboatUsLogoCell = [tableView dequeueReusableCellWithIdentifier:@"AboatUsLogoCell"];
        if (!aboatUsLogoCell) {
            aboatUsLogoCell = [[AboatUsLogoCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"AboatUsLogoCell"];
        }
        aboatUsLogoCell.settingItem = settingItem;
        cell = aboatUsLogoCell;
    }
    
    return cell;
}

#pragma mark - pravite method

- (void)layoutSubviews{
    
    [super layoutSubviews];
    self.arrowLabel.tp_x = self.bounds.size.width - kSettingCellArrowPadding - self.arrowLabel.tp_width;
    self.arrowLabel.tp_y = (self.bounds.size.height - self.arrowLabel.tp_height) / 2;

    CGFloat splitLineX = kSettingCellFrontPadding;
    CGFloat splitLineH = 1 / [UIScreen mainScreen].scale;
    CGFloat splitLineY = self.bounds.size.height;
    CGFloat splitLineW = self.bounds.size.width;
    
    self.bottomSplitLine.frame =  CGRectMake(splitLineX, splitLineY, splitLineW, splitLineH);
    
    self.topSplitLine.frame =  CGRectMake(splitLineX, 0, splitLineW, splitLineH);
    
    if(_separateLineType == SettingCellSeparateLineTypeHeader) {
        self.topSplitLine.tp_x = 0;
    }else if(_separateLineType == SettingCellSeparateLineTypeFooter) {
        self.bottomSplitLine.tp_x = 0;
    }if(_separateLineType == SettingCellSeparateLineTypeSingle) {
        self.bottomSplitLine.tp_x = 0;
        self.topSplitLine.tp_x = 0;
    }
    
    self.checkMarkLabel.tp_x = self.tp_width - self.checkMarkLabel.tp_width - 16;
    self.checkMarkLabel.tp_y = (self.tp_height - self.checkMarkLabel.tp_height) / 2;
    
}


@end
