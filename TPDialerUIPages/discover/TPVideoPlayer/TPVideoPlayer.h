//
//  TPVideoPlayer.h
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//

#ifndef TPVideoPlayer_h
#define TPVideoPlayer_h


#import <Foundation/Foundation.h>
#import "VKVideoPlayer.h"
#import "TPVideoPlayerView.h"
#import "VKVideoPlayerView.h"
#import "VKVideoPlayerCaption.h"
#import "VKVideoPlayerTrack.h"

@class TPVideoPlayer;

@protocol TPVideoPlayerDelegate <NSObject>
@optional
- (BOOL)shouldVideoPlayer:(TPVideoPlayer*)videoPlayer changeStateTo:(VKVideoPlayerState)toState;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer willChangeStateTo:(VKVideoPlayerState)toState;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didChangeStateFrom:(VKVideoPlayerState)fromState;
- (BOOL)shouldVideoPlayer:(TPVideoPlayer*)videoPlayer startVideo:(id<VKVideoPlayerTrackProtocol>)track;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer willStartVideo:(id<VKVideoPlayerTrackProtocol>)track;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didStartVideo:(id<VKVideoPlayerTrackProtocol>)track;

- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didPlayFrame:(id<VKVideoPlayerTrackProtocol>)track time:(NSTimeInterval)time lastTime:(NSTimeInterval)lastTime;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didPlayToEnd:(id<VKVideoPlayerTrackProtocol>)track;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didControlByEvent:(VKVideoPlayerControlEvent)event;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didChangeSubtitleFrom:(NSString*)fronLang to:(NSString*)toLang;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer willChangeOrientationTo:(UIInterfaceOrientation)orientation;
- (void)videoPlayer:(TPVideoPlayer*)videoPlayer didChangeOrientationFrom:(UIInterfaceOrientation)orientation;

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode track:(id<VKVideoPlayerTrackProtocol>)track customMessage:(NSString*)customMessage;
@end

@interface TPVideoPlayer : NSObject <VKVideoPlayerViewDelegate>
@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, strong) TPVideoPlayerView *view;
@property (nonatomic, strong) id<VKVideoPlayerTrackProtocol> track;
@property (nonatomic, strong) id<VKVideoPlayerTrackProtocol> pendingTrack;
@property (nonatomic, weak) id<TPVideoPlayerDelegate> delegate;
@property (nonatomic, assign) VKVideoPlayerState state;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic, assign) BOOL playerControlsEnabled;
@property (nonatomic, strong) id<VKPlayer> player;
@property (nonatomic, assign) UIInterfaceOrientation visibleInterfaceOrientation;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, strong, readonly) NSURL* streamURL;
@property (nonatomic, strong) NSString* defaultStreamKey;

@property (nonatomic, assign) CGRect portraitFrame;
@property (nonatomic, assign) CGRect landscapeFrame;
@property (nonatomic, assign) BOOL forceRotate;
@property (nonatomic, strong) AVPlayerItem *previousPlayerItem;
@property (nonatomic, assign) NSTimeInterval previousPlaybackTime;

- (instancetype) initWithVideoPlayerView:(TPVideoPlayerView *)videoPlayerView;

- (void)seekToLastWatchedDuration;
- (void)seekToTimeInSecond:(float)sec userAction:(BOOL)isUserAction completionHandler:(void (^)(BOOL finished))completionHandler;
- (BOOL)isPlayingVideo;
- (NSTimeInterval)currentTime;
- (void)performOrientationChange:(UIInterfaceOrientation)deviceOrientation;

#pragma mark - Error Handling
- (NSString*)videoPlayerErrorCodeToString:(VKVideoPlayerErrorCode)code;

#pragma mark - Resource
- (void)loadVideoWithTrack:(id<VKVideoPlayerTrackProtocol>)track;
- (void)loadVideoWithStreamURL:(NSURL*)streamURL;
- (void)reloadCurrentVideoTrack;
- (TPVideoPlayerView*)activePlayerView;

#pragma mark - Controls
- (void)playContent;
- (void)pauseContent;
- (void)pauseContentWithCompletionHandler:(void (^)())completionHandler;
- (void)pauseContent:(BOOL)isUserAction completionHandler:(void (^)())completionHandler;
- (void)updateTrackControls;

- (void) pauseContentAndStopBuffering;
- (void) playContentAndContinueBuffering;
@end


#endif /* TPVideoPlayer_h */



