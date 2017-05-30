//
//  TPShareController.m
//  TouchPalDialer
//
//  Created by lingmei xie on 13-3-27.
//
//

#import "TPShareController.h"
#import "TPMFMessageActionController.h"
#import "SmartDailerSettingModel.h"
#import "DefaultUIAlertViewHandler.h"
#import "TPDialerResourceManager.h"
#import "WePayDelegate.h"
#import "CootekNotifications.h"

#define BUFFER_SIZE          1024 * 100
#define WEIXIN_APPID_KEY     @"wx36f9a4c8e81cc8a8"
#define TITLE_MAX_LENGTH     256

TPShareController *instance_ = nil;

@interface TPShareController()<UIActionSheetDelegate>
@property (nonatomic,copy) NSString *titleName;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,retain) UINavigationController *navController;
@property (nonatomic,copy) void(^action)();
@property (nonatomic,copy) void(^afterSuccess)();
@property (nonatomic,copy) void(^payCallback)(NSDictionary*);
@property (nonatomic,copy) ShareResultCallback shareResultCallback;
@property (nonatomic,strong) NSString *source;

@end

@implementation TPShareController


+ (void)registerWeiXinApp
{
    [WXApi registerApp:WEIXIN_APPID_KEY];
}
+ (void)initialize
{
    instance_ = [[TPShareController alloc] init];
    [TPShareController registerWeiXinApp];
}
+ (TPShareController *)controller
{
    return instance_;
}


- (void)showShareActionSheet:(NSString *)title
                     message:(NSString *)msg
              naviController:(UINavigationController *)controller{
    [self showShareActionSheet:title message:msg naviController:controller actionBlock:nil];
}
- (void)showShareActionSheet:(NSString *)title
                     message:(NSString *)msg
              naviController:(UINavigationController *)controller
                 actionBlock:(void(^)())excuteBackAction{
    self.titleName = (title == nil || [title length] == 0) ? NSLocalizedString(@"(No name)", @"") : title;
    self.message = msg;
    self.navController = controller;
    self.action = excuteBackAction;
    [[self buildActionSheet] showInView:self.navController.topViewController.view];
}
- (UIActionSheet *)buildActionSheet
{
    NSString *msg = NSLocalizedString(@"send_message", @"");
    NSString *weixin = NSLocalizedString(@"Send to WeChat", @"");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:msg, weixin, nil];
    
    return actionSheet;
}
- (BOOL) installWeiXinClient{
    if (![WXApi isWXAppInstalled]) {
        NSString *urlStr = [WXApi getWXAppInstallUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        return NO;
    }
    return YES;
}
- (void) sendAppContent
{
    if ([self installWeiXinClient]) {
        NSString *message = [NSString stringWithFormat:@"%@\n%@", self.titleName,self.message];
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = YES;
        req.text = message;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];
    }
}
- (BOOL)handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)voipWechatSharePic:(UIImage *)image andIfTimeLine:(BOOL)ifTimeLine
{
    if ([self installWeiXinClient]) {
 
        WXMediaMessage *message = [WXMediaMessage message];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = UIImagePNGRepresentation(image);
        message.mediaObject = ext;
        
        NSInteger picSize = [ext.imageData length]/1024;
        if ( picSize <= 30 ){
            [message setThumbImage:image];
        }else{
            message.thumbData = [self recursiveImage:image scaledToSize:CGSizeMake(150, 150)];
        }
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        if (ifTimeLine){
            req.scene = WXSceneTimeline;
            _source = @"timeline";
        }else{
            req.scene = WXSceneSession;
            _source = @"wechat";
        }
        [WXApi sendReq:req];
    }
}

- (NSData *)recursiveImage:(UIImage*)image
              scaledToSize:(CGSize)newSize{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    while([imageData length]/1024 > 30) {
        UIImage *recursiveImage = [UIImage imageWithData:imageData];
        imageData = [self imageWithImage:recursiveImage scaledToSize:newSize];
        newSize.width = newSize.width * 0.75;
        newSize.height = newSize.height * 0.75;
    }
    return imageData;
}

- (NSData *)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 1.0);
}

- (void)voipWechatShare:(NSString *)title
         andDescription:(NSString *)description
                 andUrl:(NSString *)url
               andImage:(UIImage *)image
          andIfTimeLine:(BOOL)ifTimeLine
               andBlock:(void(^)(void))block
{
    if ([self installWeiXinClient]) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = description;
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        if ( image )
            [message setThumbImage:image];
        else
            [message setThumbImage:[TPDialerResourceManager getImage:@"voip_wechat_icon@2x.png"]];
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        if (ifTimeLine){
            req.scene = WXSceneTimeline;
            _source = @"timeline";
        }else{
            req.scene = WXSceneSession;
            _source = @"wechat";
        }
        self.afterSuccess = block;
        
        [WXApi sendReq:req];
    }
    
    
}

- (void)voipWechatShareText:(NSString *)text
               andImage:(UIImage *)image
               andBlock:(void(^)(void))block
{
    if ([self installWeiXinClient]) {
        WXMediaMessage *message = [WXMediaMessage message];
        WXWebpageObject *ext = [WXWebpageObject object];
        if (image)
            [message setThumbImage:image];
        else
            [message setThumbImage:[TPDialerResourceManager getImage:@"voip_wechat_icon@2x.png"]];
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = YES;
        req.message = message;
        req.text = text;
        self.afterSuccess = block;
        
        [WXApi sendReq:req];
    }
}


- (void)voipWechatShare:(NSString *)title
             andDescription:(NSString *)description
                 andUrl:(NSString *)url
          andIfTimeLine:(BOOL)ifTimeLine
               andBlock:(void(^)(void))block
{
    [self voipWechatShare:title andDescription:description andUrl:url andImage:nil andIfTimeLine:ifTimeLine andBlock:block];
}

- (void)voipWechatShare:(NSString *)title
         andDescription:(NSString *)description
                 andUrl:(NSString *)url
               andImage:(UIImage *)image
          andIfTimeLine:(BOOL)ifTimeLine
         resultCallback:(ShareResultCallback)block
{
    if (![self installWeiXinClient]) {
        if (block) {
            block(ShareFail, ifTimeLine?@"timeline":@"weixin", @"没有安装微信");
            block = nil;
        }

        return;
    }

    if (self.shareResultCallback) {
        self.shareResultCallback = nil;
        cootek_log(@"多次点击微信分享");
    }

    self.shareResultCallback = block;

    [self voipWechatShare:title andDescription:description andUrl:url andImage:image andIfTimeLine:ifTimeLine andBlock:nil];
}

#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [TPMFMessageActionController sendMessageToNumber:nil
                                                          withMessage:[NSString stringWithFormat:@"%@\n%@",self.titleName,self.message]
                                                          presentedBy:self.navController];

    }else if(buttonIndex == 1){
        if ([self.titleName length] > TITLE_MAX_LENGTH) {
            [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"The contact name is too long to share to WeChat", @"")
                                                      message:nil];
        } else {
            [self sendAppContent];
        }
    }
    if (self.action) {
        self.action();
    }
}
#pragma WXApiDelegate
- (void)onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }


}
- (void)onResp:(BaseResp*)resp
{
    //cootek_log(@"%@",resp);
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        
        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果 :errcode:%d", resp.errCode];
        
        NSLog(@"%@",strMsg);
        
        if (resp.errCode ==0 ){
            if ( self.afterSuccess ){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_share_timeline_success", "") message:nil];
                self.afterSuccess();
            }
            if ( self.shareResultCallback ) {
                self.shareResultCallback(ShareSuccess,_source,nil);
                self.shareResultCallback = nil;
            }
        }else{
            if ( self.afterSuccess ){
                [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_share_timeline_fail", "") message:nil];
            }
            if ( self.shareResultCallback ) {
                if (resp.errCode == -2) {
                    self.shareResultCallback(ShareCancel,_source,@"用户取消了分享");
                } else {
                    self.shareResultCallback(ShareFail,_source,@"分享失败");
                }
                self.shareResultCallback = nil;
            }
        }
        
        if ( self.afterSuccess ){
            [self setAfterSuccessNil];
        }
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert show];
        //[alert release];
    }
    
    if([resp isKindOfClass:[PayResp class]]){
        NSString *strMsg = [NSString stringWithFormat:@"微信支付结果 ：errcode:%d", resp.errCode];
        NSLog(@"%@",strMsg);
        
        
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSDictionary* resultDic;
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                resultDic = @{@"msg": @"成功",@"errcode": [NSString stringWithFormat:@"%d",resp.errCode]};
                break;
                
            default:
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                resultDic = @{@"errcode": [NSString stringWithFormat:@"%d",resp.errCode]};
                break;
        }
        
        if(self.payCallback){
            self.payCallback(resultDic);
        }
    }

}
- (void) setAfterSuccessNil{
    self.afterSuccess = nil;
}

- (void) sendPay:(NSString*) data callbackBlock:(void(^)(NSDictionary* resultDic))payBackAction
{
    NSData *realdata = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:realdata options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    self.payCallback = payBackAction;
    WePayDelegate* wePayTask = [[WePayDelegate alloc] init];
    [wePayTask sendPay:returnData];
}

@end
