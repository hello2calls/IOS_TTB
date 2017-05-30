//
//  AboatUsLogoCell.m
//  TouchPalDialer
//
//  Created by ALEX on 16/8/8.
//
//

#import "AboatUsLogoCell.h"
#import "TouchPalVersionInfo.h"

@interface AboatUsLogoCell ()
@property (nonatomic,weak) UIImageView *logoView;
@property (nonatomic,weak) UILabel *logoLabel;
@property (nonatomic,weak) UILabel *versionLabel;
@end

@implementation AboatUsLogoCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self buildUI];
        
    }
    return self;
}


- (void)buildUI{
    
    UIImage *logoImage = [[TPDialerResourceManager sharedManager] getImageByName:@"aboat_us_logo@2x.png"];
    
    UIImageView *logoView = [[UIImageView alloc] init];
    logoView.image = logoImage;
    self.logoView = logoView;
    logoView.contentMode = UIViewContentModeCenter;
    [self addSubview:logoView];
    
    
    UILabel *logoLabel = [[UILabel alloc] init];
    logoLabel.backgroundColor = [UIColor clearColor];
    logoLabel.font = [UIFont fontWithName:@"iPhoneIcon2" size:36];
    logoLabel.text  = @"8";
    self.logoLabel = logoLabel;
    logoLabel.textColor = [self mainTextColor];
    [logoLabel sizeToFit];
    [self addSubview:logoLabel];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *versionInfo = [NSString stringWithFormat:@"%@(%@)",version,VERSION_DATE];
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.textColor = [self subTextColor];
    versionLabel.text = versionInfo;
    versionLabel.font = [UIFont systemFontOfSize:13];
    [versionLabel sizeToFit];
    self.versionLabel = versionLabel;
    [self addSubview:versionLabel];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}


- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGFloat logoViewW = self.tp_width;
    CGFloat logoViewH = self.logoView.image.size.height;
    CGFloat logoViewX = 0;
    CGFloat logoViewY = 50;

    self.logoView.frame = CGRectMake(logoViewX, logoViewY, logoViewW, logoViewH);
    
    self.logoLabel.tp_x = (self.tp_width - self.logoLabel.tp_width) / 2;
    self.logoLabel.tp_y = CGRectGetMaxY(self.logoView.frame) + 12;
    
    self.versionLabel.tp_y = CGRectGetMaxY(self.logoLabel.frame) + 4;
    self.versionLabel.tp_x = (self.tp_width - self.versionLabel.tp_width) / 2;

}
@end
