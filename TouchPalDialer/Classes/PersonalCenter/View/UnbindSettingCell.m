//
//  UnbindSettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "UnbindSettingCell.h"

@interface UnbindSettingCell ()

@property (nonatomic,weak) UILabel *titleLabel;

@end
@implementation UnbindSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self buildUI];
        
    }
    return self;
}

- (void)setSettingItem:(SettingItem *)settingItem{
    [super setSettingItem:settingItem];
    _titleLabel.text    = self.settingItem.title;
    [_titleLabel sizeToFit];
}

- (void)buildUI{
    
    UILabel *titleLabel         = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [self mainTextColor];
    self.titleLabel = titleLabel;
    self.titleLabel.font        = [UIFont systemFontOfSize:17];
    [self addSubview:titleLabel];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];

    CGFloat titleLabelW = _titleLabel.bounds.size.width;
    CGFloat titleLabelH = _titleLabel.bounds.size.height;
    CGFloat titleLabelX = (self.bounds.size.width - titleLabelW) / 2;
    CGFloat titleLabelY = (self.bounds.size.height - titleLabelH) / 2;
    
    self.titleLabel.frame =  CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
}
@end
