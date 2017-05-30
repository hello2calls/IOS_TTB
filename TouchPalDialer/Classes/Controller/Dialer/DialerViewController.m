//
//  DialerViewController.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/20/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "DialerViewController.h"
// view
#import "CallAndDeleteBar.h"
#import "NumberKey.h"
#import "SpecialKey.h"
#import "CallLogDataModel.h"
#import "DialResultModel.h"
#import "CallLogCell.h"
#import "SearchResultCell.h"
#import "KeypadView.h"
#import "UIView+WithSkin.h"
#import "HighlightTip.h"
#import "YellowPageGuideView.h"
#import "CooTekPopUpSheet.h"
//data
#import "Person.h"
#import "CallLog.h"
#import "PhonePadModel.h"
#import "SyncContactWhenAppEnterForground.h"
#import "NumberPersonMappingModel.h"
#import "PhoneNumber.h"
#import "FunctionUtility.h"
#import "CallLog.h"
#import "AppSettingsModel.h"
#import "TPDialerResourceManager.h"
#import "SmartGroupNode.h"
#import "CallerIDModel.h"
#import "UserDefaultsManager.h"
//delegate
#import "TouchPalDialerAppDelegate.h"
#import "CootekSystemService.h"
//consts
#import "CootekNotifications.h"
#import "CootekNotifications.h"
#import "ImageCacheModel.h"
#import "TipsView.h"
#import "GestureUnRecognizerBar.h"
#import "UITableView+TP.h"
#import "JBCallLogCell.h"
#import "SkinHandler.h"
#import "GestureUtility.h"
#import "UITableView+TP.h"
#import "DefaultUIAlertViewHandler.h"
#import "TPABPersonActionController.h"
#import "TPMFMessageActionController.h"
#import "SmartDailerSettingModel.h"
#import "ScheduleTaskManager.h"
#import "InputNumberPasteUtility.h"
#import "UIButton+DoneButton.h"
#import "SettingsModelCreator.h"
#import "GestureSettingsViewController.h"
#import "SmartDailViewController.h"
#import "SkinSettingViewController.h"
#import "PullDownSheet.h"
#import "RootScrollViewController.h"
#import "Favorites.h"
#import "NoahManager.h"
#import "NoahToolBarView.h"
#import "PersonalCenterController.h"
#import "FreeCallLoginController.h"

#import "NotificationAlertManger.h"
#import "CommonLoginViewController.h"
#import "DialerUsageRecord.h"
#import "HandlerWebViewController.h"
#import "PublicNumberCenterView.h"

#import "DialerGuideAnimationManager.h"
#import "YellowPageMainQueue.h"

#import "DialerGuideAnimationUtil.h"
#import "TouchPalDialerLaunch.h"

#import "CommonTipsWithBolckView.h"
#import "TPDialerResourceManager.h"
#import "NSString+Color.h"
#import "AntiharassmentViewController.h"

#import "NSString+PhoneNumber.h"
#import "AddressBookAccessUtility.h"
#import "MarketLoginController.h"
#import "TouchPalVersionInfo.h"
#import "TPDialerResourceManager.h"
#import "SeattleFeatureExecutor.h"
#import "PublicNumberProvider.h"
#import "TPCallActionController.h"
#import "FunctionUtility.h"
#import "CommonTipsWithBolckView.h"
#import "SeattleFeatureExecutor.h"
#import "VoipUtils.h"
#import "FileUtils.h"
#import "TPHeaderButton.h"
#import "AnimateVerticalTextView.h"
#import "SectionGroup.h"
#import "SectionAnnouncement.h"
#import "FindNewsListViewController.h"
#import "TPAdControlRequestParams.h"
#import "IndexConstant.h"
#import "TPPerformanceRecorder.h"

#import "NewFeatureGuideManager.h"
#import "CommercialSkinManager.h"
#import "VerticallyAlignedLabel.h"
#import "YPFeedsTask.h"
#import "FeedsSigninManager.h"
#import "ImageUtils.h"

#import <Masonry.h>
#import "CallCommercialManager.h"
#import "HangupCommercialManager.h"
#import "TPDLib.h"

#import "AdStatManager.h"

//WebSearch
#define TYPE_CELL_HEIGHT 30
#define SUPER_DIAL 0
#define CALL_LOG_TYPE 1

#define INVITATION_Url_String @"http://dialer-cdn.cootekservice.com/dialer/free-call/international/oversea_main/index.html"

#define KEYPAD_ANIMATIONVIEW_DURATION 0.5

@interface DialPadADView : UIView
@property (nonatomic) CGPoint p1;
@property (nonatomic) CGPoint p2;
@property (nonatomic) BOOL allValid;
@property (nonatomic) BOOL displayedInOneSession;
@property (nonatomic,strong) NSDictionary* result;
//@property (nonatomic,strong) UIView* debugView;
@property (nonatomic,strong) HandlerWebViewController *webController;
- (void) refresh;
@end

@implementation DialPadADView

-(instancetype)init{
    self = [super init];
    if (self) {
        WEAK(self)
        
        self.allValid = NO;
        self.p1 = CGPointZero;
        self.p2 = CGPointZero;
        self.displayedInOneSession = NO;
        self.result = nil;

        self.webController = [[HandlerWebViewController alloc] init];
        
        self.webController.webViewFullScreen = YES;
        self.webController.webViewCanNotScroll = YES;
        
        [self addSubview:self.webController.commonWebView.web_view];
        [self.webController.commonWebView.web_view makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        NSString* uuid = [[AdStatManager instance] genenrateUUID];
        SET_VALUE_IN_DEFAULT(uuid, @"NumPadADUUID")
        

        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"setAllUseful" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            weakself.allValid = [note.object[@"enable"] boolValue];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"setUsefulArea" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSDictionary* d = note.object;
            weakself.p1 = CGPointMake([d[@"p1x"] integerValue], [d[@"p1y"] integerValue]);
            weakself.p2 = CGPointMake([d[@"p2x"] integerValue], [d[@"p2y"] integerValue]);

        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"closeWebViewAd" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            SET_VALUE_IN_DEFAULT([NSDate date], @"closeWebViewAdTimestamp")
            
            
        }];
                
    }
    return self;
}
        
        
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSLog(@"x:%lf, y: %lf",point.x,point.y);
    
    
    UIView* hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView != nil) {
        if (self.allValid ||
            (point.x < self.p2.x  && point.x > self.p1.x
             && point.y < self.p2.y && point.y > self.p1.y)) {
            return hitTestView;
        }
    }
    return nil;
}


- (void) refresh {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        @synchronized (self) {
            if (!self.result) {
                [UserDefaultsManager removeObjectForKey:ad_now_resource_arr];
                NSDictionary *settings1 = @{
                                            @"at": @"IMG",
                                            @"tu": kAD_TU_NUMPAD_HTML,
                                            @"w": @"640",
                                            @"h": @"100",
                                            @"ck":VALUE_IN_DEFAULT(@"NumPadADUUID")
                                            };
                self.result = [[HangupCommercialManager instance] asyncCommercialAd:kAD_TU_NUMPAD_HTML param:settings1];
            }
        }
        
        
        
//        NSDictionary* result = @{};
        if (self.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *filePath = [[VoipUtils absoluteCommercialDirectoryPath:ADResource] stringByAppendingPathComponent:ADNumPadHTML];
                NSDate* closeDate = VALUE_IN_DEFAULT(@"closeWebViewAdTimestamp");
                if (![FileUtils fileExistAtAbsolutePath:filePath]){
                    // 拉资源失败, 不加载网页，穿透
                    self.allValid = NO;
                    self.p1 = CGPointZero;
                    self.p2 = CGPointZero;
                    return;
                }else if(closeDate != nil){
                   if([[NSDate date] timeIntervalSinceDate:closeDate] < 3600*24) {
                    // 用户关闭过，不加载网页，穿透
                       self.allValid = NO;
                       self.p1 = CGPointZero;
                       self.p2 = CGPointZero;
                       return;
                   }else{
                       // 关闭超过24小时，重新开启广告
                       RESET_VALUE_IN_DEFAULT(@"closeWebViewAdTimestamp")
                       self.allValid = NO;
                   }
                }
                
                if (!self.displayedInOneSession) {
                    // 在应用的一次启动周期内，只执行一次
                    // 如果用户点了叉，又过了24小时                    
                    [self.webController reloadUrl:[filePath stringByAppendingFormat:@"?tu=40&st=%@",VALUE_IN_DEFAULT(@"NumPadADUUID")]];
                    self.displayedInOneSession = YES;
                }

            });
        }else{
            // 拉取云信息失败，不加载网页，穿透
            self.allValid = NO;
            self.p1 = CGPointZero;
            self.p2 = CGPointZero;
        }
        

    });
    
    
}

@end

@interface DialerViewController()<UIGestureRecognizerDelegate, NoahToolBarViewDelegate, AnimateVerticalTextViewDelegate>{
    LongGestureOperationView *longGestureOperationView;
    KeypadView *T9_phonePad;
    KeypadView *qwerty_phonePad;
    UIViewController *topViewController;
    UILongPressGestureRecognizer *longPressReger;

    CalllogFilterBar *filterBar;
    CalllogFilterType filterType;

    DailerKeyBoardType preChangedKeyBoardType;
    int filterHeight;
    BOOL hasInitialDataSearch_;
    BOOL old_phone_pad_state;
    BOOL isGestureCall_;
    BOOL in_multiSelect_mode;
    BOOL isShowLogsTypes_;
    NoahToolBarView *noahToolBar;
    NSArray *extensionToastArray;
    BOOL _firstActive;
    BOOL _isAppActive;
    BOOL _notFirstShow;
    BOOL _firstInViewDidLoad;
    CGRect _phonePadFrame;
    UIView *_rippleContainer;
    UIView *_rippleToolTipView;
    UIDialerSearchHintView *_newInstallHintView;
    UIImageView *_keyPadAnimaView;
    
    AnimateVerticalTextView *toutiaoAnimationview;
    // for statistics
    BOOL _isAppearedDuringLaunch;
    BOOL isSelectedTab;
}

@property(nonatomic, retain) TPHeaderButton *doneButton;
@property(nonatomic, retain) TPHeaderButton *editButton;
@property(nonatomic, retain) NSString *cellIdentifier;
@property(nonatomic, retain) NSIndexPath *selectCell;
@property(nonatomic, retain) UIView *scrollTipsView;
@property(nonatomic, retain) UIView *favTipsView;
@property(nonatomic, retain) BaseContactCell *longModeCell;
@property(nonatomic, retain) PublicNumberCenterView* pnCenter;
@property(nonatomic, retain) UIButton *updateTagView;
@property(nonatomic, retain) CommonTipsWithBolckView *tipe;
@property(nonatomic, retain) UIView *internationalInviteBgView;
@property(nonatomic, retain) VerticallyAlignedLabel* feedsView;
//@property(nonatomic, retain) NewerWizard *newerWizard;

@property(nonatomic, strong) DialPadADView *adView;
//@property(nonatomic, retain) RootScrollViewController *parent;
@property (nonatomic,weak) UIView *dbUpdateView;

@end

@implementation DialerViewController
@synthesize shared_phonepadmodel;
@synthesize contactlist_view;
@synthesize phonepad_view;
@synthesize callLogType_view;
@synthesize phone_number_label;
@synthesize header_title;
@synthesize clearall_button;
@synthesize search_result_viewcontroller;
@synthesize headerView;
@synthesize hintView;
@synthesize parent;
@synthesize tableViewName;
@synthesize keyName;
@synthesize currentCellName;
@synthesize longGestureController = longGestureController_;
@synthesize scrollTipsView;
@synthesize favTipsView;
@synthesize pnCenter;
@synthesize callDeleteBar;
@synthesize feedsView;

- (void)loadView
{
    cootek_log(@" loadView Dailer***********");
    _isAppActive = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(TPScreenWidth(), 0, TPScreenWidth(),TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff())];
	self.view = rootView;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[rootView setSkinStyleWithHost:self forStyle:@"defaultBackground_color"];

    // HeaderBar
	HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
	[self.view addSubview:headerBar];
	self.headerView = headerBar;

    // NumberInputView
	PhoneNumberInputView *numberInputView = [[PhoneNumberInputView alloc] initWithFrame:CGRectMake((TPScreenWidth()-180)/2, TPHeaderBarHeightDiff(), 180, 45)];
    [numberInputView setSkinStyleWithHost:self forStyle: @"PhoneNumberInputView_style"];
	[headerView addSubview:numberInputView];
	[headerView bringSubviewToFront:numberInputView];
	numberInputView.hidden = YES;
	self.phone_number_label = numberInputView;
    numberInputView.delegate = self;
    
    pnCenter = [[PublicNumberCenterView alloc]initWithFrame:CGRectMake(TPScreenWidth() - 45 - 50, TPHeaderBarHeightDiff(), 40, 45)];
    [self.headerView addSubview:pnCenter];

    //clear button
    TPHeaderButton *tmpClear= [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(TPScreenWidth()-50, 0,50, 45)];
    [tmpClear setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [tmpClear setTitle:NSLocalizedString(@"Clear", @"") forState:UIControlStateNormal];
    [tmpClear.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_3]];
    [tmpClear addTarget:self action:@selector(clearAllCallLog) forControlEvents:UIControlEventTouchUpInside];
    tmpClear.hidden = YES;
    [headerView addSubview:tmpClear];
    self.clearall_button = tmpClear;

    //edit button
    TPHeaderButton *tmpEdit = [[TPHeaderButton alloc] initWithFrame:CGRectMake(0, 0, 50, 45)];
    [tmpEdit setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [tmpEdit setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    tmpEdit.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    [tmpEdit addTarget:self action:@selector(editCallLog) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:tmpEdit];
    self.editButton = tmpEdit;

    //done button
    TPHeaderButton *tmpDoneBtn = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [tmpDoneBtn setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    [tmpDoneBtn setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [tmpDoneBtn.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_3]];
    [tmpDoneBtn addTarget:self action:@selector(editCallLog) forControlEvents:UIControlEventTouchUpInside];
    tmpDoneBtn.hidden = YES;
    [headerView addSubview:tmpDoneBtn];
    self.doneButton = tmpDoneBtn;

    // for showlogs type
    self.shared_phonepadmodel = [PhonePadModel getSharedPhonePadModel];
    isShowLogsTypes_  = NO;
    [self changeShowlogsStyle];

	// list view
	UITableView *tmp_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(367)) style:UITableViewStylePlain];
    [tmp_tableview setExtraCellLineHidden];
    [tmp_tableview setSkinStyleWithHost:self forStyle:@"UITableView_withBackground_style"];


	self.contactlist_view = tmp_tableview;
	contactlist_view.delegate = self;
	contactlist_view.dataSource = self;
    contactlist_view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self hideUpdateViewIfNeed];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideUpdateViewIfNeed) name:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNoahToast) name:ANTIHARASS_UPDATE_SUCCESS_NOTICE  object:nil];
    
	[self.view addSubview:contactlist_view];

    DialerSearchResultViewController *tmp_controller = [[DialerSearchResultViewController alloc] init];
    tmp_controller.delegate = self;
	self.search_result_viewcontroller = tmp_controller;
	search_result_viewcontroller.view.hidden = YES;
	[self.view addSubview:search_result_viewcontroller.view];

    _phonePadFrame = [self calculatePhonePadFrame];
    
    self.adView = [[DialPadADView alloc] init];
    
    self.phonepad_view = [[UIView alloc] initWithFrame:_phonePadFrame];
    self.phonepad_view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    T9_phonePad = [[KeypadView alloc] initWithFrame:self.phonepad_view.bounds
                                      andKeyPadType:T9KeyBoardType
                                        andDelegate:self];
    qwerty_phonePad = [[KeypadView alloc] initWithFrame:self.phonepad_view.bounds
                                          andKeyPadType:QWERTYBoardType
                                            andDelegate:self];
    [self.phonepad_view addSubview:T9_phonePad];
    [self.phonepad_view addSubview:qwerty_phonePad];

    [self.view addSubview:self.phonepad_view];
    [self.view addSubview:self.adView];
    
    [self.adView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.phonepad_view.top);
        make.height.equalTo(100);
    }];
    
    int defaultKeyboardType = [UserDefaultsManager intValueForKey:KEYBOARD_TYPE_RESTORE defaultValue:T9KeyBoardType];
    [self loadPhonePad:defaultKeyboardType];
    
    old_phone_pad_state = [UserDefaultsManager boolValueForKey:PHONE_PAD_IS_VISIBLE defaultValue:YES];
    if ([self shouldShowRippleAnimation]) {
        old_phone_pad_state = NO; // set phonepad to be hidden
        
    }
    [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
    phonepad_view.hidden = !old_phone_pad_state;
    
    if (phonepad_view.hidden) {
        [FunctionUtility setY:(TPScreenHeight() - self.parent.tabBar.frame.size.height) forView:phonepad_view];
        self.adView.hidden = YES;
    }else{
        self.adView.hidden = NO;
        [self.adView refresh];
    }

    CGFloat  Y = parent.view.frame.size.height - TAB_BAR_HEIGHT;
    if ([UIDevice currentDevice].systemVersion.floatValue<7.0) {
        Y = Y - 20;
    }
    callDeleteBar = [[CallAndDeleteBar alloc] initCallAndDeleteBarWithFrame:CGRectMake(0, Y, TPScreenWidth(), TAB_BAR_HEIGHT)];
	callDeleteBar.m_delegate = self;
    //callDeleteBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	callDeleteBar.hidden = YES;
    [parent.view addSubview:callDeleteBar];

    //gesture unreg bar
    CGFloat gestureBarY = CGRectGetMaxY(parent.view.frame) - TAB_BAR_HEIGHT;
    GestureUnRecognizerBar *gestureBar = [[GestureUnRecognizerBar alloc]
                                          initWithFrame:CGRectMake(0, gestureBarY, TPScreenWidth(), TAB_BAR_HEIGHT)];
    gestureBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [gestureBar setSkinStyleWithHost:parent forStyle:@"dialerView_gestureUnRecognizerBar_style"];
    [parent.view addSubview:gestureBar];
    cootek_log(@"end loadView Dailer***********");
    _keyPadAnimaView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _keyPadAnimaView.backgroundColor = [UIColor clearColor];
    [self.phonepad_view addSubview:_keyPadAnimaView];
    
    
    toutiaoAnimationview = [[AnimateVerticalTextView alloc] initWithFrame:CGRectMake(TPScreenWidth() - 47, TPHeaderBarHeightDiff() + 11,  36, 24)];
    toutiaoAnimationview.delegate = self;
    [toutiaoAnimationview animation];
    [headerView addSubview:toutiaoAnimationview];
    
    feedsView = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(TPScreenWidth() - 22, TPHeaderBarHeightDiff() + 5, 20, 12)];
    feedsView.layer.cornerRadius = 6;
    feedsView.backgroundColor = [ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil];
    feedsView.textColor = [UIColor whiteColor];
    feedsView.font = [UIFont systemFontOfSize:7.0f];
    feedsView.text = @"签到";
    feedsView.textAlignment= NSTextAlignmentCenter;
    feedsView.verticalAlignment = VerticalAlignmentMiddle;
    feedsView.layer.masksToBounds = YES;
    feedsView.hidden = YES;
    
    [headerView addSubview:feedsView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndex:) name:select_index_in_root_bar object:nil];
    
//    [self hidePhonePadView];
}


- (void) selectIndex:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSNumber* index = [userInfo objectForKey:@"index"];
    cootek_log(@"%D", index.integerValue);
    if (index.integerValue != 1) {
        isSelectedTab = NO;
        [toutiaoAnimationview stop];
    } else {
        if (!isSelectedTab) {
            feedsView.hidden = YES;
            [toutiaoAnimationview start];
            isSelectedTab = YES;
        }
        
    }
}

- (void)gyChangeTextView:(AnimateVerticalTextView *)textView didTapedAtIndex:(NSInteger)index
{
    [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_CLICK_FROM_DIALER];
    FindNewsListViewController* controller = [[FindNewsListViewController alloc] init];
    controller.tu = [NSString stringWithFormat:@"%d", DSP_FEEDS_DIALER];
    [TouchPalDialerAppDelegate pushViewController:controller animated:YES];
}

- (void) animationDone
{
    if ([FeedsSigninManager shouldShowSignin]) {
        feedsView.hidden = NO;
        feedsView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.3f animations:^{
            feedsView.transform = CGAffineTransformMakeScale( 1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05f animations:^{
                feedsView.transform = CGAffineTransformMakeScale( 1, 1);
            }];
        }];
    }
  
}

- (void) showToutiao
{
    toutiaoAnimationview.hidden = NO;
    feedsView.hidden = ![FeedsSigninManager shouldShowSignin];
}

- (void) hideToutiao
{
    toutiaoAnimationview.hidden = YES;
     feedsView.hidden = YES;
}


-(UIView *)loadUpdateView{
    
    _updateTagView =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 52)];
    [_updateTagView addTarget:self action:@selector(tapToUpdateAntiharassVC) forControlEvents:(UIControlEventTouchUpInside)];

    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 20, 20)];
    lable1.font = [UIFont fontWithName:@"iPhoneIcon3" size:20];
    lable1.text = @"5";
    lable1.userInteractionEnabled= NO;
    lable1.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_400"];
    [_updateTagView addSubview:lable1];
    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable1.backgroundColor = [UIColor clearColor];
    }

    UILabel *lable2 =[[UILabel alloc] initWithFrame:CGRectMake(35, 8, TPScreenWidth()-100, 20)];
    lable2.text = [[NSString stringWithFormat:@"新版骚扰号码库识别率提升%d",[(NSString *)[UserDefaultsManager objectForKey:ANTIHARASS_REMOTE_VERSION] intValue]%26+10] stringByAppendingString:@"%"];
    lable2.userInteractionEnabled= NO;
    lable2.textColor=[TPDialerResourceManager
                getColorForStyle:@"tp_color_black_transparency_800"];
    lable2.font =[UIFont systemFontOfSize:14];
    [_updateTagView addSubview:lable2];

    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable2.backgroundColor = [UIColor clearColor];
    }

    UILabel *lable3 =[[UILabel alloc] initWithFrame:CGRectMake(35, CGRectGetMaxY(lable2.frame), TPScreenWidth()-100, 18)];
    lable3.text = @"快来更新吧！";
    lable3.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
    lable3.font =[UIFont systemFontOfSize:12];
    lable3.userInteractionEnabled= NO;
    [_updateTagView addSubview:lable3];

    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable3.backgroundColor = [UIColor clearColor];
    }
    UILabel *lable4 =[[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth()-33, 8, 28, 28)];
    lable4.font =[UIFont fontWithName:@"iPhoneIcon2" size:18];
    lable4.text = @"t";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideUpdateView)];
    lable4.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_600"];
    [lable4 addGestureRecognizer:tapGesture];
    lable4.userInteractionEnabled = YES;
    [_updateTagView addSubview:lable4];
    if ( [[UIDevice currentDevice].systemVersion intValue] < 7){
        lable4.backgroundColor = [UIColor clearColor];
    }

    _updateTagView.backgroundColor =[@"0xe5f4ff" color];
    return _updateTagView;
}



-(void)hideUpdateView{
    [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_APP, @(4)), nil];
    [UserDefaultsManager setObject:[UserDefaultsManager stringForKey:ANTIHARASS_REMOTE_VERSION] forKey:ANTIHARASS_HIDE_UPDATE_WITH_VERSION];
    contactlist_view.tableHeaderView= nil;
}

-(void)hideUpdateViewIfNeed{
    
    if (![AddressBookAccessUtility isAccessible]) {
         contactlist_view.tableHeaderView= nil;
        return;
    }
    
    if([UserDefaultsManager boolValueForKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW]&&[UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON] && ![UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON  defaultValue:YES] && ![[UserDefaultsManager stringForKey:ANTIHARASS_HIDE_UPDATE_WITH_VERSION]isEqualToString:[UserDefaultsManager stringForKey:ANTIHARASS_REMOTE_VERSION]]){
        [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_APP, @(0)), nil];
        contactlist_view.tableHeaderView =[self loadUpdateView];
    }
    else{
        contactlist_view.tableHeaderView= nil;
    }
}

-(void)tapToUpdateAntiharassVC{
     [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_APP, @(1)), nil];
    [self hideUpdateView];
    CommonTipsWithBolckView *tips = [[CommonTipsWithBolckView alloc]initWithtitleString:nil lable1String:NSLocalizedString(@"It may take a little time to update the Update Now", "")  lable1textAlignment:1 lable2String:nil lable2textAlignment:0 leftString:@"暂不更新" rightString:@"立即更新" rightBlock:^{
        AntiharassmentViewController *con = [[AntiharassmentViewController alloc]init];
        PersonalCenterController *PersonalCenter = [[PersonalCenterController alloc] init];
        NSMutableArray *array = [[TouchPalDialerAppDelegate naviController].viewControllers mutableCopy];
        [array addObjectsFromArray:@[PersonalCenter,con]];
        [[TouchPalDialerAppDelegate naviController] setViewControllers:array animated:YES];
        [con updateAntiharassVersionInDialerVC];
        [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_APP, @(2)), nil];} leftBlock:nil];
    [DialogUtil showDialogWithContentView:tips inRootView:nil];
}

- (void)scrollTipsDisappear {
    for (UIPanGestureRecognizer *pangesture in [scrollTipsView gestureRecognizers]) {
        [scrollTipsView removeGestureRecognizer:pangesture];
    }
    for (UITapGestureRecognizer *tapgesture in [scrollTipsView gestureRecognizers]) {
        [scrollTipsView removeGestureRecognizer:tapgesture];
    }
    [scrollTipsView removeFromSuperview];
    scrollTipsView = nil;
    [UserDefaultsManager setBoolValue:YES forKey:@"scrollTipsView"];

    if (![UserDefaultsManager boolValueForKey: @"favTipsView" defaultValue: NO] && [[Favorites getFavoriteList] count] > 0) {
        UINavigationController *navController =
        ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
        UIViewController *rootVC = navController.viewControllers[0];
        favTipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
        favTipsView.backgroundColor = [UIColor clearColor];
        [rootVC.view addSubview:favTipsView];

        UIButton *image = [[UIButton alloc] initWithFrame:CGRectMake(5, TPScreenHeight()-40-70, 165, 70)];
        [image setBackgroundImage:[[TPDialerResourceManager sharedManager] getImageByName:@"tab_tip_fav_bg@2x.png"] forState:UIControlStateNormal];
        image.userInteractionEnabled = NO;
        [image setTitleEdgeInsets:UIEdgeInsetsMake(20, 0,30, 0)];
        image.titleLabel.font = [UIFont systemFontOfSize:16];
        [image setTitle:NSLocalizedString(@"fav tips",@"") forState:UIControlStateNormal];
        [image setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [favTipsView addSubview:image];

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(favTipsDisappear)];
        [favTipsView addGestureRecognizer:panGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favTipsDisappear)];
        [favTipsView addGestureRecognizer:tapGesture];
    }
}

- (void)favTipsDisappear {
    for (UIPanGestureRecognizer *pangesture in [favTipsView gestureRecognizers]) {
        [favTipsView removeGestureRecognizer:pangesture];
    }
    for (UITapGestureRecognizer *tapgesture in [favTipsView gestureRecognizers]) {
        [favTipsView removeGestureRecognizer:tapgesture];
    }
    [favTipsView removeFromSuperview];
    favTipsView = nil;
    [UserDefaultsManager setBoolValue:YES forKey:@"favTipsView"];
}

- (void) setType
{
    old_phone_pad_state = [shared_phonepadmodel phonepad_show];
    [shared_phonepadmodel setPhonePadShowingState:NO];
    UIActionSheet* actionSheet =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                  destructiveButtonTitle:nil
                       otherButtonTitles:NSLocalizedString(@"All_logs", @""),
     NSLocalizedString(@"Missed_logs", @""),
     NSLocalizedString(@"Outgoing_logs", @""),
     NSLocalizedString(@"Incoming_logs", @""),
     NSLocalizedString(@"Unknown_logs", @""),nil];
    actionSheet.tag = CALL_LOG_TYPE;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
    [tipForSuperDial_ removeTip];
    if (actionSheet.tag == CALL_LOG_TYPE) {
        switch (buttonIndex) {
            case 0:
                [self onClickFilter:AllCallLogFilter];
                break;
            case 1:
                [self onClickFilter:MissedCalllogFilter];
                break;
            case 2:
                [self onClickFilter:OutgoingFilter];
                break;
            case 3:
                [self onClickFilter:IncomingFilter];
                break;
            case 4:
                [self onClickFilter:UnknowCallLogFilter];
            default:
                break;
        }
    }
}


- (CGRect)calculatePhonePadFrame
{
    NSDictionary *dict = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"KeyPadBgViewT9_style"];
    NSString *bgImageName = [dict objectForKey:BACK_GROUND_IMAGE];
    UIImage *bgImage = nil;
    if (bgImageName) {
        bgImage = [TPDialerResourceManager getImage:bgImageName];
    }
    CGFloat keyPadHeight = TPKeypadHeight();
    if (bgImage) {
        keyPadHeight = TPScreenWidth() / bgImage.size.width * bgImage.size.height;
    }
    CGFloat originY = TPAppFrameHeight()-TAB_BAR_HEIGHT- keyPadHeight +TPHeaderBarHeightDiff();
    return CGRectMake(0, originY, TPScreenWidth(), keyPadHeight);
}

-(void) onInitialDataSearch
{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(onInitialDataSearch) withObject:nil waitUntilDone:YES];
        return;
    }
    @autoreleasepool {
        hasInitialDataSearch_ = YES;
        [self doWhenContactChanged];
    }
}

-(void) onInitialDataCompleted
{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(onInitialDataCompleted) withObject:nil waitUntilDone:YES];
        return;
    }
    [self updateEditButtonVisibility];

    self.cellIdentifier = [NSString stringWithFormat:@"%d",((NSInteger)arc4random())];
    
    CGRect hintFrame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight() - TAB_BAR_HEIGHT - TPHeaderBarHeight());
    UIDialerSearchHintView *hint = [[UIDialerSearchHintView alloc] initWithFrame:hintFrame];
    BOOL isNewInstall = [UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE defaultValue:nil] == nil;
    if (isNewInstall) {
        BOOL checked = [UserDefaultsManager boolValueForKey:NEW_INSTALL_FOR_EMPTY_CALLLOG_CHECKED defaultValue:NO];
        if (!checked) {
            _newInstallHintView = [[UIDialerSearchHintView alloc] initWhenNewInstallWithFrame:hintFrame];
            [hint addSubview:_newInstallHintView];
        }
    }
    self.hintView = hint;
    [self hideHintView:YES];
    [self.contactlist_view addSubview:hint];
    if (self.phonepad_view) {
            [self.contactlist_view insertSubview:self.hintView belowSubview:self.phonepad_view];
    }
    //ADD A SCHEDULE TASK
    [[ScheduleTaskManager scheduleManager] addScheduleTask:[UsageCheckScheduleTask task]];
    [[ScheduleTaskManager scheduleManager] addScheduleTask:[ServerNumberCheckScheduleTask task]];
}

- (void)viewDidLoad
{
	cootek_log(@"dialer view view did load.");
    [super viewDidLoad];

    longGestureController_ = [[LongGestureController alloc] initWithViewController:((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController
                                                                         tableView:contactlist_view
                                                                          delegate:self
                                                                     supportedType:LongGestureSupportedTypeDialer];

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    recognizer.delegate = self;
    [contactlist_view addGestureRecognizer:recognizer];


    RootScrollViewController *ctl = [((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers objectAtIndex:0];
    ctl.dialViewController = self;

    BOOL isDataReady = [TouchPalDialerLaunch getInstance].isDataInitialized;
    if (isDataReady) {
        [self onInitialDataSearch];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitialDataSearch) name:N_INITIAL_DATA_COMPLETED object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiSettiingsItemChanged:) name:N_SETTINGS_ITEM_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotiBecomeActive) name:N_APPLICATION_BECOME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelCall) name:N_CANCEL_CALL_CLICK object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phonepad_show) name:N_PHONE_PAD_SHOW object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phonepad_hide) name:N_PHONE_PAD_HIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateYPRedHint) name:N_PUBLIC_NUMBER_UPDATE object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenInputChanged:) name:N_CALL_LOG_LIST_CHANGED object:nil];

    /*Don't need to observe these two notifications due to these two method can be called when input changed. Modified by Hugh 2014-11-28*/
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenInputEmpty) name:N_DIALER_INPUT_EMPTY object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenInput) name:N_DIALER_INPUT_NOT_EMPTY object:nil];


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenCallLogChanged) name:N_CALL_LOG_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simMncChanged) name:N_CARRIER_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenContactChanged) name:N_SYSTEM_CONTACT_DATA_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenPersonChanged:) name:N_PERSON_DATA_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHiddenKeyBoard) name:N_HIDE_PHONE_PAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreKeyBoard) name:N_RESTORE_PHONE_PAD object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin) name:N_SKIN_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenCallerIDChanged) name:N_DID_CALLERIDS_CHANGED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doWhenHintButtonClick) name:N_HINT_BUTTON_CLICK object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNoahToast) name:N_NOAH_LOAD_CONFIG_SUCCESS object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getToolbarToast) name:N_NOAH_LOAD_LOCAL object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppEnterBackground) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPasteboardTipsIfNeed)  name:N_APP_ACTIVE_SHWO_PASTEBOARD object:nil];


    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:T9_phonePad];
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:qwerty_phonePad];


    in_multiSelect_mode = NO;
    [clearall_button addObserver:self
           forKeyPath:@"hidden"
              options:(NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld)
              context:NULL];
    _firstActive = YES;
    _firstInViewDidLoad = YES;
    [[NewFeatureGuideManager sharedManager] checkNewFeatureGuide];
}


- (void)loadPhonePad:(DailerKeyBoardType)keyboradType
{
    self.phonepad_view.frame = [self calculatePhonePadFrame];
    T9_phonePad.hidden = keyboradType != T9KeyBoardType;
    qwerty_phonePad.hidden = keyboradType == T9KeyBoardType;
    [self.view bringSubviewToFront:phonepad_view];
    shared_phonepadmodel.currentKeyBoard = keyboradType;
}

- (void)exitEditingMode
{
    if(contactlist_view.editing){
        [contactlist_view setEditing:NO animated:YES];
        [self.doneButton hideBtn];
        [self.clearall_button hideBtn];
//        _personalCenterButton.hidden = NO;
        pnCenter.hidden = NO;
        [self showToutiao];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	cootek_log(@"==TAB== Dialer view will appear.");
    [self getNoahToast];
    [self exitEditingMode];
    old_phone_pad_state = YES;
    if (filterType != AllCallLogFilter) {
        [header_title clickAll];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_DAILER_WILL_APPEAR object:nil userInfo:nil];
    [self updateEditButtonVisibility];
    [self setSubItemsFrame];
//    [_personalCenterButton refresh];
    [pnCenter setNeedsDisplay];
    [self showPasteboardTipsIfNeed];
    [toutiaoAnimationview setNeedsDisplay];

}

-(void)viewDidAppear:(BOOL)animated{
    // statistics for app performance
    CFAbsoluteTime dialerDidAppearTime = CFAbsoluteTimeGetCurrent();
    
    [super viewDidAppear:animated];
    [[NotificationAlertManger instance]checkShowAlert];
    [self addPersonalCenterGuideInRootViewIndex1];
    
    if (!_isAppearedDuringLaunch) {
        _isAppearedDuringLaunch = YES;
        [TPPerformanceRecorder recordWithTime:CFAbsoluteTimeGetCurrent() forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_DAILER_VIEW_DID_APPEAR byAction:PERFORMANCE_ACTION_END];
        [TPPerformanceRecorder recordWithTimeInterval:(CFAbsoluteTimeGetCurrent() - dialerDidAppearTime) forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_DAILER_VIEW_DID_APPEAR];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   feedsView.hidden = YES;
}


-(void)addPersonalCenterGuideInRootViewIndex1{

    //next_lanuch_show_guide_decide_once
    if ([UserDefaultsManager boolValueForKey:next_active_show_guide]) {
        return;
    }
    if ([UserDefaultsManager boolValueForKey:next_active_show_guide_decide_once]==NO) {
        if (([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME].length==0 &&
            [UserDefaultsManager boolValueForKey:have_click_vs_no_free]==NO)  ||
            ([UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME]==1&&
             [UserDefaultsManager boolValueForKey:IS_TOUCHPAL_NEWER defaultValue:NO])){
                [UserDefaultsManager setBoolValue:YES forKey:next_active_show_guide_decide_once];
                [UserDefaultsManager setBoolValue:YES  forKey:next_active_show_guide];
                return;
        }
    }

    if (([[TouchPalDialerAppDelegate naviController].topViewController isKindOfClass:[RootScrollViewController class]]&&
         [(RootScrollViewController*)[((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers objectAtIndex:0] getSelectedControllerIndex] == 1)){
            if ([UserDefaultsManager boolValueForKey:IS_TOUCHPAL_NEWER defaultValue:NO]==YES&&
                [UserDefaultsManager intValueForKey:ifHadShowInviteViewStates defaultValue:0]!=1){
                if ([FunctionUtility arc4randomIfmMorePersent:80]) {
                        [UserDefaultsManager setIntValue:1 forKey:had_show_personCenterGuideStatus];
//                        [_personalCenterButton refresh];
                    }
                    else{
                        [UserDefaultsManager setIntValue:2 forKey:had_show_personCenterGuideStatus];
                        [DialerUsageRecord recordpath:PATH_PERSONAL_CENTER kvs:Pair(KEY_GUIDE_SCREEN, NOTAPPEAR), nil];
                    }
            }
    }
}

-(void)touchButtonToRemoveButton{
    [UserDefaultsManager setIntValue:2 forKey:ifHadShowInviteViewStates];
    [_internationalInviteBgView removeFromSuperview];
    _internationalInviteBgView= nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DIALOG_DISMISS object:nil];

}

-(void)checkLoginToInternationalCallInvite{
    [self touchButtonToRemoveButton];
    MarketLoginController *marketLoginController = [MarketLoginController withOrigin:@"personal_center_market"];
    marketLoginController.url = TEST_INTERNATIONAL_CALL_INVITE? [INVITATION_URL_STRING stringByAppendingFormat:@"?invitation_code=%@",INVITATION_CODE_BELTA]:INVITATION_URL_STRING;
    [LoginController checkLoginWithDelegate:marketLoginController];
}

-(void)showPasteboardTipsIfNeed{
    [UserDefaultsManager setIntValue:0 forKey:PASTEBOARD_STRING_STATE];
    BOOL bool1 =[[[UIPasteboard generalPasteboard].string getNumberOnly] ifPhoneNumber];
    BOOL bool3 = ![[[UIPasteboard generalPasteboard].string getNumberOnly] isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING defaultValue:[[UIPasteboard generalPasteboard].string getNumberOnly]]];
    if (bool1) {
        [UserDefaultsManager setObject:[[UIPasteboard generalPasteboard].string getNumberOnly] forKey:PASTEBOARD_LAST_STRING];
    }

    BOOL bool2 = [UserDefaultsManager boolValueForKey:PASTEBOARD_COPY_FROM_TOUCHPAL defaultValue:NO];
    if (!bool2){
        if (bool1&&bool3){
                _tipe = [[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:NSLocalizedString(@"Whether to copy or identification number to operate?", @"")  lable1textAlignment:NSTextAlignmentCenter lable2String:[[UIPasteboard generalPasteboard].string getNumberOnly] lable2textAlignment:NSTextAlignmentCenter leftString:@"取消" rightString:@"确定" rightBlock:^{
                    UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
                    if ( [[navi.viewControllers objectAtIndex:0] isKindOfClass:[RootScrollViewController class]]){
                        RootScrollViewController *con = [navi.viewControllers objectAtIndex:0];
                        [con selectTabIndex:1];
                    }
                    [navi popToRootViewControllerAnimated:NO];

                    NSString *str = [InputNumberPasteUtility getPasteboardString];
                    phone_number_label.inputStr = str;
                } leftBlock:nil];

                [UserDefaultsManager setIntValue:1 forKey:PASTEBOARD_STRING_STATE];
                [DialogUtil  showDialogWithContentView:_tipe inRootView:nil];
            }

        }
    else{
        [UserDefaultsManager setBoolValue:NO forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];

    }

}


- (void) onNotiSettiingsItemChanged:(NSNotification*)noti
{
    NSString* settingsKey = noti.object;
    if ([settingsKey isEqualToString:APP_SET_KEY_DISPLAY_LOCATION]) {
        [contactlist_view reloadData];
    }else if([settingsKey isEqualToString:APP_SET_KEY_SECONDARY_LANGUAGE]){
        AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
        [shared_phonepadmodel resetPhonePadLanguage:appSettingsModel.secondary_language];
    }else if([settingsKey isEqualToString:APP_SET_KEY_SMARTEYE]){
        [contactlist_view reloadData];
    }
    else if([settingsKey isEqualToString:APP_SET_SLIDE_CONFIRM]){
        [contactlist_view reloadData];
    }
}


- (void)simMncChanged
{
    [shared_phonepadmodel setInputNumber:shared_phonepadmodel.input_number];
}

- (void)onNotiBecomeActive
{
    [self addPersonalCenterGuideInRootViewIndex1];
    _isAppActive = YES;
    if (shared_phonepadmodel.isCommitCalllog == NO && isGestureCall_ == YES) {
        [shared_phonepadmodel setInputNumber:@""];
    }
    isGestureCall_ = NO;
    [self getNoahToast];
    _firstActive = NO;
}


- (void)changeShowlogsStyle
{
    // for JB
    [header_title removeFromSuperview];

    CallLogTitleView* headerTitle = [CallLogTitleView createCallLogTitle:isShowLogsTypes_];
    headerTitle.isJBCallog = isShowLogsTypes_;
    [headerTitle setSkinStyleWithHost:self forStyle:@"default_headtabbar_style"];
    headerTitle.delegate = self;
    self.header_title = headerTitle;
	[headerView addSubview:header_title];
    header_title.hidden = ([shared_phonepadmodel.input_number length] > 0);

    self.currentCellName = isShowLogsTypes_ ? NSStringFromClass([JBCallLogCell class]) : NSStringFromClass([CallLogCell class]);
}

- (void)onCancelCall
{
    [shared_phonepadmodel setInputNumber:@""];
    isGestureCall_ = NO;
}

- (void)phonepad_show
{
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
	cootek_log(@"[DialerViewController phonepad_show]");
    [self showPhonePadView];
}

- (void)updateYPRedHint {
    [pnCenter setNeedsDisplay];
}

- (void)phonepad_hide
{
	cootek_log(@"[DialerViewController phonepad_hide]");
    if(search_result_viewcontroller.view.hidden == NO
       &&[shared_phonepadmodel.calllog_list.searchResults count]>3)
    {
        [search_result_viewcontroller.result_tableview reloadData];
    }
    [self hidePhonePadView];
}

- (void)updateEditButtonVisibility
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateEditButtonVisibility) withObject:nil waitUntilDone:NO];
        return;
    }
    NSString *curInput = [shared_phonepadmodel input_number];
    
    NSInteger calllogCount = [shared_phonepadmodel.calllog_list.searchResults count];

    if ( curInput == nil || [curInput isEqualToString:@""]) {
        self.editButton.hidden = calllogCount == 0;
    } else {
        self.editButton.hidden = YES;
    }
    self.editButton.hidden = YES;

    
}

- (void)doWhenInputChanged:(NSNotification *)noti
{
    BOOL needScrollToTop = [noti.object boolValue];
    if(hasInitialDataSearch_) {

        [self onInitialDataCompleted];
        hasInitialDataSearch_ = NO;
    }

	cootek_log(@"dialer view controller --> do when input changed.");
	[contactlist_view setEditing:NO animated:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:N_DONE_NOTIFICATION object:nil userInfo:nil];
	clearall_button.hidden = YES;
	if ([shared_phonepadmodel.input_number isEqualToString:@""]) {
        [self doWhenInputEmpty];
        NSInteger calllogCount = [shared_phonepadmodel.calllog_list.searchResults count];

        [self hideHintView:(calllogCount != 0)];

        filterBar.hidden = (filterType == AllCallLogFilter);
		contactlist_view.hidden = NO;
		search_result_viewcontroller.view.hidden = YES;
		[contactlist_view reloadData];
        
        if(needScrollToTop){
		  [contactlist_view setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        
	} else {
		cootek_log(@"now input is %@", shared_phonepadmodel.input_number);
        [self doWhenInput];
        [self hideHintView:YES];
        filterBar.hidden = YES;
		contactlist_view.hidden = YES;
		search_result_viewcontroller.view.hidden = NO;
		[search_result_viewcontroller.result_tableview reloadData];
        [self.view insertSubview:search_result_viewcontroller.view belowSubview:phonepad_view];
        [self.view insertSubview:search_result_viewcontroller.view belowSubview:self.adView];
        if(needScrollToTop){
		   [search_result_viewcontroller.result_tableview setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        if (isGestureCall_&&keyName) {
           [shared_phonepadmodel excuteGestureAction:keyName];
            self.keyName = nil;
        }

        if(in_multiSelect_mode){
            [longGestureController_ exitLongGestureMode];
        }
	}
    [self updateEditButtonVisibility];
}

- (void)doWhenInputEmpty
{
    cootek_log(@"now input is empty");
    header_title.hidden = NO;
	self.phone_number_label.hidden = YES;
	self.doneButton.hidden = YES;
//    _personalCenterButton.hidden = NO;
    pnCenter.hidden = NO;
    [self showToutiao];
    isGestureCall_ = NO;
    [self updateEditButtonVisibility];
}

- (void)doWhenInput
{
	cootek_log(@"do when input.");
    header_title.hidden = YES;
	self.phone_number_label.hidden = NO;
	self.doneButton.hidden = YES;
//    _personalCenterButton.hidden = YES;
    pnCenter.hidden = YES;
    [self hideToutiao];
    [self updateEditButtonVisibility];
}

- (void)doWhenCallLogChanged
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(doWhenCallLogChanged) withObject:nil waitUntilDone:NO];
        return;
    }

    [shared_phonepadmodel setInputNumber:@""];
    [self updateEditButtonVisibility];
}

- (void)dowhenExitYellowPage
{
    if ([shared_phonepadmodel.input_number length] > 0) {
        [shared_phonepadmodel setInputNumber:@""];
    }
}
- (void)doWhenHintButtonClick
{
    if ([search_result_viewcontroller.longGestureController inLongGestureMode]) {
        [search_result_viewcontroller.longGestureController exitLongGestureModeWithHintButton];
    }
}

- (void)doWhenCallerIDChanged
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(doWhenCallerIDChanged) withObject:nil waitUntilDone:NO];
        return;
    }

    if (!contactlist_view.editing) {
        [shared_phonepadmodel setInputNumberAndNoScrollWhenEmpty:shared_phonepadmodel.input_number];
    }
}

- (void)doWhenContactChanged
{
    [shared_phonepadmodel setInputNumber:shared_phonepadmodel.input_number];
}

-(void)doWhenPersonChanged:(id)personChange
{
	NotiPersonChangeData* changedData = [[personChange userInfo] objectForKey:KEY_PERSON_CHANGED];
	if (changedData.change_type == ContactChangeTypeAdd ||changedData.change_type == ContactChangeTypeModify ||changedData.change_type==ContactChangeTypeDelete) {
		[self doWhenContactChanged];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    cootek_log(@"Received memory warning in DialerViewController.");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.contactlist_view = nil;
}



- (void)dealloc
{
    favTipsView = nil;
    scrollTipsView = nil;
    for (UITapGestureRecognizer *gesture in [contactlist_view gestureRecognizers]) {
        [contactlist_view removeGestureRecognizer:gesture];
    }
    [longGestureController_ tearDown];
    [SkinHandler removeRecursively:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:phone_number_label];
}

#pragma mark Button action handler
- (void)editCallLog
{
   	if ([shared_phonepadmodel.calllog_list.searchResults count]>0) {
        BOOL editing = contactlist_view.editing;
        [contactlist_view setEditing:!editing animated:YES];
        if (!editing) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_EDIT_NOTIFICATION object:nil userInfo:nil];
            [self.editButton hideBtn];
            [self.clearall_button showBtn];
            [self.doneButton showBtn];
//            _personalCenterButton.hidden = YES;
            pnCenter.hidden = YES;
            [self hideToutiao];
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_DONE_NOTIFICATION object:nil userInfo:nil];
            [self.doneButton hideBtn];
            [self.clearall_button hideBtn];
            [self.editButton showBtn];
//            _personalCenterButton.hidden = NO;
            pnCenter.hidden = NO;
            [self showToutiao];
            NSInteger calllogCount = 0;
            if (shared_phonepadmodel.calllog_list != nil) {
                calllogCount = [shared_phonepadmodel.calllog_list.searchResults count];
            }
            [self hideHintView:(calllogCount != 0)];
            [shared_phonepadmodel setInputNumber:@""];
            [self updateEditButtonVisibility];
        }
    }else {
        [shared_phonepadmodel setInputNumber:@""];
    }
}

- (void)clearAllCallLog
{
	if ([shared_phonepadmodel.calllog_list.searchResults count]>0) {
        NSString *typeString = nil;
        switch (filterType) {
            case AllCallLogFilter:{
                typeString = NSLocalizedString(@"All", @"全部通话");
                break;
            }
            case MissedCalllogFilter:{
                typeString = NSLocalizedString(@"Missed", @"");
                break;
            }
            case UnknowCallLogFilter:{
                typeString = NSLocalizedString(@"Unknown", @"");
                break;
            }
            case OutgoingFilter:{
                typeString = NSLocalizedString(@"Outgoing", @"");
                break;
            }
            case IncomingFilter:{
                typeString = NSLocalizedString(@"Incoming", @"");
                break;
            }
            default:
                break;
        }
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Clear recent %@ call logs?", @""),[typeString lowercaseString]]
														message:nil
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
											  otherButtonTitles:NSLocalizedString(@"Ok",@""), nil];
		[alert show];
	}
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex==1) {
        NSArray *arrayWhere = nil;
        switch (filterType) {
            case AllCallLogFilter:{
                break;
            }
            case MissedCalllogFilter:{
                WhereDataModel *condition = [[WhereDataModel alloc] init];
                condition.fieldKey = [DataBaseModel getKWhereKeyCallType];
                condition.oper = [DataBaseModel getKWhereOperationEqual];
                condition.fieldValue = [NSString stringWithFormat:@"%d",CallLogIncomingMissedType];
                arrayWhere = [NSArray arrayWithObject:condition];
                break;
            }
            case UnknowCallLogFilter:{
                WhereDataModel *condition = [[WhereDataModel alloc] init];
                condition.fieldKey = [DataBaseModel getKWhereKeyPersonID];
                condition.oper = [DataBaseModel getKWhereOperationEqual];
                condition.fieldValue = [NSString stringWithFormat:@"%d", -1];
                arrayWhere = [NSArray arrayWithObject:condition];
                break;
            }
            case OutgoingFilter:{
                WhereDataModel *condition = [[WhereDataModel alloc] init];
                condition.fieldKey = [DataBaseModel getKWhereKeyCallType];
                condition.oper = [DataBaseModel getKWhereOperationEqual];
                condition.fieldValue = [NSString stringWithFormat:@"%d",CallLogOutgoingType];
                arrayWhere = [NSArray arrayWithObject:condition];
                break;
            }
            case IncomingFilter:{
                WhereDataModel *condition = [[WhereDataModel alloc] init];
                condition.fieldKey = [DataBaseModel getKWhereKeyCallType];
                condition.oper = [DataBaseModel getKWhereOperationEqual];
                condition.fieldValue = [NSString stringWithFormat:@"%d",CallLogIncomingType];
                arrayWhere = [NSArray arrayWithObject:condition];
                break;
            }
            default:
                break;
        }
        [CallLog deleteCalllogByConditional:arrayWhere];
    }
}

#pragma mark PhonePadKey protocol
- (void)beginTouchWithKeyCenter:(CGPoint )center {
    [_keyPadAnimaView stopAnimating];
    if ([PhonePadModel getSharedPhonePadModel].currentKeyBoard == T9KeyBoardType) {
        _keyPadAnimaView.animationDuration = KEYPAD_ANIMATIONVIEW_DURATION;
        _keyPadAnimaView.animationRepeatCount = 1;
        NSString *path = nil;
        NSArray *arr= [TPDialerResourceManager sharedManager].allSkinInfoList;
        for (TPSkinInfo *skinInfo  in arr) {
            if ([skinInfo.skinID isEqualToString:[TPDialerResourceManager sharedManager].skinTheme]) {
                path = skinInfo.skinDir;
            }
        }
        path = [NSString stringWithFormat:@"%@/animation",path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSMutableArray *imaggPathArray =[FileUtils getAbsPathArrayContentsOfDirectoryAtPath:path];
            NSMutableArray *imageArray = [NSMutableArray array];
            for (NSString *ImagePath in imaggPathArray) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:ImagePath]) {
                    UIImage *image = [UIImage imageWithContentsOfFile:ImagePath];
                    [imageArray addObject:image];
                }
            }
            _keyPadAnimaView.animationImages = imageArray;
            _keyPadAnimaView.center = CGPointMake(center.x, center.y-30);
            [_keyPadAnimaView startAnimating];
        }
    }
}
- (void)clickPhonePadKey:(NSString *)number_str {
    if ([search_result_viewcontroller.longGestureController inLongGestureMode]) {
        [search_result_viewcontroller.longGestureController exitLongGestureMode];
    }
	// change text
	if (phone_number_label.inputStr == nil) {
		phone_number_label.inputStr = @"";
	}
    if (phone_number_label.inputStr.length>0) {
        [self doWhenInput];
    }else{
        [self doWhenInputEmpty];
    }
	NSString *tmp_str = [NSString stringWithFormat:@"%@%@", shared_phonepadmodel.input_number, number_str];
	[shared_phonepadmodel setInputNumber:tmp_str];
    phone_number_label.inputStr = tmp_str;
}

- (void)deleteInputNumer
{
    if ([search_result_viewcontroller.longGestureController inLongGestureMode]) {
        [search_result_viewcontroller.longGestureController exitLongGestureMode];
    }
	if (phone_number_label.inputStr == nil || [phone_number_label.inputStr isEqualToString:@""]) {
		return;
	}
	int len = [phone_number_label.inputStr length] - 1;
	if (len >= 0) {
		NSString *tmp_str = [phone_number_label.inputStr substringToIndex:len];
		[shared_phonepadmodel setInputNumber:tmp_str];
        phone_number_label.inputStr = tmp_str;
        if(len==0){
            [shared_phonepadmodel setPhonePadShowingState:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ROOT_BAR_DISABLE_FOR_A_WHILE object:nil];
        }
	}
}

- (void)deleteAllInputNumber
{
    if ([search_result_viewcontroller.longGestureController inLongGestureMode]) {
        [search_result_viewcontroller.longGestureController exitLongGestureMode];
    }
	if ([phone_number_label.inputStr length] == 0) {
		return;
	}
    [shared_phonepadmodel setPhonePadShowingState:YES];
	phone_number_label.inputStr = @"";
	[shared_phonepadmodel setInputNumber:@""];
}

- (void)clickKeyBoardChanged:(DailerKeyBoardType)keyboradType
{
    if (![UserDefaultsManager boolValueForKey:ALERT_KEYPAD_CHANGE_ONCE defaultValue:NO]) {
        [UserDefaultsManager setBoolValue:YES forKey:ALERT_KEYPAD_CHANGE_ONCE];
        CommonTipsWithBolckView *tip = [[CommonTipsWithBolckView alloc] initWithtitleString:@"触宝提示" lable1String:@"您已成功进行了键盘切换，若想切回请点击或者长按“*”号键" lable1textAlignment:(NSTextAlignmentLeft) lable2String:nil lable2textAlignment:0 leftString:nil rightString:@"确定" rightBlock:nil leftBlock:nil];
        [tip.rightBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:(UIControlStateNormal)];
        [tip.rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_700"] withFrame:tip.rightBtn.bounds] forState:(UIControlStateHighlighted)];
        [tip.rightBtn setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] withFrame:tip.rightBtn.bounds] forState:(UIControlStateNormal)];
        tip.rightBtn.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"].CGColor;
        [DialogUtil showDialogWithContentView:tip inRootView:nil];
    }
    preChangedKeyBoardType = shared_phonepadmodel.currentKeyBoard;
    [self loadPhonePad:keyboradType];
    [shared_phonepadmodel setInputNumber:@""];
}

- (void)willHiddenKeyBoard
{
    old_phone_pad_state = [shared_phonepadmodel phonepad_show];
    [shared_phonepadmodel setPhonePadShowingState:NO];
}

- (void)restoreKeyBoard
{
    [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
}

- (void)clickPaste
{
    NSString *str = [InputNumberPasteUtility appendPasteboardString];
    phone_number_label.inputStr = str;
}

- (void)pasteClickedInView:(PhoneNumberInputView *)view
{
    [self clickPaste];
}

-(void)onWillChangeGestureRecginzer:(NSString *)key
{
    GestureActionType type = [GestureUtility getActionType:key];
    if(type != ActionNone) {
        NSString *number = [GestureUtility getNumber:key withAction:type];

        [shared_phonepadmodel setInputNumber:number];
        phone_number_label.inputStr = number;
        isGestureCall_ = YES;
        self.keyName = key;
    }
}

#pragma CalllogTitleClickDelegate
- (void)onClickFilter:(CalllogFilterType)type
{
    [self hideHintView:YES];
    [self.hintView hideAllView];
    switch (type) {
        case AllCallLogFilter:
            header_title.titleLabel.text = [NSString stringWithFormat:@"%@%@",
                                            NSLocalizedString(@"Outgoing_logs",@""), @" "];
            [self.hintView showAllView];
            break;
        case MissedCalllogFilter:
            header_title.titleLabel.text = [NSString stringWithFormat:@"%@%@",
                                            NSLocalizedString(@"Missed_logs", @""), @" "];
            break;
        case OutgoingFilter:
            header_title.titleLabel.text = [NSString stringWithFormat:@"%@%@",
                                            NSLocalizedString(@"Outgoing_logs", @""), @" "];
            break;
        case IncomingFilter:
            header_title.titleLabel.text = [NSString stringWithFormat:@"%@%@",
                                            NSLocalizedString(@"Incoming_logs", @""), @" "];
            break;
        case UnknowCallLogFilter:
            header_title.titleLabel.text = [NSString stringWithFormat:@"%@%@",
                                            NSLocalizedString(@"Unknown_logs", @""), @" "];
            break;
        default:
            break;
    }
    filterType = type;
    [shared_phonepadmodel setFilterType:filterType];
    [self setSubItemsFrame];
}

- (void)setSubItemsFrame
{
    CGRect frame = header_title.titleLabel.frame;
    CGFloat titleWidth = [header_title.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE_3]
                                                  constrainedToSize:CGSizeMake(frame.size.width, frame.size.height)].width;
    header_title.showSubItemsView.frame = CGRectMake(frame.size.width * 0.5 + titleWidth * 0.6 - 10, 20,
                                                     10, 6);
}

- (void)callLogTitleTabTypesClicked
{
    [self setType];
    [filterBar clickTabIndex:0];
    contactlist_view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(367));
    filterBar.hidden = NO;
}

- (void)callLogTitleTabAllClicked
{
    [self onClickFilter:AllCallLogFilter];
    contactlist_view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(367));
    if (filterBar) {
        filterBar.hidden = YES;
    }
    [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
}

#pragma JB title clicked
- (void)onClickAtIndexBar:(NSInteger)index
{
    [longGestureController_ exitLongGestureMode];
}

#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([longGestureController_ inLongGestureMode] && [longGestureController_.currentSelectIndexPath compare:indexPath] == NSOrderedSame) {
        return CALLLOG_CELL_HEIGHT * 2;
    } else {
        return CALLLOG_CELL_HEIGHT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (![shared_phonepadmodel.input_number isEqualToString:@""]) {
		return 0;
	}
    NSInteger rowsCount = 0;
	if (shared_phonepadmodel.calllog_list.searchResults != nil) {
        rowsCount = [shared_phonepadmodel.calllog_list.searchResults count];
    }
    
    BOOL haveRows = rowsCount > 0;
    BOOL checked = [UserDefaultsManager boolValueForKey:NEW_INSTALL_FOR_EMPTY_CALLLOG_CHECKED defaultValue:NO];
    if (haveRows && !checked) {
        [UserDefaultsManager setBoolValue:YES forKey:NEW_INSTALL_FOR_EMPTY_CALLLOG_CHECKED];
        if (_newInstallHintView) {
            [_newInstallHintView removeFromSuperview];
        }
    }
    [self hideHintView:haveRows];
    return rowsCount;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    id item = nil;
    NSString *cellIDentifier_withCallType;
    if (row < [shared_phonepadmodel.calllog_list.searchResults count]) {
         item = [[PhonePadModel getSharedPhonePadModel].calllog_list.searchResults objectAtIndex:row];
    }
    if ( [item isKindOfClass:[CallLogDataModel class]]
        && ((CallLogDataModel *)item).duration>10*60) {
        //10分钟
        if([UserDefaultsManager intValueForKey:unregister_fristCall10Min_tip defaultValue:0]==0){
            [UserDefaultsManager setIntValue:1 forKey:unregister_fristCall10Min_tip];
        }
    }
    NSString *style = @"dailerView_callLogCell_style";
    cellIDentifier_withCallType = [NSString stringWithFormat:@"%@_%@",self.cellIdentifier,currentCellName];
	BaseContactCell *cell = [tableView createTableViewCell:currentCellName
                                             withStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIDentifier_withCallType
                                          andSkinStyle:style
                                               forHost:self];

    [cell showAllBottomLine];
    cell.operView.hidden = YES;
    if ( [longGestureController_ inLongGestureMode]
        && [longGestureController_.currentSelectIndexPath compare: indexPath] == NSOrderedSame) {
        
        [cell.operView addSubview:longGestureController_.operView.bottomView];
//        longGestureController_.operView.bottomView.frame = CGRectMake(0, 0, cell.operView.tp_width, cell.operView.tp_height);
        [longGestureController_.operView.bottomView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.operView);
        }];
        cell.operView.hidden = NO;
        [cell showAnimation];
        self.longModeCell = cell;
    }
    
    if([item isKindOfClass:[CallLogDataModel class]]) {
        CallLogDataModel *callLog = item;
        if ([cell isKindOfClass:[CallLogCell class]] || [cell isKindOfClass:[JBCallLogCell class]]) {
            [cell refreshWithEditingState:tableView.editing];
            cell.currentData = callLog;
            [cell setDataToCell];
            cell.isExcuteAction = ^(){
                BOOL isExcute = (!in_multiSelect_mode&&!tableView.editing);
                return isExcute;
            };
            [cell.actionStrategy setPopupSheetBlock:^(){ [self willHiddenKeyBoard];}
                                          disappear:^(){ [self restoreKeyBoard];}];

            CallLogCell *callLogCell = (CallLogCell *)cell;
            if ([[AppSettingsModel appSettings]slide_confirm]) {
                [callLogCell openSlideItem];
            }else{
                [callLogCell closeSlideItem];
            }
        }
    }
    return cell;
}

- (void)showOperView:(UIButton *)sender {
    NSArray *tmp = [sender.titleLabel.text componentsSeparatedByString:@":"];
    NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[tmp[1] integerValue] inSection:[tmp[0] integerValue]];
    longGestureController_.currentSelectIndexPath = currentIndex;
    [longGestureController_ enterLongGestureMode];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    cootek_log(@"didSelectRowAtIndexPath, long gesture mode = %d", [longGestureController_ inLongGestureMode]);

    if ( [indexPath row] < 5 )
        [DialerGuideAnimationUtil waitGuideAnimation];

    if (![longGestureController_ inLongGestureMode]) {
         BaseContactCell *cell = (BaseContactCell*)[contactlist_view cellForRowAtIndexPath:indexPath];
         [cell onClick];
         [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [longGestureController_ exitLongGestureMode];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return TRUE;
    
}


-  (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		int row = [indexPath row];
		// delete from data base.
		NSMutableArray *condition_arr = [NSMutableArray arrayWithCapacity:3];
		CallLogDataModel *m_calllog = [shared_phonepadmodel.calllog_list.searchResults objectAtIndex:row];
          if(m_calllog.personID>0){
               WhereDataModel *condition_pid = [[WhereDataModel alloc] init];
               condition_pid.fieldKey = [DataBaseModel getKWhereKeyPersonID];
               condition_pid.oper = [DataBaseModel getKWhereOperationEqual];
               condition_pid.fieldValue = [NSString stringWithFormat:@"%d", m_calllog.personID];
               [condition_arr addObject:condition_pid];
		}else{
            WhereDataModel *condition_num = [[WhereDataModel alloc] init];
            condition_num.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];

            if ([[[PhoneNumber sharedInstance] getOriginalNumber:m_calllog.number] length] >= 7) {
                condition_num.oper = [DataBaseModel getKWhereOperationLike];
                condition_num.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:m_calllog.number];
            } else {
                condition_num.oper = [DataBaseModel getKWhereOperationEqual];
                condition_num.fieldValue = [DataBaseModel getFormatNumber:[NSString stringWithFormat:@"%@", m_calllog.number]];
            }

            [condition_arr addObject:condition_num];
        }
        if ([shared_phonepadmodel.calllog_list.searchResults count] > 1) {
            [CallLog deleteCalllogByConditionalWithoutNotification:condition_arr];
            // delete from uitable view.
            [shared_phonepadmodel.calllog_list.searchResults removeObjectAtIndex:row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [CallLog deleteCalllogByConditional:condition_arr];
        }
	}
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewWrapperView"]) {
        return YES;
    }
    return  NO;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer {

    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(shared_phonepadmodel.phonepad_show == YES){
        [shared_phonepadmodel setPhonePadShowingState:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_GESTURE_HIDE_UNREGN_BAR object:nil userInfo:nil];
    }
    if ([longGestureController_ inLongGestureMode]) {
        [longGestureController_ exitLongGestureMode];
    }
}

#pragma mark DialerSearchResultViewControllerDelegate
-(void)specailKey:(ADDEXTERCELLTYPE)type{
    switch (type) {
        case ChangeToNmberPad:
                [shared_phonepadmodel setInputNumber:@""];
                [self loadPhonePad:T9KeyBoardType];
            break;
        case ChangeToQWERTYPad:
            [shared_phonepadmodel setInputNumber:@""];
            [self loadPhonePad:QWERTYBoardType];
            break;
        case PasteClipBoard:{
            NSString *str = [InputNumberPasteUtility getPasteboardString];
             UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (pasteboard.string.length == 0) {
                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [uiWindow makeToast:NSLocalizedString(@"剪贴板中没有号码", "") duration:1.0f position:CSToastPositionBottom];
                return;
            }
            phone_number_label.inputStr = str;
            }
            break;
        default:
            break;
    }
}


- (void)sendMessage
{
    NSString *numStr = [PhonePadModel ABC2Num:shared_phonepadmodel.input_number];
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(1)), nil];
        }
    }
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [TPMFMessageActionController sendMessageToNumber:numStr
                                                      withMessage:@""
                                                      presentedBy:aViewController];
}

- (void)addContact
{
    NSString *numStr = [PhonePadModel ABC2Num:shared_phonepadmodel.input_number];
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(2)), nil];
            [UserDefaultsManager setIntValue:1 forKey:PASTEBOARD_STRING_STATE];
        }
    }
    if ( [FunctionUtility judgeContactAccessFail] )
        return;
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;

    CallerIDInfoModel *callerInfo = [PhonePadModel getSharedPhonePadModel].caller_id_info;
    NSString *name = nil;
    if(callerInfo != nil&&[callerInfo isCallerIdUseful]){
        name = callerInfo.name;
    }
    [[TPABPersonActionController controller] addNewPersonWithNumber:numStr name:name presentedBy:aViewController];
}

- (void)addToExistingContact
{
    NSString *numStr = [PhonePadModel ABC2Num:shared_phonepadmodel.input_number];
    if ([numStr isEqualToString:[UserDefaultsManager stringForKey:PASTEBOARD_LAST_STRING]]) {
        if ([UserDefaultsManager intValueForKey:PASTEBOARD_STRING_STATE defaultValue:0]==1) {
            [DialerUsageRecord recordpath:PATH_PASTEBOARD_OPERATE kvs:Pair( PASTEBOARD_AFTER_DO_YES_OPERATE, @(3)), nil];
        }
    }
    if ( [FunctionUtility judgeContactAccessFail])
        return;
    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    [[TPABPersonActionController controller] addToExistingContactWithNewNumber:numStr presentedBy:aViewController];
}

#pragma mark Skin change handler
- (void)changeSkin
{
    self.cellIdentifier = [NSString stringWithFormat:@"%d",((NSInteger)arc4random())];
    search_result_viewcontroller.CellIdentifier = self.cellIdentifier;
    [contactlist_view reloadData];
}

#pragma mark Long press
- (void)enterLongGestureMode
{
    if(!in_multiSelect_mode){
        in_multiSelect_mode = YES;
        old_phone_pad_state = shared_phonepadmodel.phonepad_show;
        [shared_phonepadmodel setPhonePadShowingState:NO];
        if(contactlist_view.editing){
            [self exitEditingMode];
        }
    }
    if (longGestureController_.showScrollToShow) {
        longGestureController_.showScrollToShow = NO;
        [contactlist_view scrollToRowAtIndexPath:longGestureController_.currentSelectIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    [contactlist_view reloadData];
}

- (void)exitLongGestureMode
{
    if(in_multiSelect_mode){
        in_multiSelect_mode = NO;
        [shared_phonepadmodel setPhonePadShowingState:old_phone_pad_state];
    }
    [self.longModeCell exitAnimation];
    [contactlist_view reloadData];
}

#pragma mark KVO notifications
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == clearall_button && [keyPath isEqual:@"hidden"]) {
        longGestureController_.enableLongGesture = clearall_button.hidden;
     }
}

#pragma mark Noah
- (void)getNoahToast{
    if (![NoahManager isReady]) {
        cootek_log(@"Dialer trying to get toast but not noah not ready");
        return;
    }
    cootek_log(@"Dialer page is going to get noah toast");
    [self getToolbarToast];
//    [_personalCenterButton refresh];
}



- (void)getToolbarToast{
    PresentationSystem *ps = [NoahManager sharedPSInstance];
    if (noahToolBar&&noahToolBar.priority==0) {
        //is showing a in app message
        return;
    }
    ToolbarToast *toolbarToast = [ps getToolbarToast];
    if (toolbarToast != nil){
        cootek_log(@"noah got tool bar toast");
        if (shared_phonepadmodel.input_number.length == 0 && _isAppActive) {
            [self showNoahToolBar:toolbarToast];
        }
    }else{
        [self ifShouldShowLocalMessage];
    }
}
-(void)ifShouldShowLocalMessage{
    NSString *skinTheme = [[TPDialerResourceManager sharedManager] skinTheme];
    NSDictionary *inappInfo = [CommercialSkinManager getInAppInfoFromCommercialSkinExistPlistWithSkinID:skinTheme];
    if (noahToolBar) {
        if (noahToolBar.priority==3 && (inappInfo ==nil || [UserDefaultsManager boolValueForKey:inappInfo[@"id"] defaultValue:NO])) {
            [self closeNoahToolBar];
        }
        return;
    }

    if (inappInfo != nil && ![UserDefaultsManager boolValueForKey:inappInfo[@"id"] defaultValue:NO]){
        [self showLocalMessageDic:@{@"display":inappInfo[@"text"],
           @"allowClean":@"true",
            @"toastId":inappInfo[@"id"],
            @"priority":@"3"}];
        
    }

    
    
    if ([UserDefaultsManager boolValueForKey:IS_TOUCHPAL_NEWER]
        && [UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME defaultValue:0]<=1
        && ![UserDefaultsManager boolValueForKey:VOIP_HAD_CALL defaultValue:NO]) {
        
    }else
        if([UserDefaultsManager intValueForKey:had_show_test_inapp_guide defaultValue:0]==1){
            [UserDefaultsManager setIntValue:0 forKey:had_show_test_inapp_guide];
            [self closeNoahToolBar];
    }
    
    if ([UserDefaultsManager intValueForKey:ANTIHARASS_GUIDE_INAPP defaultValue:0]==1) {
        [UserDefaultsManager setIntValue:2 forKey:ANTIHARASS_GUIDE_INAPP];
        [self showLocalMessageDic:@{@"display":@"更新至iOS10，实现骚扰电话自动拦截",
                       @"toastId":@"showUpdateToiOS10Guide",
                                    @"allowClean":@"true",
                                    @"priority":@"3"}];
    }
    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_UPDATE_SUCCESS_NOTICE defaultValue:NO]) {
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_UPDATE_SUCCESS_NOTICE];
        [self showLocalMessageDic:@{@"display":@"防骚扰号码库已经更新到最新版本",
                                    @"toastId":@"showAntiUpdatedGuide",
                                    @"allowClean":@"true",
                                    @"priority":@"4"}];
    }
    
    
    
    if ([UserDefaultsManager boolValueForKey:DIALER_GUIDE_ANIMATION_HAS_SHOWN]==NO
        &&[UserDefaultsManager boolValueForKey:DIALER_GUIDE_ANIMATION_SHOULD_SHOW]==YES){
        if ([UserDefaultsManager boolValueForKey:DIALER_GUIDE_ANIMATION_WAIT defaultValue:NO]==YES){
            [UserDefaultsManager setBoolValue:NO forKey:DIALER_GUIDE_ANIMATION_WAIT];
            return;
        }
        [UserDefaultsManager setBoolValue: YES forKey:DIALER_GUIDE_ANIMATION_HAS_SHOWN];
        if([FunctionUtility arc4randomIfmMorePersent:70]){
        [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(KEY_DIALER_GUIDE_INAPP, APPEAR), nil];
        [self showLocalMessageDic:@{@"display":@"快速找人的秘密？点此查看",
                                    @"toastId":@"showDialerGuideAnimation",
                                    @"priority":@"2"}];
        }else{
        [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(KEY_DIALER_GUIDE_INAPP, NOTAPPEAR), nil];
        }

    }
}

-(void)showLocalMessageDic:(NSDictionary *)messageDic{
    noahToolBar = [[NoahToolBarView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight()-40, TPScreenWidth(), 40) andLocaMessage:messageDic andDelegate:self];
    [self.view addSubview:noahToolBar];
    [self.view sendSubviewToBack:noahToolBar];
    [self showInAnimation];
}
- (void) showInAnimation{
    CGRect oldFrame1 = noahToolBar.frame;
    CGRect oldFrame2 = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(367));
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         noahToolBar.frame = CGRectMake(oldFrame1.origin.x, TPHeaderBarHeight(), oldFrame1.size.width,  oldFrame1.size.height);
                         self.contactlist_view.frame = CGRectMake(oldFrame2.origin.x, oldFrame2.origin.y+noahToolBar.frame.size.height, oldFrame2.size.width, oldFrame2.size.height);
                     }
                     completion:nil];
}

#pragma mark NoahToolBarViewDelegate
- (void) closeNoahToolBar{
    if (noahToolBar != nil) {
        self.contactlist_view.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(367));
        [noahToolBar removeFromSuperview];
        noahToolBar = nil;
    }
}

- (void)showNoahToolBar:(ToolbarToast *)toast {
    [self closeNoahToolBar];
    noahToolBar = [[NoahToolBarView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight()-40, TPScreenWidth(), 40) andToolbarToast:toast andDelegate:self];
    [self.view addSubview:noahToolBar];
    [self.view sendSubviewToBack:noahToolBar];
    [self showInAnimation];
}

- (void)onAppEnterBackground {
    [self closeNoahToolBar];
    _isAppActive = NO;
}

- (void)onNewerWizardClicked {
    HandlerWebViewController *con = [[HandlerWebViewController alloc]init];
    con.url_string = URL_NEWER_WIZARD;

    __weak id weakCon = con;
    [con setFinishLoadAction:^(UIView<FLWebViewProvider> *webView){
        [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nonnull ret, NSError * _Nonnull error) {

            if (!error) {
                NSString *theTitle = ret;
                if (theTitle && theTitle.length > 0 && ([theTitle rangeOfString:@"新手教程"].location != NSNotFound)) {
                    [UserDefaultsManager setBoolValue:YES forKey:NEWER_WIZARD_READ];
                }
            }
            if (weakCon) {
                [[TouchPalDialerAppDelegate naviController] pushViewController:weakCon animated:YES];
            }
        }];
    }];

}

+(void)showGuidePopView{
    [[TouchPalDialerAppDelegate naviController] popToRootViewControllerAnimated:YES];
    CallLogDataModel *call_model = [[CallLogDataModel alloc] init];
    call_model.name = @"触宝测试专线";
    call_model.callType =CallLogTestType;
    [TPCallActionController logCallFromSource:@"CallKey"];
    [[TPCallActionController controller] makeCall:call_model];
}

#pragma mark view animation
- (void) hidePhonePadView {
    // hide, to down, increase the origin.y
    [UserDefaultsManager setBoolValue:NO forKey:PHONE_PAD_IS_VISIBLE];
//    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect oldFrame = phonepad_view.frame;
                         phonepad_view.frame =
                         CGRectMake(oldFrame.origin.x, oldFrame.origin.y + _phonePadFrame.size.height,
                                    oldFrame.size.width, oldFrame.size.height);
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         phonepad_view.hidden = YES;
                         self.adView.hidden = YES;
                         
                     }];
    
}

- (void) showPhonePadView {
    if (![UserDefaultsManager boolValueForKey:KEY_PAD_TOOL_TIP_CLICKED defaultValue:NO]) {
        [UserDefaultsManager setBoolValue:YES forKey:KEY_PAD_TOOL_TIP_CLICKED];
        [self hideAnimationForHidingKeypad];
    }
    [UserDefaultsManager setBoolValue:YES forKey:PHONE_PAD_IS_VISIBLE];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         phonepad_view.hidden = NO;
                         [FunctionUtility setY:_phonePadFrame.origin.y forView:phonepad_view];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         phonepad_view.hidden = NO;
                         [self.adView refresh];
                         self.adView.hidden = NO;
                     }];
    
}

#pragma mark animations
- (void) animationForHidingKeypad {
    if (_rippleContainer == nil) {
        RootTabBar *tabBar = self.parent.tabBar;
        
        UIColor *rippleColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
        CGFloat containerDiameter = 16 * 2;
        _rippleContainer = [[UIView alloc] initWithFrame:CGRectMake(tabBar.frame.size.width/ 2, 0, containerDiameter, containerDiameter)];
        
        CGFloat pointDiameter = 10;
        CGRect pointFrame = CGRectMake((containerDiameter - pointDiameter) / 2, (containerDiameter - pointDiameter) / 2, pointDiameter, pointDiameter);
        UIView *staticPointView = [[UIView alloc] initWithFrame:pointFrame];
        staticPointView.tag = TAG_POINT_VIWE;
        staticPointView.backgroundColor = rippleColor;
        staticPointView.layer.cornerRadius = pointDiameter / 2;
        staticPointView.clipsToBounds = YES;
        
        UIView *ringView = [[UIView alloc] initWithFrame:pointFrame];
        ringView.tag = TAG_RING_VIWE;
        ringView.backgroundColor = [UIColor clearColor];
        ringView.layer.cornerRadius = ringView.frame.size.width / 2;
        ringView.layer.borderColor = rippleColor.CGColor;
        ringView.layer.borderWidth = 1;
        
        // tool tip above the tab bar
        _rippleToolTipView = [self getToolTipView];
        
        // view settings
        _rippleContainer.userInteractionEnabled = YES;
        UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickRippleContainer)];
        clickRecognizer.numberOfTapsRequired = 1;
        [_rippleContainer addGestureRecognizer:clickRecognizer];
        
        // view tree
        [_rippleContainer addSubview:ringView];
        [_rippleContainer addSubview:staticPointView];
        
        [tabBar addSubview:_rippleContainer];
        [self.view addSubview:_rippleToolTipView];
        
        [self startToAnimateGuide];
    }
}

- (void) startToAnimateGuide {
    [UIView animateWithDuration:0.8 animations:^{
        UIView *ringView = [_rippleContainer viewWithTag:TAG_RING_VIWE];
        UIView *pointView = [_rippleContainer viewWithTag:TAG_POINT_VIWE];
        ringView.alpha = 0;
        CGFloat scale = _rippleContainer.frame.size.width / pointView.frame.size.width;
        ringView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
    } completion:^(BOOL finished){
        if ([UserDefaultsManager boolValueForKey:KEY_PAD_TOOL_TIP_CLICKED defaultValue:NO]) {
            return;
        }
        UIView *ringView = [_rippleContainer viewWithTag:TAG_RING_VIWE];
        ringView.alpha = 1;
        ringView.transform = CGAffineTransformIdentity;
        [self startToAnimateGuide];
    }];
}

- (UIView *) getToolTipView {
    UIImage *triangleImage = [TPDialerResourceManager getImage:@"ripple_tool_tip_triangle@2x.png"];
    CGSize triangleSize = triangleImage.size;
    
    CGFloat gap = isIPhone5Resolution() ? 5: 3;
    CGSize labelSize = CGSizeMake(138, 30);
    
    CGSize containerSize = CGSizeMake(labelSize.width, labelSize.height + triangleSize.height + gap);
    
    CGFloat containerY = (TPScreenHeight() - containerSize.height - self.parent.tabBar.frame.size.height);
    if ([FunctionUtility systemVersionFloat] < 7.0) {
        containerY = containerY - 20;
    }
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake((TPScreenWidth() - containerSize.width)/2, containerY, containerSize.width, containerSize.height)];
    container.backgroundColor = [UIColor clearColor];
    
    CGFloat gY = 0;
    
    // label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, gY, labelSize.width, labelSize.height)];
    label.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
    label.layer.cornerRadius = labelSize.height / 2;
    label.clipsToBounds = YES;
    label.text = NSLocalizedString(@"click_to_show_keypad", @"点击展开拨号盘");
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    
    gY += label.frame.size.height;
    
    // triangle image view
    UIImageView *triangleView = [[UIImageView alloc] initWithFrame:CGRectMake((containerSize.width - triangleSize.width) / 2, gY, triangleSize.width, triangleSize.height)];
    triangleView.contentMode = UIViewContentModeScaleToFill;
    triangleView.image = triangleImage;
    
    // view tree
    [container addSubview:label];
    [container addSubview:triangleView];
    
    return container;
}

- (void) hideAnimationForHidingKeypad {
    _rippleToolTipView.hidden = YES;
    _rippleContainer.hidden = YES;
}

- (void) hideHintView:(BOOL)toHide {
    self.hintView.hidden = toHide;
    if (!toHide) {
        // to show the phonepad_view
        if ([self shouldShowRippleAnimation]) {
            [DialerUsageRecord recordpath:PATH_CALLLOG_EMPTY kvs:Pair(CALLLOG_EMPTY_CLICK_KEY_PAD, @(1)), nil];
            [self animationForHidingKeypad];
        }
    }
}

- (void) onClickRippleContainer {
    [self.parent.tabBar selectTabAtIndex:1];
}

- (BOOL) shouldShowRippleAnimation {
    BOOL isNewInstall = [UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE defaultValue:nil] == nil;
    BOOL toolTipClicked = [UserDefaultsManager boolValueForKey:KEY_PAD_TOOL_TIP_CLICKED defaultValue:NO];
    return isNewInstall && !toolTipClicked;
}
@end
