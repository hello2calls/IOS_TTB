//
//  IconSettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/1.
//
//

#import "IconSettingCell.h"


@interface IconSettingCell ()
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UIImageView *iconView;
@end

@implementation IconSettingCell

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
    
    UIImageView *imageView = [[UIImageView alloc] init];
    self.iconView = imageView;
    [self addSubview:imageView];
}


- (void)setSettingItem:(SettingItem *)settingItem{
    [super setSettingItem:settingItem];
    _titleLabel.text    = self.settingItem.title;
    _iconView.image = ((IconSettingItem *)self.settingItem).iconImage;
    [_titleLabel sizeToFit];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat titleLabelX = kSettingCellFrontPadding;
    CGFloat titleLabelY = (self.bounds.size.height - _titleLabel.bounds.size.height) / 2;
    CGFloat titleLabelW = _titleLabel.bounds.size.width;
    CGFloat titleLabelH = _titleLabel.bounds.size.height;
    self.titleLabel.frame  =  CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    
    CGFloat padding;
    if (self.settingItem.hiddenArrow) {
        padding = kSettingCellHiddenArrowTailPadding;
    }else{
        padding = kSettingCellTailPadding;
    }
    CGFloat iconViewW = 70;
    CGFloat iconViewH = 70;
    CGFloat iconViewX = self.bounds.size.width - iconViewW - padding;
    CGFloat iconViewY = (self.bounds.size.height - iconViewH) / 2;

    self.iconView.frame  =  CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH);
}

@end
