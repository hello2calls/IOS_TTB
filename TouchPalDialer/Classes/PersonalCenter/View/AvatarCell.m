//
//  AvatarCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/1.
//
//

#import "AvatarCell.h"
#import "TPDialerResourceManager.h"
@interface AvatarCell ()
@property (nonatomic,weak) UIView *selectView;
@end

@implementation AvatarCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *avatarImageView = [[UIImageView alloc] init];
        [self addSubview:avatarImageView];
        self.avatarImageView = avatarImageView;
        
        UIView *selectView = [[UIView alloc] init];
        self.selectView = selectView;
        self.selectedBackgroundView = selectView;
    }
    return self;
}



- (void)layoutSubviews{
    
    [super layoutSubviews];
    CGFloat avatarImageViewPadding = 6;
    CGFloat avatarImageViewW = self.bounds.size.width - 12;
    CGFloat avatarImageViewH = self.bounds.size.height - 12;
    self.avatarImageView.frame = CGRectMake(avatarImageViewPadding, avatarImageViewPadding, avatarImageViewW, avatarImageViewH);
    
    CGFloat selectViewX = 2 ;
    CGFloat selectViewY = 2 ;
    CGFloat selectViewW = self.bounds.size.width - 4;
    CGFloat selectViewH = self.bounds.size.height - 4;

    self.selectView.frame = CGRectMake(selectViewX, selectViewY, selectViewW, selectViewH );
    self.selectView.layer.cornerRadius = selectViewW / 2;
    self.selectView.layer.masksToBounds = YES;
    self.selectView.layer.borderWidth = 1 ;
    self.selectView.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;
}
@end
