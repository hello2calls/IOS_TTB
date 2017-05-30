//
//  SettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/25.
//
//

#import "NormalSettingCell.h"

@interface NormalSettingCell ()
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *subtitleLabel;
@property (nonatomic,weak) UILabel *badgeLabel;
@property (nonatomic,weak) UILabel *redDot;

@end

@implementation NormalSettingCell

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
    subtitleLabel.textColor     = [self subTextColor];
    subtitleLabel.backgroundColor  = [UIColor clearColor];
    self.subtitleLabel          = subtitleLabel;
    self.subtitleLabel.font     = [UIFont systemFontOfSize:13];
    [self addSubview:subtitleLabel];
    
    UILabel *badgeLabel         = [[UILabel alloc] init];
    badgeLabel.textAlignment    = NSTextAlignmentCenter;
    badgeLabel.font             = [UIFont systemFontOfSize:10];
    badgeLabel.textColor        = [UIColor whiteColor];
    badgeLabel.backgroundColor  = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
    badgeLabel.layer.masksToBounds = YES;
    self.badgeLabel             = badgeLabel;
    [self addSubview:badgeLabel];
    
    UILabel *redDot             = [[UILabel alloc] init];
    redDot.textAlignment        = NSTextAlignmentCenter;
    redDot.font                 = [UIFont systemFontOfSize:10];
    redDot.textColor            = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"];
    redDot.backgroundColor      = [UIColor clearColor];
    self.redDot                 = redDot;
    redDot.text                 = @"●";
    [redDot sizeToFit];
    [self addSubview:redDot];
}

- (void)setSettingItem:(SettingItem *)settingItem{
    [super setSettingItem:settingItem];
    _titleLabel.text    = self.settingItem.title;
    _subtitleLabel.text = self.settingItem.subTitle;
    _badgeLabel.text    = ((NormalSettingItem *)self.settingItem).badgeTitle;
    _badgeLabel.hidden  = ((NormalSettingItem *)self.settingItem).badgeTitle == nil;
    _redDot.hidden      = ((NormalSettingItem *)self.settingItem).redDotHidden;
    [_titleLabel sizeToFit];
    [_subtitleLabel sizeToFit];
    [_badgeLabel sizeToFit];

}

- (void)layoutSubviews{
    [super layoutSubviews];

    CGFloat titleLabelX = kSettingCellFrontPadding;
    CGFloat titleLabelY = (self.bounds.size.height - _titleLabel.bounds.size.height) / 2;
    CGFloat titleLabelW = _titleLabel.bounds.size.width;
    CGFloat titleLabelH = _titleLabel.bounds.size.height;
    
    CGFloat subtitleLabelX =  self.bounds.size.width - kSettingCellTailPadding - _subtitleLabel.bounds.size.width;
    CGFloat subtitleLabelY = (self.bounds.size.height - _subtitleLabel.bounds.size.height) / 2;
    CGFloat subtitleLabelW = _subtitleLabel.bounds.size.width;
    CGFloat subtitleLabelH = _subtitleLabel.bounds.size.height;
    
    self.titleLabel.frame  =  CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    self.subtitleLabel.frame =  CGRectMake(subtitleLabelX, subtitleLabelY, subtitleLabelW, subtitleLabelH);
    
    if (!self.badgeLabel.hidden) {
        CGFloat badgeLabelX = titleLabelX +titleLabelW + 4;
        CGFloat badgeLabelY = (self.bounds.size.height - _badgeLabel.bounds.size.height) / 2;
        CGFloat badgeLabelW = 35;
        CGFloat badgeLabelH = 14;
        self.badgeLabel.layer.cornerRadius = 7;
        self.badgeLabel.frame =  CGRectMake(badgeLabelX, badgeLabelY, badgeLabelW, badgeLabelH);
    }
    
    if (!self.redDot.hidden) {
        self.redDot.tp_x = titleLabelX +titleLabelW + 4;
        self.redDot.tp_y = (self.bounds.size.height - _redDot.bounds.size.height) / 2;
    }

}

@end
