//
//  shareButtonTitleView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/3/30.
//
//

#import "ShareButtonTitleView.h"
#import "TPDialerResourceManager.h"

#define HEIGHT_ADAPT (TPScreenWidth()>320?1.1:1)

@implementation ShareButtonTitleView{
    NSInteger _tag;
}

- (instancetype)initWithFrame:(CGRect)frame andButtonTitle:(NSString *)buttonTitle andLabelTitle:(NSString *)labelTitle andTag:(NSInteger)tag{
    self = [super initWithFrame:frame];
    
    if ( self ){
        _tag = tag;
        
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake( frame.size.width/2 - 20*HEIGHT_ADAPT, 0, 40 * HEIGHT_ADAPT, 40 * HEIGHT_ADAPT)];
        [self addSubview:_shareButton];
        [_shareButton addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
        [_shareButton setTitle:buttonTitle forState:UIControlStateNormal];
        _shareButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:36*HEIGHT_ADAPT];
        _shareButton.backgroundColor = [UIColor clearColor];
        _shareButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        _shareLabel = [[UILabel alloc]initWithFrame:CGRectMake( frame.size.width/2 - 30*HEIGHT_ADAPT, 50 *HEIGHT_ADAPT, 60*HEIGHT_ADAPT, 20*HEIGHT_ADAPT)];
        _shareLabel.text = labelTitle;
        _shareLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        _shareLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5*HEIGHT_ADAPT];
        _shareLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_shareLabel];
        
    }
    
    return self;
}

- (void)clickButton{
    [_delegate clickOnButton:_tag];
}

@end
