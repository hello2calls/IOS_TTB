//
//  DownloadOtherAppController.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/10/23.
//
//

#import "DownloadOtherAppController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TPDialerResourceManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "LoginController.h"
#import "DefaultLoginController.h"

const static CGFloat    kBtnHeight = 56.0f;
const static CGFloat    kImgWidth = 260.0f;
const static CGFloat    kImgHeight = 122.0f;

#define kTitle              @"title"
#define kAppScheme          @"appscheme"
#define kAppStoreID         @"appstoreid"
#define kAppID              @"appid"
#define kParamJson          @"param"
#define kEncouragement      @"type"

#define kHighlightedColor   [TPDialerResourceManager getColorForStyle:@"download_app_button_highlight_color"]
#define kNormalColor        [TPDialerResourceManager getColorForStyle:@"download_app_button_nomorl_color"]

typedef NS_ENUM (NSInteger, PageStatus) {
    Page_Firstin,
    Page_Downloaded,
    Page_Openfailed,
    Page_GetAwardsuccess,
    Page_GetAwardfailed,
    Page_GetAwardTwice
};

typedef NS_ENUM (NSInteger, OpenUrlSchemeStatus) {
    OpenUrlSchemeFail,
    OpenUrlSchemeSuccess,
    OpenUrlSchemeSuccess_WillResignActive,
    OpenUrlSchemeSuccess_DidEnterBackground,
};

@interface DownloadOtherAppController () {
    UIView      *_tipsView;
    UILabel     *_tipsTextView;
    UIButton    *_cancelButton;
    UIButton    *_downloadButton;
    UIButton    *_reDownloadButton;
    UIButton    *_reOpenButton;
    UIButton    *_openButton;
    UIImageView *_tipsImageView;

    PageStatus _pageStatus;
    OpenUrlSchemeStatus _openUrlSchemeStatus;
}
@property(nonatomic, strong) HeaderBar  *headerView;
@property(nonatomic, copy) NSDictionary *jsCallParam;
@end

@implementation DownloadOtherAppController

#pragma mark - LifeCycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        _pageStatus = Page_Firstin;
        _openUrlSchemeStatus = OpenUrlSchemeFail;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showViewForStatus:_pageStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Config View

- (void)configView
{
    // title
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];

    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    self.headerView = headerBar;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth() - 120) / 2.0, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];

    NSString *title = self.jsCallParam[kParamJson][kTitle];
    titleLabel.text = title.length ? title : @"下载";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:titleLabel];

    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];

    const CGFloat   viewWith = self.view.frame.size.width;
    CGFloat         yy = self.headerView.frame.size.height;

    // tips view
    _tipsView = [[UIView  alloc] initWithFrame:CGRectMake(0, yy, viewWith, 233)];
    _tipsView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"download_app_success_bg_color"];

    // tips Label
    _tipsTextView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWith, 233 - kImgHeight)];
    _tipsTextView.backgroundColor = [UIColor clearColor];
    _tipsTextView.textColor = [UIColor whiteColor];
    _tipsTextView.textAlignment = NSTextAlignmentCenter;
    _tipsTextView.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    _tipsTextView.numberOfLines = 0;
    _tipsTextView.attributedText = [self createAttributedString:@"应用下载后，\n必须通过此页面打开才能获得奖励。"];

    [_tipsView addSubview:_tipsTextView];

    // tips image
    _tipsImageView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWith - kImgWidth) / 2.0, (233 - kImgHeight), kImgWidth, kImgHeight)];
    _tipsImageView.image = [TPDialerResourceManager getImage:@"downloadotherapp_normal@2x.png"];
    [_tipsView addSubview:_tipsImageView];

    [self.view addSubview:_tipsView];

    yy += (233 + 20);

    CGFloat btnWidth = (viewWith - 10) / 2.0 - 15.0;
    
    // cancel Button
    _cancelButton = [self createButtonWithTitle:@"取消"];
    _cancelButton.frame = CGRectMake(15, yy, btnWidth, kBtnHeight);
    _cancelButton.layer.borderColor = [kHighlightedColor CGColor];
    [_cancelButton setTitleColor:kHighlightedColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:kNormalColor forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_cancelButton];

    // download Button
    _downloadButton = [self createButtonWithTitle:@"确认下载"];
    _downloadButton.frame = CGRectMake(viewWith - btnWidth - 15, yy, btnWidth, kBtnHeight);
    [_downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_downloadButton];

    // redownload button
    _reDownloadButton = [self createButtonWithTitle:@"重新下载"];
    _reDownloadButton.frame = CGRectMake(15, yy, btnWidth, kBtnHeight);
    _reDownloadButton.hidden = YES;
    [_reDownloadButton addTarget:self action:@selector(reDownloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_reDownloadButton];

    // reopen button
    _reOpenButton = [self createButtonWithTitle:@"再次打开"];
    _reOpenButton.frame = CGRectMake(viewWith - btnWidth - 15, yy, btnWidth, kBtnHeight);
    _reOpenButton.hidden = YES;
    [_reOpenButton addTarget:self action:@selector(reOpenButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_reOpenButton];

    // open button | confirm button | reopen button
    _openButton = [self createButtonWithTitle:@"打开"];
    _openButton.frame = CGRectMake(15.0, yy, viewWith - 15 * 2.0, kBtnHeight);
    _openButton.hidden = YES;
    [_openButton addTarget:self action:@selector(openButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:_openButton];
}

- (NSAttributedString *)createAttributedString:(NSString *)string
{
    if (!string) {
        return nil;
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
        NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE_3],
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSParagraphStyleAttributeName:paragraphStyle
    };

    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (UIButton *)createButtonWithTitle:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    btn.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
    btn.backgroundColor = [UIColor clearColor];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 4.0;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [kNormalColor CGColor];

    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kNormalColor forState:UIControlStateNormal];
    [btn setTitleColor:kHighlightedColor forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchDragOutside];
    [btn addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchUpOutside];

    return btn;
}

- (void)changeButton:(UIButton *)btn status:(BOOL)highlighted
{
    if (btn) {
        UIColor *color = highlighted ? kHighlightedColor : kNormalColor;
        btn.layer.borderColor = [color CGColor];
    }
}

- (void)showViewForStatus:(PageStatus)status
{
    switch (status) {
        case Page_Firstin:
            _downloadButton.hidden = NO;
            _cancelButton.hidden = NO;
            _reOpenButton.hidden = YES;
            _reDownloadButton.hidden = YES;
            _openButton.hidden = YES;
            _tipsTextView.attributedText = [self createAttributedString:@"应用下载后\n必须通过本页面打开才能获得奖励"];
            _tipsImageView.image = [TPDialerResourceManager getImage:@"downloadotherapp_normal@2x.png"];
            _tipsView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"download_app_success_bg_color"];
            break;

        case Page_Downloaded:
            _downloadButton.hidden = YES;
            _cancelButton.hidden = YES;
            _reOpenButton.hidden = YES;
            _reDownloadButton.hidden = YES;
            _openButton.hidden = NO;
            [_openButton setTitle:@"打开" forState:UIControlStateNormal];
            _tipsTextView.attributedText = [self createAttributedString:@"应用安装完成后\n通过本页面打开领取奖励"];
            _tipsImageView.image = [TPDialerResourceManager getImage:@"downloadotherapp_normal@2x.png"];
            _tipsView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"download_app_success_bg_color"];
            break;

        case Page_Openfailed:
            _downloadButton.hidden = YES;
            _cancelButton.hidden = YES;
            _reOpenButton.hidden = NO;
            _reDownloadButton.hidden = NO;
            _openButton.hidden = YES;
            _tipsTextView.attributedText = [self createAttributedString:@"抱歉，因为下载失败或其他原因\n应用打开失败，未能获得奖励"];
            _tipsImageView.image = [TPDialerResourceManager getImage:@"downloadotherapp_fail@2x.png"];
            _tipsView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"download_app_fail_bg_color"];
            break;

        case Page_GetAwardsuccess:
        case Page_GetAwardTwice:
        case Page_GetAwardfailed:
            _downloadButton.hidden = YES;
            _cancelButton.hidden = YES;
            _reOpenButton.hidden = YES;
            _reDownloadButton.hidden = YES;
            _openButton.hidden = NO;

            if ((_pageStatus == Page_GetAwardsuccess) || (_pageStatus == Page_GetAwardTwice)) {
                [_openButton setTitle:@"确定" forState:UIControlStateNormal];
                _tipsTextView.attributedText = [self createAttributedString:(_pageStatus == Page_GetAwardsuccess) ? @"恭喜您，奖励领取成功！" : @"您已经领取过奖励啦！"];
                _tipsImageView.image = [TPDialerResourceManager getImage:@"downloadotherapp_getreward_success@2x.png"];
                _tipsView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"download_app_getreward_success_bg_color"];
            } else {
                [_openButton setTitle:@"再次打开" forState:UIControlStateNormal];
                _tipsTextView.attributedText = [self createAttributedString:@"抱歉，奖励发放失败\n请再次打开应用"];
                _tipsImageView.image = [TPDialerResourceManager getImage:@"downloadotherapp_getreward_fail@2x.png"];
                _tipsView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"download_app_getreward_fail_bg_color"];
            }

            break;

        default:
            break;
    }
}

#pragma mark - Action

- (void)gobackBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downloadButtonAction:(id)sender
{
    NSString *appStoreID = self.jsCallParam[kParamJson][kAppStoreID];

    if (appStoreID.length) {
        [DownloadOtherAppController openAppStoreWithID:appStoreID];
        _pageStatus = Page_Downloaded;
    } else {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"页面数据出错啦，请返回刷新后再试试" message:nil onlyOkButtonActionBlock:^{}];
    }
}

- (void)reDownloadButtonAction:(id)sender
{
    [self downloadButtonAction:nil];
}

- (void)reOpenButtonAction:(id)sender
{
    [self openButtonAction:nil];
}

- (void)openButtonAction:(id)sender
{
    NSString    *urlScheme = self.jsCallParam[kParamJson][kAppScheme];
    
    if ((_pageStatus == Page_GetAwardsuccess) || (_pageStatus == Page_GetAwardTwice)) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        if ([DownloadOtherAppController openOtherAppWithUrlScheme:urlScheme]) {
            _openUrlSchemeStatus = OpenUrlSchemeSuccess;
        } else {
            _openUrlSchemeStatus = OpenUrlSchemeFail;
            _pageStatus = Page_Openfailed;
            [self showViewForStatus:_pageStatus];
        }
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlScheme]]) {
            [DownloadOtherAppController openOtherAppWithUrlScheme:urlScheme];
            [self getReward];
        }else{
            _pageStatus = Page_Openfailed;
            [self showViewForStatus:_pageStatus];
        }
    }
}

- (void)buttonTouchDown:(id)sender
{
    UIButton    *btn = (UIButton *)sender;
    BOOL        highlighted = YES;

    if (btn == _cancelButton) {
        highlighted = NO;
    }

    [self changeButton:btn status:highlighted];
}

- (void)buttonTouchCancel:(id)sender
{
    UIButton    *btn = (UIButton *)sender;
    BOOL        highlighted = NO;

    if (btn == _cancelButton) {
        highlighted = YES;
    }

    [self changeButton:btn status:highlighted];
}

#pragma mark - Public

+ (void)handleJSCallWithParam:(NSDictionary *)param
{
    NSString        *appid = param[kAppID];
    id              jsonParam = param[kParamJson];
    NSDictionary    *dic = nil;

    if ([jsonParam isKindOfClass:[NSDictionary class]]) {
        dic = jsonParam;
    } else if ([jsonParam isKindOfClass:[NSString class]]) {
        NSData *data = [jsonParam dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        dic = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers| NSJSONReadingMutableLeaves error:&error];
    } else {
        dic = nil;
    }

    if (([appid length] == 0) || (dic == nil)) {
        cootek_log(@"handleJSCallWithParam has wrong param");
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"页面数据出错啦，请刷新后再试试" message:nil onlyOkButtonActionBlock:^{}];
        return;
    }

    NSString    *appStoreID = dic[kAppStoreID];
    NSNumber    *hasEncouragement = dic[kEncouragement];

    if ([hasEncouragement boolValue]) {
        DownloadOtherAppController *ctrl = [[DownloadOtherAppController alloc] init];
        ctrl.jsCallParam = @{kAppID:appid, kParamJson:dic};
        [[TouchPalDialerAppDelegate naviController] pushViewController:ctrl animated:YES];
    } else {
        // goto app store
        [self openAppStoreWithID:appStoreID];
    }
}

#pragma mark - Private

- (void)getReward
{
    NSString    *appid = self.jsCallParam[kAppID];
    NSString    *phone = [UserDefaultsManager stringForKey:@"VOIP_REGISTER_ACCOUNT_NAME"];
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSInteger status = [SeattleFeatureExecutor getAppDownloadAwardWithAppID:appid userPhoneNumber:phone];
        if (status == 0) {
            _pageStatus = Page_GetAwardsuccess;
        } else if (status == 1) {
            _pageStatus = Page_GetAwardTwice;
        } else {
            _pageStatus = Page_GetAwardfailed;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showViewForStatus:_pageStatus];
        });
    });
}

+ (void)openAppStoreWithID:(NSString *)appid
{
    if (appid.length == 0) {
        return;
    }

    NSString    *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appid];
    NSURL       *url = [NSURL URLWithString:urlString];

    [[UIApplication sharedApplication] openURL:url];
}

+ (BOOL)openOtherAppWithUrlScheme:(NSString *)scheme
{
    if (scheme.length == 0) {
        return NO;
    }

    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
}

#pragma mark - NotificationCenter

- (void)willResignActiveNotification
{
    if (_openUrlSchemeStatus == OpenUrlSchemeSuccess) {
        _openUrlSchemeStatus = OpenUrlSchemeSuccess_WillResignActive;
    }
}

- (void)didEnterBackgroundNotification
{
    if (_openUrlSchemeStatus == OpenUrlSchemeSuccess_WillResignActive) {
        _openUrlSchemeStatus = OpenUrlSchemeSuccess_DidEnterBackground;
        [self getReward];
    }
    [self showViewForStatus:_pageStatus];
}

- (void)willEnterForegroundNotification
{
    [self showViewForStatus:_pageStatus];
}

- (void)didBecomeActiveNotification
{
    if (_openUrlSchemeStatus == OpenUrlSchemeSuccess_WillResignActive) {
        _openUrlSchemeStatus = OpenUrlSchemeFail;
        _pageStatus = Page_Openfailed;
        [self showViewForStatus:_pageStatus];
    }
}

@end
