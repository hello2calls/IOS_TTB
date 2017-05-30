//
//  InviteShareView.m
//  TouchPalDialer
//
//  Created by game3108 on 16/3/8.
//
//

#import "InviteShareView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"

@interface InviteShareView(){
    UILabel *_closeLabel;
}

@end

@implementation InviteShareView

- (instancetype)initWithFrame:(CGRect)frame andInviteShareData:(InviteShareData *)shareData{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        UIView *boardView = [[UIView alloc]initWithFrame:CGRectMake((TPScreenWidth()-272)/2, (TPScreenHeight()-348)/2, 272, 348)];
        boardView.backgroundColor = [UIColor whiteColor];
        boardView.layer.cornerRadius = 4.0f;
        boardView.layer.masksToBounds = YES;
        [self addSubview:boardView];
        
        UIButton *closeButton = [[UIButton alloc]initWithFrame:CGRectMake(boardView.frame.origin.x+boardView.frame.size.width-22.5, boardView.frame.origin.y-22.5, 45, 45)];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        [closeButton addTarget:self action:@selector(onCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [closeButton addTarget:self action:@selector(onCloseButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [closeButton addTarget:self action:@selector(onCloseButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:closeButton];
        
        _closeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.5, 10.5, 24, 24)];
        _closeLabel.layer.cornerRadius = 12.0f;
        _closeLabel.layer.masksToBounds = YES;
        _closeLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:18];
        _closeLabel.text = @"F";
        _closeLabel.textColor = [UIColor whiteColor];
        _closeLabel.textAlignment = NSTextAlignmentCenter;
        _closeLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_green_400"];
        [closeButton addSubview:_closeLabel];
        
        UIImageView *topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, boardView.frame.size.width, 160)];
        topImageView.image = [TPDialerResourceManager getImage:@"dialog_invite_header_bg@2x.png"];
        [boardView addSubview:topImageView];
        
        UIView *topCircleView = [[UIView alloc]initWithFrame:CGRectMake((boardView.frame.size.width-80)/2, 25, 80, 80)];
        topCircleView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_900"];
        topCircleView.layer.cornerRadius = 40.0f;
        [topImageView addSubview:topCircleView];
        
        UILabel *topIconView = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 32, 32)];
        topIconView.backgroundColor = [UIColor whiteColor];
        topIconView.text = shareData.iosInviteIcon.length ? shareData.iosInviteIcon : @"5";
        topIconView.font = [UIFont fontWithName:shareData.iosInviteIconFont.length?shareData.iosInviteIconFont:@"iPhoneIcon2" size:32];
        topIconView.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_green_400"];
        [topCircleView addSubview:topIconView];
        
        UILabel *shareTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 121, boardView.frame.size.width, 16)];
        shareTitleLabel.font = [UIFont systemFontOfSize:16];
        shareTitleLabel.backgroundColor = [UIColor clearColor];
        shareTitleLabel.textAlignment = NSTextAlignmentCenter;
        [topImageView addSubview:shareTitleLabel];
        
        NSString *shareTitle = shareData.inviteTitleText.length ? shareData.inviteTitleText : @"对方长时间未使用触宝电话";
        NSString *shareTitleQuantity = shareData.inviteTitleContent;
        
        NSRange range = [shareTitle rangeOfString:@"%s"];
        if (range.location == NSNotFound){
            shareTitleLabel.text = shareTitle;
            shareTitleLabel.textColor = [UIColor whiteColor];
        }else{
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor whiteColor]};
            NSAttributedString *attrShareTitle = [[NSAttributedString alloc]initWithString:shareTitle attributes:attribute];
            
            NSDictionary *quantityAttribute = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[TPDialerResourceManager getColorForStyle:@"invite_share_label_highlighted_color"]};
            NSAttributedString *attrShareTitleQuantity =[[NSAttributedString alloc]initWithString:shareTitleQuantity attributes:quantityAttribute];
            
            NSMutableAttributedString *muAttrShareTitle = [[NSMutableAttributedString alloc]initWithAttributedString:attrShareTitle];
            [muAttrShareTitle replaceCharactersInRange:range withAttributedString:attrShareTitleQuantity];
            shareTitleLabel.attributedText = muAttrShareTitle;
        }
        
        CGFloat globalY = topImageView.frame.size.height + 36;
        
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width, 16)];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.backgroundColor = [UIColor whiteColor];
        firstLabel.font = [UIFont systemFontOfSize:16];
        firstLabel.text = shareData.inviteFirstTitle.length ? shareData.inviteFirstTitle : @"本通电话会消耗通话时长";
        firstLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        [boardView addSubview:firstLabel];
        
        globalY += firstLabel.frame.size.height + 16;
        
        UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, globalY, boardView.frame.size.width, 14)];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.backgroundColor = [UIColor whiteColor];
        secondLabel.font = [UIFont systemFontOfSize:13];
        secondLabel.text = shareData.inviteSecondTitle.length ? shareData.inviteSecondTitle : @"邀请对方回归，享无限畅打！";
        secondLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_green_400"];
        [boardView addSubview:secondLabel];

        globalY += secondLabel.frame.size.height + 36;
        
        UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(20, globalY, 106, 48)];
        leftButton.layer.cornerRadius = 24.0f;
        leftButton.layer.borderWidth = 1.0f;
        leftButton.layer.masksToBounds = YES;
        leftButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
        [leftButton setTitle:shareData.inviteLeftButtonText.length?shareData.inviteLeftButtonText:@"更多方式" forState:UIControlStateNormal];
        [leftButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] withFrame:leftButton.bounds] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_150"] withFrame:leftButton.bounds] forState:UIControlStateHighlighted];
        [leftButton addTarget:self action:@selector(onLeftButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [boardView addSubview:leftButton];
        
        
        UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(146, globalY, 106, 48)];
        rightButton.layer.cornerRadius = 24.0f;
        rightButton.layer.masksToBounds = YES;
        rightButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
        [rightButton setTitle:shareData.inviteRightButtonText.length?shareData.inviteRightButtonText:@"一键邀请" forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [rightButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_green_400"] withFrame:rightButton.bounds] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_green_600"] withFrame:rightButton.bounds] forState:UIControlStateHighlighted];
        [rightButton addTarget:self action:@selector(onRightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [boardView addSubview:rightButton];
        
    }
    return self;
}

- (void)onCancelButtonClick{
    _closeLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_green_400"];
    if (_cancelBlock){
        _cancelBlock();
        self.cancelBlock = nil;
    }
    [self removeFromSuperview];
}

- (void)onCloseButtonTouchDown{
    _closeLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_green_600"];
}

- (void)onCloseButtonTouchUpOutside{
    _closeLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_green_400"];
}

- (void)onLeftButtonClick{
    if (_leftBlock){
        _leftBlock();
        self.leftBlock = nil;
    }
    [self removeFromSuperview];
}

- (void)onRightButtonClick{
    if (_rightBlock){
        _rightBlock();
        self.rightBlock = nil;
    }
    [self removeFromSuperview];
}

@end
