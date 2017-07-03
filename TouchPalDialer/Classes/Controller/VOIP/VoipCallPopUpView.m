//
//  VoipCallPopUpView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-13.
//
//
#import "TPDSelectViewController.h"
#import "VoipCallPopUpView.h"
#import "TPDialerResourceManager.h"
#import "WXApi.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPMFMessageActionController.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"
#import "Reachability.h"
#import "DefaultUIAlertViewHandler.h"
#import "TouchpalMembersManager.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "TPShareController.h"
#import "CallerDBA.h"
#import "CallerIDModel.h"
#import "EditVoipViewController.h"
#import "SmartDailerSettingModel.h"
#import "VoipLandlineAddZoneView.h"
#import "TouchPalDialerAppDelegate.h"
#import "CallCommercialCell.h"
#import "CallCommercialManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SeattleFeatureExecutor.h"
#import "VOIPCall.h"
#import "DialerUsageRecord.h"
#import "MarketLoginController.h"
#import "DialerViewController.h"
#import "FreeDialSettingViewController.h"
#import "SettingsModelCreator.h"
#import "FunctionUtility.h"
#import "CommonTipsWithBolckView.h"
#import "HandlerWebViewController.h"
#import "PersonInfoDescViewController.h"
#import "LocalStorage.h"
#import "HangupCommercialManager.h"
#import "VoipUtils.h"
#import "NSString+TPHandleNil.h"
#import "AdStatManager.h"
#import "PrepareAdManager.h"
#import "TPDLib.h"
#import <Masonry.h>
#import "GroupDeleteContactCommandCopy.h"
#import "GroupOperationCommandCreatorCopy.h"
#import "TPDExperiment.h"
#import "TPCallActionController.h"
#import "YellowPageLocationManager.h"
#import "BiBiPairManager.h"
#import "TPDVoipCallPopUpViewController.h"
#define FreeButtonTag 1000



@interface VoipCallPopUpView()<VoipLandlineAddZoneViewDelegate>{
    UIImageView *_callBoard;
    
    NSString *_userName;
    NSString *_callNumber;
    BOOL onTouchMove;
    BOOL _canBiBiCall;
    
    CGRect _initFrame;
    UIButton *_networkBoardCallButton;
    UIButton *normalCallButton;
    
    NSInteger _type;
    VoipLandlineAddZoneView *zoneView;
    UILabel *_tickerLabel;
    NSTimer *_timer;
    int _tick;
    BOOL _hasClick;
    UIView *_adView;
    UILabel *settingLabel;
    UILabel *titleLabel;
    
    HandlerWebViewController *webController;
}
//@property (nonatomic,strong) NSMutableArray *numbers;
@property (nonatomic,strong)UIButton *freeCallButton;
@property (nonatomic,strong)NSTimer *timerTest;

@property (nonatomic,strong) NSMutableArray* conferenceList;
@property (nonatomic) BOOL ifCootekUser;

@end


@implementation VoipCallPopUpView
static float scaleRatio;
-(UILabel*)getVIPLabel:(UIButton*)freeCallButton{
    UILabel* vip=nil;
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        vip = [UIImageView tpd_imageView:@"iphone-ttf:iPhoneIcon5:Y:20:tp_color_yellow_200"].cast2UILabel;
    }else{
        vip = [UIImageView tpd_imageView:@"iphone-ttf:iPhoneIcon2:S:20:tp_color_yellow_200"].cast2UILabel;
    }
    [freeCallButton addSubview:vip];
    [vip makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(freeCallButton);
        make.left.equalTo(freeCallButton.titleLabel.right).offset(5);
    }];
    return vip;
}

-(UILabel*)getVIPLabelLeft:(UIButton*)freeCallButton{
    UILabel* vip=nil;
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        vip = [UIImageView tpd_imageView:@"iphone-ttf:iPhoneIcon5:Y:20:tp_color_yellow_200"].cast2UILabel;
    }else{
        vip = [UIImageView tpd_imageView:@"iphone-ttf:iPhoneIcon2:S:20:tp_color_yellow_200"].cast2UILabel;
    }
    [freeCallButton addSubview:vip];
    [vip makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(freeCallButton);
        make.right.equalTo(freeCallButton.titleLabel.left);
    }];
    return vip;
}


-(void)fillCallBtnWrapper2:(UIButton*)freeCallBtnWrapper callBtn:(UIButton*)freeCallButton{
    double circle = [UIScreen mainScreen].bounds.size.width > 580? 46:40;
    
    
    NSMutableArray* viewArr = [NSMutableArray array];
    
    UIButton* v = [[[[[[[UILabel tpd_commonLabel] tpd_withText:@"我" color:[UIColor whiteColor] font:24] tpd_wrapper] tpd_wrapperWithButton] tpd_withCornerRadius:circle/2] tpd_withBorderWidth:1.f color:[TPDialerResourceManager  getColorForStyle:@"tp_color_green_100"]] tpd_withBackgroundColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_green_400"]].cast2UIButton;
    [freeCallBtnWrapper addSubview:v];
    [v makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(freeCallBtnWrapper);
        make.left.equalTo(freeCallBtnWrapper).offset(6);
        make.width.height.equalTo(circle);
    }];
    [viewArr addObject:v];
    
    
    for (int i=0; i<MIN(self.conferenceList.count, 3); i++) {
        int personId = [NumberPersonMappingModel queryContactIDByNumber:self.conferenceList[i]];
        
        NSString* text = self.conferenceList[i];
        if (personId > 0) {
            ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
            text = contact.fullName;
            if (text == nil || [text isEqualToString:@""]) {
                text = [((PhoneDataModel*)contact.phones[0]) number];
            }
        }
        
        
        
        UILabel* l = [[UILabel tpd_commonLabel] tpd_withText:[text substringFromIndex:text.length-1] color:[UIColor whiteColor] font:24];
        
        UIButton* tmp = [[[[[l tpd_wrapper] tpd_wrapperWithButton] tpd_withCornerRadius:circle/2] tpd_withBorderWidth:1.f color:[TPDialerResourceManager  getColorForStyle:@"tp_color_green_100"]] tpd_withBackgroundColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_green_400"]].cast2UIButton;
        [freeCallBtnWrapper addSubview:tmp];
        [tmp makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(freeCallBtnWrapper);
            make.left.equalTo(v.right).offset(-10);
            make.width.height.equalTo(circle);
        }];
        [viewArr addObject:tmp];
        v = tmp;
    }
    
    if (self.conferenceList.count <= 2) {
        UILabel* plusLabel;
        
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            plusLabel = [UIImageView tpd_imageView:@"iphone-ttf:iPhoneIcon4:w:20:tp_color_white"].cast2UILabel;
        }else{
            plusLabel = [UIImageView tpd_imageView:@"iphone-ttf:iPhoneIcon3:g:20:tp_color_white"].cast2UILabel;
        }
        
        UIButton* tmp = [[[[[[plusLabel
                              tpd_wrapper]
                             tpd_wrapperWithButton]
                            tpd_withCornerRadius:circle/2]
                           tpd_withBorderWidth:1.f color:[TPDialerResourceManager  getColorForStyle:@"tp_color_green_100"]]
                          tpd_withBackgroundColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_green_400"]].cast2UIButton
                         tpd_withBlock:^(id sender) {
                             
                             TPDSelectViewController *select = [[TPDSelectViewController alloc]initWithFinishBlock:^(NSArray *dataList) {
                                 for (id number in dataList) {
                                     if (![VoipCallPopUpView isFreeCall:number]) {
                                         [MBProgressHUD showText:@"您选择的号码不支持多人通话" toView:self];
                                         return;
                                     }
                                     
                                 }
                                 
                                 for (id number in dataList) {
                                     [self.conferenceList addObject:[PhoneNumber getCNnormalNumber:number]];
                                     
                                 }
                                 
                                 [viewArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                 [self fillCallBtnWrapper2:freeCallBtnWrapper callBtn:freeCallButton];
                                 NSLog(@"%@",dataList.description);
                                 
                             } CancelBlock:^{
                                 NSLog(@"cancel");
                                 
                             }];
                             [[UIViewController tpd_topViewController].navigationController pushViewController:select animated:YES ];
                         }];
        
        [freeCallBtnWrapper addSubview:tmp];
        [tmp makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(freeCallBtnWrapper);
            make.left.equalTo(v.right).offset(-10);
            make.width.height.equalTo(circle);
        }];
        [viewArr addObject:tmp];
        v = tmp;
    }
    
    [freeCallBtnWrapper addSubview:freeCallButton];
    [freeCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(v.right).offset(-10);
        make.right.top.bottom.equalTo(freeCallBtnWrapper);
    }];

}

-(UIView*)createFreecallButton2:(NSInteger)type{
    
    UIButton *freeCallButton = [UIButton tpd_buttonStyleCommon] ;
    freeCallButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
    if (type == VOIP_SERVICE || type == VOIP_PASS || type==VOIP_XINJIANG){
        [freeCallButton setTitle:NSLocalizedString(@"该号码不支持触宝电话", "") forState:UIControlStateNormal];
        [freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_disable_image"] forState:UIControlStateNormal];
        return freeCallButton;
    }
    
//    if (type == VOIP_OVERSEA){
//
//       
//        if (![UserDefaultsManager boolValueForKey:have_participated_voip_oversea defaultValue:NO]) {
//            if(![UserDefaultsManager boolValueForKey:had_popview_add_vip]){
//                if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
//                    [freeCallButton setTitle:NSLocalizedString(@"加入内测，国际长途免费打","") forState:UIControlStateNormal];
//                    [freeCallButton setTitleColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_yellow_200"] forState:UIControlStateNormal];
//                    [self getVIPLabelLeft:freeCallButton];
//                }else{
//                    [freeCallButton setTitle:NSLocalizedString(@"加入内测，国际长途免费打","") forState:UIControlStateNormal];
//                    [freeCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                }
//                
//                
//                [freeCallButton addTarget:self action:@selector(jumpToInternationalCallVC) forControlEvents:(UIControlEventTouchUpInside)];
//                [UserDefaultsManager setBoolValue:YES forKey:had_popview_add_vip];
//            }else{
//                [freeCallButton setTitle:NSLocalizedString(@"未开通触宝电话长途功能", "") forState:UIControlStateNormal];
//                [freeCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                [freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_disable_image"] forState:UIControlStateNormal];
//            }
//        }else{
//            [freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_image"] forState:UIControlStateNormal];
//            if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
//                [freeCallButton setTitle:NSLocalizedString(@"免费国际电话(VIP高清专线)", "") forState:UIControlStateNormal];
//                [self getVIPLabelLeft:freeCallButton];
//            }else{
//                [freeCallButton setTitle:NSLocalizedString(@"免费国际电话", "") forState:UIControlStateNormal];
//                [freeCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            }
//            
//            [freeCallButton addTarget:self action:@selector(judgeOnClickFreeCallButton) forControlEvents:UIControlEventTouchUpInside];
//        }
//        return freeCallButton;
//    }
    
    if (type == VOIP_ENABLE ||type == VOIP_PRE_17) {
        
        if ([TPDExperiment multiCallExperiment].isDefaultValue) {
//            未开启多人通话
            if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
                [freeCallButton setTitle:NSLocalizedString(@"通通宝电话", "") forState:UIControlStateNormal];
                [freeCallButton setTitleColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_yellow_200"] forState:UIControlStateNormal];
                [self getVIPLabel:freeCallButton];
            } else if (self.ifCootekUser) {
                // 如果主叫仅仅是注册用户，后缀显示`好友专线免时长`
                [freeCallButton setTitle:NSLocalizedString(@"通通宝电话", "") forState:UIControlStateNormal];
                [freeCallButton setTitleColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_yellow_200"] forState:UIControlStateNormal];
                
            }else{
                [freeCallButton setTitle:NSLocalizedString(@"通通宝电话", "") forState:UIControlStateNormal];
                [freeCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            [freeCallButton addTarget:self action:@selector(judgeOnClickFreeCallButton) forControlEvents:UIControlEventTouchUpInside];
            [freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_image"] forState:UIControlStateNormal];
            return freeCallButton;
            
        }else{
            //            开启多人通话
            if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
                [freeCallButton setTitle:NSLocalizedString(@"多人免费通话", "") forState:UIControlStateNormal];
                [freeCallButton setTitleColor:[TPDialerResourceManager  getColorForStyle:@"tp_color_yellow_200"] forState:UIControlStateNormal];
                [self getVIPLabel:freeCallButton];
            } else{
                [freeCallButton setTitle:NSLocalizedString(@"多人免费通话", "") forState:UIControlStateNormal];
                [freeCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            [freeCallButton addTarget:self action:@selector(judgeOnClickFreeCallButton) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton* freeCallBtnWrapper = [UIButton tpd_buttonStyleCommon];
            [freeCallBtnWrapper setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_image"] forState:UIControlStateNormal];
            [self fillCallBtnWrapper2:freeCallBtnWrapper callBtn:freeCallButton];
            
            return freeCallBtnWrapper;
        }
        

    }else{
        [freeCallButton setTitle:NSLocalizedString(@"不支持该号码", "") forState:UIControlStateNormal];
        [freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_disable_image"] forState:UIControlStateNormal];
        return freeCallButton;
    }
    
    
}


+ (BOOL)isFreeCall:(NSString*)number{
    NSInteger type = [[TPCallActionController controller] getCallNumberTypeCustion:[PhoneNumber getCNnormalNumber:number]];
    return type == VOIP_ENABLE ||type == VOIP_PRE_17;
}

- (void)callBibi {
    [DialerUsageRecord recordCustomEvent:PATH_BIBI_CALL extraInfo:@{KEY_CALL:@(VALUE_BIBI)}];
    NSString *number = [PhoneNumber getNormalizedNumber:_callNumber];
    NSString *url =[NSString stringWithFormat:@"bibi://touchpal/call?number=%@",number];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:nil
                                 completionHandler:^(BOOL success) {
                                     cootek_log(@"call bibi success");
                                 }];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    if (_delegate!=nil && [_delegate respondsToSelector:@selector(onClickCancelButton)]) {
        [_delegate onClickCancelButton];
    }
    [self removeFromSuperview];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBI_CALL_OUT" object:nil];
    });
}

- (id)initWithFrame:(CGRect)frame andCallLog:(CallLogDataModel*)callLog andType:(NSInteger)type{
    self = [super initWithFrame:frame];
    
    if (self){
        _adView = nil;
        settingLabel = nil;
        
        self.conferenceList = [NSMutableArray array];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        scaleRatio = POPUP_VIEW_SCALE_RATIO;
        int globalY = MARGIN_TOP_OF_SETTING_LABEL * scaleRatio;
        _type = type;
        
        NSString *number = callLog.number;
        
        [self.conferenceList addObject: [PhoneNumber getCNnormalNumber:number]];
        
        NSString *normalNumber = [[PhoneNumber sharedInstance] getCNnormalNumber:number];
        CallerIDInfoModel *info = [CallerIDModel  queryCallerIDByNumberWithOutNotification:normalNumber];
        
        int personId = [NumberPersonMappingModel queryContactIDByNumber:number];
        if (personId > 0) {
            ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
            _userName = personData.fullName;
        } else {
            if (info.name.length > 0)
                _userName = info.name;
            else
                _userName = number;
        }
        
        BOOL isVoipOn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
        && [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
        
        self.ifCootekUser =
        ([TouchpalMembersManager isNumberRegistered:number] == 1)
        || callLog.ifVoip;
        
        AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
        _callNumber = number;
        _initFrame = frame;
        

        _canBiBiCall = [[BiBiPairManager manager] canBibiCall:normalNumber];
        BOOL isShowFree = (isVoipOn && appSettingsModel.dialerMode != DialerModeNormal);
        
        BOOL isShowNormal = (appSettingsModel.dialerMode != DialerModeVoip) || (type == VOIP_PASS||type == VOIP_SERVICE||type==VOIP_XINJIANG||(type==VOIP_OVERSEA&&![UserDefaultsManager boolValueForKey:have_participated_voip_oversea defaultValue:NO]));
        isShowNormal = NO;
        int boardHeight = (16 + VOIP_POPUP_VIEW_HEIGHT) * scaleRatio;
        if (!isShowFree) {
            boardHeight = boardHeight - (CALL_BUTTON_HEIGHT + MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON) * scaleRatio;
        }
        
        if (!isShowNormal) {
            boardHeight = boardHeight - (CALL_BUTTON_HEIGHT + MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON) * scaleRatio;
        }
        
        if (_canBiBiCall) {
            boardHeight += (CALL_BUTTON_HEIGHT + MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON) * scaleRatio;
        }
        _callBoard = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height,
                                                              frame.size.width, boardHeight)];
        _callBoard.backgroundColor = [UIColor whiteColor];
        NSString *boardImagePath = [FileUtils getNewFileInCommonFileWithPathComponent:@"boardImage/board@2x.png" ifInsertDir:YES];
        _callBoard.image = [UIImage imageWithContentsOfFile:boardImagePath];
        _callBoard.contentMode = UIViewContentModeScaleToFill;
        _callBoard.userInteractionEnabled = YES;
        [self addSubview:_callBoard];
        
        NSString* content = NSLocalizedString(@"dialer_mode_setting_guide", "setting");
        UIFont* font = [UIFont systemFontOfSize:FONT_SIZE_5];
        UIColor *settingColor = [TPDialerResourceManager getColorForStyle:
                                 @"tp_color_black_transparency_600"];
        CGSize labelSize = [content sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        
        if (callLog.callFromOutside) {
            UIFont *titleFont = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
            CGSize titleSize = [content sizeWithFont:titleFont constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, globalY -(titleSize.height - labelSize.height), 200, titleSize.height)];
            [titleLabel setNumberOfLines:0];
            titleLabel.text = _userName;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.textColor = settingColor;
            [_callBoard addSubview:titleLabel];
        }
        
        
        settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-16-labelSize.width, globalY, labelSize.width, labelSize.height)];
        [settingLabel setNumberOfLines:0];
        settingLabel.text = content;
        settingLabel.font = font;
        settingLabel.textAlignment = NSTextAlignmentRight;
        settingLabel.textColor = settingColor;
        settingLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
        [settingLabel addGestureRecognizer:labelTapGestureRecognizer];
        settingLabel.hidden = YES;
        [_callBoard addSubview:settingLabel];
        
        
        UIView *settingLine = [[UIView alloc]initWithFrame:CGRectMake(settingLabel.frame.origin.x, CGRectGetMaxY(settingLabel.frame) + 0.5, labelSize.width, 1)];
        settingLine.backgroundColor = settingColor;
        settingLine.hidden = YES;
        [_callBoard addSubview:settingLine];
        globalY += settingLabel.frame.size.height;
        
        globalY += 16 * scaleRatio;
        
        CGFloat normalButtonMarginTop = 16 * scaleRatio;
        if (_canBiBiCall) {
            UIButton *bibiButton = [UIButton tpd_buttonStyleCommon] ;
            [bibiButton setTitle:NSLocalizedString(@"bibi_start_talk", "") forState:UIControlStateNormal];
            [bibiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

            [_callBoard addSubview:bibiButton];
            
            [bibiButton addTarget:self action:@selector(callBibi) forControlEvents:UIControlEventTouchUpInside];
            [bibiButton makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_callBoard);
                make.width.equalTo(_callBoard).offset(-32);
                make.top.equalTo(settingLabel.bottom).offset(normalButtonMarginTop);
                make.height.equalTo(CALL_BUTTON_HEIGHT * scaleRatio);
            }];
            CGRect rect = CGRectMake(0, 0, frame.size.width - 2*32, CALL_BUTTON_HEIGHT);
            [bibiButton tpd_withCornerRadius:CALL_BUTTON_HEIGHT * scaleRatio/2];
            [bibiButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_pink_400"
                                                                              withFrame:rect]
                                  forState:UIControlStateNormal];
            [bibiButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_pink_600"
                                                                              withFrame:rect]
                                  forState:UIControlStateHighlighted];
            normalButtonMarginTop += (MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON + CALL_BUTTON_HEIGHT) * scaleRatio;
            globalY += (MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON + CALL_BUTTON_HEIGHT) * scaleRatio;
            
        }
        if(isVoipOn && appSettingsModel.dialerMode != DialerModeNormal) {
            UIView* freeBtnWrapper = [self createFreecallButton2:type];
            [_callBoard addSubview:freeBtnWrapper];
            [freeBtnWrapper makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_callBoard);
                make.width.equalTo(_callBoard).offset(-32);
                make.top.equalTo(settingLabel.bottom).offset(normalButtonMarginTop);
                make.height.equalTo(CALL_BUTTON_HEIGHT * scaleRatio);
            }];
            [freeBtnWrapper tpd_withCornerRadius:CALL_BUTTON_HEIGHT * scaleRatio/2];
            
            normalButtonMarginTop += (MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON + CALL_BUTTON_HEIGHT) * scaleRatio;
            globalY += (MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON + CALL_BUTTON_HEIGHT) * scaleRatio;
        }

        if(isShowNormal) {
            normalCallButton = [[UIButton alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width-32, CALL_BUTTON_HEIGHT * scaleRatio)];
            normalCallButton.layer.masksToBounds = YES;
            normalCallButton.layer.cornerRadius = 4.0f;
            normalCallButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
            [normalCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_normal_bg_image"] forState:UIControlStateNormal];
            [normalCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_onClick_bg_image"] forState:UIControlStateHighlighted];
            [normalCallButton addTarget:self action:@selector(onClickNormalCallButton) forControlEvents:UIControlEventTouchUpInside];
            [normalCallButton addTarget:self action:@selector(highlightNormalCallButtonBorderColor) forControlEvents:UIControlStateHighlighted];
            [normalCallButton addTarget:self action:@selector(changeNormalCallButtonBorderColor) forControlEvents:UIControlEventTouchUpOutside];
            [normalCallButton tpd_withCornerRadius:CALL_BUTTON_HEIGHT * scaleRatio/2];
            
            
            if (type == VOIP_PASS||type == VOIP_SERVICE||type==VOIP_XINJIANG||(type==VOIP_OVERSEA && ![UserDefaultsManager boolValueForKey:have_participated_voip_oversea defaultValue:NO])) {
                //            [self showTickerToCall];
                [_callBoard addSubview:normalCallButton];
                [self showTicker:-1];
                globalY += normalCallButton.frame.size.height + MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON * scaleRatio;
                
            } else if(appSettingsModel.dialerMode != DialerModeVoip) {
                [normalCallButton setTitle:NSLocalizedString(@"voip_normal_call", "") forState:UIControlStateNormal];
                [normalCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_callBoard addSubview:normalCallButton];
                globalY += normalCallButton.frame.size.height + MARGIN_BOTTOM_OF_NORMAL_CALL_BUTTON * scaleRatio;
            }
        }
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width -32, 1)];
        line2.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_line_color"];
        [_callBoard addSubview:line2];
        
        globalY += 1;
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, VOIP_LINE_HEIGHT * scaleRatio)];
        [cancelButton setTitle:NSLocalizedString(@"voip_cancel", "") forState:UIControlStateNormal];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_cancellbutton_2_normal_color"] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
        [cancelButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_white_transparency_0" withFrame:cancelButton.bounds] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_black_transparency_100" withFrame:cancelButton.bounds] forState:UIControlStateHighlighted];
        [_callBoard addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(removeShareView) forControlEvents:UIControlEventTouchUpInside];
        
        _adView = [self getWebADView];
        if (_adView != nil) {
            [self addSubview:_adView];
        }
        [self showInAnimation:_callBoard];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTestCallName:(NSString *)name{
    self = [super initWithFrame:frame];
    
    if (self){
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        scaleRatio = POPUP_VIEW_SCALE_RATIO;
        int globalY = MARGIN_TOP_OF_SETTING_LABEL * scaleRatio;
        _callBoard = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height,
                                                              frame.size.width, TEST_VOIP_POPUP_VIEW_HEIGHT * scaleRatio )];
        _callBoard.backgroundColor = [UIColor whiteColor];
        NSString *boardImagePath = [FileUtils getNewFileInCommonFileWithPathComponent:@"boardImage/board@2x.png" ifInsertDir:YES];
        _callBoard.image = [UIImage imageWithContentsOfFile:boardImagePath];
        _callBoard.contentMode = UIViewContentModeScaleToFill;
        _callBoard.userInteractionEnabled = YES;
        [self addSubview:_callBoard];
        
        _freeCallButton = [[UIButton alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width-32, 56 * scaleRatio)];
        _freeCallButton.layer.masksToBounds = YES;
        _freeCallButton.layer.cornerRadius = 4.0f;
        _freeCallButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
        _freeCallButton.tag = FreeButtonTag;
        [_freeCallButton setTitle:NSLocalizedString(@"通通宝电话", "") forState:UIControlStateNormal];
        [_freeCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_highlight_image"] forState:UIControlStateHighlighted];
        [_freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_image"] forState:UIControlStateNormal];
        [_freeCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_freeCall_button_bg_disable_image"] forState:UIControlStateDisabled];
        [_callBoard addSubview:_freeCallButton];
        [_freeCallButton addTarget:self action:@selector(onTestClickFreeCallButton) forControlEvents:UIControlEventTouchUpInside];
        
        globalY += _freeCallButton.frame.size.height + 14 * scaleRatio;
        
        normalCallButton = [[UIButton alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width-32, 56 * scaleRatio)];
        normalCallButton.layer.masksToBounds = YES;
        normalCallButton.layer.cornerRadius = 4.0f;
        normalCallButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
        [normalCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_normal_bg_image"] forState:UIControlStateNormal];
        [normalCallButton setBackgroundImage:[[TPDialerResourceManager sharedManager]getResourceByStyle:@"voip_normalCall_button_onClick_bg_image"] forState:UIControlStateHighlighted];
        [_callBoard addSubview:normalCallButton];
        [normalCallButton addTarget:self action:@selector(onTestClickNormalCallButton) forControlEvents:UIControlEventTouchUpInside];
        
        [normalCallButton addTarget:self action:@selector(highlightNormalCallButtonBorderColor) forControlEvents:UIControlStateHighlighted];
        [normalCallButton addTarget:self action:@selector(changeNormalCallButtonBorderColor) forControlEvents:UIControlEventTouchUpOutside];
        [normalCallButton setTitle:NSLocalizedString(@"voip_normal_call", "") forState:UIControlStateNormal];
        [normalCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        globalY += normalCallButton.frame.size.height + 24 * scaleRatio;
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(16, globalY, frame.size.width -32, 1)];
        line2.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_line_color"];
        [_callBoard addSubview:line2];
        
        globalY += 1;
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, globalY, frame.size.width, VOIP_LINE_HEIGHT * scaleRatio)];
        [cancelButton setTitle:NSLocalizedString(@"voip_cancel", "") forState:UIControlStateNormal];
        [cancelButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_cancellbutton_2_normal_color"] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5 * scaleRatio];
        [cancelButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_white_transparency_0" withFrame:cancelButton.bounds] forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:[TPDialerResourceManager getImageByColorName:@"tp_color_black_transparency_100" withFrame:cancelButton.bounds] forState:UIControlStateHighlighted];
        [_callBoard addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(removeShareView) forControlEvents:UIControlEventTouchUpInside];
        [self showInAnimation:_callBoard];
        
    }
    return self;
}

-(void)sendVoipButtonClickMessage {
    [self judgeOnClickFreeCallButton];
}

-(void)jumpToInternationalCallVC{
    [self removeShareView];
    MarketLoginController *marketLoginController = [MarketLoginController withOrigin:@"dialerOversea"];
    marketLoginController.url = INVITATION_URL_STRING;
    [LoginController checkLoginWithDelegate:marketLoginController];
}

- (void)changeNormalCallButtonBorderColor{
    normalCallButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_normalbutton_normal_color"].CGColor;
}

- (void)highlightNormalCallButtonBorderColor{
    normalCallButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"voip_normalbutton_disable_color"].CGColor;
}


- (void) showInAnimation:(UIView *)animationView {
    CGRect oldFrame = animationView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         animationView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() - oldFrame.size.height , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                         _adView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (_freeCallButton) {
                             _timerTest = [[NSTimer alloc] initWithFireDate:0 interval:3 target:self selector:@selector(animationWithTime) userInfo:nil repeats:YES];
                             [[NSRunLoop mainRunLoop] addTimer:_timerTest forMode:NSDefaultRunLoopMode];
                             ;
                         }
                     }];
}
-(void)animationWithTime{
    [self showTouchHandInButton:_freeCallButton];
}

-(void)showTouchHandInButton:(UIButton *)button{
    
    CGSize buttonSize  = button.bounds.size;
    UIImage *handImage =[TPDialerResourceManager getImage:@"GuideViewHand@2x.png"];
    UIImageView *handImageView =[[UIImageView alloc] initWithFrame:CGRectMake(buttonSize.width-40-handImage.size.width, buttonSize.height/2.0, handImage.size.width, handImage.size.height)];
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    circleView.backgroundColor =[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"];;
    circleView.layer.masksToBounds  =YES;
    circleView.layer.cornerRadius = 7;
    circleView.center = CGPointMake(handImageView.frame.origin.x, handImageView.frame.origin.y);
    
    
    [button addSubview:circleView];
    [button addSubview:handImageView];
    handImageView.image  = handImage;
    handImageView.alpha = 0;
    circleView.alpha = 0;
    __block CGRect oldHandFrame = handImageView.frame;
    
    [UIView animateWithDuration:0.4 animations:^{
        handImageView.alpha =1;
    } completion:^(BOOL finished) {//0.4
        [UIView  animateWithDuration:0.4 animations:^{
            oldHandFrame.size.width = handImage.size.width*0.8;
            oldHandFrame.size.height = handImage.size.height*0.8;
            handImageView.frame =oldHandFrame;
        } completion:^(BOOL finished) {//0.8
            
            [self showCircleView:circleView];
            [UIView  animateWithDuration:0.2 animations:^{
                oldHandFrame.size.width = handImage.size.width;
                oldHandFrame.size.height = handImage.size.height;
                handImageView.frame =oldHandFrame;
                
            } completion:^(BOOL finished) {//1
                [self performSelector:@selector(hideHandImageView:) withObject:@[handImageView,circleView] afterDelay:1];
            }];
            
        }];
    }];
}
-(void)hideHandImageView:(id)objectViews{
    for (UIView *view  in objectViews) {
        [UIView  animateWithDuration:0.2 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


-(void)showCircleView:(id)objectView{
    UIView *circleView =(UIView *)objectView;
    UIView *spreadView1 = [[UIView  alloc] initWithFrame:circleView.frame];
    spreadView1.backgroundColor = [UIColor clearColor];
    spreadView1.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"].CGColor;
    spreadView1.layer.borderWidth = 1;
    spreadView1.layer.cornerRadius = 7;
    spreadView1.layer.masksToBounds = YES;
    spreadView1.alpha = 0;
    [_freeCallButton addSubview:spreadView1];
    
    UIView *spreadView2 = [[UIView  alloc] initWithFrame:circleView.frame];
    spreadView2.backgroundColor = [UIColor clearColor];
    spreadView2.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"].CGColor;
    spreadView2.layer.borderWidth = 1;
    spreadView2.layer.cornerRadius = 7;
    spreadView2.layer.masksToBounds = YES;
    spreadView2.alpha = 0;
    [_freeCallButton addSubview:spreadView2];
    
    [UIView  animateWithDuration:0.4 animations:^{
        circleView.alpha = 1;
    } completion:^(BOOL finished) {
        spreadView1.alpha= 1 ;
        [UIView  animateWithDuration:0.5 animations:^{
            [self performSelector:@selector(showSpreadView2:) withObject:spreadView2 afterDelay:0.2];
            spreadView1.transform = CGAffineTransformScale(CGAffineTransformIdentity, 50/14, 50/14);
            spreadView1.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }];
    
}

-(void)showSpreadView2:(id)spreadView{
    UIView *spreadView2 = (UIView *)spreadView;
    spreadView2.alpha= 1 ;
    [UIView  animateWithDuration:0.5 animations:^{
        spreadView2.transform = CGAffineTransformScale(CGAffineTransformIdentity, 50/14, 50/14);
        spreadView2.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    
}




- (void) showOutAnimation:(UIView *)animationView {
    CGRect oldFrame = animationView.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         animationView.frame = CGRectMake(oldFrame.origin.x, TPScreenHeight() , oldFrame.size.width,  oldFrame.size.height);
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
                         _adView.alpha = 0;
                     }
                     completion:^(BOOL finish){
                         if (finish){
                             if (_delegate!=nil && [_delegate respondsToSelector:@selector(onClickCancelButton)]) {
                                 [_delegate onClickCancelButton];
                             }
                             [UserDefaultsManager setBoolValue:NO forKey:DIALER_GUIDE_ANIMATION_WAIT];
                             
                         }
                     }];
}


- (void) onClickInviteButton{
    if (_delegate!=nil && [_delegate respondsToSelector:@selector(onClickInviteButton)]) {
        [_delegate onClickInviteButton];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_freeCallButton) {
        return;
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    if (!_callBoard.hidden){
        if (point.y < TPScreenHeight() - _callBoard.frame.size.height ){
            if(!onTouchMove){
                [self removeShareView];
            }else{
                onTouchMove = NO;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    cootek_log(@"%@",touch);
    onTouchMove = YES;
}


- (void)removeShareView {
    if (_canBiBiCall) {
        [DialerUsageRecord recordCustomEvent:PATH_BIBI_CALL extraInfo:@{KEY_CALL:@(VALUE_CANCEL)}];
    }
    if (_freeCallButton) {
        [_freeCallButton removeFromSuperview];
    }
    [_timerTest invalidate];
    [self showOutAnimation:_callBoard];
    _hasClick = YES;
    [[CallCommercialManager instance] preCallADDisappearWithCloseType:ADCLOSE_BUTTON_CANCEL];
}


- (void) judgeOnClickFreeCallButton{
    if(_canBiBiCall) {
        [DialerUsageRecord recordCustomEvent:PATH_BIBI_CALL extraInfo:@{KEY_CALL:@(VALUE_FREE)}];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if ( granted ){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self startFreeCall];
                    });
                }else{
                    NSString *showString = nil;
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
                        showString = @"拨打通通宝电话需要访问您的麦克风，否则对方将无法听见您的声音。前往「设置-触宝电话」中允许";
                    }else{
                        showString = @"拨打通通宝电话需要访问您的麦克风，否则对方将无法听见您的声音。前往「设置-隐私-麦克风」中允许";
                    }
                    
                    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"麦克风被禁用" message:showString cancelTitle:@"取消" okTitle:@"立即设置" okButtonActionBlock:^(){
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                        }
                    }];
                }
            }];
        }
    } else {
        
        [self startFreeCall];
    }
}

- (void)startFreeCall {
  
    if ( _type == VOIP_LANDLINE ){
        zoneView = [[VoipLandlineAddZoneView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())
                                                       andNumber:self.conferenceList[0]];
        zoneView.delegate = self;
        [self.superview addSubview:zoneView];
        self.hidden = YES;
        return;
    }
    
    [self judgeOnClickFreeCallButtonThroughLandline];
}

- (void) judgeOnClickFreeCallButtonThroughLandline{
    ClientNetworkType status = [[Reachability shareReachability] networkStatus];
    if (status <= network_2g || (status == network_3g && [[[SmartDailerSettingModel settings] currentChinaCarrier] isEqual:@"China Mobile"])) {
        if (status == network_none) {
            [self alertNoNetwork];
        } else if ([UserDefaultsManager boolValueForKey:VOIP_BACK_CALL_ENABLE] && [UserDefaultsManager boolValueForKey:VOIP_AUTO_BACK_CALL_ENABLE defaultValue:YES]) {
            
            
            if ( _type == VOIP_PRE_17 && ![UserDefaultsManager boolValueForKey:VOIP_17_NUMBER_ALERT defaultValue:NO]){
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_17_NUMBER_ALERT];
                [self alert17Error];
            } else {
                [self onClickFreeCallButton];
            }
        } else {
            [self alertBadNetwork];
        }
    } else if ( _type == VOIP_PRE_17 && ![UserDefaultsManager boolValueForKey:VOIP_17_NUMBER_ALERT defaultValue:NO]){
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_17_NUMBER_ALERT];
        [self alert17Error];
    } else {
        [self onClickFreeCallButton];
    }
}

- (void)onClickFreeCallButton{
    [UserDefaultsManager setBoolValue:YES forKey:VOIP_HAD_CALL];
    if (_delegate!=nil && [_delegate respondsToSelector:@selector(onClickFreeCallButton:)]) {
        [_delegate onClickFreeCallButton:self.conferenceList];
    }
    [self removeFromSuperview];
    _hasClick = YES;
    [[CallCommercialManager instance] preCallADDisappearWithCloseType:ADCLOSE_BUTTON_FREE_CALL];
}

-(BOOL)checkIfVIPNull{
    NSInteger registerIntTime = [UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME defaultValue:0];
    BOOL ifVIP = [UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO];
    BOOL ifNextDay = [FunctionUtility judgeTimeAfterNatureDayWithID:CHECK_ID_VIP_NULL_DAY];
    if (registerIntTime>3 && !ifVIP && ifNextDay) {
        [UserDefaultsManager setBoolValue:YES forKey:VIP_NULL_DAY_SHOW];
        return  YES;
    }else{
        return NO;
    }
}

- (void)onClickNormalCallButton {
    if (_canBiBiCall) {
        [DialerUsageRecord recordCustomEvent:PATH_BIBI_CALL extraInfo:@{KEY_CALL:@(VALUE_NORMAL)}];
    }
    if (_delegate!=nil && [_delegate respondsToSelector:@selector(onClickNormalCallButton)]) {
        [_delegate onClickNormalCallButton];
    }
    [self removeFromSuperview];
    _hasClick = YES;
    [[CallCommercialManager instance] preCallADDisappearWithCloseType:ADCLOSE_BUTTON_NORMAL_CALL];
}
- (void)onTestClickFreeCallButton{
    [VOIPCall makeCall:NSLocalizedString(@"touchpal_test_number", @"触宝测试专线")];
    if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME].length==0) {
        [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION,UNREGESTER_CLICK_TESTFREECALL), nil];
    }else{
        [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION,REGESTER_CLICK_TESTFREECALL), nil];
    }
    [self removeFromSuperview];
    [(TPDVoipCallPopUpViewController *)self.delegate onClickCancelButton ];
    _hasClick = YES;
}

-(void)onTestClickNormalCallButton{
    _hasClick = YES;
    normalCallButton.userInteractionEnabled = NO;
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow makeToast:@"点我可不免费，去点上面那家伙~" duration:1.0f position:CSToastPositionBottom];
    [self performSelector:@selector(enableUseruserInteraction) withObject:nil afterDelay:1.2];
}
-(void)enableUseruserInteraction{
    normalCallButton.userInteractionEnabled =YES;
}

- (void) doWhenNetworkChanged {
    ClientNetworkType status = [Reachability network];
    if ( status == network_wifi) {
        _networkBoardCallButton.enabled = YES;
    }
}

- (void)alert17Error{
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_call_17_number_alert", "")
                                              message:nil
                                          cancelTitle:nil
                                              okTitle:@"继续"
                                  okButtonActionBlock:^(){
                                      [self onClickFreeCallButton];
                                  }
                                    cancelActionBlock:^(){
                                        [self.delegate onClickCancelButton];
                                    }];
    
    
}

- (void)alertBadNetwork {
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_bad_network_use_wifi", "")
                                              message:nil
                                          cancelTitle:nil
                                              okTitle:@"我知道了"
                                  okButtonActionBlock:nil
                                    cancelActionBlock:nil];
    [self.delegate onClickCancelButton];
}

- (void)alertNoNetwork {
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_no_network_use_wifi", "")
                                              message:nil
                                          cancelTitle:nil
                                              okTitle:@"我知道了"
                                  okButtonActionBlock:nil
                                    cancelActionBlock:nil];
    [self.delegate onClickCancelButton];
}

- (void)showTickerToCall {
    if (_timer) {
        [_timer invalidate];
    }
    _tick = 3;
    [self showTicker:_tick];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calculateTicker) userInfo:nil repeats:YES];
}

- (void)calculateTicker {
    _tick --;
    if (_tick <= 0) {
        [_timer invalidate];
        _timer = nil;
        if (!_hasClick) {
            if (_delegate!=nil && [_delegate respondsToSelector:@selector(onClickNormalCallButton)]) {
                [_delegate onClickNormalCallButton];
            }
            [self removeFromSuperview];
            _hasClick = YES;
        }
    } else {
        [self showTicker:_tick];
    }
}

- (void)showTicker:(int)tick {
    if (_tickerLabel == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, normalCallButton.frame.size.width, normalCallButton.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        [normalCallButton addSubview:label];
        _tickerLabel = label;
    }
    NSString *ticker = nil;
    NSString *format = nil;
    if (tick < 0) {
        ticker = @"";
        format = @"%@%@";
    } else {
        ticker = [NSString stringWithFormat:@"%d秒后自动拨出", tick];
        format = @"%@\n%@";
    }
    NSString *text = [NSString stringWithFormat:format, @"普通电话", ticker];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    UIColor *color = [UIColor colorWithRed:COLOR_IN_256(0x33) green:COLOR_IN_256(0x33) blue:COLOR_IN_256(0x33) alpha:1];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : color} range:[text rangeOfString:ticker]];
    _tickerLabel.attributedText = attrString;
}

#pragma mark VoipLandlineAddZoneViewDelegate
- (void)sureButtonAction:(NSString *)number{
    self.conferenceList[0] = number;
    [self judgeOnClickFreeCallButtonThroughLandline];
    [zoneView removeFromSuperview];
}

- (void)cancelButtonAction{
    [zoneView removeFromSuperview];
    [self removeFromSuperview];
}

-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    FreeDialSettingViewController *vc = [[FreeDialSettingViewController alloc] init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
    [self removeShareView];
}

- (void)removeWebController {
    if (webController != nil) {
        [(UIWebView *)webController.commonWebView.web_view stopLoading];
        [webController.view removeFromSuperview];
        webController = nil;
    }
}

#pragma mark ad view
- (UIView *) getWebADView {
    NSString *tu = kAD_TU_CALL_POPUP_HTML;
    id fileName = [[CallCommercialManager instance] getCommercialForTu:tu];
    cootek_log(@"ad_pu, getWebADView, fileName: %@", fileName);
    cootek_log(@"PrepareThread show webview .....%@",tu);
    PrepareAdItem *prepare = [[PrepareAdManager instance] getPrepareAdItem:tu];
    [[AdStatManager instance] commitCommericalStat:tu pst:prepare.uuid st:nil];
    BOOL usePrepare = YES;
    NSString *filePath = [[VoipUtils absoluteCommercialDirectoryPath:ADResource] stringByAppendingPathComponent:(NSString *)fileName];
    NSString *url = nil;
    if (usePrepare) {
        if (prepare) {
            filePath = prepare.fullHtmlPath;
            url =  [filePath stringByAppendingFormat:@"?tu=%@&pst=%@",tu,prepare.uuid];
            [[PrepareAdManager instance] didShowPrepareAd:tu];
        } else {
            cootek_log(@"PrepareThread show webview fialed .....%@",tu);
            return nil;
        }
    }
    [self removeWebController];
    webController = [[HandlerWebViewController alloc] init];
    cootek_log(@"PrepareThread show webview .....%@,%@",tu,url);
    webController.webViewFullScreen = YES;
    webController.webViewCanNotScroll = YES;
    webController.url_string = url;
    
    CGFloat adViewHeight = TPScreenHeight();
    if ([FunctionUtility systemVersionFloat] < 7.0) {
        adViewHeight -= 20;
    }
    if (_callBoard != nil) {
        adViewHeight -= _callBoard.frame.size.height;
    }

    if (_callBoard.image==nil) {
        if (titleLabel != nil) {
            adViewHeight += titleLabel.frame.origin.y;
        } else if (settingLabel != nil) {
            adViewHeight += settingLabel.frame.origin.y;
        }
    }
    CGRect adViewFrame = CGRectMake(0, 0, TPScreenWidth(), adViewHeight);
    
    webController.view.frame = adViewFrame;
    webController.commonWebView.frame = adViewFrame;
    webController.commonWebView.web_view.frame = adViewFrame;
    webController.view.alpha = 0;
    
    return webController.view;
}

#pragma mark - View life cycle
- (void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        // this view will be removed from the super view.
        BOOL toDelete = (_adView != nil);
        cootek_log(@"ad_pu, VoipCallPopUpView, willMoveToSuperview, to delete: %d", toDelete);
        [[CallCommercialManager instance] removeCommercialForTu:kAD_TU_CALL_POPUP_HTML shouldDeleteFile:toDelete];
    }
}

@end
