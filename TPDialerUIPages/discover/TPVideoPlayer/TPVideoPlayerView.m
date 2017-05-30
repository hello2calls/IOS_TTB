//
//  TPVideoPlayerView.m
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//
//

#import "TPVideoPlayerView.h"
#import "VKVideoPlayerView.h"
#import "VKScrubber.h"
#import <QuartzCore/QuartzCore.h>
#import "VKVideoPlayerConfig.h"
#import "VKFoundation.h"
#import "VKVideoPlayerTrack.h"
#import "UIImage+VKFoundation.h"
#import "VKVideoPlayerSettingsManager.h"
#import <Masonry.h>
#import "VKVideoPlayerLayerView.h"
#import "TPDLib.h"
#import "VideoNewsRowView.h"
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define PADDING 8
#define DEFAULT_PLAYER_ICON_SIZE (22)

@interface TPVideoPlayerView()
@property (nonatomic, strong) NSMutableArray* customControls;
@property (nonatomic, strong) NSMutableArray* portraitControls;
@property (nonatomic, strong) NSMutableArray* landscapeControls;

@property (nonatomic, strong) CAGradientLayer *topOverlayerGradientLayer;
@property (nonatomic, strong) UIView *bottomBackgroundView;

@property (nonatomic, assign) BOOL isV6;
@property (nonatomic, strong) NSString *iconFontName;
@end



@implementation TPVideoPlayerView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scrubber removeObserver:self forKeyPath:@"maximumValue"];
}

- (void) updateUIWithData:(FindNewsItem *)newsItem {
    @weakify(self);
    _newsItem = newsItem;
    
    self.previewImageLoaded = NO;
    self.previewImageView.hidden = YES;
    
    if (_newsItem != nil) {
        NSArray *imageUrlStrings = _newsItem.images;
        if (imageUrlStrings != nil
            && imageUrlStrings.count > 0)
        [_previewImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStrings[0]]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            @strongify(self);
            self.previewImageLoaded = YES;
            if (self.loadVideoStatus == LoadVideoWaiting) {
                self.previewImageView.hidden = NO;
            }
            cootek_log(@"preview image download, url: %@", imageURL.absoluteString);
        }];
    }
}

- (void)initialize {
    _isV6 = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    if (_isV6) {
        _iconFontName = @"iPhoneIcon4";
    } else {
        // v5
        _iconFontName = @"iPhoneIcon1";
    }
    
    self.customControls = [NSMutableArray array];
    self.portraitControls = [NSMutableArray array];
    self.landscapeControls = [NSMutableArray array];
    
    self.bottomControlOverlay = [[UIView alloc] init];

    UIButton *playButton = [[UIButton alloc] init];
    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    playButton.titleLabel.font = [UIFont fontWithName:_iconFontName size:DEFAULT_PLAYER_ICON_SIZE];
    [playButton setTitle:@"3" forState:UIControlStateNormal];
    [playButton setTitle:@"2" forState:UIControlStateSelected];
    
    self.playButton = playButton;
//    OUTLINE_VIEW(playButton);

    UILabel *currentTimeLabel = [[UILabel alloc] init];
    currentTimeLabel.font = [UIFont systemFontOfSize:8];
    currentTimeLabel.textColor = [UIColor whiteColor];
    currentTimeLabel.textAlignment = NSTextAlignmentRight;
    self.currentTimeLabel = currentTimeLabel;
//    OUTLINE_VIEW(currentTimeLabel);

    UIButton *fullScreenButton = [[UIButton alloc] init];
    fullScreenButton.titleLabel.font = [UIFont fontWithName:_iconFontName size:DEFAULT_PLAYER_ICON_SIZE];
    [fullScreenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [fullScreenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [fullScreenButton setTitle:@"5" forState:UIControlStateNormal];
    [fullScreenButton setTitle:@"4" forState:UIControlStateSelected];
    if (_isV6) {
        [fullScreenButton setTitle:@"4" forState:UIControlStateNormal];
        [fullScreenButton setTitle:@"5" forState:UIControlStateSelected];
    }
    
    self.fullscreenButton = fullScreenButton;
//    OUTLINE_VIEW(fullScreenButton);

    TPVideoSlider *scrubber = [[TPVideoSlider alloc] init];
    scrubber.hidden = YES;
    self.scrubber = scrubber;
    
    _bottomBackgroundView = [[UIView alloc] init];
    _bottomBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
    
    //
    [self.bottomControlOverlay addSubview:self.bottomBackgroundView];
    [self.bottomControlOverlay addSubview:self.playButton];
    [self.bottomControlOverlay addSubview:self.currentTimeLabel];
    [self.bottomControlOverlay addSubview:self.scrubber];
    [self.bottomControlOverlay addSubview:self.fullscreenButton];

    //
    [self.bottomBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bottomControlOverlay);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(BOTTOM_HOLDER_HEIGHT, BOTTOM_HOLDER_HEIGHT));
        make.centerY.mas_equalTo(self.bottomControlOverlay);
        make.left.mas_equalTo(self.bottomControlOverlay);
    }];

    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.scrubber);
        make.size.mas_equalTo(CGSizeMake(60, 10));
        make.top.mas_equalTo(self.bottomControlOverlay).offset(22);
    }];

    [self.fullscreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(BOTTOM_HOLDER_HEIGHT, BOTTOM_HOLDER_HEIGHT));
        make.right.mas_equalTo(self.bottomControlOverlay);
        make.centerY.mas_equalTo(self.bottomControlOverlay);
    }];
    
    [self.scrubber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).offset(SLIDER_MARGIN_LEFT);
        make.right.mas_equalTo(self.fullscreenButton.mas_left).offset(-SLIDER_MARGIN_RIGHT);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(self.bottomControlOverlay).offset(14);
    }];
    
    //    OUTLINE_VIEW(playButton);
    //    OUTLINE_VIEW(fullScreenButton);
    //    OUTLINE_VIEW(self.bottomControlOverlay);
    
    
    // very strange behavior here
    //
    _bottomCacheSlider = [[UISlider alloc] init];
    _bottomCacheSlider.minimumTrackTintColor = [UIColor whiteColor];
    _bottomCacheSlider.maximumTrackTintColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
    // hide the slider thumb
    [_bottomCacheSlider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    
    _bottomPlaySlider = [[UISlider alloc] init];
    _bottomPlaySlider.hidden = YES; // hidden first
    _bottomPlaySlider.minimumTrackTintColor = [TPDialerResourceManager getColorForStyle:@"tp_color_orange_red_400"];
    _bottomPlaySlider.maximumTrackTintColor = [UIColor clearColor];
    [_bottomPlaySlider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    
    [_bottomPlaySlider addSubview:_bottomCacheSlider];
    [_bottomCacheSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_bottomPlaySlider);
    }];
    
    _loadStatusView = [[UIView alloc] init];
    _loadStatusView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_800"];
    [self setLoadVideoStatus:LoadVideoWaiting];
    
    self.playerLayerView = [[VKVideoPlayerLayerView alloc] init];
    self.playerLayerView.backgroundColor = [UIColor blackColor];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //
    
    // --- self.topControlOverlay ---
    self.topControlOverlay = [[UIView alloc] init];
    
    UIButton *backButton = [[UIButton alloc] init];
    backButton.titleLabel.textColor = [UIColor whiteColor];
    
    backButton.titleLabel.font = [UIFont fontWithName:_iconFontName size:DEFAULT_PLAYER_ICON_SIZE];
    [backButton setTitle:@"0" forState:UIControlStateNormal];
    
    if (_isV6) {
        [backButton setTitle:@"L" forState:UIControlStateNormal];
    }
    
    self.backButton = backButton;
    
    UILabel *topTitleLabel = [[UILabel alloc] init];
    topTitleLabel.numberOfLines = 1;
    topTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    topTitleLabel.textColor = [UIColor whiteColor];
    
    self.topTitleLabel = topTitleLabel;
    
    [self.topControlOverlay addSubview:self.backButton];
    [self.topControlOverlay addSubview:self.topTitleLabel];
    
    _topOverlayerGradientLayer = [[CAGradientLayer alloc] init];
    _topOverlayerGradientLayer.frame = CGRectMake(0, 0, TPScreenWidth(), TOP_OVERLAY_HEIGHT_PORTRAIT);
    _topOverlayerGradientLayer.colors = @[
        (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor,
        (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0].CGColor,
    ];
    [self.topControlOverlay.layer insertSublayer:_topOverlayerGradientLayer atIndex:0];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.topControlOverlay);
        make.left.mas_equalTo(self.topControlOverlay);
        make.width.mas_equalTo(TOP_OVERLAY_HEIGHT_PORTRAIT);
    }];
    
    [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(self.topControlOverlay);
        make.left.mas_equalTo(self.backButton.mas_right);
    }];
    
    _bigPlayButton = [[UIButton alloc] init];
    _bigPlayButton.hidden = YES;
    UIImage *playButtonImage = [TPDialerResourceManager getImage:@"feeds_video_play_icon@3x.png"];
    [_bigPlayButton setBackgroundImage:playButtonImage forState:UIControlStateNormal];
    [_bigPlayButton setBackgroundImage:playButtonImage forState:UIControlStateSelected];
    
    
    _previewImageView = [[UIImageView alloc] init];
    _previewImageView.backgroundColor = [UIColor blackColor];
    _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // --- self.topControlOverlay ---
    
    [self addSubview:self.playerLayerView];
    [self addSubview:self.loadStatusView];
    [self addSubview:self.previewImageView];
    [self addSubview:self.bigPlayButton];
    [self addSubview:self.bottomControlOverlay];
    [self addSubview:self.bottomPlaySlider];
    [self addSubview:self.activityIndicator];
    [self addSubview:self.topControlOverlay];
    
    [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.playerLayerView);
    }];
    
    [self.topControlOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(TOP_OVERLAY_HEIGHT_PORTRAIT);
    }];
    
    [self.bottomControlOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(BOTTOM_HOLDER_HEIGHT);
        make.right.left.bottom.mas_equalTo(self.playerLayerView);
    }];
    
    [self.playerLayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(VIDEO_PORTRAIT_HEIGHT);
    }];
    
    [self.bottomPlaySlider makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.playerLayerView);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.playerLayerView);
    }];
    
    [self.activityIndicator makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.playerLayerView);
    }];
    
    [self.loadStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.playerLayerView);
    }];
    
    [self.bigPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.playerLayerView);
        make.size.mas_equalTo(CGSizeMake(BIG_PLAY_BUTTON_SIZE, BIG_PLAY_BUTTON_SIZE));
    }];

     [self updateTopOverlayerToOrientation:UIDeviceOrientationPortrait];
    //
//    UIView* overlay = [[UIView alloc] init];
//    overlay.backgroundColor = [UIColor blackColor];
//    overlay.alpha = 0.54f;
//    [self.bottomControlOverlay addSubview:overlay];
//    [self.bottomControlOverlay sendSubviewToBack:overlay];
//    [overlay mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.bottomControlOverlay);
//    }];
//    
//    overlay = [[UIView alloc] init];
//    overlay.backgroundColor = [UIColor blackColor];
//    overlay.alpha = 0.54f;
//    [self.topControlOverlay addSubview:overlay];
//    [self.topControlOverlay sendSubviewToBack:overlay];
    
    
    //
    self.fullscreenButton.hidden = NO;
    self.playerControlsAutoHideTime = @(3);
    
    // notifications
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(durationDidLoad:) name:kVKVideoPlayerDurationDidLoadNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(scrubberValueUpdated:) name:kVKVideoPlayerScrubberValueUpdatedNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(readyToPlay:) name:kVKVideoPlayerItemReadyToPlay object:nil];
    [defaultCenter addObserver:self selector:@selector(loadedTime:) name:kVKVideoPlayerLoadedTime object:nil];
    
    // key-value events
    [self.scrubber addTarget:self action:@selector(updateTimeLabels) forControlEvents:UIControlEventValueChanged];
    [self.scrubber addObserver:self forKeyPath:@"maximumValue" options:0 context:nil];
    
    // UI touch events
    [self.topPortraitCloseButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullscreenButton addTarget:self action:@selector(fullscreenButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // tap gesture
    UITapGestureRecognizer *playerViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:playerViewTapRecognizer];
    
    UITapGestureRecognizer *bottomControllTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnBottomControll:)];
    [self.bottomControlOverlay addGestureRecognizer:bottomControllTapRecognizer];
    
    [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.bigPlayButton addTarget:self action:@selector(bigPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (id)init {
    self = [super init];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void) bigPlayButtonPressed:(id)sender {
    self.bigPlayButton.hidden = YES;
    self.bottomControlOverlay.hidden = NO;
    
    [self.delegate bigPlayButtonPressed];
    [self setPlayButtonsSelected:NO];
}

#pragma - VKVideoPlayerViewDelegates

- (void) playButtonTapped:(id)sender {
    UIButton* playButton;
    if ([sender isKindOfClass:[UIButton class]]) {
        playButton = (UIButton*)sender;
    }
    
    if (playButton.selected)  {
        [self.delegate playButtonPressed];
        [self setPlayButtonsSelected:NO];
    } else {
        [self.delegate pauseButtonPressed];
        [self setPlayButtonsSelected:YES];
    }
}

- (void) backButtonTapped:(id)sender {
    self.fullscreenButton.selected = !self.fullscreenButton.selected;
    if ([self.delegate respondsToSelector:@selector(backButtonPressed)]) {
        [self.delegate backButtonPressed];
    }
}

- (void) fullscreenButtonTapped:(id)sender {
    self.fullscreenButton.selected = !self.fullscreenButton.selected;
    [self.delegate fullScreenButtonTapped];
}

- (void) doneButtonTapped:(id)sender {
    [self.delegate doneButtonTapped];
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.scrubber) {
        if ([keyPath isEqualToString:@"maximumValue"]) {
            RUN_ON_UI_THREAD(^{
                [self updateTimeLabels];
            });
        }
    }
    
    if ([object isKindOfClass:[UIButton class]]) {
        UIButton* button = object;
        if ([button isDescendantOfView:self.topControlOverlay]) {
            [self layoutTopControls];
        }
    }
}

- (void)setDelegate:(id<VKVideoPlayerViewDelegate>)delegate {
    _delegate = delegate;
    self.scrubber.delegate = delegate;
}

- (void)durationDidLoad:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSNumber* duration = [info objectForKey:@"duration"];
    [self.delegate videoTrack].totalVideoDuration = duration;
    RUN_ON_UI_THREAD(^{
        float durationFloat = [duration floatValue];
        self.scrubber.maximumValue = durationFloat;
        self.scrubber.hidden = NO;
        self.scrubber.cacheSlider.maximumValue = durationFloat;
        
        // bottom slider for full screen
        self.bottomCacheSlider.maximumValue = durationFloat;
        self.bottomPlaySlider.maximumValue    = durationFloat;
        
        self.currentTimeLabel.hidden = NO;
    });
}

- (void)scrubberValueUpdated:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    RUN_ON_UI_THREAD(^{
        float playedTime = [[info objectForKey:@"scrubberValue"] floatValue];
        [self.scrubber setValue:playedTime animated:YES];
        [self.bottomPlaySlider setValue:playedTime animated:YES];
        [self updateTimeLabels];
    });
}

- (void)updateTimeLabels {
    int playedTime = (int)self.scrubber.value;
    int duration = (int)self.scrubber.maximumValue;
    if (playedTime >= 0
        && self.activityIndicator.isAnimating) {
        [self.activityIndicator stopAnimating];
//        _controlHideCountdown = 3;
//        [self setControlsHidden:NO];
    }
    NSString *currentTimeString = [VKSharedUtility timeStringFromSecondsValue:playedTime];
    NSString *totalTimeString = [VKSharedUtility timeStringFromSecondsValue:duration];
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@/%@", currentTimeString, totalTimeString];
}

- (void)layoutSliderForOrientation:(UIInterfaceOrientation)interfaceOrientation {
}

- (void)layoutSlider {
    [self layoutSliderForOrientation:self.delegate.visibleInterfaceOrientation];
}

- (void)layoutTopControls {
//    CGFloat rightMargin = CGRectGetMaxX(self.topControlOverlay.frame);
//    for (UIView* button in self.topControlOverlay.subviews) {
//        if ([button isKindOfClass:[UIButton class]] && button != self.doneButton && !button.hidden) {
//            rightMargin = MIN(CGRectGetMinX(button.frame), rightMargin);
//        }
//    }
}

- (void)setPlayButtonsSelected:(BOOL)selected {
    self.playButton.selected = selected;
    self.bigPlayButton.selected = selected;
}

- (void)setPlayButtonsEnabled:(BOOL)enabled {
    self.playButton.enabled = enabled;
    self.bigPlayButton.enabled = enabled;
}

- (void) setBigPlayButtonHidden:(BOOL)hidden {
    if (hidden != self.bigPlayButton.isHidden) {
        self.bigPlayButton.hidden = hidden;
        if (self.previewImageLoaded) {
            self.previewImageView.hidden = hidden;
        }
        BOOL selected = hidden;
        [self setPlayButtonsSelected:selected];
    }
    if (!hidden) {
        [self setPlayButtonsEnabled:YES];
        self.topControlOverlay.hidden = NO;
    }
}

- (void)setControlsEnabled:(BOOL)enabled {
    
    self.topSettingsButton.enabled = enabled;
    
    [self setPlayButtonsEnabled:enabled];
    
    self.scrubber.enabled = enabled;
    self.fullscreenButton.enabled = enabled;
    
    self.isControlsEnabled = enabled;
    
    NSMutableArray *controlList = self.customControls.mutableCopy;
    [controlList addObjectsFromArray:self.portraitControls];
    [controlList addObjectsFromArray:self.landscapeControls];
    for (UIView *control in controlList) {
        if ([control isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)control;
            button.enabled = enabled;
        }
    }
}

- (void) handleSingleTapOnBottomControll:(id)sender {
    // do nothing.
}

- (void) handleSingleTap:(id)sender {
    if (!self.bigPlayButton.isHidden) {
        return;
    }
    
    [self setControlsHidden:!self.isControlsHidden];
    if (!self.isControlsHidden) {
        self.controlHideCountdown = [self.playerControlsAutoHideTime integerValue];
    }
    [self.delegate playerViewSingleTapped];
}

- (void) handleSwipeLeft:(id)sender {
//    [self.delegate nextTrackBySwipe];
}

- (void) handleSwipeRight:(id)sender {
//    [self.delegate previousTrackBySwipe];
}

- (void) setControlHideCountdown:(NSInteger)controlHideCountdown {
    if (controlHideCountdown == 0) {
        [self setControlsHidden:YES];
    } else {
        [self setControlsHidden:NO];
    }
    _controlHideCountdown = controlHideCountdown;
}

- (void)hideControlsIfNecessary {
    if (self.isControlsHidden) return;
    if (self.controlHideCountdown == -1) {
        [self setControlsHidden:NO];
    } else if (self.controlHideCountdown == 0) {
        [self setControlsHidden:YES];
    } else {
        self.controlHideCountdown--;
    }
}

- (void)setControlsHidden:(BOOL)hidden {
    if (self.isControlsHidden != hidden) {
        self.isControlsHidden = hidden;
        self.controls.hidden = hidden;
        
        if (UIInterfaceOrientationIsLandscape(self.delegate.visibleInterfaceOrientation)) {
            for (UIView *control in self.landscapeControls) {
                control.hidden = hidden;
            }
        }
        if (UIInterfaceOrientationIsPortrait(self.delegate.visibleInterfaceOrientation)) {
            for (UIView *control in self.portraitControls) {
                control.hidden = hidden;
            }
        }
        for (UIView *control in self.customControls) {
            control.hidden = hidden;
        }
        if (self.bigPlayButton.isHidden
            && self.loadStatusView.isHidden) {
            self.bottomControlOverlay.hidden = hidden;
            self.bottomPlaySlider.hidden = !self.bottomControlOverlay.hidden;
        }
    }
    
    if (self.topControlOverlay.hidden != hidden) {
        self.topControlOverlay.hidden = hidden;
    }
    
    [self layoutTopControls];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[VKScrubber class]] ||
        [touch.view isKindOfClass:[UIButton class]]) {
        // prevent recognizing touches on the slider
        return NO;
    }
    return YES;
}

- (void)layoutForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        self.topControlOverlay.hidden = YES;
        self.topPortraitControlOverlay.hidden = NO;
        
        [self.buttonPlaceHolderView setFrameOriginY:PADDING/2];
        self.buttonPlaceHolderView.hidden = YES;
        
        [self.bigPlayButton setFrameOriginY:CGRectGetMinY(self.bottomControlOverlay.frame)/2 - CGRectGetHeight(self.bigPlayButton.frame)/2];
        
        for (UIView *control in self.portraitControls) {
            control.hidden = self.isControlsHidden;
        }
        for (UIView *control in self.landscapeControls) {
            control.hidden = YES;
        }
        
    } else {
        [self.topControlOverlay setFrameOriginY:0.0f];
        self.topControlOverlay.hidden = NO;
        self.topPortraitControlOverlay.hidden = YES;
        
        [self.buttonPlaceHolderView setFrameOriginY:PADDING/2 + CGRectGetMaxY(self.topControlOverlay.frame)];
        self.buttonPlaceHolderView.hidden = NO;
        
        [self.bigPlayButton setFrameOriginY:(CGRectGetMinY(self.bottomControlOverlay.frame) - CGRectGetMaxY(self.topControlOverlay.frame))/2 + CGRectGetMaxY(self.topControlOverlay.frame) - CGRectGetHeight(self.bigPlayButton.frame)/2];
        
        for (UIView *control in self.portraitControls) {
            control.hidden = YES;
        }
        for (UIView *control in self.landscapeControls) {
            control.hidden = self.isControlsHidden;
        }
    }
    
    [self layoutTopControls];
    [self layoutSliderForOrientation:interfaceOrientation];
}

- (void)addSubviewForControl:(UIView *)view {
    [self addSubviewForControl:view toView:self];
}
- (void)addSubviewForControl:(UIView *)view toView:(UIView*)parentView {
    [self addSubviewForControl:view toView:parentView forOrientation:UIInterfaceOrientationMaskAll];
}
- (void)addSubviewForControl:(UIView *)view toView:(UIView*)parentView forOrientation:(UIInterfaceOrientationMask)orientation {
    view.hidden = self.isControlsHidden;
    if (orientation == UIInterfaceOrientationMaskAll) {
        [self.customControls addObject:view];
    } else if (orientation == UIInterfaceOrientationMaskPortrait) {
        [self.portraitControls addObject:view];
    } else if (orientation == UIInterfaceOrientationMaskLandscape) {
        [self.landscapeControls addObject:view];
    }
    [parentView addSubview:view];
}

- (void)removeControlView:(UIView*)view {
    [view removeFromSuperview];
    [self.customControls removeObject:view];
    [self.landscapeControls removeObject:view];
    [self.portraitControls removeObject:view];
}

- (void) setLoadVideoStatus:(LoadVideoStatus)status {
    @weakify(self);
    _loadVideoStatus = status;
    _loadStatusView.hidden = (status == LoadVideoNormal);
    if (status != LoadVideoNormal) {
        self.previewImageView.hidden = YES;
        self.bottomControlOverlay.hidden = YES;
        [self setBigPlayButtonHidden:YES];
    }
    for(UIView *view in _loadStatusView.subviews) {
        [view removeFromSuperview];
    }
    
    switch (status) {
        case LoadVideoError: {
            [_activityIndicator stopAnimating];
            
            CGFloat buttonHeight = 30;
            CGFloat buttonWidth = 90;
            
            UIButton *button = [UIButton tpd_buttonStyleCommon];
            
            button.layer.cornerRadius = buttonHeight / 2;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            button.layer.borderWidth = 0.5;
            
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:NSLocalizedString(@"feeds_video_reload",
                                               @"正在使用非wi-fi网络\n继续播放将产生流量费用")
                    forState:UIControlStateNormal];
            [button tpd_withBlock:^(id sender) {
                @strongify(self);
                self.loadVideoStatus = LoadVideoWaiting;
                if (!self.activityIndicator.isAnimating) {
                    [self.activityIndicator startAnimating];
                }
                NSDictionary *userInfo = @{kLoadVideoErrorUserAction: @(ErrorActionReload)};
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:N_LOAD_VIDEO_ERROR object:nil userInfo:userInfo];
            }];
            
            UILabel *infoLabel = [UILabel tpd_commonLabel];
            infoLabel.text = NSLocalizedString(@"feeds_video_load_error",
                                               @"正在使用非wi-fi网络\n继续播放将产生流量费用");
            infoLabel.textColor = [UIColor whiteColor];
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.font = [UIFont systemFontOfSize:18];
            
            UIView *container = [[UIView alloc] init];
            [container addSubview:infoLabel];
            [container addSubview:button];
            
            [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(container);
                make.top.mas_equalTo(container);
                make.bottom.mas_equalTo(button.mas_top).offset(-24);
            }];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(container);
                make.centerX.mas_equalTo(container);
                make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
            }];
            
            [_loadStatusView addSubview:container];
            [container mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(_loadStatusView);
                make.left.right.mas_equalTo(_loadStatusView);
            }];
            
            break;
        }
        case LoadVideoNotWifi: {
            if (self.activityIndicator.isAnimating) {
                [self.activityIndicator stopAnimating];
            }
            UILabel *infoLabel = [UILabel tpd_commonLabel];
            NSString *text = NSLocalizedString(@"feeds_video_load_not_wifi",
                                               @"正在使用非wi-fi网络\n继续播放将产生流量费用");
            NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
            paraStyle.lineSpacing = 8;
            NSDictionary *attributes = @{
                    NSParagraphStyleAttributeName: paraStyle,
                                         };
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                    attributes:attributes];
            
            infoLabel.attributedText = attributedText;
            infoLabel.textColor = [UIColor whiteColor];
            infoLabel.textAlignment = NSTextAlignmentCenter;
            infoLabel.font = [UIFont systemFontOfSize:18];
            
            CGFloat buttonHeight = 30;
            CGFloat buttonWidth = 68;
            
            UIButton *stopButton = [UIButton tpd_buttonStyleCommon];
            stopButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [stopButton setTitle:NSLocalizedString(@"Stop", @"停止") forState:UIControlStateNormal];
            stopButton.layer.cornerRadius = buttonHeight / 2;
            stopButton.layer.borderColor = [UIColor clearColor].CGColor;
            stopButton.backgroundColor = [TPDialerResourceManager
                                          getColorForStyle:@"tp_color_orange_red_400"];
            [stopButton tpd_withBlock:^(id sender) {
                @strongify(self);
                self.loadVideoStatus = LoadVideoWaiting;
                NSDictionary *userInfo = @{kLoadVideoErrorUserAction: @(ErrorActionNotWiFiStop)};
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:N_LOAD_VIDEO_ERROR object:nil userInfo:userInfo];
            }];
            
            UIButton *continueButton = [UIButton tpd_buttonStyleCommon];
            continueButton.titleLabel.font = [UIFont systemFontOfSize:16];
            [continueButton setTitle:NSLocalizedString(@"Continue", @"继续") forState:UIControlStateNormal];
            continueButton.layer.cornerRadius = buttonHeight / 2;
            continueButton.layer.borderColor = [UIColor whiteColor].CGColor;
            continueButton.layer.borderWidth = 0.5;
            
            [continueButton tpd_withBlock:^(id sender) {
                @strongify(self);
                self.loadVideoStatus = LoadVideoWaiting;
                NSDictionary *userInfo = @{kLoadVideoErrorUserAction: @(ErrorActionNotWiFiContinue)};
                [UserDefaultsManager setBoolValue:YES forKey:FEEDS_VIDEO_PLAY_IN_DATA_CONNECTION];
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:N_LOAD_VIDEO_ERROR object:nil userInfo:userInfo];
            }];
            
            UIView *container = [[UIView alloc] init];
            
            [container addSubview:infoLabel];
            [container addSubview:stopButton];
            [container addSubview:continueButton];
            
            [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(container);
                make.centerX.mas_equalTo(container);
                make.bottom.mas_equalTo(stopButton.mas_top).offset(-24);
            }];
            
            [stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(container);
                make.centerX.mas_equalTo(container).offset(- buttonWidth / 2 - 23);
                make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
            }];
            
            [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(container);
                make.centerX.mas_equalTo(container).offset(buttonWidth / 2 + 23);
                make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
            }];
            
            [_loadStatusView addSubview:container];
            [container mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(_loadStatusView);
                make.left.right.mas_equalTo(_loadStatusView);
            }];
            
            break;
        }
        case LoadVideoNormal: {
            break;
        }
        default:
            break;
    }
}

- (void) updateTopOverlayerToOrientation:(UIImageOrientation)orientation {
    CGFloat height = 0;
    CGFloat width = 0;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        height = TOP_OVERLAY_HEIGHT_LANDSCAPE;
        width = TPScreenHeight();
        self.topTitleLabel.hidden = NO;
        self.topTitleLabel.text = _newsItem.title;
        
    } else if (UIDeviceOrientationIsPortrait(orientation)) {
        height = TOP_OVERLAY_HEIGHT_PORTRAIT;
        width = TPScreenWidth();
        self.topTitleLabel.hidden = YES;
    }
    
    CALayer *overlayLayer = self.topControlOverlay.layer;
    CAGradientLayer *gradientLayer = (CAGradientLayer *)overlayLayer.sublayers[0];
    if (gradientLayer != nil) {
        gradientLayer.frame = CGRectMake(0, 0, width, height);
    }
    [self.topControlOverlay mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(height);
    }];
    [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(height);
    }];
    
    [self.topControlOverlay layoutIfNeeded];
}

#pragma mark - Notifications
- (void) readyToPlay:(NSNotification *)notification {
//    if (self.bottomControlOverlay.hidden) {
//        
//    }
    _controlHideCountdown = [self.playerControlsAutoHideTime integerValue];
    [self setControlsHidden:_controlHideCountdown != 0];
}

- (void) loadedTime:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) {
        return;
    }
    float loadedTime = [[userInfo objectForKey:@"loadedTime"] floatValue];
    cootek_log(@"TPVideoPlayer, loadedTime: %f", loadedTime);
    [self.scrubber.cacheSlider setValue:loadedTime animated:YES];
    [self.bottomCacheSlider setValue:loadedTime animated:YES];
}

@end
