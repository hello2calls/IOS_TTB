//
//  AntiHarassCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "AntiHarassCell.h"
#import "AntiHarassLogoCell.h"
#import "AntiHarassSwitchCell.h"

#import "TPDialerResourceManager.h"

@interface AntiHarassCell ()

@property (nonatomic,weak) UILabel *arrowLabel;
@property (nonatomic,weak) UIView  *topSplitLine;
@property (nonatomic,weak) UIView  *bottomSplitLine;
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *subtitleLabel;
@property (nonatomic,weak) UILabel *badgeLabel;
@end

@implementation AntiHarassCell

#pragma mark - setter / getter

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setup];
        
    }
    return self;
    
}

- (UIColor *)mainTextColor{
    
    return [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_black_transparency_900"];
    
}

- (UIColor *)subTextColor{
    
    return [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_black_transparency_300"];
    
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
    
    UILabel *titleLabel         = [[UILabel alloc] init];
    self.titleLabel             = titleLabel;
    titleLabel.font             = [UIFont systemFontOfSize:17];
    titleLabel.textColor        = [self mainTextColor];
    titleLabel.backgroundColor  = [UIColor clearColor];
    [titleLabel sizeToFit];
    [self addSubview:titleLabel];
    
    UILabel *subtitleLabel      = [[UILabel alloc] init];
    self.subtitleLabel          = subtitleLabel;
    subtitleLabel.font          = [UIFont systemFontOfSize:13];
    subtitleLabel.textColor     = [self subTextColor];
    subtitleLabel.backgroundColor  = [UIColor clearColor];
    [subtitleLabel sizeToFit];
    [self addSubview:subtitleLabel];
    
    UILabel *badgeLabel         = [[UILabel alloc] init];
    badgeLabel.textColor        = [UIColor whiteColor];
    self.badgeLabel             = badgeLabel;
    badgeLabel.font             = [UIFont systemFontOfSize:10];
    badgeLabel.textAlignment    = NSTextAlignmentCenter;
    badgeLabel.layer.masksToBounds = YES;
    badgeLabel.layer.backgroundColor  = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"].CGColor;
    [self addSubview:badgeLabel];
    UIColor *lineColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_black_transparency_100"];
    
    UIView *topSplitLine        = [[UIView alloc] init];
    topSplitLine.backgroundColor = lineColor;
    self.topSplitLine           = topSplitLine;
    [self addSubview:topSplitLine];
    
    UIView *bottomSplitLine     = [[UIView alloc] init];
    bottomSplitLine.backgroundColor   = lineColor;
    self.bottomSplitLine        = bottomSplitLine;
    [self addSubview:bottomSplitLine];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] > 7)) {
        self.contentView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_white"];
    }
    self.backgroundColor        = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_white"];
    //important! make sure that the contentView's background is transparent
    
    UIView *htBackgroundView    = [[UIView alloc] init];
    UIColor *selectedBgColor    = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_100"];
    
    htBackgroundView.backgroundColor = selectedBgColor;
    htBackgroundView.layer.borderColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_100"].CGColor;
    htBackgroundView.layer.borderWidth = 0.5;
    
    self.selectedBackgroundView = htBackgroundView;
}

- (void)setItem:(AntiNormalItem *)item{

    _item = item;
    self.titleLabel.text = _item.title;
    
    if (_item.attributedSubtitle != nil) {
        
        self.subtitleLabel.attributedText = _item.attributedSubtitle;
        
    }else{
        
        self.subtitleLabel.text  = _item.subtitle;
        
    }
    
    _badgeLabel.text    = _item.badge;
    _badgeLabel.hidden  = _item.badge == nil;
    
    [_titleLabel sizeToFit];
    [_subtitleLabel sizeToFit];
    [_badgeLabel sizeToFit];

}

+ (instancetype)cellWithTableView:(UITableView *)tableView settingItem:(AntiNormalItem *)settingItem{
    
    AntiHarassCell *cell = nil;
    
    if ([settingItem isMemberOfClass:[AntiNormalItem class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AntiHarassCell"];
        if (!cell) {
            cell = [[AntiHarassCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"AntiHarassCell"];
        }
        cell.item = settingItem;
    }
    
    if ([settingItem isMemberOfClass:[AntiLogoItem class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AntiHarassLogoCell"];
        if (!cell) {
            cell = [[AntiHarassLogoCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"AntiHarassLogoCell"];
        }
        cell.item = settingItem;
    }
    
    if ([settingItem isMemberOfClass:[AntiSwitchItem class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AntiHarassSwitchCell"];
        if (!cell) {
            cell = [[AntiHarassSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"AntiHarassSwitchCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.item = settingItem;
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
    
    if (_item.attributedSubtitle != nil) {
        
        self.titleLabel.tp_x = kSettingCellFrontPadding;
        self.titleLabel.tp_y = (self.bounds.size.height - self.titleLabel.tp_height - self.subtitleLabel.tp_height - 2) / 2;
        
        self.subtitleLabel.tp_x = kSettingCellFrontPadding;
        self.subtitleLabel.tp_y = CGRectGetMaxY(self.titleLabel.frame) + 2;
        
    }else{
        
        self.titleLabel.tp_x = kSettingCellFrontPadding;
        self.titleLabel.tp_y = (self.bounds.size.height - self.titleLabel.tp_height) / 2;
        
        self.subtitleLabel.tp_x = self.bounds.size.width - kSettingCellTailPadding - self.subtitleLabel.tp_width;
        self.subtitleLabel.tp_y = (self.bounds.size.height - self.subtitleLabel.tp_height) / 2;
    }
    
    if (!self.badgeLabel.hidden) {
        CGFloat badgeLabelX = CGRectGetMaxX(self.titleLabel.frame) + 4;
        CGFloat badgeLabelY = (self.bounds.size.height - _badgeLabel.bounds.size.height) / 2;
        CGFloat badgeLabelW = 35;
        CGFloat badgeLabelH = 14;
        self.badgeLabel.layer.cornerRadius = 7;
        self.badgeLabel.frame =  CGRectMake(badgeLabelX, badgeLabelY, badgeLabelW, badgeLabelH);
    }
}
@end
