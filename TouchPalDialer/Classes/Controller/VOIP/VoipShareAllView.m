//
//  numberString.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-6.
//
//

#import "VoipShareAllView.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "TPMFMessageActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DefaultUIAlertViewHandler.h"
#import "WXApi.h"
#import "TouchPalVersionInfo.h"
#import "TPShareController.h"
#import "DialerUsageRecord.h"
#import "FunctionUtility.h"
#import "QQShareController.h"
#import "EditVoipViewController.h"
#import "SeattleFeatureExecutor.h"
#import "shareScrollButtonView.h"
#import "ShareButtonObject.h"
#define HEIGHT_ADAPT (TPScreenWidth()>320?1.1:1)

@interface VoipShareAllView()<ShareScrollButtonViewDelegate>{
    UIView *_boardView;

    BOOL onTouchMove;
    NSString *_title;
    NSString *_msg;
    NSString *_url;
    BOOL _isShareAntiharass;
    UILabel *_waitNumberLabel;

    NSArray *_buttonArray;
}

@end


@implementation VoipShareAllView

- (id)initWithFrame:(CGRect)frame title:(NSString*)title msg:(NSString*)msg url:(NSString*)url buttonArray:(NSArray*)array{
    _buttonArray = array;
    self = [self initWithFrame:frame title:title msg:msg url:url image:nil];
    return self;
}


- (id)initWithFrame:(CGRect)frame title:(NSString*)title msg:(NSString*)msg url:(NSString*)url image:(UIImage *)image{
    _isShareAntiharass = NO;
    NSRange range = [title rangeOfString:@"骚扰"];
    if (range.length != 0) {
        _isShareAntiharass = YES;
    }
    self = [self initWithFrame:frame];

    if (self){
        _title = [title copy];
        _msg = [msg copy];
        _url = [url copy];
        _image = image;

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

        _boardView = [[UIView alloc]init];
        _boardView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_boardView];

        NSInteger globalY = 30 * HEIGHT_ADAPT;

        NSString *temptStr = [NSString stringWithFormat:@"%@%@",
                              NSLocalizedString(@"voip_now_invite_friend1", ""),
                              NSLocalizedString(@"voip_now_invite_friend2", "")];
//        NSRange range1 = [temptStr rangeOfString:NSLocalizedString(@"voip_now_invite_friend1", "")];
//        NSRange range2 = [temptStr rangeOfString:NSLocalizedString(@"voip_now_invite_friend2", "")];
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:temptStr];
//        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"voip_middle_bar_text_color"] range:range1];
//        [str addAttribute:NSForegroundColorAttributeName value:[TPDialerResourceManager getColorForStyle:@"voip_editView_inviteFriendButton_color"] range:range2];
        _waitNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, globalY , frame.size.width, FONT_SIZE_1_5*HEIGHT_ADAPT)];
        _waitNumberLabel.textAlignment = NSTextAlignmentCenter;
        _waitNumberLabel.backgroundColor = [UIColor clearColor];
        _waitNumberLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
        _waitNumberLabel.text = temptStr;
        if (_isShareAntiharass) {
            _waitNumberLabel.text = @"分享到";
        }
        _waitNumberLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE_3*HEIGHT_ADAPT];
        _waitNumberLabel.textAlignment = NSTextAlignmentCenter;
        [_boardView addSubview:_waitNumberLabel];

        globalY += _waitNumberLabel.frame.size.height + 30*HEIGHT_ADAPT;

        shareScrollButtonView *shareView = [[shareScrollButtonView alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, [self getButtonArrayHeight]) andButtonArray:[self getButtonArray]];
        [_boardView addSubview:shareView];
        shareView.shareDelegate = self;

        globalY += shareView.frame.size.height + 30*HEIGHT_ADAPT;

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


        _boardView.frame = CGRectMake(0, frame.size.height, frame.size.width, 182*HEIGHT_ADAPT+[self getButtonArrayHeight]);

        [self showInAnimation];

    }
    return self;
}

- (float) getButtonArrayHeight{
    if ( _buttonArray != nil && [_buttonArray count] != 0 ){
        if ( [_buttonArray count] <= 4 ){
            return 70*HEIGHT_ADAPT;
        }else{
            return 170*HEIGHT_ADAPT;
        }
    }else{
        return 170*HEIGHT_ADAPT;
    }
}

- (NSArray *)getButtonArray{
    if ( _buttonArray != nil && [_buttonArray count] != 0 ){
        NSMutableArray *array = [NSMutableArray array];
        if ( [_buttonArray containsObject:@"wechat"] ){
            ShareButtonObject *object1 = [[ShareButtonObject alloc]init];
            object1.buttonTitle = @"r";
            object1.labelTitle = NSLocalizedString(@"voip_send_wechat", "");
            object1.normalColor = @"tp_color_green_500";
            object1.hlColor = @"tp_color_green_600";
            object1.tag = SHARE_WEIXIN;
            [array addObject:object1];
        }
        if ( [_buttonArray containsObject:@"timeline"] ){
            ShareButtonObject *object2 = [[ShareButtonObject alloc]init];
            object2.buttonTitle = @"p";
            object2.labelTitle = NSLocalizedString(@"voip_timeline", "");
            object2.normalColor = @"tp_color_light_blue_500";
            object2.hlColor = @"tp_color_light_blue_600";
            object2.tag = SHARE_TIMELINE;
            [array addObject:object2];
        }
        if ( [_buttonArray containsObject:@"qq"] ){
            ShareButtonObject *object3 = [[ShareButtonObject alloc]init];
            object3.buttonTitle = @"q";
            object3.labelTitle = NSLocalizedString(@"voip_send_qq", "");
            object3.normalColor = @"tp_color_light_blue_500";
            object3.hlColor = @"tp_color_light_blue_700";
            object3.tag = SHARE_QQ;
            [array addObject:object3];
        }
        if ( [_buttonArray containsObject:@"qzone"] ){
            ShareButtonObject *object4 = [[ShareButtonObject alloc]init];
            object4.buttonTitle = @"t";
            object4.labelTitle = NSLocalizedString(@"voip_qqzone", "");
            object4.normalColor = @"tp_color_amber_500";
            object4.hlColor = @"tp_color_amber_600";
            object4.tag = SHARE_QQZONE;
            [array addObject:object4];
        }
        if ( [_buttonArray containsObject:@"sms"] ){
            ShareButtonObject *object5 = [[ShareButtonObject alloc]init];
            object5.buttonTitle = @"v";
            object5.labelTitle = NSLocalizedString(@"voip_send_sms", "");
            object5.normalColor = @"tp_color_green_500";
            object5.hlColor = @"tp_color_green_600";
            object5.tag = SHARE_SMS;
            [array addObject:object5];
        }
        if ( [_buttonArray containsObject:@"clipboard"] ){
            ShareButtonObject *object6 = [[ShareButtonObject alloc]init];
            object6.buttonTitle = @"w";
            object6.labelTitle = @"复制";
            object6.normalColor = @"tp_color_light_blue_500";
            object6.hlColor = @"tp_color_light_blue_600";
            object6.tag = SHARE_CLIPBOARD;
            [array addObject:object6];
        }
        if ( [array count] > 0 )
            return array;
    }
    return [self generateAllButton];
}

- (NSArray *)generateAllButton{
    NSMutableArray *array = [NSMutableArray array];

    ShareButtonObject *object1 = [[ShareButtonObject alloc]init];
    object1.buttonTitle = @"r";
    object1.labelTitle = NSLocalizedString(@"voip_send_wechat", "");
    object1.normalColor = @"tp_color_green_500";
    object1.hlColor = @"tp_color_green_600";
    object1.tag = SHARE_WEIXIN;
    [array addObject:object1];

    ShareButtonObject *object2 = [[ShareButtonObject alloc]init];
    object2.buttonTitle = @"p";
    object2.labelTitle = NSLocalizedString(@"voip_timeline", "");
    object2.normalColor = @"tp_color_light_blue_500";
    object2.hlColor = @"tp_color_light_blue_600";
    object2.tag = SHARE_TIMELINE;
    [array addObject:object2];

    ShareButtonObject *object3 = [[ShareButtonObject alloc]init];
    object3.buttonTitle = @"q";
    object3.labelTitle = NSLocalizedString(@"voip_send_qq", "");
    object3.normalColor = @"tp_color_light_blue_500";
    object3.hlColor = @"tp_color_light_blue_700";
    object3.tag = SHARE_QQ;
    [array addObject:object3];

    ShareButtonObject *object4 = [[ShareButtonObject alloc]init];
    object4.buttonTitle = @"t";
    object4.labelTitle = NSLocalizedString(@"voip_qqzone", "");
    object4.normalColor = @"tp_color_amber_500";
    object4.hlColor = @"tp_color_amber_600";
    object4.tag = SHARE_QQZONE;
    [array addObject:object4];

    ShareButtonObject *object5 = [[ShareButtonObject alloc]init];
    object5.buttonTitle = @"v";
    object5.labelTitle = NSLocalizedString(@"voip_send_sms", "");
    object5.normalColor = @"tp_color_green_500";
    object5.hlColor = @"tp_color_green_600";
    object5.tag = SHARE_SMS;
    [array addObject:object5];

    ShareButtonObject *object6 = [[ShareButtonObject alloc]init];
    object6.buttonTitle = @"w";
    object6.labelTitle = @"复制";
    object6.normalColor = @"tp_color_light_blue_500";
    object6.hlColor = @"tp_color_light_blue_600";
    object6.tag = SHARE_CLIPBOARD;
    [array addObject:object6];

    return array;
}

- (void)clickOnButton:(NSInteger)tag{
    if ( tag == SHARE_WEIXIN ){
        [self shareByWeixin];
    }else if ( tag == SHARE_TIMELINE){
        [self shareByWeixinTimeLine];
    }else if ( tag == SHARE_QQ){
        [self shareByQQ];
    }else if ( tag == SHARE_QQZONE){
        [self shareByQZone];
    }else if ( tag == SHARE_SMS){
        [self clickSms];
    }else if ( tag == SHARE_CLIPBOARD ){
        [self pasteBoard];
    }
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
    if ( _shareResultCallback ){
        _shareResultCallback(ShareCancel,@"cancel",nil);
        _shareResultCallback = nil;
    }
    [self showOutAnimation];
}

- (void)clickSms{
    if ( _title == nil ){
        NSString *smsUrl = [FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"];
        [FunctionUtility shareSMS:smsUrl andNeedDefault:YES andMessage:NSLocalizedString(@"voip_sms_share_message", "") andNumber:self.msgPhone andFromWhere:_fromWhere];
    }else{
        if ([_title rangeOfString:@"骚扰电话"].length) {
            _title = @"iPhone也能识别骚扰电话了！";
            _msg = @"";
        }
        NSString *newUrl  = [NSString stringWithFormat:@"%@",_url];
        if (newUrl != nil ){
            if ([newUrl rangeOfString:@"xxxxxx"].length) {
                newUrl = TOUCHPAL_DIALER_APP_STORE_REVIEW_URL;
            }
            else{
                newUrl = [FunctionUtility generateUrlMessage:newUrl andTemptId:@"sms020" andFrom:@"sms"];
            }
        }
        else
            newUrl = [FunctionUtility generateWechatMessage:@"sms020" andFrom:@"sms"];
        NSString *message = [NSString stringWithFormat:@"%@%@",_title,_msg];
        [FunctionUtility shareSMS:newUrl andNeedDefault:NO andMessage:message andNumber:self.msgPhone andFromWhere:_fromWhere];
    }
}

- (void)pasteBoard{
    if ( _title == nil ){
        NSString *smsUrl = [FunctionUtility generateWechatMessage:@"clipboard020" andFrom:@"clipboard"];
        [FunctionUtility sharePasteboard:smsUrl andNeedDefault:YES andFromWhere:_fromWhere title:_title];
    }else{
        if ([_title rangeOfString:@"骚扰电话"].length) {
            _title = @"iPhone也能识别骚扰电话了！";
            _msg = @"";
        }
        NSString *newUrl  = [NSString stringWithFormat:@"%@",_url];
        if ( newUrl != nil ){
            if ([newUrl rangeOfString:@"xxxxxx"].length) {
                newUrl = TOUCHPAL_DIALER_APP_STORE_REVIEW_URL;
            }
            else{
            newUrl = [FunctionUtility generateUrlMessage:newUrl andTemptId:@"clipboard020" andFrom:@"clipboard"];
            }
        }
        else
            newUrl = [FunctionUtility generateWechatMessage:@"clipboard020" andFrom:@"clipboard"];
        [FunctionUtility sharePasteboard:newUrl andNeedDefault:[_title rangeOfString:@"骚扰电话"].length andFromWhere:_fromWhere title:_title];
    }
}



- (void) shareByWeixin
{
    if ( _title == nil ){
        NSString *url = [FunctionUtility generateWechatMessage:@"weixin020" andFrom:@"friends"];
        [FunctionUtility shareByWeixin:NSLocalizedString(@"voip_weixin_share_title", "") andDescription:NSLocalizedString(@"voip_weixin_share_description", "") andUrl:url andImageUrl:nil andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }else{
        if ([_title rangeOfString:@"骚扰电话"].length) {
            _title = @"iPhone也能识别骚扰电话了！";
            _msg = @"再也不用纠结陌生电话接不接了！";
        }
        NSString *newUrl  = [NSString stringWithFormat:@"%@",_url];
        if([newUrl rangeOfString:@"xxxxxx"].length) {
            newUrl = [_url stringByReplacingOccurrencesOfString:@"xxxxxx" withString:@"friend"];
        }
        else{
        newUrl = [FunctionUtility generateUrlMessage:newUrl andTemptId:@"weixin020" andFrom:@"friends"];
        }
        [FunctionUtility shareByWeixin:_title andDescription:_msg andUrl:newUrl andImageUrl:_imageUrl andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }
}

- (void) shareByQQ
{
    if ( _title == nil ){
        NSString *url = [FunctionUtility generateWechatMessage:@"qq020" andFrom:@"qq"];
        [FunctionUtility shareByQQ:NSLocalizedString(@"voip_weixin_share_title", "") andDescription:NSLocalizedString(@"voip_weixin_share_description", "") andUrl:url andImageUrl:nil andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }else{
        if ([_title rangeOfString:@"骚扰电话"].length) {
            _title = @"iPhone也能识别骚扰电话了！";
            _msg = @"再也不用纠结陌生电话接不接了！";
        }
        NSString *newUrl  = [NSString stringWithFormat:@"%@",_url];
        if([newUrl rangeOfString:@"xxxxxx"].length) {
            newUrl = [_url stringByReplacingOccurrencesOfString:@"xxxxxx" withString:@"qq"];
        }
        else{
        newUrl = [FunctionUtility generateUrlMessage:newUrl andTemptId:@"qq020" andFrom:@"qq"];
        }
        [FunctionUtility shareByQQ:_title andDescription:_msg andUrl:newUrl andImageUrl:_imageUrl andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }
}

- (void) shareByWeixinTimeLine
{
    if (_image !=nil){
        [FunctionUtility shareByWeixinImage:_image andFromWhere:_fromWhere andIfTimeLine:YES];
        return;
    }
    if ( _title == nil ){
        NSString *url = [FunctionUtility generateWechatMessage:@"timeline020" andFrom:@"timeline"];
        [FunctionUtility shareByWeixinTimeline:NSLocalizedString(@"voip_weixin_timeline_share", "") andDescription:nil andUrl:url andImageUrl:nil andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }else{
        NSString *url = [FunctionUtility generateUrlMessage:_url andTemptId:@"timeline020" andFrom:@"timeline"];
        [FunctionUtility shareByWeixinTimeline:_title andDescription:nil andUrl:url andImageUrl:_imageUrl andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }
}

- (void) shareByQZone
{

    if ( _title == nil ){
        NSString *url = [FunctionUtility generateWechatMessage:@"qzone020" andFrom:@"qzone"];
        [FunctionUtility shareByQQZone:NSLocalizedString(@"voip_weixin_timeline_share", "") andDescription:nil andUrl:url andImageUrl:nil andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }else{

        if ([_title rangeOfString:@"骚扰电话"].length) {
            _title = @"特大喜讯，iPhone也能防骚扰电话了！！！";
            _msg = @"";
        }
        NSString *newUrl  = [NSString stringWithFormat:@"%@",_url];
        if([newUrl rangeOfString:@"xxxxxx"].length) {
            newUrl = [_url stringByReplacingOccurrencesOfString:@"xxxxxx" withString:@"qzone"];
        }else{
        newUrl = [FunctionUtility generateUrlMessage:_url andTemptId:@"qzone020" andFrom:@"qzone"];
        }
        [FunctionUtility shareByQQZone:_title andDescription:nil andUrl:newUrl andImageUrl:_imageUrl andFromWhere:_fromWhere andResultCallback:_shareResultCallback];
    }
}

+ (void)shareWithTitle:(NSString *)title msg:(NSString *)msg url:(NSString *)url imageUrl:(NSString *)iamgeUrl andFrom:(NSString *)source image:(UIImage *)image{
    VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:title msg:msg url:url image:image];
    shareAllView.imageUrl = iamgeUrl;
    shareAllView.fromWhere = source;
    [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
}

@end
