//
//  PreShareVersion1View.m
//  TouchPalDialer
//
//  Created by game3108 on 16/1/13.
//
//

#import "PreShareVersion1View.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

#define WILD_MATCH_STR @"%s"
#define WIDTH_ADAPT TPScreenWidth() / 320.0

@implementation PreShareVersion1View

- (id)initWithFrame:(CGRect)frame andShareData:(ShareData *)shareData{
    self = [super initWithFrame:frame];
    if ( self ){
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        
        
        CGFloat frameWidth = self.frame.size.width - 60*WIDTH_ADAPT;
        CGFloat labelWidth = frameWidth - 56*WIDTH_ADAPT;
        CGSize labelSize = [shareData.shareBonusHint sizeWithFont:[UIFont systemFontOfSize:13*WIDTH_ADAPT] constrainedToSize:CGSizeMake(labelWidth,150*WIDTH_ADAPT)];
        CGFloat frameHeight = labelSize.height + 213*WIDTH_ADAPT;
        
        UIView *packageView = [[UIView alloc]initWithFrame:CGRectMake(30*WIDTH_ADAPT, (self.frame.size.height-frameHeight)/2, frameWidth, frameHeight)];
        packageView.backgroundColor = [UIColor clearColor];
        [self addSubview:packageView];
        
        
        UIImage *bgImage = [TPDialerResourceManager getImage:@"share_packet_version_1_bg@2x.png"];
        CGFloat bgImageHeight = bgImage.size.height / bgImage.size.width *frameWidth;
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, packageView.frame.size.height-bgImageHeight, packageView.frame.size.width, bgImageHeight)];
        bgImageView.image = bgImage;
        [packageView addSubview:bgImageView];
        
        UIView *boardView = [[UIView alloc]initWithFrame:CGRectMake(8*WIDTH_ADAPT, 0, packageView.frame.size.width-16*WIDTH_ADAPT, packageView.frame.size.height)];
        boardView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"share_packet_version_1_board_color"];
        [packageView addSubview:boardView];
        
        UIImage *fgImage = [TPDialerResourceManager getImage:@"share_packet_version1_board@2x.png"];
        CGFloat fgImageHeight = fgImage.size.height / fgImage.size.width *frameWidth;
        UIImageView *fgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, packageView.frame.size.height-fgImageHeight, packageView.frame.size.width, fgImageHeight)];
        fgImageView.image = fgImage;
        [packageView addSubview:fgImageView];
        
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(packageView.frame.origin.x+packageView.frame.size.width - 42*WIDTH_ADAPT, packageView.frame.origin.y - 10*WIDTH_ADAPT, 44*WIDTH_ADAPT, 44*WIDTH_ADAPT)];
        [backButton setTitle:@"F" forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:16*WIDTH_ADAPT];
        [backButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_300"] forState:UIControlStateNormal];
        [backButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_150"] forState:UIControlStateNormal];
        [backButton setBackgroundColor:[UIColor clearColor]];
        [backButton addTarget:self action:@selector(onCloseClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        
        CGFloat globalY = 30*WIDTH_ADAPT;
        
        UILabel *shareTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*WIDTH_ADAPT, globalY, boardView.frame.size.width-40*WIDTH_ADAPT, 17*WIDTH_ADAPT)];
        shareTitleLabel.backgroundColor = [UIColor clearColor];
        shareTitleLabel.textAlignment = NSTextAlignmentCenter;
        [boardView addSubview:shareTitleLabel];
        
        NSString *shareTitle = shareData.shareBonusMessage;
        NSString *shareTitleQuantity = shareData.shareBonusQuantity;
        
        NSRange range = [shareTitle rangeOfString:WILD_MATCH_STR];
        if (range.location == NSNotFound){
            shareTitleLabel.text = shareTitle;
            shareTitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_900"];
            shareTitleLabel.font = [UIFont systemFontOfSize:16*WIDTH_ADAPT];
        }else{
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16*WIDTH_ADAPT], NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_900"]};
            NSAttributedString *attrShareTitle = [[NSAttributedString alloc]initWithString:shareTitle attributes:attribute];
            
            NSDictionary *quantityAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16*WIDTH_ADAPT], NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"tp_color_red_500"]};
            NSAttributedString *attrShareTitleQuantity =[[NSAttributedString alloc]initWithString:shareTitleQuantity attributes:quantityAttribute];
            
            NSMutableAttributedString *muAttrShareTitle = [[NSMutableAttributedString alloc]initWithAttributedString:attrShareTitle];
            [muAttrShareTitle replaceCharactersInRange:range withAttributedString:attrShareTitleQuantity];
            shareTitleLabel.attributedText = muAttrShareTitle;
        }
        
        globalY += shareTitleLabel.frame.size.height + 30*WIDTH_ADAPT;
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(20*WIDTH_ADAPT, globalY, boardView.frame.size.width-40*WIDTH_ADAPT, 1*WIDTH_ADAPT)];
        lineView.backgroundColor = [UIColor colorWithPatternImage:[TPDialerResourceManager getImage:@"share_packet_version_1_line@2x.png"]];
        [boardView addSubview:lineView];
        
        globalY += lineView.frame.size.height + 15*WIDTH_ADAPT;
        
        UILabel *secondTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*WIDTH_ADAPT, globalY, boardView.frame.size.width-40*WIDTH_ADAPT, labelSize.height)];
        secondTitleLabel.backgroundColor = [UIColor clearColor];
        secondTitleLabel.text = shareData.shareBonusHint;
        secondTitleLabel.textAlignment = NSTextAlignmentCenter;
        secondTitleLabel.font = [UIFont systemFontOfSize:13*WIDTH_ADAPT];
        secondTitleLabel.numberOfLines = 10;
        secondTitleLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_brown_300"];
        [boardView addSubview:secondTitleLabel];
        
        globalY += secondTitleLabel.frame.size.height + 40*WIDTH_ADAPT;
        
        
        NSString *shareButtonTitle = @"我要领红包";
        if ([shareData.shareButtonTitle length])
            shareButtonTitle = shareData.shareButtonTitle;
        UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake((packageView.frame.size.width-165*WIDTH_ADAPT)/2, globalY, 165*WIDTH_ADAPT, 45*WIDTH_ADAPT)];
        shareButton.layer.borderWidth = 2.0f*WIDTH_ADAPT;
        shareButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_red_500"].CGColor ;
        shareButton.layer.masksToBounds = YES;
        shareButton.layer.cornerRadius = 22.5f*WIDTH_ADAPT;
        [shareButton setTitle:shareButtonTitle forState:UIControlStateNormal];
        shareButton.titleLabel.font = [UIFont systemFontOfSize:16*WIDTH_ADAPT];
        [shareButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_red_500"] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_yellow_300"]] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_yellow_500"]] forState:UIControlStateHighlighted];
        [shareButton addTarget:self action:@selector(onShareClicked) forControlEvents:UIControlEventTouchUpInside];
        [packageView addSubview:shareButton];
    }    
    return self;
}

@end
