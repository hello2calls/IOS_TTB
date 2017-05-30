//
//  SkinPreviewViewController.m
//  TouchPalDialer
//
//  Created by siyi on 15/10/28.
//
//

#import <Foundation/Foundation.h>
#import "SkinPreviewViewController.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "NetworkUtility.h"
#import "HeaderBar.h"
#import "Reachability.h"
#import "VoipShareAllView.h"
#import "TouchPalDialerAppDelegate.h"
#import "NetworkDataDownloader.h"
#import "RemoteSkinItemView.h"
#import "DialerUsageRecord.h"
#import "SkinDataDownloadJob.h"
#import "CootekNotifications.h"
#import "UserDefaultsManager.h"
#import "TPSkinInfo.h"
#import "FileUtils.h"
#import "WebSkinInfoProvider.h"
#import "LocalSkinItemView.h"


@implementation SkinPreviewViewController  {
    UIImageView *_iphoneFrameImageView;
    UIImageView *_previewImageView;
    UIButton *_shareButton;
    UIButton *_downloadButton;
    TPSkinInfo *_skinInfo;
    UIImage *_previewImage;
    UIActivityIndicatorView *connectionActivityIndicatorView_;
    UILabel *connectionStatusLabel_;
    UIView *_previewHolder;
    RemoteSkinReloadView *_errorViewHolder;
    UIView *_loadingViewHolder;
    RemoteSkinItemButtonStatus _currentStatus;
    UIView *_progressView;
    UIButton *_topButton;
    UIView *_downloadButtonHolder;
    RemoteSkinItemButtonStatus _initSkinStatus;
    RemoteSkinItemView *_remoteSkinItemView;
    LocalSkinItemView *_localSkinItemView;
}

- (instancetype) initWithSkinItemView:(id)skinItemView {
    if (self = [super init]) {
        if ([skinItemView isKindOfClass:[RemoteSkinItemView class]]) {
            _remoteSkinItemView = (RemoteSkinItemView *)skinItemView;
            _skinInfo = _remoteSkinItemView.skinInfo;
            _initSkinStatus = _currentStatus = _remoteSkinItemView.buttonStatus;
        }
        if ([skinItemView isKindOfClass:[LocalSkinItemView class]]) {
            _localSkinItemView = (LocalSkinItemView *)skinItemView;
            _skinInfo = _localSkinItemView.skinInfo;
            _initSkinStatus = _currentStatus = _localSkinItemView.buttonStatus;
        }
    }
    return self;
}

- (void) loadView {
    [super loadView];
    
    // header view
    CommonHeaderBar *headerView = [[CommonHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeaderBarHeight()) andHeaderTitle:_skinInfo.name];
    headerView.delegate = self;

    // buttons
    CGFloat buttonSpacerWidth = TPScaledWidth(10);
    CGFloat buttonMarginHorizontal = 35;
    CGFloat buttonWidth = (TPScreenWidth() - 2 * buttonMarginHorizontal - buttonSpacerWidth) / 2;

    CGFloat buttonMarginBottom = 20;
    if (isIPhone5Resolution()) {
        buttonMarginBottom = TPScaledHeight(30);
    }
    CGFloat statusBarHeightInView = 0;
    if ([[UIDevice currentDevice].systemVersion intValue] < 7) {
        statusBarHeightInView = 20;
    }
    CGSize previewHolderSize = CGSizeMake(TPScreenWidth(), TPScreenHeight() - TPHeaderBarHeight() - statusBarHeightInView);
    _previewHolder = [[UIView alloc] init];
    _previewHolder.frame = CGRectMake(0, headerView.frame.size.height, previewHolderSize.width, previewHolderSize.height);

    CGSize buttonSize = CGSizeMake(buttonWidth, 46);
    CGFloat buttonOriginY = previewHolderSize.height - buttonMarginBottom - buttonSize.height;

    // button, to download the skin
    _downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(
                    0, 0,
                    buttonSize.width, buttonSize.height)];
    _downloadButton.layer.cornerRadius = 4;
    _downloadButton.clipsToBounds = YES;

    _downloadButton.titleLabel.font = [UIFont systemFontOfSize:17];

    NSString *downloadText = NSLocalizedString(@"Download now", nil);
    [_downloadButton setTitle:downloadText forState:UIControlStateNormal];
    [_downloadButton setTitle:downloadText forState:UIControlStateHighlighted];

    UIColor *downloadColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    [_shareButton setTitleColor:downloadColor forState:UIControlStateNormal];
    [_shareButton setTitleColor:downloadColor forState:UIControlStateHighlighted];

    [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]] forState:UIControlStateNormal];
    [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_700"]] forState:UIControlStateHighlighted];

    // button, share to friends
    CGFloat shareButtonFrameX = TPScreenWidth() - (buttonMarginHorizontal + buttonSize.width);
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(
                    shareButtonFrameX, buttonOriginY,
                    buttonSize.width, buttonSize.height)];
    _shareButton.layer.cornerRadius = 4;
    _shareButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"].CGColor;
    _shareButton.layer.borderWidth = 1;
    _shareButton.clipsToBounds = YES;

    _shareButton.titleLabel.font = [UIFont systemFontOfSize:17];

    NSString *shareText = NSLocalizedString(@"skin_preview_share_to_friends", nil);
    [_shareButton setTitle:shareText forState:UIControlStateNormal];
    [_shareButton setTitle:shareText forState:UIControlStateHighlighted];

    UIColor *shareColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
    [_shareButton setTitleColor:shareColor forState:UIControlStateNormal];
    [_shareButton setTitleColor:shareColor forState:UIControlStateHighlighted];

    [_shareButton setBackgroundImage:[FunctionUtility imageWithColor:
                [TPDialerResourceManager getColorForStyle:@"tp_color_white"]] forState:UIControlStateNormal];
    [_shareButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"]] forState:UIControlStateHighlighted];

    //progressView
    _topButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    _topButton.layer.cornerRadius = 4;
    _topButton.clipsToBounds = YES;
    [_topButton setTitle:NSLocalizedString(@"downloading", @"") forState:UIControlStateNormal];
    _topButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _topButton.titleLabel.textColor = [UIColor whiteColor];
    [_topButton setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]];

    _progressView = [[UIView alloc] initWithFrame: CGRectMake(
            0, 0,
            0, _downloadButton.frame.size.height
    )];
    _progressView.layer.cornerRadius = 4.0f;
    _progressView.clipsToBounds = YES;
    _progressView.hidden = YES;
    [_progressView addSubview:_topButton];

    // download button holder
    _downloadButtonHolder = [[UIView alloc] initWithFrame:CGRectMake(
            buttonMarginHorizontal, buttonOriginY,
            _downloadButton.frame.size.width, _downloadButton.frame.size.height)];
    [_downloadButtonHolder addSubview:_downloadButton];
    [_downloadButtonHolder addSubview:_progressView];

    // phone frame image and imageView

    //based on iphone 5
    CGSize iphoneFrameSize = TPScaledSizeMake(221, 390);
    _iphoneFrameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
                            (TPScreenWidth() - iphoneFrameSize.width) / 2, 0,
                            iphoneFrameSize.width, iphoneFrameSize.height)];
    _iphoneFrameImageView.image = [TPDialerResourceManager getImage:@"theme_preview_tempalte@2x.png"];
    _iphoneFrameImageView.clipsToBounds = YES;
    _iphoneFrameImageView.contentMode = UIViewContentModeScaleAspectFit;

    // preview image and imageView
    CGSize previewViewSize = TPScaledSizeMake(170, 300);
    _previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
                        (iphoneFrameSize.width - previewViewSize.width) / 2, TPScaledHeight(30),
                        previewViewSize.width, previewViewSize.height)];
    _previewImageView.image = _previewImage;
    _previewImageView.clipsToBounds = YES;
    _previewImageView.contentMode = UIViewContentModeScaleAspectFit;

    // horn label
    CGSize hornSize = TPScaledSizeMake(37, 30);

    CGFloat hornSpacerWidth = 0;
    if (isIPhone5Resolution()) {
        hornSpacerWidth = 10;
    } else {
        //for iphone 4
        hornSpacerWidth = -5;
    }
    CGFloat originalHornX = TPScreenWidth() / 2 + previewViewSize.width / 2 + TPScaledWidth(hornSpacerWidth);
    CGRect hornFrame = CGRectMake(originalHornX, TPScaledHeight(300),
                                  hornSize.width, hornSize.height);
    UILabel *hornLabel = [[UILabel alloc] initWithFrame:hornFrame];
    hornLabel.text = @"4";
    hornLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    hornLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:20];
    hornLabel.backgroundColor = [TPDialerResourceManager getColorForStyle:@"skin_horn_bg_color"];
    hornLabel.textAlignment = NSTextAlignmentCenter;
    hornLabel.hidden = !_skinInfo.hasSound;
    hornLabel.clipsToBounds = YES;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:hornLabel.bounds
                              byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                              cornerRadii:CGSizeMake(hornSize.height/2, hornSize.height/2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = hornLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    hornLabel.layer.mask = maskLayer;

    //--- loading views  ---
    // connection activity indicator
    connectionActivityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    connectionActivityIndicatorView_.hidesWhenStopped = YES;
    connectionActivityIndicatorView_.frame = CGRectMake(0, 0, 36, 36);
    connectionActivityIndicatorView_.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    // connection status label
    connectionStatusLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, TPScreenWidth(), 40)];
    connectionStatusLabel_.text = NSLocalizedString(@"Loading...", @"");
    connectionStatusLabel_.font = [UIFont systemFontOfSize:16];
    connectionStatusLabel_.textAlignment = NSTextAlignmentCenter;
    connectionStatusLabel_.textColor = [UIColor blackColor];
    connectionStatusLabel_.backgroundColor = [UIColor clearColor];
    connectionStatusLabel_.textColor = [[TPDialerResourceManager sharedManager] getUIColorInDefaultPackageByNumberString:@"RankEmptyReminderView_reminderLabelText_color"];

    //--- loading holder ---
    _loadingViewHolder = [[UIView alloc] init];
    [_loadingViewHolder addSubview:connectionActivityIndicatorView_];
    [_loadingViewHolder addSubview:connectionStatusLabel_];
    CGSize loadingHolderSize = CGSizeMake(
        MAX(connectionActivityIndicatorView_.frame.size.width, connectionStatusLabel_.frame.size.width),
        connectionActivityIndicatorView_.frame.size.height + connectionStatusLabel_.frame.size.height);
    _loadingViewHolder.frame = CGRectMake((TPScreenWidth() - loadingHolderSize.width)/2, 100, loadingHolderSize.width, loadingHolderSize.height);
    connectionActivityIndicatorView_.frame = CGRectMake((TPScreenWidth() - 36) / 2, 0,
        connectionActivityIndicatorView_.bounds.size.width, connectionActivityIndicatorView_.bounds.size.height);

    //--- loading error holder ---
    _errorViewHolder = [[RemoteSkinReloadView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), TPHeightFit(415))];
    _errorViewHolder.delegate = self;

    // set up the view contains
    [_iphoneFrameImageView addSubview:_previewImageView];

    // preview containers if successfully loaded
    [self setButtonStatus:_currentStatus];
    [_downloadButton addTarget:self action:@selector(downloadButtonDidClick) forControlEvents:UIControlEventTouchUpInside];

    [_previewHolder addSubview:_iphoneFrameImageView];
    [_previewHolder addSubview:_shareButton];
    [_previewHolder addSubview:_downloadButtonHolder];
    [_previewHolder addSubview:hornLabel];

    // set up the view tree
    self.view.backgroundColor = [UIColor whiteColor];

    _previewHolder.hidden = YES;
    _errorViewHolder.hidden = YES;
    _loadingViewHolder.hidden = NO;

    [self.view addSubview:_previewHolder];
    [self.view addSubview:headerView];
    [self.view addSubview:_loadingViewHolder];
    [self.view addSubview:_errorViewHolder];

    // binding click listener
    [_shareButton addTarget:self action:@selector(toShare) forControlEvents:UIControlEventTouchUpInside];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangedSkin) name:N_SKIN_DID_CHANGE object:nil];
    [self loadPreviewImage];
    
}

- (void) onChangedSkin {
    [FunctionUtility updateStatusBarStyle];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [FunctionUtility updateStatusBarStyle];
}

- (void) viewDidLoad {
    [self addSkinDownloaderObserver];
}

- (void) toShare {
    // to share to friends
    {
        VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:@"超好玩的拨号音，只在触宝电话，你不要来装一个？" msg:@"才不告诉你装了还能免费打电话呢~" url:@"http://dialer.cdn.cootekservice.com/web/external/laststep/index.html?code=ops_sicong_theme_20151015" buttonArray:@[@"wechat", @"qq"]];
        [shareAllView setHeadTitle:@"分享给"];
        //            shareAllView.imageUrl = _responseBody[SHARE_IMAGE_URL_KEY];
        shareAllView.fromWhere = @"shareRing";
        [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
    }
}

- (void) loadPreviewImage {
    // try to download the preview image from the internet or load from the local image folder.
    cootek_log(@"SkinPreviewViewController, url: %@, path: %@", _skinInfo.previewUrl, _skinInfo.previewPath);

    [self onLoadWillStart];
    __weak SkinPreviewViewController *this = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *imageData = nil;
        if (_skinInfo.isBuiltIn) {
            if (!_skinInfo.previewPath) {
                [self onLoadImageError:ERROR_LOCAL_FAILED];
            } else {
                [self onLoadImageError:ERROR_NONE];
            }
        } else {
            if (!_skinInfo.previewPath) {
                [self onLoadImageError:ERROR_LOCAL_FAILED];
            } else {
                cootek_log(@"SkinPreviewController, previewPath: %@", _skinInfo.previewPath);
                if (![FileUtils fileExistAtAbsolutePath:_skinInfo.previewPath]) {
                    // path not exist
                    cootek_log(@"SkinPreviewController, path not exist");
                    if ([Reachability network] == network_none) {
                        [this onLoadImageError:ERROR_NO_NETWORK];
                        return;
                    }
                    imageData = [WebSkinInfoProvider downloadPreviewImageByString:_skinInfo.previewUrl];
                    if (imageData == nil) {
                        // pity, failed to get the preview image for three tries.
                        [this onLoadImageError:ERROR_DOWNLOAD_FAILED];
                    } else {
                        if ([FileUtils saveFileAtAbsolutePathWithData:imageData atPath:_skinInfo.previewPath overWrite:YES]) {
                            [this onLoadImageError:ERROR_NONE];
                        } else {
                            [this onLoadImageError:ERROR_LOCAL_FAILED];
                        }
                    }
                } else {
                    // preview image already saved
                    cootek_log(@"SkinPreviewController, path already exist");
                    [this onLoadImageError:ERROR_NONE];
                }
            }
        }
        // end of block
    });
}

- (void) onLoadImageError:(ErrorType) type {
    dispatch_async(dispatch_get_main_queue(), ^(){
        switch (type) {
            case ERROR_NO_NETWORK:
                [self onNoNetwork];
                break;
            case ERROR_DOWNLOAD_FAILED:
                [self onDownloadFailed];
                break;
            case ERROR_LOCAL_FAILED:
                [self onDownloadFailed];
                break;
            case ERROR_NONE:
                _previewImageView.image = [UIImage imageWithContentsOfFile:_skinInfo.previewPath];
                [self onLoadSuccess];
                break;
            default:
                break;
        }
    });
}

- (void) onLoadWillStart {
    _errorViewHolder.hidden = YES;

    _loadingViewHolder.hidden = NO;
    [connectionActivityIndicatorView_ startAnimating];
}

- (void) onLoadDidFinish {
    [connectionActivityIndicatorView_ stopAnimating];
    _loadingViewHolder.hidden = YES;
}

- (void) onLoadSuccess {
    [self onLoadDidFinish];
    _errorViewHolder.hidden = YES;
    _previewHolder.hidden = NO;
}

- (void) onDownloadFailed {
    // show the download failed view
    [self onLoadDidFinish];
    _errorViewHolder.hidden = NO;
}

- (void) onNoNetwork {
    // show the network error view  by delaying a moment
    // show users the activity indicator.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self onLoadDidFinish];
        _errorViewHolder.hidden = NO;
    });
}

- (void) remoteSkinReloadViewClicked:(RemoteSkinReloadView *)view {
    [self loadPreviewImage];
}

-(void)setButtonStatus:(RemoteSkinItemButtonStatus)buttonStatus{
    switch (buttonStatus) {
        case SkinItemStatusNotDownloaded: {
            // download button
            [_downloadButton setTitle:NSLocalizedString(@"Download now", @"") forState:UIControlStateNormal];
            [_downloadButton setTitle:NSLocalizedString(@"Download now", @"") forState:UIControlStateHighlighted];
            [_downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"]] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_700"]] forState:UIControlStateHighlighted];
            [self clearButtonBorder];
            _downloadButton.userInteractionEnabled = YES;

            // top button
            _progressView.hidden = NO;
            break;
        }
        case SkinItemStatusDownloading: {
            // download button
            [_downloadButton setTitle:NSLocalizedString(@"downloading", @"") forState:UIControlStateNormal];
            [_downloadButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_green_500"] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"]] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"]] forState:UIControlStateHighlighted];
            [self clearButtonBorder];
            _downloadButton.userInteractionEnabled = YES;

            // top button
            if (_progressView.hidden) {
                _progressView.hidden = NO;
            }
            break;
        }
        case SkinItemStatusDownloaded: {
            BOOL shouldAutoInstall = NO;
            shouldAutoInstall = (_initSkinStatus == SkinItemStatusNotDownloaded || _initSkinStatus == SkinItemStatusDownloading)
                                && ENABLE_SKIN_AUTO_INSTALL;
            NSString *statusDesc = NSLocalizedString(@"Use", @"");
            if (shouldAutoInstall) {
                statusDesc = NSLocalizedString(@"skin_preview_download_ok", @"");
            }
            [_downloadButton setTitle:statusDesc forState:UIControlStateNormal];
            [_downloadButton setTitle:statusDesc forState:UIControlStateHighlighted];
            [_downloadButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:UIControlStateNormal];
            [_downloadButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white"] forState:UIControlStateHighlighted];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"]] forState:UIControlStateHighlighted];
            _downloadButton.layer.borderColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"].CGColor;
            _downloadButton.layer.borderWidth = 1.0f;
            _downloadButton.userInteractionEnabled = YES;

            // top button
            _progressView.hidden = YES;
            if (shouldAutoInstall) {
                [self toUseSkinItem];
            }
            break;
        }
        case SkinItemStatusUsed: {
            // download button
            [_downloadButton setTitle:NSLocalizedString(@"In use", @"") forState:UIControlStateNormal];
            [_downloadButton setTitle:NSLocalizedString(@"In use", @"") forState:UIControlStateHighlighted];
            [_downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"]] forState:UIControlStateNormal];
            [_downloadButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_700"]] forState:UIControlStateHighlighted];
            [self clearButtonBorder];
            _downloadButton.userInteractionEnabled = NO;

            // top button
            _progressView.hidden = YES;
            break;
        }
        default: {
            break;
        }
    }
    _currentStatus = buttonStatus;
}

- (void) clearBorder:(UIView *) view {
    if (view) {
        view.layer.borderWidth = 0.0f;
        view.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void) clearButtonBorder {
    if (_downloadButton) {
        [self clearBorder:_downloadButton];
    }
}

// handling the downloading action
- (void)downloadButtonDidClick {
    switch (_currentStatus) {
        case SkinItemStatusDownloaded:
            // downloaded, click to use
            [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_CLICK, _skinInfo.skinID), nil];
            [self toUseSkinItem];
            break;
        case SkinItemStatusDownloading:
            // downloading, click to cancel
            [self toCancelDownloadingSkinItem];
            break;
        case SkinItemStatusNotDownloaded:
            // not downloaded yet, click to download
            [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_DOWNLOAD, _skinInfo.skinID), nil];
            [self toDownloadSkinItem];
            break;
        case SkinItemStatusUsed:
            // used as the theme now. do nothing
            break;
        default:
            break;
    }
}

- (void)addSkinDownloaderObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(skinDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(skinDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_FAIL
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(skinDownloaderStatusChanged:)
                                                 name:N_DOWNLOAD_DATA_PROGRESS
                                               object:nil];
}

- (void)skinDownloaderStatusChanged:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(skinDownloaderStatusChanged:) withObject:notification waitUntilDone:YES];
        return;
    }

    id sender = [notification object];
    if(![sender isKindOfClass:[NetworkDataDownloaderWrapper class]]) {
        return;
    }

    NetworkDataDownloaderWrapper *downloader = sender;
    if(downloader) {
        [self updateDownloadingUI:downloader];
    }
}

- (void) updateDownloadingUI:(NetworkDataDownloaderWrapper *)downloader {
    switch (downloader.downloadStatus) {
        case NetworkDataDownloadCompleted:
            [[TPDialerResourceManager sharedManager] loadAllSkinInfoList];
            [self setButtonStatus:SkinItemStatusDownloaded];
            break;
        case NetworkDataDownloadNotStarted:
        case NetworkDataDownloadFailed: {
            [self setButtonStatus:SkinItemStatusNotDownloaded];
            break;
        }
        case NetworkDataDownloadStarting:
        case NetworkDataDownloadDownloading: {
            [self setButtonStatus:SkinItemStatusDownloading];
            [self updateProgress:downloader];
            break;
        }
        default:
            break;
    }
}

- (void) updateProgress:(NetworkDataDownloaderWrapper *)downloader {
    if (downloader == nil) return;
    // 95 discount the downloading progress for ui considering
    CGFloat newWidth = _downloadButton.frame.size.width * downloader.downloadPercent * 0.95;
    _progressView.frame  = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, newWidth, _progressView.frame.size.height);
}

- (void)cancelRemoteDownloadingJobs
{
    NSArray *identities = [NetworkDataDownloadWrapperManager identities];
    for (NSString *identity in identities) {
        if ([identity hasPrefix:SKIN_DOWNLOAD_IDENTITY_PREFIX]) {
            NetworkDataDownloaderWrapper *downloader = [NetworkDataDownloadWrapperManager downloaderForIdentity:identity];
            [downloader cancelDownload];
        }
    }
}

- (void) toUseSkinItem {
    [UserDefaultsManager setBoolValue:YES forKey:ASK_LIKE_VIEW_COULD_SHOW];
    [self setButtonStatus:SkinItemStatusUsed];
    [TPDialerResourceManager sharedManager].skinTheme = _skinInfo.skinID;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_SKIN_SHOULD_CHANGE object:nil];

}

- (void)toCancelDownloadingSkinItem {
    // in downloading, can only be cancelled
    [self cancelRemoteDownloadingJobs];

    [self setButtonStatus:SkinItemStatusNotDownloaded];
    if (_remoteSkinItemView != nil) {
        _remoteSkinItemView.buttonStatus = SkinItemStatusNotDownloaded;
        [self resetProgressView:0];
    }
}

- (void) resetProgressView:(CGFloat) newWidth {
    _progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, 0, _progressView.frame.size.height);
}

- (void) toDownloadSkinItem {
    // begin to download
    if (_currentStatus == SkinItemStatusNotDownloaded) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_skinInfo.skinDir error:nil];
    }

    NSData *imageData = UIImagePNGRepresentation(_previewImage);
    [FileUtils saveFileAtAbsolutePathWithData:imageData atPath:_skinInfo.previewPath overWrite:YES];

    SkinDataDownloadJob *job = [[SkinDataDownloadJob alloc] initWithSkin:_skinInfo];
    NetworkDataDownloaderWrapper *downloader = [NetworkDataDownloadWrapperManager downloaderForJob:job];

    //luchenAdded

    if(downloader.downloadStatus == NetworkDataDownloadNotStarted || downloader.downloadStatus == NetworkDataDownloadFailed) {
        [downloader download];
    }

    [self setButtonStatus:SkinItemStatusDownloading];
}

#pragma delegate CommonHeaderBarProtocol
- (void) leftButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
