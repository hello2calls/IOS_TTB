//
//  TPVideoSlider.m
//  FirstSight
//
//  Created by siyi on 2016-11-25.
//  Copyright © 2016 CooTek. All rights reserved.
//

#import "TPVideoSlider.h"
#import "TPDialerResourceManager.h"
#import <Masonry.h>

@implementation TPVideoSlider
- (instancetype) init {
    self = [super init];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (void) initialize {
    [self setThumbImage:[TPDialerResourceManager getImage:@"feeds_video_slider_thumb@3x.png"]
               forState:UIControlStateNormal];
    
    self.minimumTrackTintColor =
        [TPDialerResourceManager getColorForStyle:@"tp_color_orange_red_400"];
    self.maximumTrackTintColor = [UIColor clearColor];
    
    [self addTarget:self action:@selector(scrubbingBegin) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(scrubbingEnd) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [self addTarget:self action:@selector(scrubberValueChanged) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(clickToPlayPosition:)];
    [self addGestureRecognizer:tapGesture];
    self.exclusiveTouch = YES;
    
    // cached slider
    [self setupCacheSlider];
}

- (void) setupCacheSlider {
    _cacheSlider = [[UISlider alloc] init];
    [self addSubview:_cacheSlider];
    [_cacheSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    _cacheSlider.minimumTrackTintColor = [UIColor whiteColor];
    _cacheSlider.maximumTrackTintColor =
        [TPDialerResourceManager getColorForStyle:@"tp_color_grey_300"];
    [_cacheSlider setThumbImage:[[UIImage alloc] init] forState:UIControlStateNormal];
}


- (void) scrubbingBegin {
    if (self.delegate != nil) {
        [self.delegate scrubbingBegin];
    }
}

- (void) scrubbingEnd {
    if (self.delegate != nil) {
        [self.delegate scrubbingEnd];
    }
}

- (void)scrubberValueChanged {
}

- (void) clickToPlayPosition:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    cootek_log(@"%s, location: %@, self.frame: %@",
               __func__, NSStringFromCGPoint(location), NSStringFromCGRect(self.frame));
    float targetTime = self.maximumValue * (location.x / self.frame.size.width);
    NSDictionary *userInfo = @{@"seekedValue": @(targetTime)};
    [[NSNotificationCenter defaultCenter]
        postNotificationName:N_USER_SEEK_TO_POSITION object:nil userInfo:userInfo];
}

#pragma mark - Overrides
//
// to increase the clickable area of this slider thumb
//
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -15, -15);
    return CGRectContainsPoint(bounds, point);
}

@end
