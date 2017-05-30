//
//  AntiHarassLogoCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/9.
//
//

#import "AntiHarassLogoCell.h"
#import "FunctionUtility.h"

@interface AntiHarassLogoCell ()

@property (nonatomic,weak) UIImageView  *bgImageView;
@property (nonatomic,weak) UIImageView  *logoImageView;
@property (nonatomic,weak) UIButton     *tipsButton;
@end

@implementation AntiHarassLogoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self buildUI];
        
    }
    return self;
}

- (void)buildUI{

    self.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
    
    if (!([[[UIDevice currentDevice] systemVersion] floatValue] > 7)) {
        self.contentView.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_light_blue_500"];
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *bgImageView = [[UIImageView alloc] init];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [TPDialerResourceManager getImage:@"antiharass_top_view_bg@2x.png"];
    self.bgImageView = bgImageView;
    [self addSubview:bgImageView];
    
    UIImageView *logoImageView = [[UIImageView alloc] init];
    
    UIImage *logoImage = [TPDialerResourceManager getImage:@"antiharass_top_view_center@2x.png"];

    logoImageView.contentMode   = UIViewContentModeScaleAspectFit;
    logoImageView.image         = logoImage;
    self.logoImageView          = logoImageView;
    logoImageView.tp_width         = 140;
    logoImageView.tp_height        = 140;

    [self addSubview:logoImageView];
    
        
    UIButton *tipsButton            = [[UIButton alloc]init];
    [tipsButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_100"] withFrame:CGRectMake(1, 1, 1, 1)]
        forState:UIControlStateHighlighted];
    tipsButton.titleLabel.font      = [UIFont systemFontOfSize:13];
    tipsButton.backgroundColor      = [UIColor clearColor];
    tipsButton.layer.masksToBounds  = YES;
    tipsButton.layer.cornerRadius   = 14;
    tipsButton.layer.borderColor    = [UIColor whiteColor].CGColor;
    tipsButton.layer.borderWidth    = 1.0f;
    [tipsButton setTitle:@"陌生来电不敢回？快来看秘籍>>" forState:UIControlStateNormal];
    [tipsButton addTarget:self action:@selector(showTips) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tipsButton];
    
    self.tipsButton = tipsButton;

    ((UIView *)[self valueForKey:@"_bottomSplitLine"]).hidden = YES;
    ((UIView *)[self valueForKey:@"_topSplitLine"]).hidden = YES;
    ((UIView *)[self valueForKey:@"_arrowLabel"]).hidden = YES;

}

- (void)showTips{
    
    AntiLogoItem *item = (AntiLogoItem *)self.item;
    if (item.logoHandle) {
        item.logoHandle();
    }
}

- (void)layoutSubviews{

    [super layoutSubviews];
    
    self.logoImageView.center   =   self.center;
    self.bgImageView.frame      =   self.bounds;
    
    CGFloat tipsButtonX         =   (self.tp_width - 220) / 2;;
    CGFloat tipsButtonY         =   CGRectGetMaxY(self.logoImageView.frame) + 15;;
    CGFloat tipsButtonW         =   220;
    CGFloat tipsButtonH         =   28;
    
    self.tipsButton.frame       =   CGRectMake(tipsButtonX, tipsButtonY, tipsButtonW, tipsButtonH);

}
@end
