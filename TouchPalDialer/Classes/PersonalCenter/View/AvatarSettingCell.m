//
//  AvatarSettingCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/29.
//
//

#import "AvatarSettingCell.h"

@interface AvatarSettingCell ()
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *subtitleLabel;
@property (nonatomic,weak) UIImageView  *avatarView;
@property (nonatomic,weak) UIButton *avatarButton;
@end

@implementation AvatarSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self buildUI];
        
    }
    return self;
}

- (void)setSettingItem:(SettingItem *)settingItem{
    [super setSettingItem:settingItem];
    _titleLabel.text    = self.settingItem.title;
    _subtitleLabel.text = self.settingItem.subTitle;
    _avatarView.image   = ((AvatarSettingItem *)self.settingItem).avatarImage;
    _avatarButton.enabled = ((AvatarSettingItem *)self.settingItem).avatarClickHandle != nil;
    [_titleLabel sizeToFit];
    [_subtitleLabel sizeToFit];
}

- (void)buildUI{
    
    UILabel *titleLabel         = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [self mainTextColor];//[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_900"];
    self.titleLabel = titleLabel;
    self.titleLabel.font        = [UIFont systemFontOfSize:17];
    [self addSubview:titleLabel];
    
    UILabel *subtitleLabel      = [[UILabel alloc] init];
    subtitleLabel.backgroundColor  = [UIColor clearColor];
    subtitleLabel.textColor     = [self subTextColor];//[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
    self.subtitleLabel          = subtitleLabel;
    self.subtitleLabel.font     = [UIFont systemFontOfSize:13];
    [self addSubview:subtitleLabel];
    
    UIImageView *avatarView     = [[UIImageView alloc] init];
    self.avatarView = avatarView;
    avatarView.layer.masksToBounds = YES;
    [self addSubview:avatarView];
    
    UIButton *avatarButton      = [[UIButton alloc] init];
    self.avatarButton           = avatarButton;
    avatarButton.backgroundColor= [UIColor clearColor];
    [avatarButton addTarget:self action:@selector(avatarDidClick) forControlEvents:UIControlEventTouchDown];
    [self addSubview:avatarButton];

}

- (void)avatarDidClick{

    if ( ((AvatarSettingItem *)self.settingItem).avatarClickHandle != nil) {
        ((AvatarSettingItem *)self.settingItem).avatarClickHandle();
    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat avatarViewX = kSettingCellFrontPadding;
    
    CGFloat size = [UIScreen mainScreen].scale > 2 ? 70 : 60;
    
    CGFloat avatarViewY = (self.bounds.size.height - size) / 2;
    
    CGFloat avatarViewW = size;
    CGFloat avatarViewH = size;
    
    CGFloat titleLabelX = avatarViewX + avatarViewW + 16;
    CGFloat titleLabelY = (self.bounds.size.height - 32) / 2;
    CGFloat titleLabelW = _titleLabel.bounds.size.width;
    CGFloat titleLabelH = _titleLabel.bounds.size.height;
    
    CGFloat subtitleLabelX =  titleLabelX;
    CGFloat subtitleLabelY =  titleLabelY + titleLabelH + 2;
    CGFloat subtitleLabelW = _subtitleLabel.bounds.size.width;
    CGFloat subtitleLabelH = _subtitleLabel.bounds.size.height;
    
    self.avatarView.frame =  CGRectMake(avatarViewX, avatarViewY, avatarViewW, avatarViewH);
    self.avatarView.layer.cornerRadius = avatarViewW / 2;
    self.titleLabel.frame =  CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    self.subtitleLabel.frame =  CGRectMake(subtitleLabelX, subtitleLabelY, subtitleLabelW, subtitleLabelH);
    self.avatarButton.frame = self.avatarView.frame;
}
@end
