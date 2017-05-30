//
//  numberString.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-6.
//
//

#import "VoipShareView.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "TPMFMessageActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DefaultUIAlertViewHandler.h"
#import "WXApi.h"
#import "TouchPalVersionInfo.h"
#import "TPShareController.h"
#import "TPAnalyticConstants.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"
#import "QQShareController.h"

#define HEIGHT_ADAPT (TPScreenWidth()>320?1.1:1)

@interface VoipShareView(){
    UIView *_boardView;
    
    BOOL onTouchMove;
    NSString *_title;
    NSString *_msg;
    NSString *_url;
    
    UILabel *_waitNumberLabel;
}

@end


@implementation VoipShareView

- (id)initWithFrame:(CGRect)frame title:(NSString*)title msg:(NSString*)msg url:(NSString*)url{
    self = [self initWithFrame:frame];
    
    if (self){
        _title = [title copy];
        _msg = [msg copy];
        _url = [url copy];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        _title = nil;
        _msg = nil;
        _url = nil;
        
        _boardView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 252*HEIGHT_ADAPT)];
        _boardView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_boardView];
        
        NSInteger globalY = 32 * HEIGHT_ADAPT;

        NSString *temptStr = [NSString stringWithFormat:@"%@%@",
                              NSLocalizedString(@"voip_now_invite_friend1", ""),
                              NSLocalizedString(@"voip_now_invite_friend2", "")];
        NSRange range1 = [temptStr rangeOfString:NSLocalizedString(@"voip_now_invite_friend1", "")];
        NSRange range2 = [temptStr rangeOfString:NSLocalizedString(@"voip_now_invite_friend2", "")];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temptStr];
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"voip_middle_bar_text_color"] range:range1];
        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"voip_editView_inviteFriendButton_color"] range:range2];
        _waitNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, globalY , frame.size.width, (FONT_SIZE_4_5+1)*HEIGHT_ADAPT)];
        _waitNumberLabel.textAlignment = NSTextAlignmentCenter;
        _waitNumberLabel.backgroundColor = [UIColor clearColor];
        _waitNumberLabel.attributedText = str;
        _waitNumberLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5*HEIGHT_ADAPT];
        _waitNumberLabel.textAlignment = NSTextAlignmentCenter;
        [_boardView addSubview:_waitNumberLabel];
        
        globalY += _waitNumberLabel.frame.size.height + 30*HEIGHT_ADAPT;
        
        UIView *shareView = [[UIView alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, 82 * HEIGHT_ADAPT)];
        [_boardView addSubview:shareView];
        
        UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake( 50*HEIGHT_ADAPT, 0, 50 * HEIGHT_ADAPT, 50 * HEIGHT_ADAPT)];
        [copyButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareView_button3_normal_image"] forState:UIControlStateNormal];
        [copyButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareView_button3_highlight_image"] forState:UIControlStateHighlighted];
        copyButton.layer.masksToBounds = YES;
        copyButton.layer.cornerRadius = copyButton.frame.size.width/2;
        copyButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size: 32*HEIGHT_ADAPT];
        [copyButton setTitle:@"v" forState:UIControlStateNormal];
        [copyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareView addSubview:copyButton];
        [copyButton addTarget:self action:@selector(clickSms) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILabel *copyLabel = [[UILabel alloc]initWithFrame:CGRectMake(25*HEIGHT_ADAPT, 68 *HEIGHT_ADAPT, 100*HEIGHT_ADAPT, FONT_SIZE_4_5*HEIGHT_ADAPT)];
        copyLabel.text = NSLocalizedString(@"voip_send_sms", "");
        copyLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_subLabel_text_color"];
        copyLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5*HEIGHT_ADAPT];
        copyLabel.textAlignment = NSTextAlignmentCenter;
        [shareView addSubview:copyLabel];
        
        UIButton *SMSButton = [[UIButton alloc] initWithFrame:CGRectMake( frame.size.width/2-25*HEIGHT_ADAPT , 0, 50*HEIGHT_ADAPT, 50*HEIGHT_ADAPT)];
        [SMSButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareView_button1_normal_image"] forState:UIControlStateNormal];
        [SMSButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareView_button1_highlight_image"] forState:UIControlStateHighlighted];
        SMSButton.layer.masksToBounds = YES;
        SMSButton.layer.cornerRadius = SMSButton.frame.size.width/2;
        SMSButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size: 32*HEIGHT_ADAPT];
        [SMSButton setTitle:@"s" forState:UIControlStateNormal];
        [SMSButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareView addSubview:SMSButton];
        [SMSButton addTarget:self action:@selector(shareByWeixin) forControlEvents:UIControlEventTouchUpInside];
        

        UILabel *smsLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width/2-50*HEIGHT_ADAPT, 68*HEIGHT_ADAPT , 100*HEIGHT_ADAPT, FONT_SIZE_4_5*HEIGHT_ADAPT)];
        smsLabel.text = NSLocalizedString(@"voip_send_wechat", "");
        smsLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_subLabel_text_color"];
        smsLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5*HEIGHT_ADAPT];
        smsLabel.textAlignment = NSTextAlignmentCenter;
        [shareView addSubview:smsLabel];
        
        UIButton *wechatButton = [[UIButton alloc] initWithFrame:CGRectMake( frame.size.width - 100*HEIGHT_ADAPT , 0, 50*HEIGHT_ADAPT, 50*HEIGHT_ADAPT)];
        [wechatButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareView_button2_normal_image"] forState:UIControlStateNormal];
        [wechatButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareView_button2_highlight_image"] forState:UIControlStateHighlighted];
        wechatButton.layer.masksToBounds = YES;
        wechatButton.layer.cornerRadius = wechatButton.frame.size.width/2;
        wechatButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size: 32*HEIGHT_ADAPT];
        [wechatButton setTitle:@"q" forState:UIControlStateNormal];
        [wechatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareView addSubview:wechatButton];
        [wechatButton addTarget:self action:@selector(shareByQQ) forControlEvents:UIControlEventTouchUpInside];

        
        UILabel *wechatLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 125*HEIGHT_ADAPT , 68*HEIGHT_ADAPT , 100*HEIGHT_ADAPT, FONT_SIZE_4_5*HEIGHT_ADAPT)];
        wechatLabel.text = NSLocalizedString(@"voip_send_qq", "");
        wechatLabel.textColor = [TPDialerResourceManager getColorForStyle:@"voip_subLabel_text_color"];
        wechatLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5*HEIGHT_ADAPT];
        wechatLabel.textAlignment = NSTextAlignmentCenter;
        [shareView addSubview:wechatLabel];
        
        globalY += shareView.frame.size.height + 22*HEIGHT_ADAPT;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(16, globalY, frame.size.width-32, 1)];
        bottomLine.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_line_color"];
        [_boardView addSubview:bottomLine];
        
        globalY += bottomLine.frame.size.height;
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, globalY, frame.size.width, VOIP_CELL_HEIGHT*HEIGHT_ADAPT)];
        [cancelButton setTitle: NSLocalizedString(@"voip_cancel", "") forState:UIControlStateNormal];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_subLabel_text_color"] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareview_cancel_button_normal_image"] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[[TPDialerResourceManager sharedManager] getResourceByStyle:@"voip_shareview_cancel_button_hl_image"] forState:UIControlEventTouchUpInside];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5*HEIGHT_ADAPT];
        [_boardView addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(removeShareView) forControlEvents:UIControlEventTouchUpInside];
        
        [self showInAnimation];
    
    }
    
    return self;
}

- (void)setHeadTitle:(NSString*)headTitle{
    _waitNumberLabel.text = headTitle;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    if (point.y < TPScreenHeight() - _boardView.frame.size.height && !onTouchMove){
        [self removeShareView];
    }else{
        onTouchMove = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    onTouchMove = YES;
}

- (void) showInAnimation {
    CGRect oldFrame = _boardView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() , oldFrame.size.width,  oldFrame.size.height);
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() - oldFrame.size.height - (20 - TPHeaderBarHeightDiff()) , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }
                     completion:nil];
}

- (void) showOutAnimation {
    CGRect oldFrame = _boardView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight()-oldFrame.size.height - (20 - TPHeaderBarHeightDiff()), oldFrame.size.width,  oldFrame.size.height);
                         _boardView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
                     }
                     completion:^(BOOL finish){
                         if (finish)
                            [self removeFromSuperview];
                     }];
}

- (void) removeShareView {
    [self showOutAnimation];
}





- (void)clickSms{
    if ( _title == nil ){
        NSString *smsUrl = [FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"];
        [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url){
            if ( [smsUrl isEqualToString:url ]){
                url = @"http://t.cn/Rz2PYLn";
            }
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"voip_sms_share_message", ""),url];
            UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
            [TPMFMessageActionController sendMessageToNumber:self.msgPhone
                                                              withMessage:message
                                                              presentedBy:aViewController];
            cootek_log(@"voip share single sms from %@", _fromWhere);
            [DialerUsageRecord recordpath:EV_VOIP_SHARE_SINGLE_SMS kvs:Pair(@"fromWhere", _fromWhere), nil];
        }];
    }else{
        NSString *smsUrl;
        if (_url != nil )
            smsUrl = _url;
        else
            smsUrl = [FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"];
        [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url){
            NSString *message;
            if ( _msg != nil )
                message = [NSString stringWithFormat:@"%@%@",_msg,_url];
            else
                message = [NSString stringWithFormat:@"%@%@",_title,_url];
            UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
            [TPMFMessageActionController sendMessageToNumber:self.msgPhone
                                                              withMessage:message
                                                              presentedBy:aViewController];
            cootek_log(@"web page share from %@", _fromWhere);
            [DialerUsageRecord recordpath:EV_VOIP_SHARE_SINGLE_SMS kvs:Pair(@"fromWhere", _fromWhere), nil];
        }];
    }
    
}

- (void)pasteBoard{
    NSString *smsUrl = [FunctionUtility generateWechatMessage:@"clipboard020" andFrom:@"clipboard"];
    [FunctionUtility shortenUrl:smsUrl andBlock:^(NSString *url){
        if ( [smsUrl isEqualToString:url ]){
            url = @"http://t.cn/Rzt2p5m";
        }
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
        pasteboard.string = [NSString stringWithFormat:NSLocalizedString(@"voip_copy_share_message", @""),  [UserDefaultsManager stringForKey:VOIP_INVITATION_CODE] ,url];
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_copy_success", @"") message:nil];
        cootek_log(@"voip share single copy from %@", _fromWhere);
        [DialerUsageRecord recordpath:EV_VOIP_SHARE_SINGLE_COPY kvs:Pair(@"fromWhere", _fromWhere), nil];
    }];
}



- (void) shareByWeixin
{
    if ( _title == nil ){
        [[TPShareController controller] voipWechatShare:NSLocalizedString(@"voip_weixin_share_title", "") andDescription:NSLocalizedString(@"voip_weixin_share_description", "") andUrl:[FunctionUtility generateWechatMessage:@"weixin020" andFrom:@"friends"] andIfTimeLine:NO andBlock:nil];
        cootek_log(@"voip share single wechat %@", _fromWhere);
        [DialerUsageRecord recordpath:EV_VOIP_SHARE_SINGLE_WECHAT kvs:Pair(@"fromWhere", _fromWhere), nil];
    }else{
        [[TPShareController controller] voipWechatShare:_title andDescription:_msg andUrl:_url andIfTimeLine:NO andBlock:nil];
        cootek_log(@"web page share from %@", _fromWhere);
        [DialerUsageRecord recordpath:_url kvs:Pair(@"fromWhere", _fromWhere), nil];
    }
}

- (void) shareByQQ
{
    if ( _title == nil ){
        [[QQShareController instance] shareQQMessage:NSLocalizedString(@"voip_weixin_share_title", "") andDescription:NSLocalizedString(@"voip_weixin_share_description", "") andUrl:[FunctionUtility generateWechatMessage:@"qq020" andFrom:@"qq"] andImageUrl:nil andIfQQZone:NO andBlock:nil];
        cootek_log(@"voip share single qq %@", _fromWhere);
        [DialerUsageRecord recordpath:EV_VOIP_SHARE_SINGLE_QQ kvs:Pair(@"fromWhere", _fromWhere), nil];
    }else{
        [[QQShareController instance] shareQQMessage:_title andDescription:_msg andUrl:_url andImageUrl:nil andIfQQZone:NO andBlock:nil];
        cootek_log(@"web page share qq %@", _fromWhere);
        [DialerUsageRecord recordpath:_url kvs:Pair(@"fromWhere", _fromWhere), nil];
    }
}


@end
