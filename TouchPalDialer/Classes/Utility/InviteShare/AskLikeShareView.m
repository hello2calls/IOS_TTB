//
//  AskLikeShareView.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/9.
//
//

#import "AskLikeShareView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "UIView+WithSkin.h"

@implementation AskLikeShareView

- (instancetype) initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)dict{
    self = [super initWithFrame:frame];
    
    if (self){
        
        UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake((frame.size.width-60)/2, 0, 60, 60)];
        shareButton.layer.cornerRadius = 8.0f;
        shareButton.layer.borderWidth = 0.5f;
        shareButton.layer.masksToBounds = YES;
        shareButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"].CGColor;
        [shareButton setTitle:dict[@"share_icon"] forState:UIControlStateNormal];
        [shareButton setTitleColor:[TPDialerResourceManager getColorForStyle:dict[@"share_icon_color"]] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[FunctionUtility imageWithColor:[UIColor whiteColor] withFrame:shareButton.bounds] forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_100"] withFrame:shareButton.bounds] forState:UIControlStateHighlighted];
        shareButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:28];
        [shareButton addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shareButton];
        
        UILabel *shareLabel =[[UILabel alloc]initWithFrame:CGRectMake((frame.size.width-60)/2, 68, 60, 14)];
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.backgroundColor = [UIColor clearColor];
        shareLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_600"];
        shareLabel.font = [UIFont systemFontOfSize:13];
        shareLabel.text = dict[@"share_text"];
        [self addSubview:shareLabel];
        
        
    }
    return self;
}

- (void)onButtonClick{
    if (self.clickBlock)
        self.clickBlock();
}

@end
