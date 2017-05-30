//
//  VideoNewsRowView.m
//  TouchPalDialer
//
//  Created by siyi on 2016-11-30.
//
//

#import "VideoNewsRowView.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TPDialerResourceManager.h"

#define VIDEO_TIME_LABEL_HEIGHT (16)

@implementation VideoNewsRowView
- (instancetype) init {
    self = [super init];
    if (self != nil) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(16, 16, 16, 16);
        
        _titleLabel = [UILabel tpd_commonLabel];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_titleLabel tpd_withText:@"" color:VIDEO_TITLE_COLOR font:VIDEO_TITLE_FONT_SIZE];
        
        _subTitleLabel = [UILabel tpd_commonLabel];
        _subTitleLabel.numberOfLines = 1;
        _subTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_subTitleLabel tpd_withText:@"" color:VIDEO_SUBTITLE_COLOR font:VIDEO_SUBTITLE_FONT_SIZE];
        
        _videoTimeLabel = [UILabel tpd_commonLabel];
        [_videoTimeLabel tpd_withText:@"" color:[UIColor whiteColor] font:10];
        _videoTimeLabel.layer.cornerRadius = VIDEO_TIME_LABEL_HEIGHT / 2;
        _videoTimeLabel.clipsToBounds = YES;
        
        _videoTimeLabel.textColor = [UIColor whiteColor];
        _videoTimeLabel.textAlignment = NSTextAlignmentCenter;
        _videoTimeLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        _preivewImageView = [[UIImageView alloc] init];
        _preivewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _preivewImageView.clipsToBounds = YES;
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = VIDEO_LINE_COLOR;
        
        [_preivewImageView addSubview:_videoTimeLabel];
        [_videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_offset(-10);
            make.size.mas_equalTo(CGSizeMake(34, VIDEO_TIME_LABEL_HEIGHT));
        }];
        
        [self addSubview:_titleLabel];
        [self addSubview:_subTitleLabel];
        [self addSubview:_preivewImageView];
        [self addSubview:_bottomLine];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(contentInsets.top);
            make.top.mas_equalTo(self).offset(contentInsets.left);
            make.right.mas_equalTo(_preivewImageView.left).offset(-28);
        }];
        
        [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_titleLabel);
            make.bottom.mas_equalTo(self).offset(-contentInsets.bottom);
        }];
        
        [_preivewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).offset(contentInsets.top);
            make.right.mas_equalTo(self).offset(-contentInsets.right);
            make.size.mas_equalTo(CGSizeMake(120, 78));
        }];
        
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_subTitleLabel);
            make.right.mas_equalTo(_preivewImageView);
            make.bottom.mas_equalTo(self).offset(-0.5);
            make.height.mas_equalTo(0.5);
        }];
        
        // self config
    }
    return self;
}

- (void) updateUIWithItem:(FindNewsItem *)item {
    _item = item;
    if (_item == nil) {
        return;
    }
    
    _titleLabel.text = item.title;
    _subTitleLabel.text = item.subTitle;
    NSArray *materialImages = item.images;
    if (materialImages != nil  && materialImages.count >= 1) {
        [_preivewImageView sd_setImageWithURL:[NSURL URLWithString:materialImages[0]]
                             placeholderImage:[TPDialerResourceManager getImage:@"feeds_video_preview_placeholder_small@3x.png"]];
    }
    int minutes = item.duration / 60;
    int seconds = item.duration % 60;
    _videoTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

@end
