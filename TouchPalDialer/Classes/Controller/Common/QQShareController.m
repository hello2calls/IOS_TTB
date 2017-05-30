//
//  QQShareController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/27.
//
//

#import "QQShareController.h"
#import "DefaultUIAlertViewHandler.h"

#define QQ_APP_ID @"100809145"
#define QQ_APP_KEY @"e6ea9ffdd5566da805d7f73082f0afe1"


static QQShareController *instance = nil;
@interface QQShareController()<TencentSessionDelegate,QQApiInterfaceDelegate>{
    TencentOAuth *auth;
    NSString *_source;
}
@property (nonatomic,copy) void(^afterSuccess)();
@property (nonatomic,copy) ShareResultCallback shareResultCallback;

@end


@implementation QQShareController
+ (void)initialize{
    instance = [[QQShareController alloc]init];
}

+(instancetype)instance{
    return instance;
}

- (void)registerQQApi{
    auth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID andDelegate:self];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    return [QQApiInterface handleOpenURL:url delegate:self];
}

- (BOOL)isInstallQQClient{
    if (![QQApiInterface isQQInstalled]){
        NSString *urlStr = [QQApiInterface getQQInstallUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        return NO;
    }
    
    return YES;
}


-(void)shareQQMessage:(NSString *)title
       andDescription:(NSString *)description
               andUrl:(NSString *)url
          andImageUrl:(NSString *)imageUrl
          andIfQQZone:(BOOL)ifQQZone
             andBlock:(void(^)(void))block
{
    if ([self isInstallQQClient]){
        if ( imageUrl == nil || [imageUrl length] == 0){
            imageUrl = @"http://dialer.cdn.cootekservice.com/android/default/voipShare/shareicon_6.jpg";
        }
        
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:url]
                                    title:title
                                    description:description
                                    previewImageURL:[NSURL URLWithString:imageUrl]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent;
        if (!ifQQZone){
            //将内容分享到qq
            sent = [QQApiInterface sendReq:req];
            _source = @"qq";
        //将内容分享到qzone
        }else{
            sent = [QQApiInterface SendReqToQZone:req];
            _source = @"qzone";
        }
        self.afterSuccess = nil;
        if ( sent == EQQAPIAPPSHAREASYNC && ifQQZone){
            self.afterSuccess = block;
        }
        
        [self handleSendResult:sent];
    }
    
}

-(void)shareQQMessage:(NSString *)title
       andDescription:(NSString *)description
               andUrl:(NSString *)url
          andImageUrl:(NSString *)imageUrl
          andIfQQZone:(BOOL)ifQQZone
       resultCallback:(ShareResultCallback)block
{
    if (![self isInstallQQClient]) {
        if (block) {
            block(ShareFail, ifQQZone?@"qzone":@"qq", @"未安装QQ");
            block = nil;
        }

        return;
    }

    if (self.shareResultCallback) {
        self.shareResultCallback = nil;
        cootek_log(@"连续多次点击了分享");
    }

    self.shareResultCallback = block;
    [self shareQQMessage:title andDescription:description andUrl:url andImageUrl:imageUrl andIfQQZone:ifQQZone andBlock:nil];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    NSString *error = nil;
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            error = @"App未注册";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            error = @"发送参数错误";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            error = @"未安装手Q";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            error = @"API接口不支持";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            error = @"发送失败";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            error = @"空间分享不支持纯文本分享，请使用图文分享";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            error = @"空间分享不支持纯图片分享，请使用图文分享";
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
    if (error && self.shareResultCallback) {
        self.shareResultCallback(ShareFail,_source,error);
        self.shareResultCallback = nil;
    }
}

#pragma mark TencentSessionDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin{
    
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled{
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork{
    
}

#pragma mark QQApiInterfaceDelegate
/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req{
    switch (req.type)
    {
        case EGETMESSAGEFROMQQREQTYPE:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}

/**
 处理来至QQ的响应
 */
- (void)onResp:(QQBaseResp *)resp{
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if ( [sendResp.result isEqualToString:@"0"] ){
                if ( self.afterSuccess ){
                    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_share_qqzone_success", "") message:nil];
                    self.afterSuccess();
                }
                if (self.shareResultCallback) {
                    self.shareResultCallback(ShareSuccess,_source,nil);
                    self.shareResultCallback = nil;
                }
            }else{
                if ( self.afterSuccess ){
                    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_share_qqzone_fail", "") message:nil];
                }
                if (self.shareResultCallback) {
                    if ([sendResp.result integerValue] == -4) {
                        self.shareResultCallback(ShareCancel,_source,@"用户取消了分享");
                    }else{
                        self.shareResultCallback(ShareFail,_source,@"分享失败");
                    }
                    self.shareResultCallback = nil;
                }
            }
            
            if ( self.afterSuccess ){
                [self setAfterSuccessNil];
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void) setAfterSuccessNil{
    self.afterSuccess = nil;
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response{
    NSArray *QQUins = [response allKeys];
    NSMutableString *messageStr = [NSMutableString string];
    for (NSString *str in QQUins) {
        if ([[response objectForKey:str] isEqualToString:@"YES"]) {
            [messageStr appendFormat:@"QQ号码为:%@ 的用户在线\n",str];
        } else {
            [messageStr appendFormat:@"QQ号码为:%@ 的用户不在线\n",str];
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"操作成功" message:messageStr
                          
                                                   delegate:self cancelButtonTitle:@"我知道啦" otherButtonTitles: nil];
    [alert show];
    NSLog(@"response:%@",response);
}






@end
