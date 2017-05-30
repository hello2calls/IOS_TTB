//
//  TPVideoPlayerView.h
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//

#ifndef TPVideoPlayerView_h
#define TPVideoPlayerView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VKVideoPlayerView.h"
#import "TPVideoSlider.h"
#import "FindNewsItem.h"

#define VIDEO_HEIGHT_RATIO (TPScreenWidth() > 360 ? 1: (TPScreenWidth() / 360))
#define VIDEO_PORTRAIT_HEIGHT (255 * VIDEO_HEIGHT_RATIO)

#define BOTTOM_HOLDER_HEIGHT (38)
#define SLIDER_MARGIN_LEFT (10)
#define SLIDER_MARGIN_RIGHT (10)

#define N_LOAD_VIDEO_ERROR @"n_load_video_error"
#define kLoadVideoErrorUserAction @"LoadVideoErrorUserAction"


#define TOP_OVERLAY_HEIGHT_PORTRAIT (32)
#define TOP_OVERLAY_HEIGHT_LANDSCAPE (48)

#define BIG_PLAY_BUTTON_SIZE (42)

typedef NS_ENUM(NSInteger, LoadVideoStatus) {
    LoadVideoNotWifi,
    LoadVideoError,
    LoadVideoNormal,
    LoadVideoWaiting,
};

typedef NS_ENUM(NSInteger, LoadVideoErrorUserAction) {
    ErrorActionReload,
    ErrorActionNotWiFiStop,
    ErrorActionNotWiFiContinue,
};

@interface TPVideoPlayerView : UIView

@property (nonatomic, strong) UIView* view;
@property (nonatomic, strong) VKVideoPlayerLayerView* playerLayerView;
@property (nonatomic, strong) UIView* controls;
@property (nonatomic, strong) UIView* bottomControlOverlay;
@property (nonatomic, strong) UIView* topControlOverlay;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

//@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIButton* topSettingsButton;

@property (nonatomic, strong) UIButton* playButton;
@property (nonatomic, strong) UILabel* currentTimeLabel;
@property (nonatomic, strong) TPVideoSlider* scrubber;
@property (nonatomic, strong) UILabel* totalTimeLabel;
@property (nonatomic, strong) UIButton* fullscreenButton;

@property (nonatomic, strong) UIButton* doneButton;

@property (nonatomic, strong) UILabel* messageLabel;

@property (nonatomic, strong) UIView* buttonPlaceHolderView;

@property (nonatomic, strong) UIButton* bigPlayButton;

@property (nonatomic, assign) BOOL isControlsEnabled;
@property (nonatomic, assign) BOOL isControlsHidden;

@property (nonatomic, weak) id<VKVideoPlayerViewDelegate> delegate;

@property (nonatomic, assign) NSInteger controlHideCountdown;

@property (nonatomic, strong) UIView* externalDeviceView;
@property (nonatomic, strong) UIImageView* externalDeviceImageView;
@property (nonatomic, strong) UILabel* externalDeviceLabel;

@property (nonatomic, strong) UIView* topPortraitControlOverlay;
@property (nonatomic, strong) UIButton* topPortraitCloseButton;

@property (nonatomic, strong) UIImageView* playerShadow;

@property (nonatomic, strong) NSNumber* playerControlsAutoHideTime;

@property (nonatomic, strong) FindNewsItem *newsItem;

@property (nonatomic, strong) UISlider *bottomPlaySlider;
@property (nonatomic, strong) UISlider *bottomCacheSlider;

@property (nonatomic, strong) UIView *loadStatusView;
@property (nonatomic, assign) LoadVideoStatus loadVideoStatus;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *topTitleLabel;

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, assign) BOOL previewImageLoaded;

- (void) fullscreenButtonTapped:(id)sender;
- (void) playButtonTapped:(id)sender;


- (void)handleSingleTap:(id)sender;
- (void)handleSwipeLeft:(id)sender;
- (void)handleSwipeRight:(id)sender;

- (void)updateTimeLabels;
- (void)setControlsHidden:(BOOL)hidden;
- (void)setControlsEnabled:(BOOL)enabled;
- (void)hideControlsIfNecessary;

- (void)setPlayButtonsSelected:(BOOL)selected;
- (void)setPlayButtonsEnabled:(BOOL)enabled;

- (void)layoutForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)addSubviewForControl:(UIView *)view;
- (void)addSubviewForControl:(UIView *)view toView:(UIView*)parentView;
- (void)addSubviewForControl:(UIView *)view toView:(UIView*)parentView forOrientation:(UIInterfaceOrientationMask)orientation;
- (void)removeControlView:(UIView*)view;

- (void) updateUIWithData:(FindNewsItem *)newsItem;

- (void) updateTopOverlayerToOrientation:(UIImageOrientation)orientation;
- (void) setBigPlayButtonHidden:(BOOL)hidden;

@end

#endif /* TPVideoPlayerView_h */
