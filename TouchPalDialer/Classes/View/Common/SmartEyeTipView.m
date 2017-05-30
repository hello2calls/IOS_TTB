//
//  SmartEyeTipView.m
//  TouchPalDialer
//
//  Created by 亮秀 李 on 10/24/12.
//
//

#import "SmartEyeTipView.h"
#import "TPDialerResourceManager.h"

@implementation SmartEyeTipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        UIView *coverView = [[UIView alloc] initWithFrame:frame];
        coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self addSubview:coverView];
        [coverView release];
        
        UIImage *tipViewImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"smartEye_tip_image@2x.png"];
        UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - tipViewImage.size.width)/2,70, tipViewImage.size.width,tipViewImage.size.height)];
        [self addSubview:tipView];
        [tipView release];
        
        UIImageView *tipViewBG = [[UIImageView alloc] initWithImage:tipViewImage];
        tipViewBG.frame = CGRectMake(0,0,tipView.frame.size.width,tipView.frame.size.height);
        [tipView addSubview:tipViewBG];
        [tipViewBG release];
        
        CGFloat textLeftGap = 35;
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,33,tipView.frame.size.width ,50)];
        headLabel.backgroundColor = [UIColor clearColor];
        headLabel.text = NSLocalizedString(@"TouchPal tips", @"");
        headLabel.font = [UIFont boldSystemFontOfSize:CELL_FONT_LARGER];
        headLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_title_color"];
        headLabel.textAlignment = UITextAlignmentCenter;
        [tipView addSubview:headLabel];
        [headLabel release];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLeftGap, 57, tipView.frame.size.width-2*textLeftGap, 140)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 4;
        textLabel.font = [UIFont systemFontOfSize:CELL_FONT_INPUT];
        textLabel.text = NSLocalizedString(@"SmartEye is ...", @"");
        textLabel.textColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_text_color"];
        [tipView addSubview:textLabel];
        [textLabel release];
        
        UIButton *knownButton = [[UIButton alloc] initWithFrame:CGRectMake(59, 244, 200,40)];
        [knownButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_normal@2x.png"] forState:UIControlStateNormal];
        [knownButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"common_popup_button_hg@2x.png"] forState:UIControlStateHighlighted];
        [knownButton setTitleColor:[[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"common_popup_button_text_color"] forState:UIControlStateNormal];
    
        [knownButton addTarget:self action:@selector(removeTipView) forControlEvents:UIControlEventTouchUpInside];
        [knownButton setTitle:NSLocalizedString(@"OK",@"") forState:UIControlStateNormal];
       
        [tipView addSubview:knownButton];
        [knownButton release];
    
    }
    return self;
}
- (void)removeTipView{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
