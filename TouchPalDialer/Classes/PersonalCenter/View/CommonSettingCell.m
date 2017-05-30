//
//  CommonSettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/3.
//
//

#import "CommonSettingCell.h"

@interface CommonSettingCell  ()

@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *subtitleLabel;
@property (nonatomic,weak) UILabel *rightTitleLabel;

@end

@implementation CommonSettingCell

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

    UILabel *rightTitleLabel    = [[UILabel alloc] init];
    rightTitleLabel.backgroundColor  = [UIColor clearColor];
    self.rightTitleLabel        = rightTitleLabel;
    self.rightTitleLabel.font     = [UIFont systemFontOfSize:13];
    self.rightTitleLabel.textColor     = [self subTextColor];
    [self addSubview:rightTitleLabel];

}

- (void)setSettingItem:(SettingItem *)settingItem{
    [super setSettingItem:settingItem];
    _titleLabel.text    = self.settingItem.title;
    _subtitleLabel.text = self.settingItem.subTitle;
    
    _rightTitleLabel.text = ((CommonSettingItem *)self.settingItem).rightTitle;
    if (((CommonSettingItem *)self.settingItem).rightTitleColor != nil) {
        _rightTitleLabel.textColor = ((CommonSettingItem *)self.settingItem).rightTitleColor;

    }
    
    [_titleLabel sizeToFit];
    [_subtitleLabel sizeToFit];
    [_rightTitleLabel sizeToFit];
    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat titleLabelX = 20;
    CGFloat titleLabelY = (self.bounds.size.height - _titleLabel.tp_height - _subtitleLabel.tp_height) / 2;
    CGFloat titleLabelW = _titleLabel.bounds.size.width;
    CGFloat titleLabelH = _titleLabel.bounds.size.height;
    
    CGFloat subtitleLabelX =  20;
    CGFloat subtitleLabelY =  titleLabelY + titleLabelH + 2;
    CGFloat subtitleLabelW = _subtitleLabel.bounds.size.width;
    CGFloat subtitleLabelH = _subtitleLabel.bounds.size.height;
    
    self.titleLabel.frame  =  CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    self.subtitleLabel.frame =  CGRectMake(subtitleLabelX, subtitleLabelY, subtitleLabelW, subtitleLabelH);
    
    if (self.rightTitleLabel.hidden) {
        return;
    }
    
    CGFloat padding;
    if (self.settingItem.hiddenArrow) {
        padding = kSettingCellHiddenArrowTailPadding;
    }else{
        padding = kSettingCellTailPadding;
    }
    
    self.rightTitleLabel.tp_x = self.tp_width - padding - self.rightTitleLabel.tp_width;
    self.rightTitleLabel.tp_y = (self.tp_height - self.rightTitleLabel.tp_height) / 2;
}



@end
