//
//  TPVideoPlayer.m
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//

#import "TPVideoPlayer.h"
#import "VKVideoPlayer.h"
#import "VKVideoPlayerConfig.h"
#import "VKVideoPlayerCaption.h"
#import "VKVideoPlayerSettingsManager.h"
#import "VKVideoPlayerLayerView.h"
#import "VKVideoPlayerTrack.h"
#import "NSObject+VKFoundation.h"
#import "VKVideoPlayerExternalMonitor.h"
#import <Masonry.h>
#import "TPVideoPlayerView.h"
#import "TPDVideoPlayController.h"
#import "UserDefaultsManager.h"
#import <ReactiveCocoa.h>
#import "TPDLib.h"
#import "DialerUsageRecord.h"


#define VKCaptionPadding 10
#define degreesToRadians(x) (M_PI * x / 180.0f)

extern NSString *kTracksKey;
extern NSString *kPlayableKey;

static const NSString *ItemStatusContext;


typedef enum {
    VKVideoPlayerCaptionPositionTop = 1111,
    VKVideoPlayerCaptionPositionBottom
} VKVideoPlayerCaptionPosition;

@interface TPVideoPlayer()
@property (nonatomic, assign) BOOL scrubbing;
@property (nonatomic, assign) NSTimeInterval beforeSeek;
@property (nonatomic, assign) double previousIndicatedBandwidth;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) BOOL pausedByResigningActive;
@property (nonatomic, assign) BOOL bufferingStopped;
@end


@implementation TPVideoPlayer

- (id)init {
    self = [super init];
    if (self) {
        self.view = [[TPVideoPlayerView alloc] init];
        [self initialize];
    }
    return self;
}

- (id)initWithVideoPlayerView:(TPVideoPlayerView*)videoPlayerView {
    self = [super init];
    if (self) {
        self.view = videoPlayerView;
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
    self.timeObserver = nil;
    self.avPlayer = nil;
    self.captionTopTimer = nil;
    self.captionBottomTimer = nil;
    
    self.playerItem = nil;
    
    [self pauseContent];
}

#pragma mark - initialize
- (void)initialize {
    [self initializeProperties];
    [self initializePlayerView];
    [self addObservers];
}

- (void)initializeProperties {
    self.state = VKVideoPlayerStateUnknown;
    self.scrubbing = NO;
    self.beforeSeek = 0.0;
    self.previousPlaybackTime = 0;
    
    self.supportedOrientations =
        UIInterfaceOrientationMaskPortrait
        | UIInterfaceOrientationMaskLandscapeRight
        | UIInterfaceOrientationMaskLandscapeLeft;
    
    self.forceRotate = NO;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(userSeekToPosition:)
                          name:N_USER_SEEK_TO_POSITION object:nil];
}

- (void)initializePlayerView {
    self.view.delegate = self;
    [self.view setPlayButtonsSelected:NO];
    [self.view.scrubber setValue:0.0f animated:NO];
    self.view.controlHideCountdown = [self.view.playerControlsAutoHideTime integerValue];
    
    if (!self.forceRotate) {
        self.view.fullscreenButton.hidden = YES;
    }
}

- (void)loadCurrentVideoTrack {
    __weak __typeof__(self) weakSelf = self;
    RUN_ON_UI_THREAD(^{
        [weakSelf playVideoTrack:self.videoTrack];
    });
}

#pragma mark - Error Handling

- (NSString*)videoPlayerErrorCodeToString:(VKVideoPlayerErrorCode)code {
    switch (code) {
        case kVideoPlayerErrorVideoBlocked:
            return @"kVideoPlayerErrorVideoBlocked";
            break;
        case kVideoPlayerErrorFetchStreamError:
            return @"kVideoPlayerErrorFetchStreamError";
            break;
        case kVideoPlayerErrorStreamNotFound:
            return @"kVideoPlayerErrorStreamNotFound";
            break;
        case kVideoPlayerErrorAssetLoadError:
            return @"kVideoPlayerErrorAssetLoadError";
            break;
        case kVideoPlayerErrorDurationLoadError:
            return @"kVideoPlayerErrorDurationLoadError";
            break;
        case kVideoPlayerErrorAVPlayerFail:
            return @"kVideoPlayerErrorAVPlayerFail";
            break;
        case kVideoPlayerErrorAVPlayerItemFail:
            return @"kVideoPlayerErrorAVPlayerItemFail";
            break;
        case kVideoPlayerErrorUnknown:
        default:
            return @"kVideoPlayerErrorUnknown";
            break;
    }
}

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode track:(id<VKVideoPlayerTrackProtocol>)track {
    [self handleErrorCode:errorCode track:track customMessage:nil];
}

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode track:(id<VKVideoPlayerTrackProtocol>)track customMessage:(NSString*)customMessage {
    RUN_ON_UI_THREAD(^{
        self.view.loadVideoStatus = LoadVideoError;
        if ([self.delegate respondsToSelector:@selector(handleErrorCode:track:customMessage:)]) {
            [self.delegate handleErrorCode:errorCode track:track customMessage:customMessage];
        }
    });
}

#pragma mark - KVO

- (void)setTimeObserver:(id)timeObserver {
    if (_timeObserver) {
        [self.avPlayer removeTimeObserver:_timeObserver];
    }
    _timeObserver = timeObserver;
    if (timeObserver) {
    }
}

- (void)setCaptionBottomTimer:(id)captionBottomTimer {
}

- (void)setCaptionTopTimer:(id)captionTopTimer {
}

- (void)addObservers {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    [defaultCenter addObserver:self selector:@selector(reachabilityChanged:) name:N_REACHABILITY_NETWORK_CHANE object:nil];
    [defaultCenter addObserver:self selector:@selector(playerItemReadyToPlay) name:kVKVideoPlayerItemReadyToPlay object:nil];
    [defaultCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:kVKSettingsSubtitlesEnabledKey options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    [defaults addObserver:self forKeyPath:kVKSettingsTopSubtitlesEnabledKey options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    [defaults addObserver:self forKeyPath:kVKSettingsSubtitleLanguageCodeKey options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    [defaults addObserver:self forKeyPath:kVKVideoQualityKey options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    
    [defaultCenter addObserver:self selector:@selector(loadVideoError:)
                          name:N_LOAD_VIDEO_ERROR object:nil];
    
      [defaultCenter addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
      [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:kVKSettingsSubtitlesEnabledKey];
    [defaults removeObserver:self forKeyPath:kVKSettingsTopSubtitlesEnabledKey];
    [defaults removeObserver:self forKeyPath:kVKSettingsSubtitleLanguageCodeKey];
    [defaults removeObserver:self forKeyPath:kVKVideoQualityKey];
}

- (NSString*)observedBitrateBucket:(NSNumber*)observedKbps {
    NSString* observedKbpsString = @"";
    if ([observedKbps integerValue] <= 100) {
        observedKbpsString = @"0-100";
    } else if ([observedKbps integerValue] <= 200) {
        observedKbpsString = @"101-200";
    } else if ([observedKbps integerValue] <= 400) {
        observedKbpsString = @"201-400";
    } else if ([observedKbps integerValue] <= 600) {
        observedKbpsString = @"401-600";
    } else if ([observedKbps integerValue] <= 800) {
        observedKbpsString = @"601-800";
    } else if ([observedKbps integerValue] <= 1000) {
        observedKbpsString = @"801-1000";
    } else if ([observedKbps integerValue] > 1000) {
        observedKbpsString = @">1000";
    }
    return observedKbpsString;
}

- (void)periodicTimeObserver:(CMTime)time {
    NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
    NSTimeInterval lastTimeInSeconds = _previousPlaybackTime;
    
    if (timeInSeconds <= 0) {
        return;
    }
    
    if ([self isPlayingVideo]) {
        NSTimeInterval interval = fabs(timeInSeconds - _previousPlaybackTime);
        if (interval < 2 ) {
        }
        
        _previousPlaybackTime = timeInSeconds;
    }
    
    if ([self.player currentItemDuration] > 1) {
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:timeInSeconds] forKey:@"scrubberValue"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerScrubberValueUpdatedNotification object:self userInfo:info];
        
        NSDictionary *durationInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:self.track.hasPrevious], @"hasPreviousVideo",
                                      [NSNumber numberWithBool:self.track.hasNext], @"hasNextVideo",
                                      [NSNumber numberWithDouble:[self.player currentItemDuration]], @"duration",
                                      nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerDurationDidLoadNotification object:self userInfo:durationInfo];
    }
    
    [self.view hideControlsIfNecessary];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayFrame:time:lastTime:)]) {
        [self.delegate videoPlayer:self didPlayFrame:self.track time:timeInSeconds lastTime:lastTimeInSeconds];
    }
}

- (void)seekToTimeInSecond:(float)sec userAction:(BOOL)isUserAction completionHandler:(void (^)(BOOL finished))completionHandler {
    [self scrubbingBegin];
    [self scrubbingEndAtSecond:sec userAction:isUserAction completionHandler:completionHandler];
}

- (void)scrubbingEndAtSecond:(float)sec userAction:(BOOL)isUserAction completionHandler:(void (^)(BOOL finished))completionHandler {
    [self.player seekToTimeInSeconds:sec completionHandler:completionHandler];
}


#pragma mark - Playback position

- (void)seekToLastWatchedDuration {
    RUN_ON_UI_THREAD(^{
        
        [self.view setPlayButtonsEnabled:NO];
        
        CGFloat lastWatchedTime = [self.track.lastDurationWatchedInSeconds floatValue];
        if (lastWatchedTime > 5) lastWatchedTime -= 5;
        
        [self.view.scrubber setValue:([self.player currentItemDuration] > 0) ? lastWatchedTime / [self.player currentItemDuration] : 0.0f animated:NO];
        
        [self.player seekToTimeInSeconds:lastWatchedTime completionHandler:^(BOOL finished) {
            if (finished) [self playContent];
            [self.view setPlayButtonsEnabled:YES];
            
            if ([self.delegate respondsToSelector:@selector(videoPlayer:didStartVideo:)]) {
                [self.delegate videoPlayer:self didStartVideo:self.track];
            }
        }];
        
    });
}

- (void)playerDidPlayToEnd:(NSNotification *)notification {
    RUN_ON_UI_THREAD(^{
        
        self.track.isPlayedToEnd = YES;
        if ([self isFullScreen]) {
            [self.view fullscreenButtonTapped:nil];
        }
        [self pauseContent:NO completionHandler:^{
            if ([self.delegate respondsToSelector:@selector(videoPlayer:didPlayToEnd:)]) {
                [self.delegate videoPlayer:self didPlayToEnd:self.track];
            }
        }];
        
    });
}

#pragma mark - AVPlayer wrappers

- (BOOL)isPlayingVideo {
    return (self.avPlayer && self.avPlayer.rate != 0.0);
}


#pragma mark - Airplay

- (TPVideoPlayerView*)activePlayerView {
    return self.view;
}

- (BOOL)isPlayingOnExternalDevice {
    return NO;
}

#pragma mark - Hundle Videos
- (void)loadVideoWithTrack:(id<VKVideoPlayerTrackProtocol>)track {
    self.track = track;
    self.state = VKVideoPlayerStateContentLoading;
    
    VoidBlock completionHandler = ^{
        [self playVideoTrack:self.track];
    };
    switch (self.state) {
        case VKVideoPlayerStateError:
        case VKVideoPlayerStateContentPaused:
        case VKVideoPlayerStateContentLoading:
            completionHandler();
            break;
        case VKVideoPlayerStateContentPlaying:
            [self pauseContent:NO completionHandler:completionHandler];
            break;
        default:
            break;
    };
}
- (void)loadVideoWithStreamURL:(NSURL*)streamURL {
    [self loadVideoWithTrack:[[VKVideoPlayerTrack alloc] initWithStreamURL:streamURL]];
}

- (void)setTrack:(id<VKVideoPlayerTrackProtocol>)track {
    _track = track;
    _pendingTrack = nil;
    [self clearPlayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerUpdateVideoTrack object:track];
    [self updateTrackControls];
}


- (void)clearPlayer {
    self.playerItem = nil;
    self.avPlayer = nil;
    self.player = nil;
}

- (void)playVideoTrack:(id<VKVideoPlayerTrackProtocol>)track {
    if (![UserDefaultsManager boolValueForKey:FEEDS_VIDEO_PLAY_IN_DATA_CONNECTION defaultValue:NO]) {
        ClientNetworkType networkType = [Reachability network];
        if (networkType != network_wifi
            && networkType > network_none) {
            self.pendingTrack = track;
            self.view.loadVideoStatus = LoadVideoNotWifi;
            return;
        }
    }

    if ([self.delegate respondsToSelector:@selector(shouldVideoPlayer:startVideo:)]) {
        if (![self.delegate shouldVideoPlayer:self startVideo:track]) {
            return;
        }
    }
    [self clearPlayer];
    
    NSURL *streamURL = [track streamURL];
    if (!streamURL) {
        return;
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:N_FEEDS_VIDEO_RESET_STATS object:nil];
    [self playOnAVPlayer:streamURL playerLayerView:[self activePlayerView].playerLayerView track:track];
}

- (void)playOnAVPlayer:(NSURL*)streamURL playerLayerView:(VKVideoPlayerLayerView*)playerLayerView track:(id<VKVideoPlayerTrackProtocol>)track {
    
    if (!track.isVideoLoadedBefore) {
        track.isVideoLoadedBefore = YES;
    }
    
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:streamURL options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    [asset loadValuesAsynchronouslyForKeys:@[kTracksKey, kPlayableKey] completionHandler:^{
        // Completion handler block.
        RUN_ON_UI_THREAD(^{
            if (self.state == VKVideoPlayerStateDismissed) return;
            if (![asset.URL.absoluteString isEqualToString:streamURL.absoluteString]) {
                return;
            }
            NSError *error = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                self.avPlayer = [self playerWithPlayerItem:self.playerItem];
                self.player = (id<VKPlayer>)self.avPlayer;
                [playerLayerView setPlayer:self.avPlayer];
                
                [DialerUsageRecord recordpath:PATH_FEEDS_VIDEO kvs:Pair(FEEDS_VIDEO_PLAYED_COUNT, @(1)), nil];
                
            } else {
                // You should deal with the error appropriately.
                [self handleErrorCode:kVideoPlayerErrorAssetLoadError track:track];
            }
        });
    }];
}

- (void)playerItemReadyToPlay {
    
    RUN_ON_UI_THREAD(^{
        switch (self.state) {
            case VKVideoPlayerStateContentPaused:
                break;
            case VKVideoPlayerStateContentLoading:{}
            case VKVideoPlayerStateError:{
                [self pauseContent:NO completionHandler:^{
                    if ([self.delegate respondsToSelector:@selector(videoPlayer:willStartVideo:)]) {
                        [self.delegate videoPlayer:self willStartVideo:self.track];
                    }
                    [self seekToLastWatchedDuration];
                }];
                break;
            }
            default:
                break;
        }
    });
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    _playerItem = playerItem;
    _previousIndicatedBandwidth = 0.0f;
    
    if (!playerItem) {
        return;
    }
    [_playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
}

- (void)setAvPlayer:(AVPlayer *)avPlayer {
    self.timeObserver = nil;
    self.captionTopTimer = nil;
    self.captionBottomTimer = nil;
    [_avPlayer removeObserver:self forKeyPath:@"status"];
    _avPlayer = avPlayer;
    if (avPlayer) {
        __weak __typeof(self) weakSelf = self;
        [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
        self.timeObserver = [avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
            [weakSelf periodicTimeObserver:time];
        }];
    }
}

- (AVPlayer*)playerWithPlayerItem:(AVPlayerItem*)playerItem {
    AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
    return player;
}

- (void)reloadCurrentVideoTrack {
    RUN_ON_UI_THREAD(^{
        VoidBlock completionHandler = ^{
            self.state = VKVideoPlayerStateContentLoading;
            [self loadCurrentVideoTrack];
        };
        
        switch (self.state) {
            case VKVideoPlayerStateUnknown:
            case VKVideoPlayerStateContentLoading:
            case VKVideoPlayerStateContentPaused:
            case VKVideoPlayerStateError:
                completionHandler();
                break;
            case VKVideoPlayerStateContentPlaying:
                [self pauseContent:NO completionHandler:completionHandler];
                break;
            case VKVideoPlayerStateDismissed:
            case VKVideoPlayerStateSuspend:
                break;
        }
    });
}

- (float)currentBitRateInKbps {
    return [self.playerItem.accessLog.events.lastObject observedBitrate]/1000;
}

- (void) pauseContentAndStopBuffering {
    if (!self.bufferingStopped) {
        self.bufferingStopped = YES;
        self.previousPlayerItem = self.avPlayer.currentItem;
        [self pauseContent];
        [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
        self.view.bottomControlOverlay.hidden = YES;
        
        if ([Reachability network] == network_none) {
            self.view.loadVideoStatus = LoadVideoError;
        } else {
            self.view.loadVideoStatus = LoadVideoNotWifi;
        }
    }
}

- (void) playContentAndContinueBuffering {
    if (self.bufferingStopped) {
        self.bufferingStopped = NO;
        [self.avPlayer replaceCurrentItemWithPlayerItem:self.previousPlayerItem];
        self.previousPlayerItem = nil;
        [self playContent];
    }
}

#pragma mark -

- (NSTimeInterval)currentTime {
    if (!self.track.isVideoLoadedBefore) {
        return [self.track.lastDurationWatchedInSeconds doubleValue] > 0 ? [self.track.lastDurationWatchedInSeconds doubleValue] : 0.0f;
    } else return CMTimeGetSeconds([self.player currentCMTime]);
}

#pragma mark - captions
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [NSUserDefaults standardUserDefaults]) {
        if ([keyPath isEqualToString:kVKSettingsSubtitlesEnabledKey]) {
            NSString  *fromLang, *toLang;
            if ([[change valueForKeyPath:NSKeyValueChangeNewKey] boolValue]) {
                fromLang = @"null";
                toLang = VKSharedVideoPlayerSettingsManager.subtitleLanguageCode;
            } else {
                fromLang = VKSharedVideoPlayerSettingsManager.subtitleLanguageCode;
                toLang = @"null";
            }
            
            if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeSubtitleFrom:to:)]) {
                [self.delegate videoPlayer:self didChangeSubtitleFrom:fromLang to:toLang];
            }
        }
        if ([keyPath isEqualToString:kVKSettingsTopSubtitlesEnabledKey]) {
            if ([[change valueForKeyPath:NSKeyValueChangeNewKey] boolValue]) {
                //        self.track.topSubtitleEnabled = @YES;
            } else {
            }
        }
        if ([keyPath isEqualToString:kVKSettingsSubtitleLanguageCodeKey]) {
        }
        if ([keyPath isEqualToString:kVKVideoQualityKey]) {
            [self reloadCurrentVideoTrack];
        }
    }
    
    if (object == self.avPlayer) {
        if ([keyPath isEqualToString:@"status"]) {
            switch ([self.avPlayer status]) {
                case AVPlayerStatusReadyToPlay:
                    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerItemReadyToPlay object:nil];
                    }
                    break;
                case AVPlayerStatusFailed:
                    [self handleErrorCode:kVideoPlayerErrorAVPlayerFail track:self.track];
                default:
                    break;
            }
        }
    }
    
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            if (self.playerItem.isPlaybackBufferEmpty && [self currentTime] > 0 && [self currentTime] < [self.player currentItemDuration] - 1 && self.state == VKVideoPlayerStateContentPlaying) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerPlaybackBufferEmpty object:nil];
                self.view.loadVideoStatus = LoadVideoError;
            }
        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.playerItem.playbackLikelyToKeepUp) {
                if (self.state == VKVideoPlayerStateContentPlaying && ![self isPlayingVideo]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerPlaybackLikelyToKeepUp object:nil];
                    [self.player play];
                }
            }
        }
        if ([keyPath isEqualToString:@"status"]) {
            switch ([self.playerItem status]) {
                case AVPlayerItemStatusReadyToPlay:
                    if ([self.avPlayer status] == AVPlayerStatusReadyToPlay) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerItemReadyToPlay object:nil];
                    }
                    break;
                case AVPlayerItemStatusFailed:
                    [self handleErrorCode:kVideoPlayerErrorAVPlayerItemFail track:self.track];
                default:
                    break;
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSArray *timeRanges = (NSArray*)[change objectForKey:NSKeyValueChangeNewKey];
            if (timeRanges && [timeRanges count]) {
                CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
                cootek_log(@"TPVideoPlayer, timerange:");
                float loadedTime = CMTimeGetSeconds(timerange.duration);
                NSDictionary *info = @{@"loadedTime": @(loadedTime)};
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:kVKVideoPlayerLoadedTime object:nil userInfo:info];
            }
        }
    }
}



#pragma mark - Controls

- (NSString*)playerStateDescription:(VKVideoPlayerState)playerState {
    switch (playerState) {
        case VKVideoPlayerStateUnknown:
            return @"Unknown";
            break;
        case VKVideoPlayerStateContentLoading:
            return @"ContentLoading";
            break;
        case VKVideoPlayerStateContentPaused:
            return @"ContentPaused";
            break;
        case VKVideoPlayerStateContentPlaying:
            return @"ContentPlaying";
            break;
        case VKVideoPlayerStateSuspend:
            return @"Player Stay";
            break;
        case VKVideoPlayerStateDismissed:
            return @"Player Dismissed";
            break;
        case VKVideoPlayerStateError:
            return @"Player Error";
            break;
    }
}


- (void)setState:(VKVideoPlayerState)newPlayerState {
    if ([self.delegate respondsToSelector:@selector(shouldVideoPlayer:changeStateTo:)]) {
        if (![self.delegate shouldVideoPlayer:self changeStateTo:newPlayerState]) {
            return;
        }
    }
    RUN_ON_UI_THREAD(^{
        if ([self.delegate respondsToSelector:@selector(videoPlayer:willChangeStateTo:)]) {
            [self.delegate videoPlayer:self willChangeStateTo:newPlayerState];
        }
        
        VKVideoPlayerState oldPlayerState = self.state;
        if (oldPlayerState == newPlayerState) return;
        
        switch (oldPlayerState) {
            case VKVideoPlayerStateContentLoading:
                break;
            case VKVideoPlayerStateContentPlaying:
                break;
            case VKVideoPlayerStateContentPaused:
                self.view.bigPlayButton.hidden = YES;
                break;
            case VKVideoPlayerStateDismissed:
                break;
            case VKVideoPlayerStateError:
                self.view.messageLabel.hidden = YES;
                break;
            default:
                break;
        }
        
        _state = newPlayerState;
        
        switch (newPlayerState) {
            case VKVideoPlayerStateUnknown:
                break;
            case VKVideoPlayerStateContentLoading:
                [self setLoading:YES];
                self.playerControlsEnabled = NO;
                if (self.view.previewImageLoaded) {
                    self.view.previewImageView.hidden = NO;
                }
                break;
            case VKVideoPlayerStateContentPlaying: {
                self.view.loadVideoStatus = LoadVideoNormal;
                self.view.controlHideCountdown = [self.view.playerControlsAutoHideTime integerValue];
                self.playerControlsEnabled = YES;
                [self.view setPlayButtonsSelected:NO];
                self.view.playerLayerView.hidden = NO;
                self.view.messageLabel.hidden = YES;
                self.view.previewImageView.hidden = YES;
                self.view.externalDeviceView.hidden = ![self isPlayingOnExternalDevice];
                [self.player play];
            } break;
            case VKVideoPlayerStateContentPaused:
                self.playerControlsEnabled = YES;
                [self.view setPlayButtonsSelected:YES];
                self.view.playerLayerView.hidden = NO;
                self.track.lastDurationWatchedInSeconds = [NSNumber numberWithFloat:[self currentTime]];
                self.view.messageLabel.hidden = YES;
                self.view.externalDeviceView.hidden = ![self isPlayingOnExternalDevice];
                [self.player pause];
                break;
            case VKVideoPlayerStateSuspend:
                break;
            case VKVideoPlayerStateError:{
                [self.player pause];
                self.view.externalDeviceView.hidden = YES;
                self.view.playerLayerView.hidden = YES;
                self.playerControlsEnabled = NO;
                self.view.messageLabel.hidden = NO;
                self.view.controlHideCountdown = kPlayerControlsDisableAutoHide;
                break;
            }
            case VKVideoPlayerStateDismissed:
                self.view.playerLayerView.hidden = YES;
                self.playerControlsEnabled = NO;
                self.avPlayer = nil;
                self.playerItem = nil;
                break;
        }
        
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeStateFrom:)]) {
            [self.delegate videoPlayer:self didChangeStateFrom:oldPlayerState];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVKVideoPlayerStateChanged object:nil userInfo:@{
                                                                                                                    @"oldState":[NSNumber numberWithInteger:oldPlayerState],
                                                                                                                    @"newState":[NSNumber numberWithInteger:newPlayerState]
                                                                                                                    }];
    });
}

- (void)playContent {
    RUN_ON_UI_THREAD(^{
        if (self.state == VKVideoPlayerStateContentPaused) {
            self.state = VKVideoPlayerStateContentPlaying;
        }
    });
}

- (void)pauseContent {
    [self pauseContent:NO completionHandler:nil];
}

- (void)pauseContentWithCompletionHandler:(void (^)())completionHandler {
    [self pauseContent:NO completionHandler:completionHandler];
}

- (void)pauseContent:(BOOL)isUserAction completionHandler:(void (^)())completionHandler {
    
    RUN_ON_UI_THREAD(^{
        
        switch ([self.playerItem status]) {
            case AVPlayerItemStatusFailed:
                self.state = VKVideoPlayerStateError;
                return;
                break;
            case AVPlayerItemStatusUnknown:
                self.state = VKVideoPlayerStateContentLoading;
                return;
                break;
            default:
                break;
        }
        
        switch ([self.avPlayer status]) {
            case AVPlayerStatusFailed:
                self.state = VKVideoPlayerStateError;
                return;
                break;
            case AVPlayerStatusUnknown:
                self.state = VKVideoPlayerStateContentLoading;
                return;
                break;
            default:
                break;
        }
        
        switch (self.state) {
            case VKVideoPlayerStateContentLoading:
            case VKVideoPlayerStateContentPlaying:
            case VKVideoPlayerStateContentPaused:
            case VKVideoPlayerStateSuspend:
            case VKVideoPlayerStateError: {
                self.state = VKVideoPlayerStateContentPaused;
                long playedTimeInSeconds = (long)self.previousPlaybackTime;
                NSDictionary *info = @{@"previousPlaybackTime": @(playedTimeInSeconds)};
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:N_FEEDS_VIDEO_PAUSED_STATS object:nil userInfo:info];
                if (completionHandler)  {
                    completionHandler();
                }
                break;
            }
            default:
                break;
        }
    });
}

- (void)setPlayerControlsEnabled:(BOOL)enabled {
    [self.view setControlsEnabled:enabled];
}


- (void)updateTrackControls {
}


#pragma mark - VKScrubberDelegate

- (void)scrubbingBegin {
    [self pauseContent:NO completionHandler:^{
        _scrubbing = YES;
        self.view.controlHideCountdown = -1;
        _beforeSeek = [self currentTime];
    }];
}

- (void)scrubbingEnd {
    _scrubbing = NO;
    float afterSeekTime = self.view.scrubber.value;
    [self scrubbingEndAtSecond:afterSeekTime userAction:YES completionHandler:^(BOOL finished) {
        if (finished) [self playContent];
    }];
}

- (void)zoomInPressed {
    ((AVPlayerLayer *)self.view.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
        self.view.frame = self.view.frame;
    }
}

- (void)zoomOutPressed {
    ((AVPlayerLayer *)self.view.layer).videoGravity = AVLayerVideoGravityResizeAspect;
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
        self.view.frame = self.view.frame;
    }
}

#pragma mark - VKVideoPlayerViewDelegate
- (id<VKVideoPlayerTrackProtocol>)videoTrack {
    return self.track;
}

- (void)fullScreenButtonTapped {
    self.isFullScreen = self.view.fullscreenButton.selected;
    
    // self.isFullScreen
    // if it is to enter full screen
    if (self.isFullScreen) {
        [self performOrientationChange:UIInterfaceOrientationLandscapeRight];
    } else {
        [self performOrientationChange:UIInterfaceOrientationPortrait];
    }
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:VKVideoPlayerControlEventTapFullScreen];
    }
    
    UINavigationBar *naviBar = self.viewController.navigationController.navigationBar;
    naviBar.hidden = [self isFullScreen];
    [self.viewController setNeedsStatusBarAppearanceUpdate];
}

- (void)playButtonPressed {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:N_FEEDS_VIDEO_RESET_STATS object:nil];
    [self playContent];
}

- (void)pauseButtonPressed {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:N_FEEDS_VIDEO_SEND_STATS object:nil];
    switch (self.state) {
        case VKVideoPlayerStateContentPlaying:
            [self pauseContent:YES completionHandler:nil];
            break;
        default:
            break;
    }
}

- (void) backButtonPressed {
    if ([self isFullScreen]) {
        [self fullScreenButtonTapped];
    } else {
        [(TPDVideoPlayController *)self.viewController backButtonPressed];
    }
}

- (void) bigPlayButtonPressed {
    if (self.bufferingStopped && self.pendingTrack == nil) {
        BOOL canPlayInDataConnection = [UserDefaultsManager
                                        boolValueForKey:FEEDS_VIDEO_PLAY_IN_DATA_CONNECTION defaultValue:NO];
        if (!canPlayInDataConnection
            && [Reachability network] != network_wifi) {
            self.view.loadVideoStatus = LoadVideoNotWifi;
        } else {
           [self playContentAndContinueBuffering];
        }
        
    } else if (self.state == VKVideoPlayerStateContentPaused) {
        [self playContent];
    } else {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:N_FEEDS_VIDEO_RESET_STATS object:nil];
        [self reloadCurrentVideoTrack];
    }
}

- (void)doneButtonTapped {
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:VKVideoPlayerControlEventTapDone];
    }
}

- (void)playerViewSingleTapped {
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:VKVideoPlayerControlEventTapPlayerView];
    }
}

- (void)layoutNavigationAndStatusBarForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:NO];
}

#pragma mark - Auto hide controls

- (void)setForceRotate:(BOOL)forceRotate {
    if (_forceRotate != forceRotate) {
        _forceRotate = forceRotate;
    }
    
    self.view.fullscreenButton.hidden = !self.forceRotate;
}

- (void)setLoading:(BOOL)loading {
    if (loading) {
        [self.view.activityIndicator startAnimating];
    } else {
        [self.view.activityIndicator stopAnimating];
    }
}

#pragma mark - Handle volume change

- (void)volumeChanged:(NSNotification *)notification {
    self.view.controlHideCountdown = [self.view.playerControlsAutoHideTime integerValue];
}



#pragma mark - Remote Control Events handler

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self playButtonPressed];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self pauseButtonPressed];
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self nextTrackButtonPressed];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self previousTrackButtonPressed];
                break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
                [self scrubbingBegin];
                break;
            case UIEventSubtypeRemoteControlEndSeekingForward:
            case UIEventSubtypeRemoteControlEndSeekingBackward:
                self.view.scrubber.value = receivedEvent.timestamp;
                [self scrubbingEnd];
                break;
            default:
                break;
        }
    }
}


#pragma mark - Orientation
- (void)orientationChanged:(NSNotification *)note {
    UIDevice * device = note.object;
    
    UIInterfaceOrientation rotateToOrientation;
    switch(device.orientation) {
        case UIDeviceOrientationPortrait:
            rotateToOrientation = UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            rotateToOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotateToOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotateToOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            rotateToOrientation = self.visibleInterfaceOrientation;
            break;
    }
    
    if ((1 << rotateToOrientation) & self.supportedOrientations && rotateToOrientation != self.visibleInterfaceOrientation) {
        [self performOrientationChange:rotateToOrientation];
    }
}

- (void)performOrientationChange:(UIInterfaceOrientation)deviceOrientation {
    if (!self.forceRotate) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayer:willChangeOrientationTo:)]) {
        [self.delegate videoPlayer:self willChangeOrientationTo:deviceOrientation];
    }
    
    CGFloat degrees = [self degreesForOrientation:deviceOrientation];
    UIInterfaceOrientation lastOrientation = self.visibleInterfaceOrientation;
    self.visibleInterfaceOrientation = deviceOrientation;
    
    @weakify(self);
    [UIView animateWithDuration:0.3f animations:^{
        @strongify(self);
        TPVideoPlayerView *playerView = self.view;
        UIView *parentView = playerView.superview; // ==> self.view
        
        CGRect bounds = [[UIScreen mainScreen] bounds];
        parentView.transform = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        parentView.frame = bounds;
        
//        parentView.layer.borderColor = [UIColor redColor].CGColor;
//        parentView.layer.borderWidth = 2;
//        
//        playerView.layer.borderColor = [UIColor blueColor].CGColor;
//        playerView.layer.borderWidth = 1;
//        
//        playerView.playerLayerView.layer.borderColor = [UIColor whiteColor].CGColor;
//        playerView.playerLayerView.layer.borderWidth = 1;
        
        
        if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
            // to enter full screen
            [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(parentView);
                make.left.right.mas_equalTo(parentView);
                make.height.mas_equalTo(parentView);
            }];
            
            [playerView.playerLayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(playerView);
            }];
            
        } else {
            // to exit full screen
            [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(parentView).offset(20);
                make.left.right.mas_equalTo(parentView);
                make.height.mas_equalTo(VIDEO_PORTRAIT_HEIGHT);
            }];
            
            [playerView.playerLayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.mas_equalTo(playerView);
                make.height.mas_equalTo(VIDEO_PORTRAIT_HEIGHT);
            }];
        }
        [parentView layoutIfNeeded];
        [self.view updateTopOverlayerToOrientation:deviceOrientation];
        
//        CGRect wvFrame = weakSelf.view.superview.superview.frame;
//        if (wvFrame.origin.y > 0) {
//            wvFrame.size.height = CGRectGetHeight(bounds) ;
//            wvFrame.origin.y = 0;
//            weakSelf.view.superview.superview.frame = wvFrame;
//        }
        
    } completion:^(BOOL finished) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeOrientationFrom:)]) {
            [self.delegate videoPlayer:self didChangeOrientationFrom:lastOrientation];
        }
    }];

    [[UIApplication sharedApplication] setStatusBarOrientation:self.visibleInterfaceOrientation
                                                      animated:YES];
    self.view.fullscreenButton.selected = self.isFullScreen = UIInterfaceOrientationIsLandscape(deviceOrientation);
    
    [[UIApplication sharedApplication] setStatusBarHidden:[self isFullScreen]];
    if (self.view.loadStatusView.hidden) {
        [self.view handleSingleTap:nil];
    }
}

- (CGFloat)degreesForOrientation:(UIInterfaceOrientation)deviceOrientation {
    switch (deviceOrientation) {
        case UIInterfaceOrientationPortrait:
            return 0;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return 90;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return -90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 180;
            break;
        case UIInterfaceOrientationUnknown:
            break;
    }
    return 0;
}

#pragma mark - Notification:
- (void) loadVideoError:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) {
        return;
    }
    LoadVideoErrorUserAction userAction = (LoadVideoErrorUserAction)[[userInfo objectForKey:kLoadVideoErrorUserAction] integerValue];
    switch (userAction) {
        case ErrorActionReload: {
            if (self.bufferingStopped) {
                self.bufferingStopped = NO;
                [self playContentAndContinueBuffering];
                
            } else if (self.state == VKVideoPlayerStateContentPaused) {
                [self playContent];
                
            } else {
                [self reloadCurrentVideoTrack];
            }
            
            break;
        }
        case ErrorActionNotWiFiStop: {
//            [self loadVideoWithTrack:self.pendingTrack];
            self.view.loadVideoStatus = LoadVideoNormal;
            [self.view setBigPlayButtonHidden:NO];
            break;
        }
        case ErrorActionNotWiFiContinue: {
            if (self.bufferingStopped && self.pendingTrack == nil) {
                if ([UserDefaultsManager boolValueForKey:FEEDS_VIDEO_PLAY_IN_DATA_CONNECTION
                                            defaultValue:NO]) {
                    [self playContentAndContinueBuffering];
                } else {
                    [self.view setBigPlayButtonHidden:NO];
                    self.view.bottomControlOverlay.hidden = YES;
                }
            } else if (self.state == VKVideoPlayerStateContentPaused) {
                [self playContent];
                
            } else {
                if (self.pendingTrack != nil) {
                    self.state = VKVideoPlayerStateUnknown;
                    [self loadVideoWithTrack:self.pendingTrack];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void) applicationWillResignActive {
    if ([self isPlayingVideo]) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:N_FEEDS_VIDEO_SEND_STATS object:nil];
        
        self.pausedByResigningActive = YES;
        [self pauseContent];
    
        [self.view setBigPlayButtonHidden:YES];
        self.view.topControlOverlay.hidden = NO;
        self.view.bottomControlOverlay.hidden = NO;
    }
}

- (void) applicationDidBecomeActive {
    if (self.pausedByResigningActive) {
        self.pausedByResigningActive = NO;

        [[NSNotificationCenter defaultCenter]
            postNotificationName:N_FEEDS_VIDEO_RESET_STATS object:nil];
    }
}

- (void) userSeekToPosition:(NSNotification *)notification {
    float seekedTime = [[notification.userInfo objectForKey:@"seekedValue"] floatValue];
    [self seekToTimeInSecond:seekedTime userAction:YES completionHandler:^(BOOL finished) {
        if (![self isPlayingVideo]) {
            [self playContent];
        }
    }];
}

- (void)reachabilityChanged:(NSNotification*)notification {
    Reachability* curReachability = notification.object;
    if (curReachability.networkStatus != network_wifi) {
        if (![UserDefaultsManager boolValueForKey:FEEDS_VIDEO_PLAY_IN_DATA_CONNECTION
                                     defaultValue:NO]){
            RUN_ON_UI_THREAD(^{
                [self pauseContentAndStopBuffering];
            });
        }
    }
}

@end


