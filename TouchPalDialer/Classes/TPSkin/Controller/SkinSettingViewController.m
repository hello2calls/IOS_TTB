//
//  SkinSettingViewController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 6/18/12.
//  Refactored by Leon Lu on 5/16/13.
//  Copyright (c) 2012 CooTek. All rights reserved.
//

#import "SkinSettingViewController.h"
#import "TPDialerResourceManager.h"
#import "TPHeaderButton.h"
#import "UITableView+TP.h"
#import "SkinHandler.h"
#import "DefaultUIAlertViewHandler.h"
#import "UITableView+TP.h"
#import "WebSkinInfoProvider.h"
#import "TouchPalVersionInfo.h"
#import "CootekNotifications.h"
#import "UIButton+DoneButton.h"
#import "NetworkDataDownloader.h"
#import "SkinDataDownloadJob.h"
#import "RemoteSkinReloadView.h"
#import "RemoteSkinEmptyView.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "AppSettingsModel.h"
#import <AVFoundation/AVFoundation.h>
#import "DialToneTips.h"
#import "CommonSettingViewController.h"
#import "SettingsModelCreator.h"
#import "TouchPalDialerAppDelegate.h"
#import "TurnToneTips.h"
#import "SkinPreviewViewController.h"
#import "WebSkinInfoProvider.h"
#import "FileUtils.h"
#import "CommonWebView.h"
#import "CootekWebHandler.h"
#import "Reachability.h"
#import "NSString+TPHandleNil.h"
#import "CommercialSkinManager.h"
#import "TPDMySkinViewController.h"
#define BLOCK_VIEW_IN_SKIN_SETTING_CONTROLLER 138422

@interface SkinSettingViewController () <UIWebViewDelegate, CootekWebHandlerDelegate>{
    UIScrollView *localScrollView_;
    CommonWebView *_commonWebView;
    CootekWebHandler *_webHandler;
    HeaderBar *headBar_;
    BOOL isEditing_;
    BOOL isLocal_;
    BOOL _hasNewDownloadedSkin;
    NSInteger localAnimationOngoingCount_;
    BOOL isFirst_;
    BOOL hasChanged_;
}
@property (nonatomic, retain) NSArray       *onlineSkins;
@property (nonatomic, retain) TPHeaderButton*editButton;
@property (nonatomic, retain) AVPlayer      *player;
@property (nonatomic, strong) TPHeaderButton*backBtn;
@property (nonatomic, strong) HeadTabBar    *titleBar;
@end

@implementation SkinSettingViewController

@synthesize startPage;

- (void)dealloc
{
    if(self.view != nil) {
        [[TPDialerResourceManager sharedManager] removeSkinHandlerForView:self.view];
    }
    [SkinHandler removeRecursively:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight());
    // skin list page bg: grey_50
    UIColor *colorGrey50 = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"];
    [self.view setBackgroundColor:colorGrey50];

    // local scroll view
    localScrollView_ = [[UIScrollView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    localScrollView_.showsHorizontalScrollIndicator = NO;
    localScrollView_.showsVerticalScrollIndicator = NO;
    localScrollView_.alwaysBounceVertical = YES;
    localScrollView_.backgroundColor = colorGrey50;
    [self.view addSubview:localScrollView_];
    
	// head bar
    headBar_ = [[HeaderBar alloc] initHeaderBar];
    [self.view addSubview:headBar_];
    [headBar_ setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    
    HeadTabBar *titleBar = [[HeadTabBar alloc] initWithFrame:CGRectMake((TPScreenWidth()-184)/2, 7.5+TPHeaderBarHeightDiff(), 184, 30) buttonCount:isVersionSix?1:2];
    titleBar.changeSkinHeadTabBar = YES;
    [titleBar tabBarTitle:isVersionSix?@[@"个性换肤"] : [NSArray arrayWithObjects:NSLocalizedString(@"More Themes", @""),NSLocalizedString(@"Theme", @""),nil]];
    [titleBar setSkinStyleWithHost:self forStyle:@"theme_headtabbar_style"];
    titleBar.delegate = self;
    self.titleBar = titleBar;
    [headBar_ addSubview:titleBar];
    
    //初始化hasChanged_，让它可以第一次进来加载页面
    hasChanged_ = YES;
    if (isVersionSix) {
        [titleBar clickTabIndex:-1];
        startPage = REMOTE_TAB_SKIN_INDEX;
    } else {
    
        if (startPage == UNKNOWN_TAB_SKIN_INDEX) {
            [titleBar clickTabIndex:LOCAL_TAB_SKIN_INDEX];
        } else {
            [titleBar clickTabIndex:startPage];
        }

    }
    
    // edit button
    TPHeaderButton *tmpEdit = [[TPHeaderButton alloc] initWithFrame:CGRectMake(TPScreenWidth() - 55, 0, 50, 45)];
    [tmpEdit setSkinStyleWithHost:self forStyle:@"defaultTPHeaderButton_style"];
    tmpEdit.titleLabel.font = [UIFont systemFontOfSize:16];
    [tmpEdit setTitle:isVersionSix ? @"我的" : NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
    [tmpEdit addTarget:self action:@selector(editDidClick) forControlEvents:UIControlEventTouchUpInside];
    tmpEdit.titleLabel.font = [UIFont systemFontOfSize:CELL_FONT_MEDIUM];
    self.editButton = tmpEdit;
    [headBar_ addSubview:tmpEdit];
    
    isLocal_ = startPage != REMOTE_TAB_SKIN_INDEX;

    if (isVersionSix) {
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        [self.editButton setTitleColor:tColor forState:UIControlStateNormal];
        // back button
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [backBtn setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
        backBtn.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon1" size:22];
        [backBtn setTitle:@"0" forState:UIControlStateNormal];
        [backBtn setTitle:@"0" forState:UIControlStateHighlighted];
        [backBtn setTitleColor:tColor forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar_ addSubview:backBtn];
        self.backBtn = backBtn;
    }else {
        // back button
        TPHeaderButton *backBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0,50, 45)];
        [backBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar_ addSubview:backBtn];
        
    }


    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin) name:N_SKIN_DID_CHANGE object:nil];
    _hasNewDownloadedSkin = NO;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FunctionUtility updateStatusBarStyle];
    if (isFirst_ && !isLocal_ && hasChanged_){
        [self addWebView];
    }else{
        isFirst_ = YES;
    }
}

- (void)viewDidLoad
{
    [FunctionUtility setAppHeaderStyle];
    [super viewDidLoad];
    [self loadData:NO];
    [[TPDialerResourceManager sharedManager] addSkinHandlerForView:self.view];
    
    // update skin item status
    [self updateLocalSkinItemUIByStatus];
}

- (void)loadData:(BOOL) isRefresh
{
    if (isRefresh){
        [UserDefaultsManager setBoolValue:YES forKey:ASK_LIKE_VIEW_COULD_SHOW];
    }
    isEditing_ = NO;
    // configure local scroll view
    NSArray *localUsableSkins = [self localUsableSkins];
    [self configureLocalScrollView:localUsableSkins isEditing:NO];
    [self resetLocalSkinEditButton:localUsableSkins];
}

- (void)editDidClick
{
    
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if (isVersionSix) {
        //my local skin
        [self.navigationController pushViewController:[TPDMySkinViewController new] animated:YES];
    } else {
        if (!isEditing_) {
            [self.editButton setTitle:isVersionSix ? @"我的" : NSLocalizedString(@"Done",@"") forState:UIControlStateNormal];
            isEditing_ = YES;
        } else {
            [self.editButton setTitle:isVersionSix ? @"我的" : NSLocalizedString(@"Edit",@"") forState:UIControlStateNormal];
            isEditing_ = NO;
        }
        [self updateLocalScrollViewDeleteButtonVisibility];
        
    }
    
}

- (void)changeSkin
{
    hasChanged_ = YES;
    [self updateLocalSkinItemUIByStatus];
    [FunctionUtility updateStatusBarStyle];
}

- (void) updateLocalSkinItemUIByStatus {
    NSString *skinId = nil;
    for (UIView *subView in localScrollView_.subviews) {
        if ([subView isKindOfClass:[LocalSkinItemView class]]) {
            LocalSkinItemView *localItem =((LocalSkinItemView*)subView);
            skinId = localItem.skinInfo.skinID;
            RemoteSkinItemButtonStatus status = SkinItemStatusNotDownloaded;
            if ([[TPDialerResourceManager sharedManager].skinTheme isEqualToString:skinId]) {
                status = SkinItemStatusUsed;
            } else if ([[TPDialerResourceManager sharedManager] isSkinExisting:skinId]) {
                status = SkinItemStatusDownloaded;
            }
            localItem.buttonStatus = status;
        }
        
    }
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if (isVersionSix) {
        UIColor *tColor =[TPDialerResourceManager getColorForStyle:@"skinHeaderBarOperationText_normal_color"];
        [self.editButton setTitleColor:tColor forState:UIControlStateNormal];
        // back button
        [self.backBtn       setTitleColor:tColor forState:UIControlStateNormal];
        [self.editButton    setTitleColor:tColor forState:UIControlStateNormal];
        [(UIButton *)self.titleBar.buttonArray[0] setTitleColor:[TPDialerResourceManager getColorForStyle:@"skinHeaderBarTitleText_color"] forState:UIControlStateNormal];
    }
}

- (void)localSkinItemViewDidClick:(LocalSkinItemView *)itemView
{
    if (isEditing_) {
        return;
    }
    // apply skin change
    NSString *skinId = itemView.skinInfo.skinID;
    [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_CLICK, [NSString nilToEmpty:skinId]), nil];
    
    [TPDialerResourceManager sharedManager].skinTheme = skinId;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SKIN_SHOULD_CHANGE object:nil];
    // reload scroll view
    [self configureLocalScrollView:[self localUsableSkins] isEditing:NO];
    [self loadData:YES];
    if (itemView.skinInfo.hasSound == YES) {
        if ([UserDefaultsManager objectForKey:@"SHARE_RING_DATA"] ==nil) {
            [UserDefaultsManager setObject:[NSDate date] forKey:@"SHARE_RING_DATA"];
            NSLog(@"%@", [UserDefaultsManager objectForKey:@"SHARE_RING_DATA"]);
        }
        AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
        if (appSettingsModel.dial_tone==NO) {
            cootek_log(@"还没开按键音");
           TurnToneTips *tips = [[TurnToneTips alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) titleString:@"检测到您未开启拨号盘按键音，是否立即开启？" leftString:@"暂不开启" rightString:@"立即开启" sureBlock:^{
                CommonSettingViewController *vc = [[CommonSettingViewController alloc] init];
                [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];

            }] ;
            [DialogUtil showDialogWithContentView:tips inRootView:self.view];
            
        }
    }
}

- (void)localSkinItemViewDeleteButtonDidClick:(LocalSkinItemView *)itemView
{
    // animation
    itemView.transform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformScale(itemView.transform, 0.001, 0.001);
    [UIView beginAnimations:@"scale" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [itemView setTransform:transform];
    [UIView commitAnimations];
    
    localAnimationOngoingCount_++;
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        localAnimationOngoingCount_--;
        
        if (!isEditing_ || itemView.skinInfo.isBuiltIn) {
            return;
        }
        
        // delete skin
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:itemView.skinInfo.skinDir error:nil];
        
        // apply default skin change
        if ([itemView.skinInfo.skinID isEqualToString:[TPDialerResourceManager sharedManager].skinTheme]) {
            [TPDialerResourceManager sharedManager].skinTheme = DEFAULT_SKIN_THEME;
            [[NSNotificationCenter defaultCenter] postNotificationName:N_SKIN_SHOULD_CHANGE object:nil];
        }
        
        if ([itemView.skinInfo.skinID rangeOfString:@".AD."].length > 0) {
            [CommercialSkinManager deleteCommercialSkinInfoWithSkinId:itemView.skinInfo.skinID];
            [UserDefaultsManager setBoolValue:YES forKey:[@"ifAutoShowSkin" stringByAppendingString:itemView.skinInfo.skinID]];
        }
        if (localAnimationOngoingCount_ == 0) {
            NSArray *localUsableSkins = [self localUsableSkins];
            [self configureLocalScrollView:localUsableSkins isEditing:YES];
            [self resetLocalSkinEditStateInEditingMode:localUsableSkins];
        }
    });
}

- (void) localSkinItemIconDidClick:(LocalSkinItemView *)itemView {
    cootek_log(@"SkinSettingViewController, local skin item icon did click");
    [self goToSkinPreview:itemView];
}

- (void) goToSkinPreview:(UIView *) view {
    if (!view) return;
    TPSkinInfo *info = nil;
    RemoteSkinItemButtonStatus status = SkinItemStatusNotDownloaded;
    if ([view isKindOfClass:[LocalSkinItemView class]] ) {
        info = ((LocalSkinItemView *)view).skinInfo;
        status = ((LocalSkinItemView *)view).buttonStatus;
        cootek_log(@"theme: %@, skinId: %@, skinDir: %@",
                   [TPDialerResourceManager sharedManager].skinTheme,info.skinID, info.skinDir);
        SkinPreviewViewController *skinPreveiwController = [[SkinPreviewViewController alloc] initWithSkinItemView:view];
        [self.navigationController pushViewController:skinPreveiwController animated:YES];
    }
}



- (NSArray *)localUsableSkins
{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];

    [[TPDialerResourceManager sharedManager] loadAllSkinInfoList];
    NSArray *allSkins = [TPDialerResourceManager sharedManager].allSkinInfoList;

    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:allSkins.count];
    for (TPSkinInfo *skinInfo in allSkins) {
        if ([CommercialSkinManager checkSkinInPlistAndFileWithSkinID:skinInfo.skinID] && [CommercialSkinManager checkLocalSkinShouldShowWithSkinID:skinInfo.skinID]==NO) {
            continue;
        }
        if (skinInfo.version >= [LOWEST_SKIN_VERSION_CAN_BE_USED intValue]) {
            if (!isVersionSix) {
                if (skinInfo.version > [NEW_SKIN_VERSION_CAN_BE_USED intValue]) continue;
            }else {
                if (skinInfo.version < [NEW_SKIN_VERSION_CAN_BE_USED intValue]) continue;
            }
            [tmpArr addObject:skinInfo];
        }
    }
    return tmpArr;
}

- (void)configureLocalScrollView:(NSArray *)localUsableSkins isEditing:(BOOL)isEditing
{
    // for managing the downloaded skins
    for (UIView *subView in localScrollView_.subviews) {
        if ([subView isKindOfClass:[LocalSkinItemView class]]) {
            [subView removeFromSuperview];
        }
    }

    int i = 0;
    CGFloat skinItemHeight = 0;
    CGFloat diff = 20;
    if ([[UIDevice currentDevice].systemVersion intValue] <7) {
        diff = 0;
    }
    for (TPSkinInfo *skinInfo in localUsableSkins) {
        LocalSkinItemView __strong *skinView = [[LocalSkinItemView alloc] initWithSkinInfo:skinInfo];
        skinView.isChecked = [skinInfo.skinID isEqualToString:[TPDialerResourceManager sharedManager].skinTheme];
        skinView.showsCheckedView = skinView.isChecked;
        
        // is in editing mode or not
        if (isEditing) {
            skinView.showsDeleteButton = !skinInfo.isBuiltIn;
            skinView.showsCheckedView = NO;
        } 
        if (skinItemHeight == 0) {
            skinItemHeight = skinView.frame.size.height;
        }
        CGFloat y = i * (10 + skinItemHeight) + 10;
        skinView.frame = CGRectMake(0, y - diff, skinView.bounds.size.width, skinView.bounds.size.height);
        skinView.delegate = self;
        skinView.horn.hidden = !skinInfo.hasSound;
        [localScrollView_ addSubview:skinView];
        i++;
    }
    CGFloat contentHeight = localUsableSkins.count * (skinItemHeight + 10) + 10 - 20;
    localScrollView_.contentSize = CGSizeMake(TPScreenWidth(), contentHeight);
}

- (void)updateLocalScrollViewDeleteButtonVisibility
{
    for (UIView *subView in localScrollView_.subviews) {
        if ([subView isKindOfClass:[LocalSkinItemView class]]) {
            LocalSkinItemView *itemView = (LocalSkinItemView *)subView;
            if (isEditing_) {
                if(itemView.skinInfo.isBuiltIn) {
                    itemView.showsDeleteButton = NO;
                }
            } else {
                itemView.showsDeleteButton = YES;
            }
            //BOOL isChecked = itemView.isChecked;
            [itemView setButtonStatus:itemView.buttonStatus isEditing:isEditing_];
            cootek_log(@"isEditing: %d", isEditing_);
            //itemView.showsCheckedView = isChecked && (!isEditing_);
        }
    }
}

- (BOOL)uninstallableLocalSkinExisting:(NSArray *)localUsableSkins
{
    if (!isLocal_) {
        return NO;
    }
    for (TPSkinInfo *skinInfo in localUsableSkins) {
        if (!skinInfo.isBuiltIn) {
            return YES;
        }
    }
    return NO;
}

- (void)resetLocalSkinEditButton:(NSArray *)localUsableSkins
{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];

    [self.editButton setTitle:isVersionSix ? @"我的" : NSLocalizedString(@"Edit",@"") forState:UIControlStateNormal];
    isEditing_ = NO;
    self.editButton.hidden = isVersionSix ? NO : ![self uninstallableLocalSkinExisting:localUsableSkins];
}

- (void)resetLocalSkinEditStateInEditingMode:(NSArray *)localUsableSkins
{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    BOOL uninstallableLocalSkinExisting = [self uninstallableLocalSkinExisting:localUsableSkins];
    if (!uninstallableLocalSkinExisting) {
        [self editDidClick];
    }
    self.editButton.hidden = isVersionSix ? NO :  !uninstallableLocalSkinExisting;
}

- (void)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark HeadTabBarDelegate
- (void)onClickAtIndexBar:(NSInteger)index
{
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if (isVersionSix) {
        index = REMOTE_TAB_SKIN_INDEX;
    }
    
    if (index == LOCAL_TAB_SKIN_INDEX) {
        isLocal_ = YES;
        localScrollView_.hidden = NO;
        _commonWebView.hidden = YES;
        NSArray *localUsableSkins = [self localUsableSkins];
        [self configureLocalScrollView:localUsableSkins isEditing:NO];
        [self resetLocalSkinEditButton:localUsableSkins];
        [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_ENTRANCE, @"local"), nil];
    } else if(index == REMOTE_TAB_SKIN_INDEX) {
        [self addWebView];
        isLocal_ = NO;
        self.editButton.hidden = isVersionSix ? NO : YES;
        localScrollView_.hidden = YES;
        _commonWebView.hidden = NO;
        [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_ENTRANCE, @"remote"), nil];
    }
}

- (void)registerHandlerEvent{
    _webHandler = nil;
    _webHandler = [[CootekWebHandler alloc]initWithWebView:_commonWebView.web_view andDelegate:self];
    _webHandler.webDelegate = self;
    [_webHandler registerHandler];
}

- (void)clearWebView{
    [_commonWebView removeFromSuperview];
    _commonWebView = nil;
}

- (void)addWebView{
    if (!hasChanged_)
        return;
    hasChanged_ = NO;
    if (_commonWebView != nil )
        [self clearWebView];
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];

    NSString *webUrl = [NSString stringWithFormat:@"http://dialer.cdn.cootekservice.com/web/internal/app_skin/index.html?lang=%@&version=%@&skin_version=%@&newversion=%@",NSLocalizedString(@"skin_lang",@"cn"),CURRENT_TOUCHPAL_VERSION,LOWEST_SKIN_VERSION_CAN_BE_USED,isVersionSix ? @"v6":@"v5"];
    _commonWebView = [[CommonWebView alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415)) andIfNoah:NO andUsingWkWebview:NO];
    
    [_commonWebView.web_view setDelegateViews:self];
    _commonWebView.url_string = webUrl;
    [self.view addSubview:_commonWebView];
    [_commonWebView loadURL];
    [self registerHandlerEvent];

}


#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if (_commonWebView.needLoad) {
        [_commonWebView showLoading];
        _commonWebView.needLoad = NO;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_commonWebView.hasLoaded) {
        return;
    }
    
    ClientNetworkType netType = [[Reachability shareReachability] networkStatus];
    if (netType == network_none){
        cootek_log(@"webview no net");
        _commonWebView.hasLoaded = NO;
        [_commonWebView showReload];
        return;
    }
    
    _commonWebView.hasLoaded = YES;
    [_commonWebView showPage];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    _commonWebView.hasLoaded = NO;
    cootek_log(@"webview error : %@",[error localizedDescription]);
    if (error.code == 102) {
        [_commonWebView showReloadWithText:@"此链接不可用"];
    } else if (error.code != NSURLErrorCancelled) {
        [_commonWebView showReload];
    }
}

#pragma mark 

- (void)setHeaderTitle:(NSString *)headerTitle{
}

- (void) setWebViewScroll:(BOOL)ifScroll{
    if ( [_commonWebView.web_view isKindOfClass:[UIWebView class]] ){
        ((UIWebView *)_commonWebView.web_view).scrollView.scrollEnabled = ifScroll;
    }else if ( [_commonWebView.web_view isKindOfClass:[WKWebView class]] ){
        ((WKWebView *)_commonWebView.web_view).scrollView.scrollEnabled = ifScroll;
    }
}

@end
