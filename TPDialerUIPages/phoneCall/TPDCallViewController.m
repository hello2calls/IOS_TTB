//
//  TPDCallViewController.m
//  TouchPalDialer
//
//  Created by weyl on 16/11/30.
//
//

#import "TPDCallViewController.h"
#import "TPDLib.h"
#import <Masonry.h>
#import "TPDialerResourceManager.h"
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import "PJSIPManager.h"
#import "CallFunctionButtons.h"
#import "HangupCommercialManager.h"
#import "PersonDBA.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "SeattleFeatureExecutor.h"

#import "NumberPersonMappingModel.h"
#import "AppSettingsModel.h"
#import "CootekSystemService.h"
#import "ContactCacheDataManager.h"
#import "PersonalCenterUtility.h"

#import "UserDefaultsManager.h"
#import "CallAvatarView.h"
#import <BlocksKit.h>
#import "VoipShareAllView.h"
#import <ReactiveCocoa.h>
#import "DialerGuideAnimationUtil.h"
#import "TimerTickerManager.h"
#import "VoipSystemCallInteract.h"

//#import "TPDModel.h"
#import "TPDCallStateInfo.h"
#import <MJExtension.h>
#import "TouchpalMembersManager.h"
#import "TPDFamilyInfo.h"
#import "CootekSystemService.h"
#import "CallRingUtil.h"

#import "MagicUltis.h"
#import "FunctionUtility.h"
#import <BlocksKit.h>
#import <UIAlertView+BlocksKit.h>

@interface TPDCallViewController ()
// 按钮控件组
@property (nonatomic, strong) UIView* muteButtonWrapper;
@property (nonatomic, strong) UIView* speakButtonWrapper;
@property (nonatomic, strong) UIView* shareButtonWrapper;
@property (nonatomic, strong) UIView* backCallButtonWrapper;
@property (nonatomic, strong) UIView* hideButtonWrapper;
@property (nonatomic, strong) UIButton* keyboardButton;
@property (nonatomic, strong) UIButton* hangupButton;

@property (nonatomic, strong) UIView* buttonLine1;
@property (nonatomic, strong) UIView* buttonLine2;
@property (nonatomic, strong) UIView* buttonLine2BackCall;

// 软键盘
@property (nonatomic, strong) UIView* keyboardView;
@property (nonatomic, strong) UIView* keyboardMaskView;
// headerView控件
@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) UIView* mainLabel;
@property (nonatomic, strong) UIView* altLabel;
@property (nonatomic, strong) UIView* bigLabel;
@property (nonatomic, strong) UIButton* familyBtn;

// 头像控件组
@property (nonatomic, strong) UIView* avatarGroupView;
@property (nonatomic, strong) NSTimer* animationTimer;
@property (nonatomic, strong) UILabel* statusLabel;
@property (nonatomic, strong) UILabel* dotLineLabel;

// 提示区域
@property (nonatomic, strong) UIView* infoPart;
@property (nonatomic, strong) UILabel* infoLabel;

// 信号
@property (nonatomic, strong) RACReplaySubject* isPalSignal;
@property (nonatomic, strong) RACReplaySubject* callModeSignal;
@property (nonatomic, strong) RACSignal* isFamilySignal;
@property (nonatomic, strong) RACReplaySubject* tickSignal;
@property (nonatomic, strong) NSMutableArray* disposableArray;
@end


@implementation TPDCallViewController

#pragma mark 子组件们

#pragma mark 第一排按钮
-(void)createMuteButton{
    static BOOL mute = NO;
    WEAK(self)
    

    
//    [d dispose];
    UIButton* muteButton = [[[[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        mute = !mute;
        [sender setSelected:mute];
        [PJSIPManager mute:mute];
    }] tpd_withCornerRadius:30] tpd_withSize:CGSizeMake(60, 60)] tpd_withBorderWidth:1.f color:[UIColor whiteColor]].cast2UIButton;
    [muteButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [muteButton setBackgroundImage:[UIImage tpd_imageWithColor:[TPDialerResourceManager getColorForStyle:@"outgoing_button_highlight_color"]] forState:UIControlStateSelected];
    [muteButton setTitleColor:RGB2UIColor2(0x0f, 0x74, 0xd9) forState:UIControlStateSelected];
    muteButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30*(TPScreenWidth()/414)];
    [muteButton setTitle:@"2" forState:UIControlStateNormal];
    [muteButton setTitle:@"3" forState:UIControlStateSelected];
    UILabel* muteButtonText = [[UILabel tpd_commonLabel] tpd_withText:NSLocalizedString(@"voip_outgoing_mute", @"") color:[UIColor whiteColor  ] font:12];
    muteButtonText.textAlignment = NSTextAlignmentCenter;
    self.muteButtonWrapper = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[muteButton,muteButtonText] offsets:@[@0,@10]];
    
}

-(void)createSpeakButton{
    static BOOL enableSpeaker = NO;
    WEAK(self)
    
    UIButton* speakButton = [[[[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        enableSpeaker = !enableSpeaker;
        if(weakself.callMode == CallModeTestType){
            if (enableSpeaker) {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            } else {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            }
            return;
        }
        [sender setSelected:enableSpeaker];
        [PJSIPManager setSpeakerEnabled:enableSpeaker];
    }] tpd_withCornerRadius:30] tpd_withSize:CGSizeMake(60, 60)] tpd_withBorderWidth:1.f color:[UIColor whiteColor]].cast2UIButton;
    [speakButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [speakButton setBackgroundImage:[UIImage tpd_imageWithColor:[TPDialerResourceManager getColorForStyle:@"outgoing_button_highlight_color"]] forState:UIControlStateSelected];
    [speakButton setTitleColor:RGB2UIColor2(0x0f, 0x74, 0xd9) forState:UIControlStateSelected];
    speakButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30*(TPScreenWidth()/414)];
    [speakButton setTitle:@"4" forState:UIControlStateNormal];
    [speakButton setTitle:@"5" forState:UIControlStateSelected];
    UILabel* speakButtonText = [[UILabel tpd_commonLabel] tpd_withText:NSLocalizedString(@"voip_outgoing_speaker", @"") color:[UIColor whiteColor  ] font:12];
    speakButtonText.textAlignment = NSTextAlignmentCenter;
    self.speakButtonWrapper = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[speakButton,speakButtonText] offsets:@[@0,@10]];

    
}



-(void)createBackcallButton{
    WEAK(self)
    
    void (^doBackCallBlock)() = ^void(){
        if ([MagicUltis instance].getRoaming || ![FunctionUtility isInChina]) {
            UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:@"当前处于漫游状态。因手机套餐不同，运营商可能会收取漫游费用。继续回拨么？" message:nil];
            [alert bk_addButtonWithTitle:@"继续" handler:^{
                [weakself hangupEngine:@"switchcallback"];
                [UserDefaultsManager setObject:CALL_TYPE_BACK_CALL forKey:LAST_FREE_CALL_TYPE];
            }];
            [alert bk_addButtonWithTitle:@"取消" handler:^{ }];
            [alert show];
        }else{
            [weakself hangupEngine:@"switchcallback"];
            [UserDefaultsManager setObject:CALL_TYPE_BACK_CALL forKey:LAST_FREE_CALL_TYPE];
        }
    };
    
    UIButton* backCallButton = [[[[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        //        [delegate onBackCallButtonPressed];
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            [SeattleFeatureExecutor getVoipDealStrategyWithCaller:[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] callee:weakself.numbers[0]];
            int  deal_strategy_code = [UserDefaultsManager intValueForKey:deal_strategy_number defaultValue:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (deal_strategy_code == 1 && ![TouchpalMembersManager isNumberRegistered:self.numbers[0]]) {
                    UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:@"对方非触宝好友，使用回拨模式将扣除双倍时长，是否继续？" message:nil];
                    [alert bk_addButtonWithTitle:@"继续" handler:^{
                        EXEC_BLOCK(doBackCallBlock);
                    }];
                    [alert bk_addButtonWithTitle:@"取消" handler:^{ }];
                    [alert show];
                }else if(deal_strategy_code == 2){
                    UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:@"使用回拨模式时，会双倍消耗免费通话时长，是否继续？" message:nil];
                    [alert bk_addButtonWithTitle:@"继续" handler:^{
                        EXEC_BLOCK(doBackCallBlock);
                    }];
                    [alert bk_addButtonWithTitle:@"取消" handler:^{ }];
                    [alert show];
                }else if(deal_strategy_code == 3){
                    UIAlertView* alert = [UIAlertView bk_alertViewWithTitle:@"您当前的网络不适合使用回拨模式，推荐直接使用免费通话" message:nil];
                    [alert bk_addButtonWithTitle:@"我知道了" handler:^{ }];
                    [alert show];
                }else{
                    EXEC_BLOCK(doBackCallBlock);
                }
            });
            
        });
        
        [weakself configBackCallLayout];
        weakself.callMode = CallModeBackCall;
        [weakself.callModeSignal sendNext:@(weakself.callMode)];
//        [self asyncGetAD];

    }] tpd_withCornerRadius:30] tpd_withSize:CGSizeMake(60, 60)] tpd_withBorderWidth:1.f color:[UIColor whiteColor]] .cast2UIButton;
    [backCallButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [backCallButton setBackgroundImage:[UIImage tpd_imageWithColor:[TPDialerResourceManager getColorForStyle:@"outgoing_button_highlight_color"]] forState:UIControlStateHighlighted];
    //    [backCallButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backCallButton setTitleColor:RGB2UIColor2(0x0f, 0x74, 0xd9) forState:UIControlStateHighlighted];
    backCallButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30*(TPScreenWidth()/414)];
    [backCallButton setTitle:@"V" forState:UIControlStateNormal];
    [backCallButton setTitle:@"W" forState:UIControlStateHighlighted];
    UILabel* backCallButtonText = [[UILabel tpd_commonLabel] tpd_withText:NSLocalizedString(@"call_type_back_call", @"") color:[UIColor whiteColor  ] font:12];
    backCallButtonText.textAlignment = NSTextAlignmentCenter;
    self.backCallButtonWrapper = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[backCallButton,backCallButtonText] offsets:@[@0,@10]];
}

#pragma mark 第二排按钮（键盘、挂断）
-(void)createHangupButton{
    WEAK(self)
    UIButton *hangupButton = [[UIButton buttonWithType:UIButtonTypeCustom] tpd_withBlock:^(id sender) {

//        [_callProceedingDisplay stop]; // stop the animation if possible
        [weakself.navigationController popViewControllerAnimated:YES];
        [PJSIPManager setCallStateDelegate:nil];
        [weakself hangupEngine:@""];
//        [[HangupCommercialManager instance] callingADDisappearWithCloseType:ADCLOSE_BUTTEN_CLOSE];  清除通话中广告
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [CallRingUtil audioEnd];
        });
    }];
    [[hangupButton tpd_withSize:CGSizeMake(60, 60)] tpd_withCornerRadius:30.f];


    [hangupButton setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor2(0xfd, 0x49, 0x5b)] forState:UIControlStateNormal];
    [hangupButton setBackgroundImage:[UIImage tpd_imageWithColor:RGB2UIColor2(0xca, 0x3a, 0x49)] forState:UIControlStateHighlighted];
    [hangupButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor blackColor]] forState:UIControlStateDisabled];
    hangupButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:34];
    [hangupButton setTitle:@"R" forState:UIControlStateNormal];
    
    self.hangupButton = hangupButton;
    
}

-(void)createKeyboardButton{
    static BOOL keyboardShow = NO;
    WEAK(self)
    self.keyboardButton = [[UIButton buttonWithType:UIButtonTypeCustom] tpd_withBlock:^(id sender) {
        keyboardShow = !keyboardShow;
        weakself.keyboardView.hidden = !keyboardShow;
        weakself.keyboardMaskView.hidden = !keyboardShow;
        weakself.buttonLine1.hidden = keyboardShow;
        [sender setSelected:keyboardShow];
    }];
    [self.keyboardButton setImage:[TPDialerResourceManager getImage:@"voip_key_hide@2x.png"] forState:UIControlStateNormal];
    [self.keyboardButton setImage:[TPDialerResourceManager getImage:@"voip_key_show@2x.png"] forState:UIControlStateSelected];
    
    [[self.keyboardButton tpd_withCornerRadius:30] tpd_withSize:CGSizeMake(60, 60)];
    
}

#pragma mark 回拨电话第二排按钮（分享、隐藏）
-(void)createHideButton{
    WEAK(self)
    UIButton* hideButton = [[[[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        //        [bself shareByTimeline];
        //        [delegate onCloseButtonPressed];
        [weakself.navigationController popViewControllerAnimated:NO];
    }] tpd_withCornerRadius:30] tpd_withSize:CGSizeMake(60, 60)]tpd_withBorderWidth:1.f color:[UIColor whiteColor]] .cast2UIButton;
    [hideButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [hideButton setBackgroundImage:[UIImage tpd_imageWithColor:[TPDialerResourceManager getColorForStyle:@"outgoing_button_highlight_color"]] forState:UIControlStateHighlighted];
    [hideButton setTitleColor:RGB2UIColor2(0x0f, 0x74, 0xd9) forState:UIControlStateHighlighted];
    hideButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30*(TPScreenWidth()/414)];
    [hideButton setTitle:@"F" forState:UIControlStateNormal];
    [hideButton setTitle:@"F" forState:UIControlStateHighlighted];
    UILabel* hideButtonText = [[UILabel tpd_commonLabel] tpd_withText:NSLocalizedString(@"voip_hide", @"") color:[UIColor whiteColor  ] font:12];
    hideButtonText.textAlignment = NSTextAlignmentCenter;
    self.hideButtonWrapper = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[hideButton,hideButtonText] offsets:@[@0,@10]];
    
}

-(void)createShareButton{
    WEAK(self)
    UIButton* shareButton = [[[[[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
        VoipShareAllView *view = [[VoipShareAllView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
        view.fromWhere = @"VoipCall";
        [weakself.view addSubview:view];
    }] tpd_withCornerRadius:30] tpd_withSize:CGSizeMake(60, 60)] tpd_withBorderWidth:1.f color:[UIColor whiteColor]] .cast2UIButton;
    [shareButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage tpd_imageWithColor:[TPDialerResourceManager getColorForStyle:@"outgoing_button_highlight_color"]] forState:UIControlStateSelected];
    [shareButton setTitleColor:RGB2UIColor2(0x0f, 0x74, 0xd9) forState:UIControlStateSelected];
    shareButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30*(TPScreenWidth()/414)];
    [shareButton setTitle:@"b" forState:UIControlStateNormal];
    [shareButton setTitle:@"S" forState:UIControlStateSelected];
    UILabel* shareButtonText = [[UILabel tpd_commonLabel] tpd_withText:NSLocalizedString(@"voip_share", @"") color:[UIColor whiteColor  ] font:12];
    shareButtonText.textAlignment = NSTextAlignmentCenter;
    self.shareButtonWrapper = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:@[shareButton,shareButtonText] offsets:@[@0,@10]];
}

#pragma mark 头部信息
-(void)createHeaderView{
    UIView* headerView = [[[UIView alloc] init] tpd_withBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"]];
    WEAK(self)
    
    NSString* mainStr = @"";
    if (self.numbers.count > 1) {
        for (NSString* num in self.numbers) {
            int personId = [NumberPersonMappingModel queryContactIDByNumber:num];
            if (personId > 0) {
                ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
                mainStr = [[mainStr stringByAppendingString:@"、"] stringByAppendingString: contact.displayName];
            }else{
                mainStr = [[mainStr stringByAppendingString:@"、"] stringByAppendingString: num];
            }
        }
        
    }else{
        int personId = [NumberPersonMappingModel queryContactIDByNumber:self.numbers[0]];
        if (personId > 0) {
            ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
            mainStr = contact.displayName;
        }else{
            mainStr = self.numbers[0];
        }
    }
    UILabel* mainLabel = [[UILabel tpd_commonLabel] tpd_withText:mainStr color:[UIColor whiteColor] font:12];
    mainLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton* familyButton = [[[UIButton tpd_buttonStyleCommon] tpd_withBorderWidth:1.f color:RGB2UIColor(0xff85a6)] tpd_withCornerRadius:12.f].cast2UIButton;
    [familyButton setTitle:@"加为亲情号" forState:(UIControlStateNormal)];
    familyButton.titleLabel.font = [UIFont systemFontOfSize:12];
    familyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [familyButton  setTitleColor:[TPDialerResourceManager getColorForStyle:@"#ff85a6"] forState:(UIControlStateNormal)];
    [familyButton  setTitleColor:[TPDialerResourceManager getColorForStyle:@"#ff85a6"] forState:(UIControlStateHighlighted)];
    familyButton.hidden = YES;
    [familyButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor colorWithHexString:@"0xff4477" alpha:0.33]] forState:UIControlStateHighlighted];
    
    UIView* tmp = [[UIView new] tpd_withHeight:44.f];
    [tmp addSubview:mainLabel];
    [tmp addSubview:familyButton];
    [headerView addSubview:tmp];
    
    [mainLabel makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(tmp);
        make.right.equalTo(familyButton.left).offset(-5);
    }];
    
    [familyButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tmp);
        make.size.equalTo(CGSizeMake(100, 24));
        make.right.equalTo(tmp).offset(-20);
    }];
    
    [tmp makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(headerView);
    }];
    
    self.familyBtn = familyButton;
    


    self.headerView = headerView;
    
    
    
}

#pragma mark 键盘
-(void)createKeyboardView{
    UILabel* input = [UILabel tpd_commonLabel];
    input.text = @"";
    input.textColor = [UIColor whiteColor];
    
    NSArray* rawKeys = @[
                         @"1",@"2",@"3",
                         @"4",@"5",@"6",
                         @"7",@"8",@"9",
                         @"*",@"0",@"#",
                         ];
    NSArray* numKeyTone = @[
                            @1,@2,@3,
                            @4,@5,@6,
                            @7,@8,@9,
                            @10,@0,@11,
                            ];
    NSMutableArray* totalArr = [NSMutableArray array];
    
    for (int row=0; row<4; row++) {
        NSMutableArray* lineArr = [NSMutableArray array];
        for (int col=0; col<3; col++) {
            int index = row*3+col;
            UIButton* padKeyButton = [[UIButton tpd_buttonStyleCommon] tpd_withBlock:^(id sender) {
                if ([AppSettingsModel appSettings].dial_tone) {
                    [CootekSystemService playCustomKeySound:[numKeyTone[index] integerValue]]; //按键声音
                }
                [PJSIPManager sendDTMF:rawKeys[index]];
                input.text = [input.text stringByAppendingString:rawKeys[index]];
            }];
            [[[padKeyButton tpd_withSize:CGSizeMake(60, 60)] tpd_withCornerRadius:30.f] tpd_withBorderWidth:1.f color:[UIColor whiteColor]];
            [padKeyButton setTitle:rawKeys[index] forState:UIControlStateNormal];
            [padKeyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [padKeyButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
            [padKeyButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [padKeyButton setBackgroundImage:[UIImage tpd_imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
            
            [lineArr addObject:padKeyButton];
        }
        UIView* line = [UIView tpd_horizontalLinearLayoutWith:lineArr horizontalPadding:0 verticalPadding:0 interPadding:30];
        [totalArr addObject:line];
    }
    UIView* keysView = [[[UIView alloc] init] tpd_addSubviewsWithVerticalLayout:totalArr offsets:@[@10,@10,@10,@10]];
    
    
    UIView* maskview = [[[UIView alloc] init] tpd_withBackgroundColor:[UIColor blackColor]];
    maskview.alpha = 0.85f;
    
    self.keyboardView = [[UIView alloc] init];
    UIView* dummy = [keysView tpd_wrapper];
    dummy.userInteractionEnabled = YES;
    [self.view addSubview:maskview];
    [self.keyboardView addSubview:input];
    [self.keyboardView addSubview:dummy];
    
    [maskview makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [input makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self.keyboardView);
        make.height.equalTo(60);
    }];
    [dummy makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.keyboardView);
        make.top.equalTo(input.bottom);
    }];
    
    self.keyboardMaskView = maskview;
    self.keyboardView.hidden = YES;
    self.keyboardMaskView.hidden = YES;
}

#pragma mark 头像栏
+(void)configFamilyAvatar:(UIButton*)avatar{
    avatar.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:30];
    avatar.alpha = 0.5;
    [avatar setTitle:@"s" forState:UIControlStateNormal];
    avatar.backgroundColor = RGB2UIColor(0xfc5c8d);
    avatar.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"].CGColor;
}

+(void)configInActiveAvatar:(UIButton*)avatar{
    
    avatar.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30];
    avatar.alpha = 0.5;
    [avatar setTitle:@"I" forState:UIControlStateNormal];
    avatar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_500"];
    avatar.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"].CGColor;
}

+(void)configActiveAvatar:(UIButton*)avatar{
    
    avatar.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30];
    avatar.alpha = 0.5;
    [avatar setTitle:@"I" forState:UIControlStateNormal];
    avatar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"];
    avatar.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"].CGColor;
}

+(void)configOverSeaAvatar:(UIButton*)avatar{
    
    avatar.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30];
    avatar.alpha = 0.5;
    [avatar setTitle:@"9" forState:UIControlStateNormal];
    avatar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_cyan_500"];
    avatar.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"].CGColor;
}

+(void)configCallingActiveAvatar:(UIButton*)avatar{
    
    avatar.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30];
    avatar.alpha = 0.5;
    [avatar setTitle:@"I" forState:UIControlStateNormal];
    avatar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_blue_500"];
    avatar.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"].CGColor;
}
+(void)configUnknownAvatar:(UIButton*)avatar{
    
    avatar.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:30];
    avatar.alpha = 0.5;
    [avatar setTitle:@"9" forState:UIControlStateNormal];
    avatar.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_500"];
    avatar.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"].CGColor;
}


-(void)createAvatarGroupView{
    if (self.numbers.count>1) {
        NSMutableArray* avatarArr = [NSMutableArray array];
        NSMutableArray* weightArr = [NSMutableArray array];
        
        UIButton* me = [[[[UIButton tpd_buttonStyleCommon] tpd_withSize:CGSizeMake(60, 60)] tpd_withCornerRadius:30.f] tpd_withBorderWidth:.5f color:[UIColor whiteColor]].cast2UIButton;
        UIView* meAvatar = [[UIView new] tpd_addSubviewsWithVerticalLayout:@[me, [[UILabel tpd_commonLabel] tpd_withText:@"我" color:[TPDialerResourceManager getColorForStyle:@"tp_color_white"]]]];
        [avatarArr addObject:meAvatar];
        [weightArr addObject:@1];
        
        for (NSString* otherNumber in self.numbers) {
            
            NSString* name = nil;
            int personId = [NumberPersonMappingModel queryContactIDByNumber:otherNumber];
            if (personId > 0) {
                ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
                name = contact.displayName;
            }else{
                name = otherNumber;
            }
            UIButton* other = [[[[UIButton tpd_buttonStyleCommon] tpd_withSize:CGSizeMake(60, 60)] tpd_withCornerRadius:30.f] tpd_withBorderWidth:.5f color:[UIColor whiteColor]].cast2UIButton;
            UIView* otherAvatar = [[UIView new] tpd_addSubviewsWithVerticalLayout:@[me, [[UILabel tpd_commonLabel] tpd_withText:name color:[TPDialerResourceManager getColorForStyle:@"tp_color_white"]]]];
            [avatarArr addObject:otherAvatar];
            [weightArr addObject:@1];
        }
        
        UIView* avatarLine = [UIView tpd_horizontalGroupFullScreenForIOS7:avatarArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:weightArr];
        
        
        NSString *initString = @"正在呼叫";
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]
            || (self.callMode == CallModeIncomingCall) ) {
            initString = @" ";
        }
        UILabel* statusLabel = [[UILabel tpd_commonLabel] tpd_withText:initString color:[UIColor whiteColor] font:14];
        
        self.avatarGroupView = [[UIView alloc] init];
        
        [self.avatarGroupView addSubview:avatarLine];
        [self.avatarGroupView addSubview:statusLabel];
        
        [avatarLine makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.avatarGroupView);
            make.height.equalTo(60);
        }];
        
        [statusLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(avatarLine.bottom).offset(20);
            make.centerX.bottom.equalTo(self.avatarGroupView);
        }];
        self.statusLabel = statusLabel;
        self.dotLineLabel = nil;
    }else{

        UIButton* me = [UIButton tpd_buttonStyleCommon];
        [[[me tpd_withSize:CGSizeMake(60, 60)] tpd_withCornerRadius:30.f] tpd_withBorderWidth:.5f color:[UIColor whiteColor]];

        UIButton* other = [UIButton tpd_buttonStyleCommon];
        [[[other tpd_withSize:CGSizeMake(60, 60)] tpd_withCornerRadius:30.f] tpd_withBorderWidth:.5f color:[UIColor whiteColor]];
        
        WEAK(self)
        [self.disposableArray addObject: [[RACSignal combineLatest:@[self.callModeSignal, self.isFamilySignal]] subscribeNext:^(id x) {
            RACTupleUnpack(NSNumber *callMode, TPDFamilyInfo *f) = x;
            CallMode mode = [callMode integerValue];
            NSString *userPhotoName = [UserDefaultsManager stringForKey:PERSON_PROFILE_URL];
            
            if ([NSString isNilOrEmpty:userPhotoName]) {
                if (mode == CallModeTestType) {
                    [TPDCallViewController configInActiveAvatar:me];
                }else{
                    [TPDCallViewController configActiveAvatar:me];
                }
            }else{
                UIImage *userPhoto = [PersonalCenterUtility getHeadViewPhotoWithName:userPhotoName];
                if (userPhoto != nil) {
                    [me setBackgroundImage:userPhoto forState:UIControlStateNormal];
                }else{
                    [TPDCallViewController configActiveAvatar:me];
                }
            }
            
            if (f != nil && [f isFamilyNumber:[PhoneNumber getCNnormalNumber:weakself.numbers[0]]]) {
                [TPDCallViewController configFamilyAvatar:other];
            }else{
                if (mode == CallModeTestType) {
                    [TPDCallViewController configActiveAvatar:other];
                } else {
                    [TPDCallViewController configUnknownAvatar:other];
                }
            }
        }]];
        
        UIButton* left = me;
        UIButton* right = other;
        
        if (self.callMode == CallModeIncomingCall) {
            left = other;
            right = me;
        }
        
        // status label
        NSString *initString = @"正在呼叫";
        if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]
            || (self.callMode == CallModeIncomingCall) ) {
            initString = @" ";
        }
        UILabel* statusLabel = [[UILabel tpd_commonLabel] tpd_withText:initString color:[UIColor whiteColor] font:14];
        
        UILabel* dotLineLabel = [UILabel tpd_commonLabel];
        dotLineLabel.textColor = [UIColor whiteColor];
        [dotLineLabel setFont:[UIFont fontWithName:@"iPhoneIcon1" size:14]];
        
        
        self.avatarGroupView = [[UIView alloc] init];
        // view tree
        [self.avatarGroupView addSubview:left];
        [self.avatarGroupView addSubview:right];
        [self.avatarGroupView addSubview:statusLabel];
        [self.avatarGroupView addSubview:dotLineLabel];
        
        [left makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.avatarGroupView.centerX).offset(-100);
            make.top.bottom.equalTo(self.avatarGroupView);
        }];
        
        [right makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.avatarGroupView.centerX).offset(100);
            make.top.equalTo(left);
        }];
        
        [statusLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.top.equalTo(self.avatarGroupView);
        }];
        
        [dotLineLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.avatarGroupView);
            make.top.equalTo(statusLabel.bottom).offset(30);
        }];

        
        __block int i=0;
        self.animationTimer = [NSTimer bk_scheduledTimerWithTimeInterval:0.4 block:^(NSTimer *timer) {
             
            NSMutableString* s = [@"" mutableCopy];
            for (int j=0; j<4; j++) {
                if (j==i) {
                    [s appendString:@"qq"];
                }else{
                    [s appendString:@"pp"];
                }
            }
            dotLineLabel.text = s;
            i = (i+1)%4;
            
        } repeats:YES];
        self.dotLineLabel = dotLineLabel;
        self.statusLabel = statusLabel;
        
        
        // 电话接通后停止移动
        [self.disposableArray addObject:[[[GlobalVariables getInstance].onConnectedSignal filter:^BOOL(id value) {
            return [value boolValue];
        }] subscribeNext:^(id x) {
            [weakself.animationTimer invalidate];
            weakself.animationTimer = nil;
            weakself.dotLineLabel.text = @"pppppp";
        }]];
        
    }
}

#pragma mark 提示信息
-(void)createInformationView{
    UIView* toplineLeft = [[[[UIView alloc] init] tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withHeight:1.f];
    toplineLeft.alpha = .2f;
    
    UIView* toplineRight = [[[[UIView alloc] init] tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withHeight:1.f];
    toplineRight.alpha = .2f;
    
    UIImageView* icon = [[UIImageView tpd_imageView:@"listitem_detail_icon_normal@2x.png"] tpd_withSize:CGSizeMake(20, 20)].cast2UIImageView;
    
    UILabel* infoLabel = [[[UILabel tpd_commonLabel] tpd_withText:@"" color:[UIColor whiteColor] font:12] tpd_withSize:CGSizeMake(20, 20)].cast2UILabel;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 2;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    UIView* bottomLine = [[[[UIView alloc] init] tpd_withBackgroundColor:[UIColor whiteColor]] tpd_withHeight:1.f];
    bottomLine.alpha = .2f;
    
    UIView* topline = [UIView new];
    [topline addSubview:toplineLeft];
    [topline addSubview:icon];
    [topline addSubview:toplineRight];
    [toplineLeft makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(topline);
        make.right.equalTo(icon.left).offset(-5);
    }];
    [icon makeConstraints:^(MASConstraintMaker *make) {
        make.center.height.equalTo(topline);
    }];
    [toplineRight makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(topline);
        make.left.equalTo(icon.right).offset(5);
    }];
    
    self.infoPart = [[UIView new] tpd_addSubviewsWithVerticalLayout:@[topline, infoLabel, bottomLine] offsets:@[@10, @50, @60]];
    self.infoLabel = infoLabel;
}


#pragma mark UI配置
-(void)configNormalCallLayout{
    self.buttonLine1.hidden = NO;
    self.buttonLine2.hidden = NO;
    self.buttonLine2BackCall.hidden = YES;
    
    self.headerView.hidden = NO;
    self.avatarGroupView.hidden = NO;
    self.infoPart.hidden = NO;
    self.keyboardView.hidden = YES;
}

-(void)configNormalCallLayoutKeyboardShow{
    self.buttonLine1.hidden = YES;
    self.buttonLine2.hidden = NO;
    self.buttonLine2BackCall.hidden = YES;
    
    self.headerView.hidden = NO;
    self.avatarGroupView.hidden = YES;
    self.infoPart.hidden = YES;
    self.keyboardView.hidden = NO;
}

-(void)configBackCallLayout{
    self.buttonLine1.hidden = YES;
    self.buttonLine2.hidden = YES;
    self.buttonLine2BackCall.hidden = NO;
    
    self.headerView.hidden = NO;
    self.avatarGroupView.hidden = NO;
    self.infoPart.hidden = NO;
    self.keyboardView.hidden = YES;
}

-(void)configIncomingCallLayout{
    
}

-(void)assembleUI{
    
    
    // 第一行
    [self createBackcallButton];
    [self createMuteButton];
    [self createSpeakButton];
    self.buttonLine1 = [UIView tpd_horizontalLinearLayoutWith:@[self.backCallButtonWrapper,self.muteButtonWrapper, self.speakButtonWrapper] horizontalPadding:0 verticalPadding:0 interPadding:30];
    
    // 第二行
    [self createKeyboardButton];
    [self createHangupButton];
    self.buttonLine2 = [UIView tpd_horizontalLinearLayoutWith:@[self.keyboardButton,self.hangupButton] horizontalPadding:0 verticalPadding:0 interPadding:30];
    
    // 回拨第二行
    [self createHideButton];
    [self createShareButton];
    self.buttonLine2BackCall = [UIView tpd_horizontalLinearLayoutWith:@[self.hideButtonWrapper,[[UIView alloc] init],self.shareButtonWrapper] horizontalPadding:0 verticalPadding:0 interPadding:30];
    
    
    
    
    
    [self createHeaderView];
    [self createAvatarGroupView];
    [self createInformationView];
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.avatarGroupView];
    [self.view addSubview:self.buttonLine1];
    [self.view addSubview:self.buttonLine2BackCall];
    [self.view addSubview:self.infoPart];
    
    [self createKeyboardView];
    [self.view addSubview:self.keyboardView];
    [self.view addSubview:self.buttonLine2];

    
    [self.headerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(60);
    }];
    
    [self.avatarGroupView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.headerView.bottom).offset(20);
    }];
    
    [self.infoPart makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.avatarGroupView.bottom).offset(20);
        make.width.equalTo(self.view).offset(-100);
    }];
    
    [self.buttonLine1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.buttonLine2.top).offset(-30);
    }];
    
    [self.buttonLine2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.buttonLine1);
        make.bottom.equalTo(self.view.bottom).offset(-30);
    }];
    
    [self.buttonLine2BackCall makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.buttonLine1);
        make.top.equalTo(self.buttonLine2);
    }];
    
    [self.keyboardView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.bottom);
        make.bottom.lessThanOrEqualTo(self.buttonLine2.top);
        make.left.right.equalTo(self.view);
    }];
    
    
    self.buttonLine2.hidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 禁止侧滑返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    UIView *bgView = [UIImageView tpd_imageView:@"outgoing_bg@2x.png"];
    [self.view addSubview:bgView];
    [bgView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self initSignals];
    
    [self assembleUI];
    
    [self setupSignals];
    
    
    if (self.callMode == CallModeOutgoingCall) {
        [self startNormalCall];
    }
    
//    [self testSignal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    for (RACDisposable* d in self.disposableArray) {
        [d dispose];
    }
}
#pragma mark 电话操作相关
- (void)hangupEngine:(NSString *)info {
    [TimerTickerManager setTimerTickerUpStop:self];
    [TimerTickerManager removeDelegate:self];
    [VoipSystemCallInteract setSystemCallDelegate:nil];
    [PJSIPManager hangup:info];
    
}

-(void)startBackCall{
    [DialerUsageRecord recordpath:EV_VOIP_CALL kvs:Pair(@"count", @(1)), nil];
    [VoipSystemCallInteract setSystemCallDelegate:self];
    // 如果是回拨模式，挂断后重新调用PJSIP
    [DialerGuideAnimationUtil shouldReFreshLocalNoah];
    if (self.numbers.count > 1) {
        [PJSIPManager confercenceCall:self.numbers withDelegate:self];
    }else{
        [PJSIPManager call:self.numbers[0] callback:YES withDelegate:self];
    }
    //        [self displayCallBackMode];
    [CallRingUtil playBackCallConnectingTone];
    [self configBackCallLayout];
}

-(void)startNormalCall{
    [DialerUsageRecord recordpath:EV_VOIP_CALL kvs:Pair(@"count", @(1)), nil];
    [VoipSystemCallInteract setSystemCallDelegate:self];
    [DialerGuideAnimationUtil shouldReFreshLocalNoah];
    if (self.numbers.count > 1) {
        [PJSIPManager confercenceCall:self.numbers withDelegate:self];
    }else{
        [PJSIPManager call:self.numbers[0] callback:NO withDelegate:self];
    }
    [self configNormalCallLayout];
    
//    [self animateShowFunctionButtons];   UI切换
//    [self asyncGetAD];  准备广告
    [TimerTickerManager startTimerTickerUp:self withTicker:[PJSIPManager callDuration]];
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
}
#pragma mark 信号
-(void) onTimerTicker:(NSInteger) ticker{
    // 此ticker每0.1秒来一次
    [self.tickSignal sendNext:nil];
//    if (_isConnected && ticker % 10 == 0) {
//        if (_webViewShow) {
//            _callHeaderView.altLabel.text = [CallProceedingDisplay translateTickerToTime:_tick];
//        } else {
//            [_callProceedingDisplay showTicker:_tick];
//        }
//        
//        if (!_isPal && _decidedPal && _tick == _minuteMinus) {
//            if (_ratio < 0) {
//                if ([[TPCallActionController alloc] getCallNumberTypeCustion:self.numberArr[0]]==VOIP_OVERSEA) {
//                    //拨打海外用户时不显示扣费
//                    _ratio = 0;
//                }
//                _remainingMinutes += _ratio*1;
//                if (_remainingMinutes < 0) {
//                    _remainingMinutes = 0;
//                }
//                [_callProceedingDisplay showRemainingMinutes:_remainingMinutes];
//            }
//            _minuteMinus+=60;
//        }
//        if (_tick > 0 && _tick % 3 ==0) {
//            [self exchangeStateDisplay];
//        }
//        _tick++;
//    }
//    
//    if (ticker % 5 == 0) {
//        [_callProceedingDisplay animateIndicator];
//    }
//    if (ticker % 20 == 0) {
//        [_snowGenerator startSnow];
//    }
//    
//    if (_errorHangupStamp > 0) {
//        _errorHangupStamp++;
//        if (_errorHangupStamp == 20) {
//            [self afterErrorCompasateAsk];
//        }
//    }
    NSLog(@"ticker weyl: %ld",ticker);
}

-(void)initSignals{
    self.isFamilySignal = [[TPDFamilyInfo familyInfoSignal] replay];
    self.isPalSignal = [RACReplaySubject replaySubjectWithCapacity:1];
    self.callModeSignal = [RACReplaySubject replaySubjectWithCapacity:1];
    self.disposableArray = [NSMutableArray array];
    
}

-(void)testSignal{
//    self.callModeSignal, self.isFamilySignal
    
    [self.callModeSignal sendNext:@(self.callMode)];
    [(RACReplaySubject*)self.isFamilySignal sendNext:nil];
    
    [NSThread sleepForTimeInterval:3];
    [[GlobalVariables getInstance].onConnectedSignal sendNext:@(YES)];
    
}

-(void)setupSignals{
    
    WEAK(self)
    
    // isPalSignal 对方身份发生变化时
    // callModeSignal 模式发生变化时（呼出 》 回拨）
    // isFamilySignal 亲情号信息发生变化
    [self.isPalSignal sendNext:@([TouchpalMembersManager isNumberRegistered:self.numbers[0]])];
    [self.callModeSignal sendNext:@(self.callMode)];
    [[GlobalVariables getInstance].onConnectedSignal sendNext:@(NO)];
    
    
    // 计时
    __block int tick = 0;
    [[[[GlobalVariables getInstance].onConnectedSignal filter:^BOOL(id value) {
        return [value boolValue];
    }] flattenMap:^RACStream *(id value) {
        return self.tickSignal;
    }] subscribeNext:^(id x) {
        tick ++;
        int second = tick /10;
        
    }];
    
    // 亲情号按钮
    [self.disposableArray addObject:[self.isFamilySignal subscribeNext:^(id x) {
        TPDFamilyInfo* f = x;
        //        NSInteger type = [[TPCallActionController controller] getCallNumberTypeCustion:[PhoneNumber getCNnormalNumber:_number]];
        if (weakself.callMode == CallModeOutgoingCall // && type!=VOIP_LANDLINE
            && (f == nil || ![f isFamilyNumber:weakself.numbers[0]])) {
            weakself.familyBtn.hidden = NO;
            [weakself.familyBtn tpd_withBlock:^(id sender) {
                if (f == nil || f.bind_success_list.count >=5) {
                    [MBProgressHUD showText:@"您的亲情号名额已经用光了！"];
                }else{
                    [MBProgressHUD showText:@"已向对方发送绑定邀请"];
                    NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:weakself.numbers[0]];
                    ContactCacheDataModel *model = [PersonDBA getConatctInfoByRecordID:personID];
                    [TPDFamilyInfo bindFamily:weakself.numbers[0] name:model.fullName];
                    
                }
            }];
        }else{
            weakself.familyBtn.hidden = YES;
        }
    }]];
    
    // statuslabel文字
    [self.disposableArray addObject:[[RACSignal combineLatest:@[self.callModeSignal, [GlobalVariables getInstance].onConnectedSignal]] subscribeNext:^(id x) {
        RACTupleUnpack(NSNumber *callmode, NSNumber *connected) = x;
        if ([callmode integerValue] != CallModeIncomingCall) {
            BOOL isVip = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
            if (isVip) {
                weakself.statusLabel.text = @"VIP专线通话中";
            }else{
                weakself.statusLabel.text = @"正在呼叫";
            }
            [UserDefaultsManager setObject:CALL_TYPE_C2P forKey:LAST_FREE_CALL_TYPE];
        }
        
    }]];
    
    // 提示信息文字
    [self.disposableArray addObject:[[RACSignal combineLatest:@[self.callModeSignal, [GlobalVariables getInstance].onConnectedSignal]] subscribeNext:^(id x) {
        RACTupleUnpack(NSNumber *callmode, NSNumber *connected) = x;
        if ([callmode integerValue] != CallModeIncomingCall) {
            BOOL isVip = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
            if (isVip) {
                weakself.statusLabel.text = @"VIP专线通话中";
            }else{
                weakself.statusLabel.text = @"正在呼叫";
            }
            [UserDefaultsManager setObject:CALL_TYPE_C2P forKey:LAST_FREE_CALL_TYPE];
        }
        
    }]];
    
    // 挂断逻辑
    [[[GlobalVariables getInstance].onConnectedSignal filter:^BOOL(id value) {
        return ![value boolValue];
    }] subscribeNext:^(id x) {
        // 准备hangup广告
//        [self hangupPrepare];
        
        [CootekSystemService playVibrate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [CallRingUtil audioEnd];
        });
    }];
    
    [[[RACSignal combineLatest:@[[GlobalVariables getInstance].onConnectedSignal, self.callModeSignal]] filter:^BOOL(id value) {
        RACTupleUnpack(NSNumber* x, NSNumber* y) = value;
        return ![x boolValue] && [y integerValue] == CallModeBackCall;
    }] subscribeNext:^(id x) {
        [weakself startBackCall];

    }];
    
    [[RACSignal combineLatest:@[self.isFamilySignal,self.isPalSignal,self.callModeSignal, [GlobalVariables getInstance].onCallStateInfoSignal]] subscribeNext:^(id x) {
//        RACTupleUnpack(TPDFamilyInfo* f, NSNumber* ispal, NSNumber* callmode, TPDCallStateInfo* callState) = x;
//        if ([callmode integerValue] == CallModeIncomingCall) {
//            weakself.infoLabel.text = @"您的触宝好友来电\n请注意接听";
//            return;
//        }
        
//        if (f!=nil && [f isFamilyNumber:weakself.numbers[0]]) {
//            weakself.infoLabel.text = @"对方是你的亲情号\n打满1分钟，就得1分钟";
//        }else{
//            if ([ispal boolValue]) {
//                if (!callState.isActive) {
//                    weakself.infoLabel.text = @"对方已经没有再使用触宝电话了，本次通话扣除免费分钟数";
//                }else if([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
//                    int days = [UserDefaultsManager intValueForKey:VOIP_FIND_PRIVILEGA_DAY defaultValue:-1];
//                    if (days > 0) {
//                        weakself.infoLabel.text = [NSString stringWithFormat:@"VIP享高清通话不中断保护\nVIP特权剩余%d天", days];
//                    }
//                    
//                }else{
//                    if ([callmode integerValue] == CallModeTestType) {
//                        weakself.infoLabel.text = @"本次通话不消耗分钟数和流量";
//                    } else {
//                        weakself.infoLabel.text = @"对方是触宝好友，本次通话不消耗免费时长";
//                    }
//                }
//            }else{
                weakself.infoLabel.text = [NSString stringWithFormat:@"剩余时长%d分钟", 3];
//            }
//        }
    }];
}


- (void)onSwitchingToC2P{
    [[GlobalVariables getInstance].onSwitchingToC2PSignal sendNext:nil];
    [UserDefaultsManager setObject:CALL_TYPE_C2P forKey:LAST_FREE_CALL_TYPE];
}
- (void)onRinging{
    [[GlobalVariables getInstance].onRingingSignal sendNext:nil];
}
- (void)onConnected{
    [[GlobalVariables getInstance].onConnectedSignal sendNext:@(YES)];
}
- (void)onCallStateInfo:(NSDictionary *)info{
    TPDCallStateInfo* f = [TPDCallStateInfo mj_objectWithKeyValues:info];
    [[GlobalVariables getInstance].onCallStateInfoSignal sendNext:f];
    [self.isPalSignal sendNext:@(f.registered)];
}
- (void)onDisconected{
    [[GlobalVariables getInstance].onConnectedSignal sendNext:@(NO)];
}
- (void)onCallErrorWithCode:(int)errorCode{
    [[GlobalVariables getInstance].onCallErrorWithCodeSignal sendNext:@(errorCode)];
}
- (void)onCallModeSet:(NSString *)callMode{
    [[GlobalVariables getInstance].onCallModeSetSignal sendNext:callMode];
}
- (void)notifyEdgeNotStable{
    
}
- (void)onIncoming:(NSString *)number{
    [[GlobalVariables getInstance].onIncomingSignal sendNext:number];
}

- (void)onSysIncomingCall{
    [[GlobalVariables getInstance].onSysIncomingCallSignal sendNext:nil];
}

- (void)onSysHangupCall{
    [[GlobalVariables getInstance].onSysHangupCallSignal sendNext:nil];
}
- (void)onSystemCallConnected{
    [[GlobalVariables getInstance].onSystemCallConnected sendNext:nil];
}

#pragma mark 
@end
