//
//  TPDVideoPlayerController.m
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//


#include <stdlib.h>
#include <stdarg.h>

#import "TPDVideoPlayController.h"
#import <Masonry.h>
#import "VKVideoPlayerTrack.h"
#import "ASIWrapper.h"
#import "ASIHTTPRequest.h"
#import "VideoNewsRowView.h"
#import "UpdateService.h"
#import "NSString+TPHandleNil.h"
#import <MJExtension.h>
#import "IndexData.h"
#import "SectionFindNews.h"
#import <ReactiveCocoa.h>
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "TPDialerResourceManager.h"
#import "YPAdTaskNews.h"
#import "NetworkUtil.h"
#import "UserDefaultsManager.h"
#import "EdurlManager.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"
#import "DateTimeUtil.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerUsageRecord.h"

#define IDENTIFIER_DETAIL_FEEDS_NEWS @"detail_feeds_news"

#define TAG_VIDEO_ROW_VIEW (101)

#define FEEDS_VIDEO_FEEDBACK_API @"http://ws2.cootekservice.com/news/transform?"

static CGFloat sDeviceHeight;
static CGFloat sDeviceWidth;

void outline_view(UIView *view, ...) {
    va_list list;
    va_start(list, view);
    UIColor *borderColor = va_arg(list, UIColor *);
    va_end(list);
    
    if (view != nil
        && !CGRectIsNull(view.frame)) {
        if (borderColor == nil ) {
            borderColor = [UIColor colorWithRed:(random() % 100 / 100.f) green:0 blue:0
                                                   alpha:1];
        }
        view.layer.borderWidth = 1;
        view.layer.borderColor = borderColor.CGColor;
    }
}

#define MORE_VIDEO_LABEL_HEIGHT (38)
#define VIDEO_TITLE_INFO_HEIGHT (96)

@interface TPDVideoPlayController ()

@property (nonatomic, assign) BOOL applicationIdleTimerDisabled;
@property (nonatomic, strong) UIView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *newsData;

@property (nonatomic, strong) UILabel *moreVideoCommingLabel;
@property (nonatomic, strong) UIView  *moreVideoLoadingFailedView;

@property (nonatomic, strong) NSMutableSet *finishedEdurSet;
// for statics
@property (nonatomic, strong) NSString *tsin; // millisecond string
@property (nonatomic, assign) long progressTime;


@property (nonatomic, strong) UILabel *videoTitleLabel;
@property (nonatomic, strong) UILabel *videoSubtitleLabel;
@property (nonatomic, strong) UIView *videoMetaInfoView;

//@property (nonatomic, strong) UIView *videoInfoView;

@end

@implementation TPDVideoPlayController
#pragma mark - Life Cycle
- (instancetype) initWithVideoURLString:(NSString *)videoURLString {
    _videoURLString = videoURLString;
    self = [super init];
    if (self != nil) {
        _finishedEdurSet = [[NSMutableSet alloc] init];
        _newsData = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (instancetype) initWithNewItem:(FindNewsItem *)newsItem {
    self = [super init];
    if (self != nil) {
        _finishedEdurSet = [[NSMutableSet alloc] init];
        _newsItem = newsItem;
        _newsData = [[NSMutableArray alloc] initWithCapacity:5];
        if (newsItem != nil) {
            _videoURLString = newsItem.curl;
        }
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    [self addObservers];
    [self requestData];
    
    // disable the fullscreen popup recognizer
    self.fd_interactivePopDisabled = YES;
}

- (void) requestData {
    [self requestDataWithLoadingBlock:^{
        //
        if (_newsData.count == 0) {
            _moreVideoCommingLabel.hidden = NO;
            _tableView.hidden = YES;
        }
        _moreVideoLoadingFailedView.hidden = YES;
        
    } successBlock:^{
        //
        _moreVideoCommingLabel.hidden = YES;
        _moreVideoLoadingFailedView.hidden = YES;
        _tableView.hidden = NO;
        [self reloadTableView];
        
        NSInteger displayedCount = self.finishedEdurSet.count;
        NSString *tu = [NSString nilToEmpty:self.newsItem.tu];
        NSArray *info = @[Pair(FEEDS_VIDEO_DISPLAYED_COUNT, @(displayedCount)),
                          Pair(@"tu", tu)
                          ];
        [DialerUsageRecord recordpath:PATH_FEEDS_VIDEO kvarray:info];
        
        _finishedEdurSet = [[NSMutableSet alloc] init];
        
    } failBlock:^{
        //
        _moreVideoCommingLabel.hidden = YES;
        _moreVideoLoadingFailedView.hidden = NO;
        _tableView.hidden = YES;
    }];
}

- (void) requestDataWithLoadingBlock:(void (^)())loadingBlock
                        successBlock:(void (^)())successBlock
                           failBlock:(void (^)())failBlock {
    @weakify(self);
    if (loadingBlock != nil) {
        RUN_ON_UI_THREAD(loadingBlock);
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self);
        NSString *urlString = [self videoRequestURLString];
        cootek_log(@"%s, urlstring: %@", __func__, urlString);
        if (urlString == nil) {
            RUN_ON_UI_THREAD(failBlock);
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (data == nil) {
            RUN_ON_UI_THREAD(failBlock);
            return;
        }
        
        NSError *error = nil;
        NSDictionary *response = (NSDictionary *)[data mj_JSONObject];
        if (error != nil) {
            cootek_log(@"%s, json error: %@", error);
            RUN_ON_UI_THREAD(failBlock);
            return;
        }
        
        NSArray *news = [response objectForKey:@"news"];
        if (news == nil && news.count == 0) {
            RUN_ON_UI_THREAD(failBlock);
            return;
        }
        SectionFindNews* section = [[SectionFindNews alloc] initWithJson:news[0]];
        if (section != nil) {
            self.newsData = section.items;
            if (_newsData.count > 0) {
                RUN_ON_UI_THREAD(successBlock);
                return;
            }
        }
        RUN_ON_UI_THREAD(failBlock);
    });

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.applicationIdleTimerDisabled = [UIApplication sharedApplication].isIdleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    if (_videoURLString != nil) {
        [self loadVideo];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TouchPalDialerAppDelegate naviController].interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled = self.applicationIdleTimerDisabled;
    [super viewWillDisappear:animated];
}

- (BOOL) prefersStatusBarHidden {
    return [_player isFullScreen];
}

- (void) backButtonPressed {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.player isPlayingVideo]) {
        [self sendStatsData];
    }
    [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
}

- (void) initialize {
    UIView *statusBarView = [[UIView alloc] init];
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarView];
    [statusBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    UIScreen *screen = [UIScreen mainScreen];
    sDeviceWidth = screen.bounds.size.width;
    sDeviceHeight = screen.bounds.size.height;
    
    _playerView = [[TPVideoPlayerView alloc] init];//
    [self.view addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(VIDEO_PORTRAIT_HEIGHT);
        make.top.mas_equalTo(self.view).offset(20);
    }];
    [self configPlayer];
    
    // _tableContainer
    
    _tableView = [[UITableView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self tableHeaderView];
    
    // _tableContainer
    _tableContainer = [[UIView alloc] init];
    _tableContainer.backgroundColor = [UIColor whiteColor];
    
    [_tableContainer addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(_tableContainer);
        make.bottom.mas_equalTo(_tableContainer);
    }];
    
    [self.view addSubview:_tableContainer];
    [_tableContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(_playerView.bottom);
    }];
    
    // more video views
    _moreVideoCommingLabel = [UILabel tpd_commonLabel];
    _moreVideoCommingLabel.numberOfLines = 1;
    _moreVideoCommingLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _moreVideoCommingLabel.textAlignment = NSTextAlignmentCenter;
    _moreVideoCommingLabel.font = [UIFont systemFontOfSize:18];;
    _moreVideoCommingLabel.text = NSLocalizedString(@"feeds_video_more_video_comming",
                                                    @"更多精彩视频正在赶来...");
    _moreVideoCommingLabel.textColor = [UIColor colorWithHexString:@"0x808080"];
    
    //
    _moreVideoLoadingFailedView = [[UIView alloc] init];
    UIImageView *moreVideoFailedImageView = [[UIImageView alloc] init];
    moreVideoFailedImageView.image = [TPDialerResourceManager getImage:@"feeds_video_more_details_failed@3x.png"];
    moreVideoFailedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *moreVideoFailedLabel = [UILabel tpd_commonLabel];
    moreVideoFailedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    moreVideoFailedLabel.numberOfLines = 1;
    moreVideoFailedLabel.textAlignment = NSTextAlignmentCenter;
    moreVideoFailedLabel.font = [UIFont systemFontOfSize:18];
    moreVideoFailedLabel.text = NSLocalizedString(@"feeds_video_more_video_empty",
                                                  @"一片空白，什么都没有");
    moreVideoFailedLabel.textColor = [UIColor colorWithHexString:@"0x808080"];
    
    [_moreVideoLoadingFailedView addSubview:moreVideoFailedImageView];
    [_moreVideoLoadingFailedView addSubview:moreVideoFailedLabel];
    
    [moreVideoFailedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_moreVideoLoadingFailedView).offset(80);
        make.centerX.mas_equalTo(_moreVideoLoadingFailedView);
    }];
    
    [moreVideoFailedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(moreVideoFailedImageView.bottom).offset(36);
        make.left.right.mas_equalTo(_moreVideoLoadingFailedView);
    }];
    
    //
    [_tableContainer addSubview:_moreVideoCommingLabel];
    [_tableContainer addSubview:_moreVideoLoadingFailedView];
    
    [_moreVideoCommingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tableContainer).offset(123);
        make.left.right.mas_equalTo(_tableContainer);
    }];
    
    [_moreVideoLoadingFailedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_tableContainer);
    }];
    
    _moreVideoCommingLabel.hidden = YES;
    _moreVideoLoadingFailedView.hidden = YES;
    _tableView.hidden = YES;
    
}

- (void) addObservers {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(loadVideoError:)
                          name:N_LOAD_VIDEO_ERROR object:nil];
    [defaultCenter addObserver:self selector:@selector(resetStatsData)
                          name:N_FEEDS_VIDEO_RESET_STATS object:nil];
    [defaultCenter addObserver:self selector:@selector(sendStatsData)
                          name:N_FEEDS_VIDEO_SEND_STATS object:nil];
    [defaultCenter addObserver:self selector:@selector(scrubberValueChanged:)
                          name:kVKVideoPlayerScrubberValueUpdatedNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(videoPaused:)
                          name:N_FEEDS_VIDEO_PAUSED_STATS object:nil];
    
}

- (void) loadVideo {
    if (_player != nil) {
        // stats
        NSTimeInterval duration = [_player.player currentItemDuration];
        if (duration > 1) {
            NSString *playedPercentage = [NSString stringWithFormat:@"%.2f",
                                          _player.previousPlaybackTime/duration];
            if (playedPercentage != nil) {
                [DialerUsageRecord recordpath:PATH_FEEDS_VIDEO
                                          kvs:Pair(FEEDS_VIDEO_PLAYED_PERCENTAGE, playedPercentage), nil];
            }
        }
        
        NSURL *trackURL = [NSURL URLWithString:_videoURLString];
        [_player seekToTimeInSecond:0 userAction:NO completionHandler:^(BOOL finished) {
            TPVideoPlayerView *playerView = self.playerView;
            playerView.scrubber.hidden  = YES;
            playerView.bottomPlaySlider.hidden = YES;
            playerView.currentTimeLabel.hidden = YES;
        }];
        self.previousPausedTime = 0.0f;
        _player.previousPlaybackTime = 0.0;
        [_playerView updateUIWithData:_newsItem];
        [self updateVideoInfo];
        [_player loadVideoWithTrack:[[VKVideoPlayerTrack alloc] initWithStreamURL:trackURL]];
    }
}

- (void) reloadTableView {
    [_tableView reloadData];
}

- (void) loadVideoByItem:(FindNewsItem *)item {
    if (item == nil) {
        return;
    }
    _newsItem = item;
    _videoURLString = item.curl;
    if ([_player isPlayingVideo]) {
        [_player pauseContent];
    }
    [self requestData];
    _playerView.loadVideoStatus = LoadVideoWaiting;
    [self loadVideo];
}

- (NSString *) videoRequestURLString {
    NSDictionary *extra = @{
                            @"mode": @"1",
                            @"tu" : [@(115) stringValue],
                            @"layout": [@(16) stringValue],
                            @"ctid": [NSString nilToEmpty:self.newsItem.newsId],
                            @"ctn": @"5",
                            };
    NSString *urlString = [YPAdTaskNews requestURLStringWithExtra:extra];
    
#ifdef DEBUG_FEEDS_VIDEO
    urlString = DEBUG_URL_DETAIL_VIDEO_LIST;
#endif
    
    return [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Logics
- (void) updateVideoInfo {
    NSString *title = nil;
    NSString *subtitle = nil;
    if (self.newsItem != nil) {
        title = self.newsItem.title;
        subtitle = self.newsItem.subTitle;
    }
    self.videoTitleLabel.text = title;
    self.videoSubtitleLabel.text = subtitle;
}

- (void) configPlayer {
    _player = [[TPVideoPlayer alloc] initWithVideoPlayerView:_playerView];
    _player.delegate = self;
    _player.viewController = self;
    
    _player.forceRotate = YES;
    
    _player.landscapeFrame = CGRectMake(0, 0, sDeviceHeight, sDeviceWidth);
    _player.portraitFrame = CGRectMake(0, 0, sDeviceWidth, VIDEO_PORTRAIT_HEIGHT);
    
    // force to play audio even if the Silent switch is on
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error != nil) {
        cootek_log(@"feeds_video, set AVAudioSessionCategoryPlayback error: %@ ", error);
    }
}

#pragma mark - VKVideoPlayerControllerDelegate
- (void)videoPlayer:(VKVideoPlayer*)videoPlayer didControlByEvent:(VKVideoPlayerControlEvent)event {
    if (event == VKVideoPlayerControlEventTapDone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) videoPlayer:(TPVideoPlayer *)videoPlayer
            willChangeOrientationTo:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_tableContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
    } else {
        [_tableContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_playerView.bottom);
            make.left.right.bottom.mas_equalTo(self.view);
        }];
    }
}

- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didPlayToEnd:(id<VKVideoPlayerTrackProtocol>)track {
    [_player seekToTimeInSecond:0 userAction:NO completionHandler:^(BOOL finished){
        // do nothing
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0] forKey:@"scrubberValue"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerScrubberValueUpdatedNotification object:self userInfo:info];
        [_player.view setBigPlayButtonHidden:NO];
        _player.view.bottomControlOverlay.hidden = YES;
    }];
}

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode track:(id<VKVideoPlayerTrackProtocol>)track customMessage:(NSString*)customMessage {
    cootek_log(@"VKVideoPlayerErrorCode: %d, customMessage: %@", errorCode, customMessage);
    return;
}

#pragma mark - App States

- (void)applicationWillResignActive {
    self.player.view.controlHideCountdown = -1;
    if (self.player.state == VKVideoPlayerStateContentPlaying) [self.player pauseContent:NO completionHandler:nil];
}

- (void)applicationDidBecomeActive {
    self.player.view.controlHideCountdown = kPlayerControlsDisableAutoHide;
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return VIDEO_CELL_HEIGHT;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER_DETAIL_FEEDS_NEWS];
    VideoNewsRowView *rowView = nil;
    FindNewsItem *item = [_newsData objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDENTIFIER_DETAIL_FEEDS_NEWS];
        rowView = [[VideoNewsRowView alloc] init];
        rowView.tag = TAG_VIDEO_ROW_VIEW;
        [cell addSubview:rowView];
        [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cell);
            make.width.mas_equalTo(cell);
        }];
        
        @weakify(self);
        @weakify(rowView);
        rowView.block = ^{
            @strongify(self);
            @strongify(rowView);
            NSString *tu = [NSString nilToEmpty:self.newsItem.tu];
            NSArray *stats = @[Pair(FEEDS_VIDEO_CLICKED, @(1)),
                               Pair(@"tu", tu),
                               ];
            [DialerUsageRecord recordpath:PATH_FEEDS_VIDEO kvarray:stats];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:rowView.item.curl]];
                [NetworkUtil executeWithUrlRequest:request success:nil failure:nil];
            });
            
            // send stats data
            [[EdurlManager instance] sendCMonitorUrl:rowView.item];
            [self sendStatsData];
            
            [self loadVideoByItem:rowView.item];
        };
        
    } else {
        rowView = (VideoNewsRowView *)[cell viewWithTag:TAG_VIDEO_ROW_VIEW];
    }
    
    [rowView updateUIWithItem:item];
    return cell;
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _newsData.count;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        FindNewsItem *item = [_newsData objectAtIndex:indexPath.row];
        if (item.edMonitorUrl.count > 0) {
            NSString *edurlString = item.edMonitorUrl[0];
            if (![self.finishedEdurSet containsObject:edurlString]) {
                NSURL *edURL = [NSURL URLWithString:edurlString];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:edURL];
                request.HTTPMethod = @"GET";
                @weakify(self);
                [NetworkUtil executeWithUrlRequest:request success:^(NSData *data) {
                    @strongify(self);
                    [self.finishedEdurSet addObject:edurlString];
                    cootek_log(@"TPVideoPlayController, sendEdurl, sucess, edurlString: %@",
                               edurlString);
                    
                } failure:^(NSData *data) {
                    cootek_log(@"TPVideoPlayController, sendEdurl, failed, edurlString: %@",
                               edurlString);
                }];
            }
        }
    });
}

#pragma mark - Notifications 
- (void) loadVideoError:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    LoadVideoErrorUserAction errorStatus = (LoadVideoErrorUserAction)[[userInfo objectForKey:kLoadVideoErrorUserAction] integerValue];
    switch (errorStatus) {
        case ErrorActionReload: {
            if (_newsData.count == 0) {
               [self requestData];
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - Statistics
- (NSInteger) displayedVideoCount {
    CGFloat tableHeight = _tableView.frame.size.height;
    NSInteger count = (NSInteger)(tableHeight / (VIDEO_CELL_HEIGHT * 0.5));
    if (count % 2 == 0) {
        return count / 2;
    } else {
        return (count + 1) / 2;
    }
}

- (void) sendStatsData {
    // 2016-12-15
    // 根据服务器的指示，暂时没有上传的字段:
    // url
    // 其中 flts 实际被解释成 开始播放的时间, pn被指定为1
    //
    if (self.newsItem.duration <= 0) {
        return;
    }
    double videoTimeLength = (double) self.newsItem.duration;
    long playedTime = self.progressTime - self.previousPausedTime;
    if (playedTime < 0) {
        playedTime = 0;
    }
    NSString *readrateString = [NSString stringWithFormat:@"%.2f",
                                playedTime/videoTimeLength];
    
    cootek_log(@"%s, video_stats, progress: %ld, pausedTime: %ld, playedTime: %ld, readrate: %@",
               __func__,
            self.progressTime, self.previousPausedTime, playedTime, readrateString);
    
    NSDictionary *info = @{
        @"type": @"1",
        @"s": [NSString nilToEmpty:self.newsItem.s],
        @"pn": @"1",
        @"ctid": [NSString nilToEmpty:self.newsItem.newsId],
        @"tsin": [NSString nilToEmpty:self.tsin],
        @"tsout": [DateTimeUtil stringTimestampInMillis],
        @"duration": [NSString stringWithFormat:@"%.0f", playedTime],
        @"flts": [NSString nilToEmpty:self.tsin],
        @"tu": [NSString nilToEmpty:self.newsItem.tu],
        @"readrate": readrateString,
//        @"url": @"",
        @"from": @"11",
        @"app_ver": CURRENT_TOUCHPAL_VERSION,
    };
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:FEEDS_VIDEO_FEEDBACK_API];
    NSUInteger keyCount = info.allKeys.count;
    for(NSUInteger i = 0; i < keyCount; i++) {
        NSString *key = info.allKeys[i];
        NSString *value = info.allValues[i];
        if (value != nil) {
            if (i == keyCount - 1) {
                [urlString appendFormat:@"%@=%@", key, value];
            } else {
                [urlString appendFormat:@"%@=%@&", key, value];
            }
        }
     }
    NSString *statsUrl = [urlString copy];
    NSLog(@"%s, video_stats, statsUrl: %@",
            __func__, statsUrl);
    [FunctionUtility asyncVisitUrl:statsUrl];
}

- (void) resetStatsData {
    self.tsin = [DateTimeUtil stringTimestampInMillis];
    self.progressTime = 0;
}

- (void) scrubberValueChanged:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    long progress = (long)[[info objectForKey:@"scrubberValue"] floatValue];
    if (progress > self.progressTime) {
        self.progressTime = progress;
    }
}

- (void) videoPaused:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    self.previousPausedTime = [[info objectForKey:@"previousPlaybackTime"] longValue];
    cootek_log(@"%s, video_stats, info: %@, pausedTime: %ld",
               __func__, [info mj_JSONString], self.previousPausedTime);
}

#pragma mark - View Helpers
- (UIView *) tableHeaderView {
    CGFloat height = MORE_VIDEO_LABEL_HEIGHT + VIDEO_TITLE_INFO_HEIGHT;
    UIView *metaView = [[UIView alloc] initWithFrame:
                        CGRectMake(0, 0, TPScreenWidth(), height)];
    
    metaView.backgroundColor = [UIColor whiteColor];
    self.videoMetaInfoView = metaView;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = VIDEO_LINE_COLOR;
    
    _videoTitleLabel = [UILabel tpd_commonLabel];
    _videoTitleLabel.numberOfLines = 2;
    _videoTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_videoTitleLabel tpd_withText:@"" color:VIDEO_TITLE_COLOR font:VIDEO_TITLE_FONT_SIZE];
    
    _videoSubtitleLabel = [UILabel tpd_commonLabel];
    _videoSubtitleLabel.numberOfLines = 1;
    _videoSubtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_videoSubtitleLabel tpd_withText:@"" color:VIDEO_SUBTITLE_COLOR font:VIDEO_SUBTITLE_FONT_SIZE];
    
    
    UILabel *moreVideoLabel = [UILabel tpd_commonLabel];
    [moreVideoLabel tpd_withText:NSLocalizedString(@"feeds_video_more_video", @"更多视频")
                           color:VIDEO_SUBTITLE_COLOR
                            font:VIDEO_SUBTITLE_FONT_SIZE];
    moreVideoLabel.backgroundColor = [UIColor whiteColor];
    
    
    [metaView addSubview:_videoTitleLabel];
    [metaView addSubview:_videoSubtitleLabel];
    [metaView addSubview:lineView];
    [metaView addSubview:moreVideoLabel];
    
    [metaView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(metaView).offset(16);
        make.right.mas_equalTo(metaView).offset(-16);
    }];
    
    
    [_videoTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(metaView).offset(16);
    }];
    
    [lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(metaView.mas_top).offset(VIDEO_TITLE_INFO_HEIGHT - 0.5);
        make.height.mas_equalTo(0.5);
    }];
    
    [_videoSubtitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(lineView.mas_top).offset(-16);
    }];

    [moreVideoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(metaView);
        make.height.mas_equalTo(MORE_VIDEO_LABEL_HEIGHT);
    }];
    [self updateVideoInfo];
    
    return metaView;
}

@end

